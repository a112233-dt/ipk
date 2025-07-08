#!/bin/sh

# Đường dẫn các file cấu hình
RT_TABLES="/etc/iproute2/rt_tables"
NETWORK_CONFIG="/etc/config/network"
FIREWALL_CONFIG="/etc/config/firewall"

# Thêm bảng định tuyến nếu chưa có
grep -q -E "^201\s+warp" $RT_TABLES || echo "201 warp" >> $RT_TABLES
grep -q -E "^202\s+tailscale" $RT_TABLES || echo "202 tailscale" >> $RT_TABLES

# Cấu hình mạng (network)
uci batch <<EOF
set network.warp_route='route'
set network.warp_route.interface='warpplus'
set network.warp_route.target='0.0.0.0/0'
set network.warp_route.table='201'

set network.warp_rule='rule'
set network.warp_rule.mark='1'
set network.warp_rule.lookup='warp'

set network.ts_route='route'
set network.ts_route.interface='tailscale0'
set network.ts_route.target='100.64.0.0/10'
set network.ts_route.table='202'

set network.ts_rule='rule'
set network.ts_rule.dest='100.64.0.0/10'
set network.ts_rule.lookup='tailscale'
EOF

# Áp dụng cấu hình
uci commit network
uci commit firewall

# Khởi động lại dịch vụ
/etc/init.d/network restart
/etc/init.d/firewall restart

echo "Đã cấu hình xong routes, rules và firewall cho Warp+ và Tailscale."
