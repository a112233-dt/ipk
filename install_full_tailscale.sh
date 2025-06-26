#!/bin/sh
# Script tổng hợp cài đặt và cấu hình Tailscale tự động trên OpenWrt

echo "[1] Cập nhật danh sách gói"
/bin/opkg update

echo "[2] Cài đặt Tailscale và các gói cần thiết"
/bin/opkg install tailscale ca-bundle kmod-tun iptables-nft

echo "[3] Tạo file init.d cho tailscaled"
/bin/cat << 'EOF' > /etc/init.d/tailscaled
#!/bin/sh /etc/rc.common
START=98
USE_PROCD=1
PROG=/usr/sbin/tailscaled

start_service() {
    procd_open_instance
    procd_set_param command $PROG
    procd_set_param respawn
    procd_close_instance
}
EOF

echo "[4] Tạo file init.d cho tailscale-autostart"
/bin/cat << 'EOF' > /etc/init.d/tailscale-autostart
#!/bin/sh /etc/rc.common
START=99
STOP=15
USE_PROCD=1
PROG=/usr/sbin/tailscaled

start_service() {
    echo "[+] Khởi động tailscaled"
    procd_open_instance
    procd_set_param command $PROG
    procd_set_param respawn
    procd_close_instance

    sleep 2

    echo "[+] Kiểm tra trạng thái Tailscale..."
    tailscale status >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "[+] Tailscale chưa kết nối, thực hiện up..."
        tailscale up --ssh
    else
        echo "[✓] Tailscale đã kết nối"
    fi
}

stop_service() {
    echo "[-] Dừng tailscaled"
    killall tailscaled 2>/dev/null
}
EOF

echo "[5] Cấp quyền thực thi và kích hoạt dịch vụ"
chmod +x /etc/init.d/tailscaled
chmod +x /etc/init.d/tailscale-autostart
/etc/init.d/tailscaled enable
/etc/init.d/tailscale-autostart enable

echo "[6] Tạo zone firewall cho tailscale"
/bin/uci delete firewall.tailscale 2>/dev/null
/bin/uci add firewall zone
/bin/uci set firewall.@zone[-1].name='tailscale'
/bin/uci set firewall.@zone[-1].input='ACCEPT'
/bin/uci set firewall.@zone[-1].output='ACCEPT'
/bin/uci set firewall.@zone[-1].forward='REJECT'
/bin/uci set firewall.@zone[-1].device='tailscale0'

echo "[7] Thêm rule firewall cho SSH và LuCI từ tailscale"
/bin/uci add firewall rule
/bin/uci set firewall.@rule[-1].name='Allow-Tailscale-SSH'
/bin/uci set firewall.@rule[-1].src='tailscale'
/bin/uci set firewall.@rule[-1].target='ACCEPT'
/bin/uci set firewall.@rule[-1].proto='tcp'
/bin/uci set firewall.@rule[-1].dest_port='22'

/bin/uci add firewall rule
/bin/uci set firewall.@rule[-1].name='Allow-Tailscale-LuCI'
/bin/uci set firewall.@rule[-1].src='tailscale'
/bin/uci set firewall.@rule[-1].target='ACCEPT'
/bin/uci set firewall.@rule[-1].proto='tcp'
/bin/uci set firewall.@rule[-1].dest_port='80 443'

echo "[8] Mở LuCI cho mọi giao diện"
/bin/uci delete uhttpd.main.listen_interface 2>/dev/null
/bin/uci set uhttpd.main.listen_http='0.0.0.0:80'
/bin/uci set uhttpd.main.listen_https='0.0.0.0:443'

echo "[9] Lưu cấu hình và khởi động dịch vụ"
/bin/uci commit
/etc/init.d/firewall restart
/etc/init.d/uhttpd restart
/etc/init.d/tailscaled start
/etc/init.d/tailscale-autostart start

echo "✅ Hoàn tất! Hãy chạy 'tailscale status' để kiểm tra kết nối hoặc 'tailscale up --ssh' nếu chưa kết nối."
