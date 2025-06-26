#!/bin/sh
echo "🧹 Dọn cấu hình Tailscale cũ..."

# 1. Stop và gỡ init script cũ
/etc/init.d/tailscaled stop 2>/dev/null
/etc/init.d/tailscaled disable 2>/dev/null
rm -f /etc/init.d/tailscaled

# 2. Xoá binary cũ
rm -f /usr/bin/tailscale /usr/bin/tailscaled

# 3. Xoá firewall zone 'tailscale' nếu có
for i in $(uci show firewall | grep "=zone" | cut -d. -f2 | cut -d= -f1); do
  NAME=$(uci get firewall.$i.name 2>/dev/null)
  [ "$NAME" = "tailscale" ] && uci delete firewall.$i
done

# 4. Xoá firewall rule Allow-Tailscale-*
for i in $(uci show firewall | grep "=rule" | cut -d. -f2 | cut -d= -f1); do
  NAME=$(uci get firewall.$i.name 2>/dev/null)
  case "$NAME" in
    Allow-Tailscale-SSH|Allow-Tailscale-HTTP|Allow-Tailscale-HTTPS)
      uci delete firewall.$i
      ;;
  esac
done

uci commit firewall
/etc/init.d/firewall restart

# 5. Cài Tailscale userspace bản 1.84.0
echo "📥 Tải Tailscale userspace 1.84.0..."
cd /tmp || exit 1
wget -q https://pkgs.tailscale.com/stable/tailscale_1.84.0_arm.tgz -O tailscale.tgz || {
  echo "❌ Lỗi tải tailscale.tgz"
  exit 1
}
tar -xzf tailscale.tgz
cp tailscale*/tailscaled tailscale*/tailscale /usr/bin/
chmod +x /usr/bin/tailscaled /usr/bin/tailscale
rm -rf /tmp/tailscale*

# 6. Tạo lại init.d chuẩn
echo "⚙️ Tạo /etc/init.d/tailscaled..."
cat << 'EOF' > /etc/init.d/tailscaled
#!/bin/sh /etc/rc.common
START=99
STOP=10
USE_PROCD=1

PROG=/usr/bin/tailscaled
ARGS="--tun=userspace-networking"
KEY="tskey-auth-kuc4vRSYnH11CNTRL-S9RvbVq9ASUcrYoxSeyATU6knbrDmsUA5"

start_service() {
    mkdir -p /var/run/tailscale

    procd_open_instance
    procd_set_param command "$PROG" $ARGS
    procd_set_param respawn
    procd_close_instance

    (
        sleep 8
        if ! /usr/bin/tailscale status | grep -q "100."; then
            /usr/bin/tailscale up --reset --authkey="$KEY" --hostname=x-wrt
        fi
    ) &
}

stop_service() {
    /usr/bin/tailscale down 2>/dev/null
}
EOF

chmod +x /etc/init.d/tailscaled
/etc/init.d/tailscaled enable
/etc/init.d/tailscaled start

# 7. Cấu hình firewall mở port cho tailscale0
echo "🔥 Cấu hình firewall cho tailscale0..."
uci batch <<EOF
add firewall zone
set firewall.@zone[-1].name='tailscale'
set firewall.@zone[-1].input='ACCEPT'
set firewall.@zone[-1].output='ACCEPT'
set firewall.@zone[-1].forward='ACCEPT'
set firewall.@zone[-1].device='tailscale0'

add firewall rule
set firewall.@rule[-1].name='Allow-Tailscale-SSH'
set firewall.@rule[-1].src='tailscale'
set firewall.@rule[-1].proto='tcp'
set firewall.@rule[-1].dest_port='22'
set firewall.@rule[-1].target='ACCEPT'

add firewall rule
set firewall.@rule[-1].name='Allow-Tailscale-HTTP'
set firewall.@rule[-1].src='tailscale'
set firewall.@rule[-1].proto='tcp'
set firewall.@rule[-1].dest_port='80'
set firewall.@rule[-1].target='ACCEPT'

add firewall rule
set firewall.@rule[-1].name='Allow-Tailscale-HTTPS'
set firewall.@rule[-1].src='tailscale'
set firewall.@rule[-1].proto='tcp'
set firewall.@rule[-1].dest_port='443'
set firewall.@rule[-1].target='ACCEPT'
EOF

uci commit firewall
/etc/init.d/firewall restart

echo ""
echo "✅ Đã cài xong Tailscale userspace 1.84.0 và cấu hình khởi động lại đầy đủ."
echo "🔁 Sẵn sàng tự động kết nối sau reboot."
