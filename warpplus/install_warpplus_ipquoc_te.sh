#!/bin/sh
# Tự động cấu hình Warp+ chỉ áp dụng cho IP quốc tế (không phải IP Việt Nam)

# Thêm bảng định tuyến
grep -q '201 vpn.cloudflare' /etc/iproute2/rt_tables || echo "201 vpn.cloudflare" >> /etc/iproute2/rt_tables

# Cấu hình network
uci batch <<EOF
set network.warp_route='route'
set network.warp_route.interface='warpplus'
set network.warp_route.target='0.0.0.0/0'
set network.warp_route.table='201'

set network.warp_rule='rule'
set network.warp_rule.mark='1'
set network.warp_rule.lookup='vpn.cloudflare'
EOF

uci commit network

# Cấu hình firewall
uci batch <<EOF
set firewall.mark_not_vn='rule'
set firewall.mark_not_vn.name='Mark Not IPv4 VN'
set firewall.mark_not_vn.family='ipv4'
set firewall.mark_not_vn.src='lan'
set firewall.mark_not_vn.target='MARK'
set firewall.mark_not_vn.set_mark='1'
set firewall.mark_not_vn.extra=' -m set ! --match-set ipv4vn dst'
add_list firewall.mark_not_vn.proto='all'
set firewall.mark_not_vn.dest='*'
set firewall.mark_not_vn.enabled='0'

set firewall.ipv4vn='ipset'
set firewall.ipv4vn.name='ipv4vn'
set firewall.ipv4vn.match='src_net'
set firewall.ipv4vn.family='ipv4'
set firewall.ipv4vn.storage='hash'
set firewall.ipv4vn.enabled='1'
EOF

uci commit firewall

# Khởi động lại dịch vụ
/etc/init.d/network restart
/etc/init.d/firewall restart

echo "Đã cấu hình thành công Warp+ cho IP quốc tế (IP ngoài danh sách IPv4VN)."
