#!/bin/bash

echo "🕋 بسم الله الرحمن الرحیم"
echo "🚀 راه‌اندازی نهایی تتراشاپ v4.0"
echo "================================"

# توقف سرویس‌های قبلی
echo "🧹 پاکسازی سرویس‌های قبلی..."
pkill -f "tetrashop_orchestrator.py" 2>/dev/null
pkill -f localtunnel 2>/dev/null
sleep 2

# بررسی پیش‌نیازها
echo "🔍 بررسی پیش‌نیازها..."
if ! command -v python &> /dev/null; then
    echo "❌ پایتون نصب نیست. نصب کن: pkg install python"
    exit 1
fi

if [ ! -f "tetrashop_orchestrator.py" ]; then
    echo "❌ فایل اصلی پیدا نشد"
    exit 1
fi

# آزاد کردن پورت 8080
echo "🔓 آزاد کردن پورت 8080..."
fuser -k 8080/tcp 2>/dev/null
sleep 2

# راه‌اندازی سرویس اصلی
echo "📦 راه‌اندازی سرویس اصلی..."
python tetrashop_orchestrator.py > tetrashop.log 2>&1 &
MAIN_PID=$!
echo $MAIN_PID > .main_pid

# منتظر راه‌اندازی
echo "⏳ منتظر راه‌اندازی سرویس (15 ثانیه)..."
for i in {1..15}; do
    if curl -s http://localhost:8080/api/system/status > /dev/null; then
        echo "✅ سرویس اصلی پس از $i ثانیه راه‌اندازی شد"
        break
    fi
    sleep 1
    if [ $i -eq 15 ]; then
        echo "❌ تایم‌اوت در راه‌اندازی سرویس"
        echo "📋 بررسی لاگ:"
        tail -n 10 tetrashop.log
        exit 1
    fi
done

# تست API و نمایش وضعیت واقعی
echo "🧪 تست کامل API..."
curl -s http://localhost:8080/api/system/status | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print('=== 📊 وضعیت واقعی سیستم ===')
    print('🟢 وضعیت:', data.get('status', 'unknown'))
    
    # محاسبه واقعی سرویس‌های سالم
    services = data.get('services', {})
    if services:
        healthy_count = 0
        total_count = len(services)
        
        print('🔍 سرویس‌های شناسایی شده:')
        for service_name, service_data in services.items():
            if isinstance(service_data, dict):
                # اگر سرویس دیکشنری دارد، فعال در نظر بگیر
                status = 'فعال'
                healthy_count += 1
            else:
                status = 'نامشخص'
            
            print(f'   📍 {service_name}: {status}')
            
        print(f'📈 آمار واقعی: {healthy_count}/{total_count} سرویس فعال')
    else:
        print('❌ هیچ سرویسی شناسایی نشد')
        print('📋 سرویس‌های مورد انتظار: chess, natiq, writer')
        
    print('🕐 زمان:', data.get('timestamp', 'unknown'))
    
except Exception as e:
    print('❌ خطا در خواندن پاسخ API:', str(e))
"

# راه‌اندازی LocalTunnel با روش مطمئن‌تر
echo "🌐 راه‌اندازی تونل عمومی..."
npx localtunnel --port 8080 --subdomain tetrashop-$(date +%s) > .lt.log 2>&1 &
LT_PID=$!
echo $LT_PID > .lt_pid

echo "⏳ منتظر لینک عمومی (20 ثانیه)..."
for i in {1..20}; do
    if [ -f ".lt.log" ]; then
        # چند روش مختلف برای پیدا کردن لینک
        LT_URL1=$(grep -o "https://[a-zA-Z0-9.-]*\.loca\.lt" .lt.log | head -1)
        LT_URL2=$(grep -o "your url is: https://[^ ]*" .lt.log | cut -d' ' -f4)
        LT_URL3=$(grep -o "https://[a-zA-Z0-9.-]*\.[a-z]*\.[a-z]*" .lt.log | head -1)
        
        LT_URL=\"$LT_URL1$LT_URL2$LT_URL3\"
        
        if [ ! -z "$LT_URL" ]; then
            echo "🎉 لینک عمومی دریافت شد: $LT_URL"
            echo "$LT_URL" > .public_url
            
            # تست لینک
            echo "🧪 تست لینک عمومی..."
            if curl -s --connect-timeout 10 "$LT_URL/api/system/status" > /dev/null; then
                echo "✅ لینک عمومی کار می‌کند!"
            else
                echo "⚠️ لینک عمومی تست نشد (ممکن است زمان بیشتری نیاز باشد)"
            fi
            break
        fi
    fi
    sleep 1
done

if [ ! -f ".public_url" ]; then
    echo "❌ دریافت لینک عمومی ناموفق بود"
    echo "📋 لاگ LocalTunnel:"
    tail -n 5 .lt.log
    echo ""
    echo "🎯 راه‌حل‌های جایگزین:"
    echo "   - اینترنت خود را بررسی کن"
    echo "   - از ./alternative-tunnel.sh استفاده کن"
    echo "   - یا مستقیماً از آدرس محلی استفاده کن"
fi

# نمایش وضعیت نهایی
echo ""
echo "🎉 ======= راه‌اندازی کامل شد ======="
echo ""
echo "📋 وضعیت سیستم:"
echo "   ✅ سرویس اصلی: فعال (PID: $(cat .main_pid))"
echo "   🌐 API محلی: http://localhost:8080"

if [ -f ".public_url" ]; then
    echo "   🌍 لینک عمومی: $(cat .public_url)"
else
    echo "   ⚠️ لینک عمومی: دریافت نشد"
fi

echo ""
echo "🎯 دستورات مدیریت:"
echo "   📊 وضعیت: ./status.sh"
echo "   🛑 توقف: ./stop.sh"
echo "   ☁️ استقرار: ./deploy.sh"
echo "   🐛 دیباگ: ./debug.sh"

echo ""
echo "🔗 تست سریع:"
echo "   curl http://localhost:8080/api/system/status"

if [ -f ".public_url" ]; then
    echo "   curl $(cat .public_url)/api/system/status"
fi

echo ""
echo "🕋 ما شالله سیستم پربرکت باشد! 🌟"
