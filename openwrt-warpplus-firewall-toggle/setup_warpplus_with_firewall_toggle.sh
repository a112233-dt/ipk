#!/bin/sh

IPSET_NAME="ipv4vn"
IPSET_FILE="/etc/warpplus/ipv4vn.set"
TMP_CSV="/tmp/ip2location_vn.csv"
WARP_INTERFACE="warpplus"

echo "📥 Tải danh sách IP Việt Nam từ ipv4.fetus.jp..."
mkdir -p /etc/warpplus
wget -qO "$IPSET_FILE" "https://ipv4.fetus.jp/vn.txt" || {
    echo "❌ Tải thất bại!"
    exit 1
}

# Tạo ipset nếu chưa có
ipset list "$IPSET_NAME" >/dev/null 2>&1 || ipset create "$IPSET_NAME" hash:net
ipset flush "$IPSET_NAME"
cat "$IPSET_FILE" | while read ip; do
    [ -n "$ip" ] && ipset add "$IPSET_NAME" "$ip"
done

# Tạo bảng định tuyến riêng
grep -q "^201 warp$" /etc/iproute2/rt_tables || echo "201 warp" >> /etc/iproute2/rt_tables

# Ghi cấu hình network
cat <<EOF >> /etc/config/network

config route
    option interface '$WARP_INTERFACE'
    option target '0.0.0.0/0'
    option table 'warp'

config rule
    option mark 1
    option lookup 'warp'
EOF

# Ghi cấu hình firewall
cat <<EOF >> /etc/config/firewall

config rule
    option name 'Mark Not IPv4 VN'
    option family 'ipv4'
    option src 'lan'
    option target 'MARK'
    option set_mark '1'
    option extra '-m set ! --match-set $IPSET_NAME dst'
    list proto 'all'
    option dest '*'
    option enabled '1'

config ipset
    option name '$IPSET_NAME'
    option match 'src_net'
    option family 'ipv4'
    option storage 'hash'
    option enabled '1'
EOF

while IFS= read -r line; do
    echo "    list entry '$line'" >> /etc/config/firewall
done < "$IPSET_FILE"

/etc/init.d/network restart
/etc/init.d/firewall restart

echo "✅ Đã cài đặt Warp+ với điều kiện lọc có thể bật/tắt qua firewall."
echo "👉 Bật rule 'Mark Not IPv4 VN' để chỉ định tuyến quốc tế."
echo "👉 Tắt rule đó để định tuyến toàn bộ qua Warp."
