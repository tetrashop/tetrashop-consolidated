#!/bin/bash

echo "🧪 تست سریع سیستم"
echo "================="

# تست سرویس محلی
echo "1. تست سرویس محلی..."
if curl -s http://localhost:8080/api/system/status > /dev/null; then
    echo "✅ سرویس محلی کار می‌کند"
    curl -s http://localhost:8080/api/system/status | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print('   📊 وضعیت:', data.get('status', 'unknown'))
    print('   🕐 زمان:', data.get('timestamp', 'unknown'))
except:
    print('   ❌ خطا در خواندن پاسخ')
"
else
    echo "❌ سرویس محلی کار نمی‌کند"
    echo "   راه‌حل: python tetrashop_orchestrator.py"
fi

# نمایش آدرس‌های مفید
echo ""
echo "2. 🔗 آدرس‌های مفید:"
IP=$(ip addr show | grep inet | grep -v 127.0.0.1 | grep -v ::1 | head -1 | awk '{print $2}' | cut -d'/' -f1)
if [ ! -z "$IP" ]; then
    echo "   🌐 شبکه محلی: http://$IP:8080"
fi
echo "   💻 localhost: http://localhost:8080"

echo ""
echo "3. 🎯 قدم بعدی:"
echo "   برای استقرار اجرا کن: ./instant-deploy.sh"
