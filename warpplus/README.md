# Cài đặt Warp+ (1.1.1.1) Cloudflare chỉ cho IP quốc tế trên OpenWrt

## Mục đích
- Định tuyến **chỉ IP quốc tế** qua Warp+ (Cloudflare VPN).
- Giữ nguyên truy cập IP Việt Nam theo đường mạng gốc (nội địa).
- Tăng tốc truy cập quốc tế và tránh giảm hiệu năng trong nước.

---

## 1. Tạo bảng định tuyến riêng cho Warp+
```sh
echo "201 vpn.cloudflare" >> /etc/iproute2/rt_tables
```

## 2. Thêm cấu hình `/etc/config/network`
```text
config route
    option interface 'warpplus'
    option target '0.0.0.0/0'
    option table '201'

config rule
    option mark 1
    option lookup 'vpn.cloudflare'
```

## 3. Thêm cấu hình `/etc/config/firewall`
```text
config rule
    option name 'Mark Not IPv4 VN'
    option family 'ipv4'
    option src 'lan'
    option target 'MARK'
    option set_mark '1'
    option extra ' -m set ! --match-set ipv4vn dst'
    list proto 'all'
    option dest '*'
    option enabled '0'

config ipset
    option name 'ipv4vn'
    option match 'src_net'
    option family 'ipv4'
    option storage 'hash'
    option enabled '1'
    list entry '103.252.0.0/22'
    list entry '115.146.120.0/21'
    ... (các dải IP VN đầy đủ như trong danh sách)
```

> 📌 Bạn có thể lưu danh sách IP Việt Nam vào file riêng (ví dụ: `/etc/firewall/ipv4vn.set`) rồi import qua `ipset restore < /etc/firewall/ipv4vn.set`.

## 4. Khởi động lại để áp dụng
```sh
/etc/init.d/network restart
/etc/init.d/firewall restart
```

---

## ✅ Cách đơn giản hơn: Dùng script tự động

Chỉ cần chạy:

```sh
sh install_warpplus_ipquoc_te.sh
```

> Script sẽ tự cấu hình rule + route + ipset IPv4VN để chỉ IP quốc tế đi qua Warp+.

