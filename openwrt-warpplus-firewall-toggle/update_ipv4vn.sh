#!/bin/sh

IPSET_FILE="/etc/warpplus/ipv4vn.set"

echo "📥 Đang tải danh sách IP Việt Nam từ ipv4.fetus.jp..."
wget -qO "$IPSET_FILE" "https://ipv4.fetus.jp/vn.txt"

if [ $? -eq 0 ]; then
    echo "✅ Đã cập nhật danh sách IP Việt Nam thành công tại $IPSET_FILE"
else
    echo "❌ Lỗi khi tải danh sách IP. Vui lòng kiểm tra kết nối mạng hoặc URL."
fi
