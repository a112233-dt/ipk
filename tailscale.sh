#!/bin/sh
# Tự động cài đặt và cấu hình Tailscale để truy cập LuCI và SSH từ xa

echo "[1] Cập nhật danh sách gói..."
opkg update

echo "[2] Cài đặt Tailscale và các gói phụ thuộc..."
opkg install tailscale ca-bundle kmod-tun iptables-nft

echo "[3] Khởi động Tailscale với SSH bật..."
tailscale up --ssh

echo "[4] Thêm firewall zone cho tailscale..."
uci delete firewall.tailscale 2>/dev/null
uci add firewall zone
uci set firewall.@zone[-1].name='tailscale'
uci set firewall.@zone[-1].input='ACCEPT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='REJECT'
uci set firewall.@zone[-1].device='tailscale0'

echo "[5] Thêm rule cho phép LuCI qua Tailscale..."
uci add firewall rule
uci set firewall.@rule[-1].name='Allow-Tailscale-LuCI'
uci set firewall.@rule[-1].src='tailscale'
uci set firewall.@rule[-1].target='ACCEPT'
uci set firewall.@rule[-1].proto='tcp'
uci set firewall.@rule[-1].dest_port='80 443'

echo "[6] Thêm rule cho phép SSH qua Tailscale..."
uci add firewall rule
uci set firewall.@rule[-1].name='Allow-Tailscale-SSH'
uci set firewall.@rule[-1].src='tailscale'
uci set firewall.@rule[-1].target='ACCEPT'
uci set firewall.@rule[-1].proto='tcp'
uci set firewall.@rule[-1].dest_port='22'

echo "[7] Áp dụng cấu hình firewall..."
uci commit firewall
/etc/init.d/firewall restart

echo "[8] Cấu hình uhttpd để lắng nghe tất cả các giao diện..."
uci delete uhttpd.main.listen_interface
uci set uhttpd.main.listen_http='0.0.0.0:80'
uci set uhttpd.main.listen_https='0.0.0.0:443'
uci commit uhttpd
/etc/init.d/uhttpd restart

echo "✅ Hoàn tất! Đăng nhập Tailscale nếu chưa, sau đó truy cập LuCI qua IP Tailscale."
