#!/bin/sh

IPSET_NAME="ipv4vn"
IPSET_FILE="/etc/warpplus/ipv4vn.set"
TMP_CSV="/tmp/ip2location_vn.csv"

mkdir -p /etc/warpplus

echo "📥 Đang tải danh sách IP Việt Nam từ IP2Location..."
wget -qO - "https://download.ip2location.com/lite/IP2LOCATION-LITE-DB1.CSV.ZIP" > /tmp/ipdb.zip
unzip -p /tmp/ipdb.zip > "$TMP_CSV"

echo "📄 Đang tạo file $IPSET_FILE..."
rm -f "$IPSET_FILE"
awk -F',' '$3=="\"VN\"" {
    gsub(/\"/, "", $1); gsub(/\"/, "", $2)
    ip_start = $1 + 0; ip_end = $2 + 0
    while (ip_start <= ip_end) {
        for (mask=32; mask>0; mask--) {
            step = 2^(32 - mask)
            if (ip_start % step == 0 && ip_start + step - 1 <= ip_end) break
        }
        ip = sprintf("%d.%d.%d.%d",
           int(ip_start/2^24)%256,
           int(ip_start/2^16)%256,
           int(ip_start/2^8)%256,
           ip_start%256)
        print ip "/" mask >> "'"$IPSET_FILE"'"
        ip_start += step
    }
}' "$TMP_CSV"

grep -q "vpn.cloudflare" /etc/iproute2/rt_tables || echo "201 vpn.cloudflare" >> /etc/iproute2/rt_tables

cat <<EOF >> /etc/config/network

config route
    option interface 'warpplus'
    option target '0.0.0.0/0'
    option table '201'

config rule
    option mark 1
    option lookup 'vpn.cloudflare'
EOF

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

echo "✅ Cài Warp+ + định tuyến quốc tế hoàn tất!"
