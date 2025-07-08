#!/bin/sh

# Cập nhật gói
opkg update

# Cài đặt Tailscale và các phụ thuộc
opkg install tailscale ca-bundle kmod-tun iptables-nft

# Khởi động Tailscale với quyền SSH (người dùng cần đăng nhập thủ công ở bước tiếp theo)
tailscale up --ssh

echo "==> Đăng nhập tài khoản Tailscale tại đường link được hiển thị ở trên."

# Thêm zone Tailscale vào firewall
uci add firewall zone
uci set firewall.@zone[-1].name='tailscale'
uci set firewall.@zone[-1].input='ACCEPT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='REJECT'
uci set firewall.@zone[-1].device='tailscale0'

# Cho phép truy cập LuCI từ Tailscale
uci add firewall rule
uci set firewall.@rule[-1].name='Allow-Tailscale-LuCI'
uci set firewall.@rule[-1].src='tailscale'
uci set firewall.@rule[-1].target='ACCEPT'
uci set firewall.@rule[-1].proto='tcp'
uci set firewall.@rule[-1].dest_port='80 443'

# Cho phép SSH từ Tailscale
uci add firewall rule
uci set firewall.@rule[-1].name='Allow-Tailscale-SSH'
uci set firewall.@rule[-1].src='tailscale'
uci set firewall.@rule[-1].target='ACCEPT'
uci set firewall.@rule[-1].proto='tcp'
uci set firewall.@rule[-1].dest_port='22'

# Áp dụng cấu hình firewall
uci commit firewall
/etc/init.d/firewall restart

# Cấu hình uhttpd cho phép truy cập từ xa
uci delete uhttpd.main.listen_interface
uci set uhttpd.main.listen_http='0.0.0.0:80'
uci set uhttpd.main.listen_https='0.0.0.0:443'
uci commit uhttpd
/etc/init.d/uhttpd restart

echo "==> Đã cấu hình xong. Bạn có thể truy cập LuCI và SSH thông qua IP Tailscale."
