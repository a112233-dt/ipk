#!/bin/sh

echo "🧹 Dọn cấu hình Tailscale cũ..."

# 1. Stop & gỡ init script cũ
/etc/init.d/tailscaled stop 2>/dev/null
/etc/init.d/tailscaled disable 2>/dev/null
rm -f /etc/init.d/tailscaled

# 2. Xoá binary cũ
rm -f /usr/bin/tailscale /usr/bin/tailscaled

# 3. Xoá firewall zone 'tailscale'
for i in $(uci show firewall | grep "=zone" | cut -d. -f2 | cut -d= -f1); do
  NAME=$(uci get firewall.$i.name 2>/dev/null)
  [ "$NAME" = "tailscale" ] && uci delete firewall.$i
done

# 4. Xoá firewall rule có tên Allow-Tailscale-*
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

# 5. Cài bản mới
echo "📥 Tải Tailscale userspace 1.84.0..."
cd /tmp || exit 1
wget https://pkgs.tailscale.com/stable/tailscale_1.84.0_arm.tgz -O tailscale.tgz || {
  echo "❌ Lỗi tải tailscale.tgz"
  exit 1
}
tar -xzf tailscale.tgz
cp tailscale*/tailscaled tailscale*/tailscale /usr/bin/
chmod +x /usr/bin/tailscaled /usr/bin/tailscale

# 6. Tạo init.d script fix auto-up
echo "⚙️ Tạo /etc/init.d/tailscaled..."

cat << "EOF" > /etc/init.d/tailscaled
#!/bin/sh /etc/rc.common

START=99
STOP=10
USE_PROCD=1

PROG=/usr/bin/tailscaled
KEY="tskey-auth-keSvCzrHgB11CNTRL-WrpEiMiERK64TiaizbydK6YrgkFB5S64"
ARGS="--tun=userspace-networking"

start_service() {
    procd_open_instance
    procd_set_param command "$PROG" $ARGS
    procd_set_param respawn
    procd_close_instance

    # Đợi daemon sẵn sàng
    for i in $(seq 1 15); do
        sleep 1
        /usr/bin/tailscale status >/dev/null 2>&1 && break
    done

    /usr/bin/tailscale up $ARGS --authkey="$KEY" 2>/dev/null || true
}
EOF

chmod +x /etc/init.d/tailscaled
/etc/init.d/tailscaled enable
/etc/init.d/tailscaled start

# 7. Cấu hình firewall tailscale0
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

# 8. Kết thúc
echo ""
echo "✅ Cài đặt Tailscale userspace 1.84.0 hoàn tất!"
echo "🔁 Tự động kết nối sau reboot"
echo "🔐 Key: tskey-auth-kATwwJeHs721CNTRL-owHxPrrj2WNDQ16jyjUHWNJMq2hPFZSx"
echo "🛡️ Firewall: mở cổng 22/80/443 qua tailscale0"
