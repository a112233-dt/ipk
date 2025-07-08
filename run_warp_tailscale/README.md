# Hướng dẫn cấu hình Warp+ và Tailscale song song trên OpenWrt

Script này giúp bạn cấu hình định tuyến riêng cho Warp+ và Tailscale trên OpenWrt một cách tự động, cho phép:
- Truy cập quốc tế qua Warp+.
- Truy cập mạng riêng (Tailscale) qua interface `tailscale0`.

---

## 📦 Yêu cầu trước khi chạy
- Đã cài đặt và kích hoạt Warp+ (`warpplus`) và Tailscale (`tailscale0`).
- Đã cài gói `iproute2`, `kmod-tun`, `tailscale`, v.v.
- Các interface `warpplus` và `tailscale0` phải hoạt động bình thường.

---

## 🚀 Cách sử dụng script

1. Tải script về:
```sh
wget -O setup_warp_tailscale.sh https://yourdomain.com/setup_warp_tailscale.sh
chmod +x setup_warp_tailscale.sh
```

2. Chạy script:
```sh
./setup_warp_tailscale.sh
```

---

## 🧰 Script thực hiện các việc sau:

### 1. Tạo bảng định tuyến mới nếu chưa có:
- `201 warp`
- `202 tailscale`

```sh
echo "201 warp" >> /etc/iproute2/rt_tables
echo "202 tailscale" >> /etc/iproute2/rt_tables
```

---

### 2. Cấu hình `/etc/config/network`:
```sh
config route
    option interface 'warpplus'
    option target '0.0.0.0/0'
    option table '201'

config rule
    option mark '1'
    option lookup 'warp'

config route
    option interface 'tailscale0'
    option target '100.64.0.0/10'
    option table '202'

config rule
    option dest '100.64.0.0/10'
    option lookup 'tailscale'
```

---

### 3. Khởi động lại dịch vụ mạng và firewall:
```sh
/etc/init.d/network restart
/etc/init.d/firewall restart
```

---

## ✅ Kết quả sau khi chạy

- Các kết nối được **đánh dấu mark 1** sẽ đi qua Warp+.
- Các kết nối hướng đến **dải IP Tailscale 100.64.0.0/10** sẽ đi qua `tailscale0`.

---

## ℹ️ Ghi chú

- Nếu bạn có thêm rules mark cho IP quốc tế (như thông qua ipset `ipv4vn`), hãy đảm bảo mark `1` được áp dụng cho đúng đối tượng.
- Bạn có thể kết hợp script này với firewall marking để điều hướng quốc tế qua Warp+.

---
