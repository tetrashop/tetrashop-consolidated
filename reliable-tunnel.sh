#!/bin/bash

echo "🌐 راه‌اندازی تونل مطمئن"
echo "======================"

# روش ۱: LocalTunnel با تنظیمات بهتر
echo "🔄 روش ۱: LocalTunnel پیشرفته..."
npx localtunnel --port 8080 --print-requests > .lt-detailed.log 2>&1 &
LT_PID=$!
echo $LT_PID > .lt_pid

echo "⏳ منتظر لینک (25 ثانیه)..."
for i in {1..25}; do
    if [ -f ".lt-detailed.log" ]; then
        # روش‌های مختلف استخراج لینک
        LT_URL=$(grep -E "your url is:|https://.*\.loca\.lt" .lt-detailed.log | grep -o "https://[^ ]*" | head -1)
        
        if [ ! -z "$LT_URL" ] && [ "$LT_URL" != "https://" ]; then
            echo "🎉 لینک دریافت شد: $LT_URL"
            echo "$LT_URL" > .public_url
            break
        fi
    fi
    sleep 1
done

if [ ! -f ".public_url" ]; then
    echo "❌ LocalTunnel موفق نبود. روش ۲ را امتحان می‌کنیم..."
    pkill -f localtunnel
    
    # روش ۲: استفاده از localtunnel با subdomain ثابت
    echo "🔄 روش ۲: LocalTunnel با subdomain ثابت..."
    npx localtunnel --port 8080 --subdomain tetrashop-$(whoami) > .lt2.log 2>&1 &
    LT2_PID=$!
    echo $LT2_PID > .lt_pid
    
    sleep 15
    
    LT2_URL="https://tetrashop-$(whoami).loca.lt"
    if curl -s --connect-timeout 5 "$LT2_URL/api/system/status" > /dev/null; then
        echo "🎉 لینک روش ۲ کار می‌کند: $LT2_URL"
        echo "$LT2_URL" > .public_url
    else
        echo "❌ روش ۲ هم کار نکرد"
        echo "📋 استفاده از آدرس‌های شبکه محلی..."
    fi
fi

# نمایش نتیجه
if [ -f ".public_url" ]; then
    echo ""
    echo "✅ تونل عمومی فعال: $(cat .public_url)"
    echo "🧪 تست لینک..."
    curl -s "$(cat .public_url)/api/system/status" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print('✅ لینک عمومی کار می‌کند!')
    print('   وضعیت:', data.get('status', 'unknown'))
except:
    print('⚠️ لینک تست نشد (ممکن است زمان بیشتری نیاز باشد)')
"
else
    echo ""
    echo "📋 راه‌حل‌های جایگزین:"
    echo "1. از آدرس محلی استفاده کن: http://localhost:8080"
    echo "2. از آدرس IP محلی استفاده کن (در شبکه محلی)"
    echo "3. بعداً دوباره امتحان کن"
fi
