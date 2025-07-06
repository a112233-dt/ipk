#!/bin/sh

echo "🧹 Gỡ bỏ Tailscale cũ..."
# 1. Dừng và xoá init script cũ
/etc/init.d/tailscaled stop 2>/dev/null
/etc/init.d/tailscaled disable 2>/dev/null
rm -f /etc/init.d/tailscaled

# 2. Xoá binary
rm -f /usr/bin/tailscale /usr/bin/tailscaled

# 3. Xoá firewall zone 'tailscale' nếu có
for i in $(uci show firewall | grep "=zone" | cut -d. -f2 | cut -d= -f1); do
  NAME=$(uci get firewall.$i.name 2>/dev/null)
  [ "$NAME" = "tailscale" ] && uci delete firewall.$i
done

# 4. Xoá các rule Allow-Tailscale-*
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







