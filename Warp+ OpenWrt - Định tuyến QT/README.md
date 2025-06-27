# 🇻🇳 OpenWrt Warp+ chỉ định tuyến quốc tế (IP ngoài Việt Nam)

Repo này giúp bạn cấu hình Cloudflare Warp+ (1.1.1.1 VPN) cho OpenWrt **chỉ áp dụng với IP quốc tế**, trong khi IP Việt Nam đi thẳng — tối ưu tốc độ và tránh trùng lặp định tuyến.

---

## 📦 Gồm các file:

| File | Mô tả |
|------|-------|
| `setup_warpplus_with_ipv4vn_fetch.sh` | Thiết lập Warp+ và ipset định tuyến quốc tế |
| `update_ipv4vn.sh` | Tự động cập nhật danh sách IP Việt Nam mới nhất |
| `README.md` | Tài liệu hướng dẫn sử dụng |

---

## 🛠 Script setup sẽ thực hiện:

- ✅ Tải danh sách IP Việt Nam từ IP2Location
- ✅ Tạo file: `/etc/warpplus/ipv4vn.set`
- ✅ Cấu hình định tuyến `warpplus` thông qua route table
- ✅ Ghi `ipset` và `firewall rule` vào cấu hình OpenWrt
- ✅ Khởi động lại dịch vụ mạng (`network` và `firewall`)

---

## 🔄 Script cập nhật IP Việt Nam hàng tháng

Chạy:

```bash
wget -O update.sh https://raw.githubusercontent.com/a112233-dt/ipk/main/Warp%2B%20OpenWrt%20-%20Định%20tuyến%20QT/update_ipv4vn.sh
chmod +x update.sh
./update.sh
```

Script này sẽ:

- 📥 Tải danh sách IP mới nhất từ IP2Location
- ✏️ Ghi đè file `/etc/warpplus/ipv4vn.set` bằng dữ liệu mới
- 🔒 Không thay đổi hoặc ghi đè cấu hình `firewall` hay `network`

---

## ⏰ Thiết lập tự cập nhật IP Việt Nam theo tháng

Chạy lệnh:

```bash
crontab -e
```

Thêm dòng sau để script chạy vào **4:00 sáng ngày 1 mỗi tháng**:

```cron
0 4 1 * * /bin/sh /etc/warpplus/update_ipv4vn.sh >/dev/null 2>&1
```

---

## 📂 Vị trí danh sách IP Việt Nam

```bash
/etc/warpplus/ipv4vn.set
```

- Bạn có thể mở file này và chỉnh sửa thủ công nếu cần
- Ví dụ: thêm IP nội bộ, loại trừ một vài vùng đặc biệt, v.v.

---

## ⚠️ Lưu ý

- Interface `warpplus` phải được cấu hình thủ công trước (qua Warp-go, Wireguard, hoặc Warp-userspace).
- Chỉ áp dụng cho IPv4.
- Yêu cầu thiết bị OpenWrt có ít nhất 8MB Flash và 64MB RAM để chạy Warp ổn định.
