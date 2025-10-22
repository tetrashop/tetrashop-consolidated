#!/bin/bash

echo "🚀 راه‌اندازی فوری تتراشاپ"
echo "========================="

# بررسی پیش‌نیازها
echo "🔍 بررسی پیش‌نیازها..."

# بررسی پایتون
if ! command -v python &> /dev/null; then
    echo "❌ پایتون نصب نیست. نصب کن: pkg install python"
    exit 1
fi

# بررسی فایل اصلی
if [ ! -f "tetrashop_orchestrator.py" ]; then
    echo "❌ فایل اصلی پیدا نشد"
    exit 1
fi

echo "✅ پیش‌نیازها بررسی شدند"

# توقف سرویس‌های قبلی
echo "🛑 توقف سرویس‌های قبلی..."
pkill -f "tetrashop_orchestrator.py" 2>/dev/null
pkill ngrok 2>/dev/null

# راه‌اندازی سرویس اصلی
echo "📦 راه‌اندازی سرویس اصلی..."
python tetrashop_orchestrator.py > tetrashop.log 2>&1 &
MAIN_PID=$!
echo $MAIN_PID > .main_pid

# منتظر راه‌اندازی
echo "⏳ منتظر راه‌اندازی سرویس..."
for i in {1..10}; do
    if curl -s http://localhost:8080/api/system/status > /dev/null; then
        echo "✅ سرویس اصلی پس از $i ثانیه راه‌اندازی شد"
        break
    fi
    sleep 1
    if [ $i -eq 10 ]; then
        echo "❌ تایم‌اوت در راه‌اندازی سرویس"
        echo "📋 لاگ سیستم:"
        tail -n 10 tetrashop.log
        exit 1
    fi
done

# تست API
echo "🧪 تست API..."
curl -s http://localhost:8080/api/system/status | python -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print('📊 وضعیت سیستم:')
    print(f'   وضعیت: {data.get(\"status\", \"unknown\")}')
    print(f'   سرویس‌های سالم: {data.get(\"healthy_services\", 0)}/{data.get(\"total_services\", 0)}')
    print(f'   زمان: {data.get(\"timestamp\", \"unknown\")}')
except Exception as e:
    print(f'❌ خطا در تست API: {e}')
"

# راه‌اندازی Ngrok اگر نصب باشد
if command -v ngrok &> /dev/null; then
    echo "🌐 راه‌اندازی Ngrok..."
    ngrok http 8080 > .ngrok.log 2>&1 &
    NGROK_PID=$!
    echo $NGROK_PID > .ngrok_pid
    
    # منتظر لینک عمومی
    echo "⏳ دریافت لینک عمومی..."
    for i in {1..15}; do
        NGROK_URL=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null | python -c "
import json, sys
try:
    data = json.load(sys.stdin)
    for tunnel in data['tunnels']:
        if tunnel['proto'] == 'https':
            print(tunnel['public_url'])
            break
except:
    pass
")
        
        if [ ! -z "$NGROK_URL" ]; then
            echo "✅ لینک عمومی: $NGROK_URL"
            echo "$NGROK_URL" > .public_url
            break
        fi
        sleep 1
    done
else
    echo "⚠️ Ngrok نصب نیست - فقط دسترسی محلی فعال است"
fi

# نمایش وضعیت نهایی
echo ""
echo "🎉 راه‌اندازی کامل شد!"
echo ""
echo "📋 وضعیت سیستم:"
echo "   ✅ سرویس اصلی: فعال (PID: $MAIN_PID)"
if [ -f ".public_url" ]; then
    echo "   ✅ Ngrok: فعال - لینک: $(cat .public_url)"
else
    echo "   ⚠️ Ngrok: غیرفعال"
fi
echo "   🌐 API محلی: http://localhost:8080"
echo ""
echo "🎯 دستورات مفید:"
echo "   وضعیت: ./status.sh"
echo "   توقف: ./stop.sh" 
echo "   استقرار: ./deploy-cloudflare.sh"
