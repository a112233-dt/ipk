# Hướng dẫn truy cập LuCI từ xa qua Tailscale trên OpenWrt (không có IP công khai)

## 1. Cài đặt Tailscale trên router OpenWrt

```sh
opkg update
opkg install tailscale ca-bundle kmod-tun iptables-nft
```

## 2. Khởi động và đăng nhập Tailscale

```sh
tailscale up --ssh
```

> ⚠️ Sau đó truy cập đường link hiển thị để đăng nhập tài khoản Tailscale.

## 3. Kiểm tra IP Tailscale của router

```sh
tailscale status
```

Ví dụ kết quả:
```
100.125.93.73   ImmortalWrt   online
```

## 4. Cấu hình Firewall cho phép truy cập

```sh
uci add firewall zone
uci set firewall.@zone[-1].name='tailscale'
uci set firewall.@zone[-1].input='ACCEPT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='REJECT'
uci set firewall.@zone[-1].device='tailscale0'

uci add firewall rule
uci set firewall.@rule[-1].name='Allow-Tailscale-LuCI'
uci set firewall.@rule[-1].src='tailscale'
uci set firewall.@rule[-1].target='ACCEPT'
uci set firewall.@rule[-1].proto='tcp'
uci set firewall.@rule[-1].dest_port='80 443'

uci add firewall rule
uci set firewall.@rule[-1].name='Allow-Tailscale-SSH'
uci set firewall.@rule[-1].src='tailscale'
uci set firewall.@rule[-1].target='ACCEPT'
uci set firewall.@rule[-1].proto='tcp'
uci set firewall.@rule[-1].dest_port='22'

uci commit firewall
/etc/init.d/firewall restart
```

## 5. Cấu hình uHTTPd cho phép truy cập từ xa

```sh
uci delete uhttpd.main.listen_interface
uci set uhttpd.main.listen_http='0.0.0.0:80'
uci set uhttpd.main.listen_https='0.0.0.0:443'
uci commit uhttpd
/etc/init.d/uhttpd restart
```

## 6. Cài Tailscale trên thiết bị truy cập (PC / điện thoại)

- Tải từ [https://tailscale.com/download](https://tailscale.com/download)
- Đăng nhập cùng tài khoản
- Kiểm tra `tailscale status` để thấy router online

## 7. Truy cập từ xa

- Truy cập LuCI:  
  👉 `http://100.xxx.xxx.xxx/cgi-bin/luci/`

- Truy cập SSH:  
  👉 `ssh root@100.xxx.xxx.xxx`

---

## ✅ Gợi ý: Tự động hóa

Nếu bạn muốn cấu hình tất cả chỉ bằng 1 dòng lệnh:

```sh
wget -O - https://yourdomain.com/install_tailscale_luci.sh | sh
```

> Thay `yourdomain.com` bằng nơi bạn host file script.
