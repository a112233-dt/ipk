# 🌐 OpenWrt Warp+ - Định tuyến toàn bộ hoặc chỉ quốc tế (tùy firewall)

Repo này giúp bạn cấu hình Cloudflare Warp+ (1.1.1.1 VPN) trên OpenWrt, với khả năng:

- ✅ Định tuyến **chỉ IP quốc tế** qua Warp (giữ IP Việt Nam đi thẳng).
- ✅ Hoặc định tuyến **toàn bộ lưu lượng** qua Warp.
- 🔁 Bạn có thể **chuyển đổi linh hoạt bằng cách bật/tắt firewall rule**, không cần cài lại!

## 📦 Gồm các file:

| File | Mô tả |
|------|-------|
| `setup_warpplus_with_firewall_toggle.sh` | Cài đặt Warp+ kèm cấu hình rule có thể bật/tắt |
| `README.md` | Hướng dẫn sử dụng |

## 🛠 Cài đặt Warp+

```bash
wget -O setup.sh https://raw.githubusercontent.com/a112233-dt/openwrt-warpplus-vnroute/main/setup_warpplus_with_firewall_toggle.sh
chmod +x setup.sh
./setup.sh
```

Script sẽ:

- Tải danh sách IP Việt Nam từ IP2Location
- Tạo `/etc/warpplus/ipv4vn.set`
- Tạo bảng định tuyến riêng `warp`
- Gán rule:
  - mark 1 → dùng bảng warp
  - firewall lọc IP quốc tế (rule `Mark Not IPv4 VN`)
- ✅ **Bật rule = chỉ quốc tế qua Warp**
- ❌ **Tắt rule = tất cả qua Warp**

## 🔁 Bật / Tắt chuyển đổi ngay trong LuCI

1. Truy cập LuCI > Firewall > Traffic Rules
2. Tìm rule: **`Mark Not IPv4 VN`**
3. ✅ Bật rule → chỉ IP quốc tế đi Warp  
   ❌ Tắt rule → toàn bộ IP đi Warp

## 📂 File danh sách IP Việt Nam

Lưu tại:
```
/etc/warpplus/ipv4vn.set
```

## ⚠️ Yêu cầu

- Interface Warp+ (`warpplus`, `wg0`, `tun0`) đã hoạt động.
- OpenWrt >= 21.02 khuyến nghị.
- Đã cài `unzip`, `wget`, `awk`, `ipset`.
