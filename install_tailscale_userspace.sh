#!/bin/sh

echo "🔧 Cài Tailscale 1.84.0 (userspace) cho OpenWrt/X-WRT"
echo "✅ Không cần opkg, không cần kmod-tun, không cần libc ngoài"

# Bước 1: Chuẩn bị thư mục
cd /tmp || exit 1

# Bước 2: Tải binary từ link bạn yêu cầu
TS_URL="https://pkgs.tailscale.com/stable/tailscale_1.84.0_arm.tgz"
echo "📥 Tải Tailscale từ $TS_URL ..."
wget "$TS_URL" -O tailscale.tgz || { echo "❌ Lỗi tải tailscale.tgz"; exit 1; }

# Bước 3: Giải nén
echo "📦 Đang giải nén..."
tar -xzf tailscale.tgz || { echo "❌ Giải nén lỗi"; exit 1; }

# Bước 4: Cài binary
echo "🚚 Cài đặt vào /usr/bin..."
cp tailscale*/tailscaled tailscale*/tailscale /usr/bin/
chmod +x /usr/bin/tailscaled /usr/bin/tailscale

# Bước 5: Khởi chạy
echo "🚀 Khởi chạy tailscaled..."
/usr/bin/tailscaled --tun=userspace-networking &

# Bước 6: Hướng dẫn người dùng
echo ""
echo "✅ Hoàn tất! Chạy lệnh sau để kết nối:"
echo "  tailscale up --tun=userspace-networking"
echo ""
echo "📌 Hoặc dùng authkey:"
echo "  tailscale up --tun=userspace-networking --authkey <KEY>"
echo "👉 Tạo key tại: https://login.tailscale.com/admin/settings/keys"
