# 🛠️ ScriptHub by MrCamap

> **Kho lưu trữ & chia sẻ các script tiện ích cho OpenWrt, Linux, mạng và nhiều hơn thế nữa.**

---

## 📌 Giới thiệu

Chào mừng bạn đến với **ScriptHub** – nơi tôi tổng hợp, lưu trữ và chia sẻ các **script shell tiện dụng**, dùng để:
- Cấu hình mạng (OpenWrt / Linux)
- Tự động hoá (cron, khởi động, bảo trì)
- Thiết lập VPN / Tailscale / DNS
- Quản lý modem 4G/5G (Quectel, Fibocom)
- Và nhiều công cụ nhỏ gọn khác giúp tiết kiệm thời gian & công sức 💡

---

## 📂 Cấu trúc thư mục

```bash
📁 /                         # Root repository
├── install_tailscale.sh    # Script cài Tailscale đầy đủ
├── install_dns_proxy.sh    # Cài DNS-over-HTTPS (NextDNS/Cloudflare)
├── check_wan.sh            # Kiểm tra kết nối WAN tự động
├── auto_reboot.sh          # Script tự động reboot thiết bị
├── ...
```

---

## ⚙️ Cách sử dụng

Bạn có thể tải và chạy script trực tiếp bằng `wget` hoặc `curl`. Ví dụ:

```bash
wget https://raw.githubusercontent.com/a112233-dt/ipk/main/install_tailscale.sh
sh install_tailscale.sh
```

Hoặc:

```bash
curl -O https://raw.githubusercontent.com/a112233-dt/ipk/main/check_wan.sh
chmod +x check_wan.sh && ./check_wan.sh
```

---

## 🧑‍💻 Đóng góp & phản hồi

Nếu bạn thấy script hữu ích hoặc muốn cải tiến thêm:
- 🌟 Hãy **star** repo
- 🐛 Gửi issue nếu có lỗi
- 🔧 Gửi pull request nếu bạn muốn đóng góp script mới

---

## ☕ Ủng hộ tôi

Nếu bạn thấy những script này hữu ích, hãy ủng hộ tôi một ly cà phê!  
**Momo/MB Bank:** *[tuỳ bạn điền]*

---

## 📜 Giấy phép

Toàn bộ nội dung chia sẻ tại đây tuân theo [MIT License](LICENSE).

---

> “Mọi rắc rối trong hệ thống đều có thể giải quyết bằng một script phù hợp.” – *MrCamap*
