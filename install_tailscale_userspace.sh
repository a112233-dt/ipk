#!/bin/sh

echo "🔧 Cài đặt Tailscale 1.84.0 (userspace) cho OpenWrt/X-WRT"

# Bước 1: Tải binary
cd /tmp || exit 1
TS_URL="https://pkgs.tailscale.com/stable/tailscale_1.84.0_arm.tgz"
echo "📥 Đang tải $TS_URL ..."
wget "$TS_URL" -O tailscale.tgz || {
  echo "❌ Lỗi tải tailscale.tgz"
  exit 1
}

# Bước 2: Giải nén và cài binary
echo "📦 Giải nén và cài đặt..."
tar -xzf tailscale.tgz || {
  echo "❌ Giải nén thất bại"
  exit 1
}
cp tailscale*/tailscale tailscale*/tailscaled /usr/bin/
chmod +x /usr/bin/tailscale /usr/bin/tailscaled

# Bước 3: Tạo init.d script tự khởi động
echo "⚙️ Tạo script /etc/init.d/tailscaled..."

cat << "EOF" > /etc/init.d/tailscaled
#!/bin/sh /etc/rc.common

START=99
STOP=10
USE_PROCD=1

PROG=/usr/bin/tailscaled
KEY="tskey-auth-kATwwJeHs721CNTRL-owHxPrrj2WNDQ16jyjUHWNJMq2hPFZSx"
ARGS="--tun=userspace-networking"

start_service() {
    procd_open_instance
    procd_set_param command "$PROG" $ARGS
    procd_set_param respawn
    procd_close_instance

    # Đợi tailscaled sẵn sàng (tối đa 15s)
    for i in $(seq 1 15); do
        sleep 1
        /usr/bin/tailscale status >/dev/null 2>&1 && break
    done

    # Gọi tailscale up (sẽ fail nếu đã kết nối)
    /usr/bin/tailscale up $ARGS --authkey="$KEY" 2>/dev/null || true
}
EOF

chmod +x /etc/init.d/tailscaled
/etc/init.d/tailscaled enable
/etc/init.d/tailscaled start

# Bước 4: Cấu hình firewall cho interface tailscale0
echo "🔥 Cấu hình firewall: mở port 22/80/443 cho tailscale0..."

uci batch <<EOF
# Xóa zone cũ (nếu có)
delete firewall.@zone[.name='tailscale']

# Tạo zone tailscale
add firewall zone
set firewall.@zone[-1].name='tailscale'
set firewall.@zone[-1].input='ACCEPT'
set firewall.@zone[-1].output='ACCEPT'
set firewall.@zone[-1].forward='ACCEPT'
set firewall.@zone[-1].device='tailscale0'

# Mở các cổng từ interface tailscale
delete firewall.@rule[.name='Allow-Tailscale-SSH']
add firewall rule
set firewall.@rule[-1].name='Allow-Tailscale-SSH'
set firewall.@rule[-1].src='tailscale'
set firewall.@rule[-1].proto='tcp'
set firewall.@rule[-1].dest_port='22'
set firewall.@rule[-1].target='ACCEPT'

delete firewall.@rule[.name='Allow-Tailscale-HTTP']
add firewall rule
set firewall.@rule[-1].name='Allow-Tailscale-HTTP'
set firewall.@rule[-1].src='tailscale'
set firewall.@rule[-1].proto='tcp'
set firewall.@rule[-1].dest_port='80'
set firewall.@rule[-1].target='ACCEPT'

delete firewall.@rule[.name='Allow-Tailscale-HTTPS']
add firewall rule
set firewall.@rule[-1].name='Allow-Tailscale-HTTPS'
set firewall.@rule[-1].src='tailscale'
set firewall.@rule[-1].proto='tcp'
set firewall.@rule[-1].dest_port='443'
set firewall.@rule[-1].target='ACCEPT'
EOF

/etc/init.d/firewall restart

# Bước 5: Hoàn tất
echo ""
echo "✅ Tailscale userspace đã được cài đặt thành công!"
echo "🔐 Authkey: tskey-auth-kATwwJeHs721CNTRL-owHxPrrj2WNDQ16jyjUHWNJMq2hPFZSx"
echo "🔁 Tự động chạy và reconnect sau reboot"
echo "🛡️ Firewall chỉ mở cổng từ tailscale0: 22, 80, 443"
