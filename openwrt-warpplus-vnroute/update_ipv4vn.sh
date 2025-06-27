#!/bin/sh

IPSET_FILE="/etc/warpplus/ipv4vn.set"
TMP_CSV="/tmp/ip2location_vn.csv"

echo "📥 Tải IP mới từ IP2Location..."
wget -qO - "https://download.ip2location.com/lite/IP2LOCATION-LITE-DB1.CSV.ZIP" > /tmp/ipdb.zip
unzip -p /tmp/ipdb.zip > "$TMP_CSV"

echo "📄 Cập nhật $IPSET_FILE..."
rm -f "$IPSET_FILE"
awk -F',' '$3=="\"VN\"" {
    gsub(/\"/, "", $1); gsub(/\"/, "", $2)
    ip_start = $1 + 0; ip_end = $2 + 0
    while (ip_start <= ip_end) {
        for (mask=32; mask>0; mask--) {
            step = 2^(32 - mask)
            if (ip_start % step == 0 && ip_start + step - 1 <= ip_end) break
        }
        ip = sprintf("%d.%d.%d.%d",
           int(ip_start/2^24)%256,
           int(ip_start/2^16)%256,
           int(ip_start/2^8)%256,
           ip_start%256)
        print ip "/" mask >> "'"$IPSET_FILE"'"
        ip_start += step
    }
}' "$TMP_CSV"

echo "✅ Đã cập nhật $IPSET_FILE"
