#!/bin/bash

echo "🔄 راه‌حل‌های جایگزین برای تونل عمومی"
echo "===================================="

echo "🎯 در حال حاضر از LocalTunnel استفاده می‌شود."
echo "اگر کار نکرد، این گزینه‌ها را امتحان کن:"

echo ""
echo "1. 🔄 راه‌اندازی مجدد LocalTunnel:"
echo "   ./stop.sh && ./run.sh"

echo ""
echo "2. 📍 استفاده از آدرس‌های شبکه محلی:"
IP=$(ip addr show | grep inet | grep -v 127.0.0.1 | grep -v ::1 | head -1 | awk '{print $2}' | cut -d'/' -f1)
if [ ! -z "$IP" ]; then
    echo "   آدرس IP شما: $IP"
    echo "   می‌توانی از آدرس زیر استفاده کنی:"
    echo "   http://$IP:8080/api/system/status"
else
    echo "   آدرس IP پیدا نشد"
fi

echo ""
echo "3. 🌐 استفاده از سرویس‌های جایگزین:"
echo "   - Cloudflare Tunnel (نیاز به ثبت‌نام دارد)"
echo "   - Ngrok (نیاز به نصب دستی دارد)"
echo "   - Serveo (از طریق SSH)"

echo ""
echo "4. ☁️ استقرار مستقیم روی Cloudflare:"
echo "   حتی بدون لینک عمومی هم می‌توانی استقرار کنی:"
echo "   ./deploy.sh"
echo "   سپس در Cloudflare Dashboard آدرس واقعی را جایگزین کنی"

echo ""
echo "📝 نکته: برای توسعه و تست، آدرس محلی کافی است:"
echo "   http://localhost:8080"
