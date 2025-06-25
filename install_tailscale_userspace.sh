#!/bin/sh

echo "🔧 Tailscale install script for X-WRT (kernel 6.6.90)"
echo "✅ Không cần opkg, không cần kmod-tun"

# Bước 1: Tạo thư mục tạm
TMPDIR="/tmp/tailscale"
mkdir -p "$TMPDIR"
cd "$TMPDIR"

# Bước 2: Tải binary mới nhất từ Tailscale
echo "📥 Đang tải Tailscale binary..."
TS_URL="https://pkgs.tailscale.com/stable/tailscale-latest-linux-arm.tgz"
wget "$TS_URL" -O tailscale.tgz || {
  echo "❌ Lỗi tải tailscale.tgz"
  exit 1
}

# Bước 3: Giải nén
echo "📦 Đang giải nén..."
tar -xzf tailscale.tgz

# Bước 4: Cài đặt
echo "📂 Đang cài vào /usr/bin..."
cp tailscale*/tailscale /usr/bin/
cp tailscale*/tailscaled /usr/bin/
chmod +x /usr/bin/tailscale /usr/bin/tailscaled

# Bước 5: Khởi chạy tailscaled
echo "🚀 Khởi chạy tailscaled (userspace)..."
/usr/bin/tailscaled --tun=userspace-networking &

# Bước 6: Hướng dẫn khởi động
echo ""
echo "✅ Hoàn tất! Chạy lệnh sau để đăng nhập Tailscale:"
echo ""
echo "  tailscale up --tun=userspace-networking"
echo ""
echo "📌 Hoặc dùng authkey (tạo tại https://login.tailscale.com/admin/settings/keys):"
echo "  tailscale up --tun=userspace-networking --authkey <KEY>"
