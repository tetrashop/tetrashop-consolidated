#!/bin/bash

echo "🏠 استفاده از شبکه محلی"
echo "====================="

# پیدا کردن آدرس IP
IP=$(ip addr show 2>/dev/null | grep inet | grep -v 127.0.0.1 | head -1 | awk '{print $2}' | cut -d'/' -f1)

echo "✅ API شما در حال اجراست روی:"
echo ""
echo "🔗 آدرس‌های دسترسی:"
echo "   1. روی همین دستگاه: http://localhost:8080"
if [ ! -z "$IP" ]; then
    echo "   2. در شبکه WiFi: http://$IP:8080"
    echo "   3. سایر دستگاه‌ها در همین WiFi می‌توانند به آدرس بالا وصل شوند"
else
    echo "   2. آدرس IP پیدا نشد - از localhost استفاده کن"
fi

echo ""
echo "📋 مسیرهای API:"
echo "   - وضعیت سیستم: /api/system/status"
echo "   - محصولات: /api/products"
echo "   - سفارشات: /api/orders"
echo "   - کاربران: /api/users"
echo "   - موجودی: /api/inventory"

echo ""
echo "🎯 مثال:"
if [ ! -z "$IP" ]; then
    echo "   http://$IP:8080/api/system/status"
else
    echo "   http://localhost:8080/api/system/status"
fi

echo ""
echo "📱 روی موبایل:"
echo "   1. مرورگر را باز کن"
echo "   2. آدرس بالا را وارد کن"
echo "   3. باید پاسخ JSON ببینی"
