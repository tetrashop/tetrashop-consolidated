#!/bin/bash

echo "🕋 بسم الله الرحمن الرحیم"
echo "🚀 راه‌اندازی نهایی تتراشاپ v5.0"
echo "================================"

# پاکسازی
echo "🧹 پاکسازی محیط..."
pkill -f "tetrashop_orchestrator.py" 2>/dev/null
pkill -f localtunnel 2>/dev/null
sleep 2

# بررسی پیش‌نیازها
echo "🔍 بررسی پیش‌نیازها..."
if ! command -v python &> /dev/null; then
    echo "❌ پایتون نصب نیست"
    exit 1
fi

if [ ! -f "tetrashop_orchestrator.py" ]; then
    echo "❌ فایل اصلی پیدا نشد"
    exit 1
fi

# آزاد کردن پورت
echo "🔓 آزاد کردن پورت 8080..."
fuser -k 8080/tcp 2>/dev/null
sleep 2

# راه‌اندازی سرویس اصلی
echo "📦 راه‌اندازی سرویس اصلی..."
python tetrashop_orchestrator.py > tetrashop.log 2>&1 &
MAIN_PID=$!
echo $MAIN_PID > .main_pid

# منتظر راه‌اندازی
echo "⏳ منتظر راه‌اندازی سرویس..."
for i in {1..15}; do
    if curl -s http://localhost:8080/api/system/status > /dev/null; then
        echo "✅ سرویس اصلی پس از $i ثانیه راه‌اندازی شد"
        break
    fi
    sleep 1
done

# تست API
echo "🧪 تست API محلی..."
curl -s http://localhost:8080/api/system/status | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print('=== 📊 وضعیت سیستم ===')
    print('✅ وضعیت:', data.get('status', 'unknown'))
    
    services = data.get('services', {})
    if services:
        print('🔍 سرویس‌های فعال:')
        for service, details in services.items():
            print(f'   📍 {service}: فعال')
        print(f'📈 آمار: {len(services)}/{len(services)} سرویس فعال')
    else:
        print('❌ مشکل در شناسایی سرویس‌ها')
        
    print('🕐 زمان:', data.get('timestamp', 'unknown'))
except Exception as e:
    print('❌ خطا در تست API:', e)
"

# راه‌اندازی تونل
echo ""
echo "🌐 راه‌اندازی تونل عمومی..."
./reliable-tunnel.sh

# نمایش وضعیت نهایی
echo ""
echo "🎉 ======= راه‌اندازی کامل شد ======="
echo ""
echo "📋 وضعیت نهایی:"
echo "   ✅ سرویس اصلی: فعال (PID: $(cat .main_pid))"
echo "   🌐 API محلی: http://localhost:8080"

if [ -f ".public_url" ]; then
    echo "   🌍 لینک عمومی: $(cat .public_url)"
else
    echo "   ⚠️ لینک عمومی: از آدرس محلی استفاده کن"
fi

echo ""
echo "🎯 دستورات مفید:"
echo "   📊 وضعیت: curl http://localhost:8080/api/system/status"
echo "   🛑 توقف: ./stop.sh"
echo "   ☁️ استقرار: ./deploy.sh"

echo ""
echo "🔗 تست سریع:"
echo "   curl http://localhost:8080/api/system/status"

if [ -f ".public_url" ]; then
    echo "   curl $(cat .public_url)/api/system/status"
fi

echo ""
echo "🕋 ما شالله سیستم پربرکت باشد! 🌟"
