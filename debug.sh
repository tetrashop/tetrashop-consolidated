#!/bin/bash

echo "🐛 دیباگ سیستم تتراشاپ"
echo "====================="

# بررسی سرویس اصلی
echo "🔍 بررسی سرویس اصلی..."
if [ -f ".main_pid" ]; then
    if ps -p $(cat ".main_pid") > /dev/null; then
        echo "✅ سرویس اصلی در حال اجراست (PID: $(cat .main_pid))"
    else
        echo "❌ سرویس اصلی متوقف شده"
    fi
else
    echo "❌ فایل PID پیدا نشد"
fi

# بررسی پورت
echo "🔍 بررسی پورت 8080..."
if netstat -tulpn 2>/dev/null | grep ":8080" > /dev/null; then
    echo "✅ پورت 8080 در استفاده است"
else
    echo "❌ پورت 8080 آزاد است"
fi

# بررسی لاگ
echo "🔍 بررسی لاگ‌ها..."
if [ -f "tetrashop.log" ]; then
    echo "📋 آخرین خطاهای لاگ:"
    tail -n 10 tetrashop.log | grep -i error | tail -n 5 || echo "   هیچ خطایی یافت نشد"
else
    echo "❌ فایل لاگ پیدا نشد"
fi

# تست API
echo "🔍 تست API..."
curl -s http://localhost:8080/api/system/status | python -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print('✅ API پاسخ می‌دهد')
    print(f'   وضعیت: {data.get(\"status\", \"unknown\")}')
    print(f'   سرویس‌ها: {data.get(\"healthy_services\", 0)}/{data.get(\"total_services\", 0)}')
    
    # بررسی جزئیات
    services = data.get('services', {})
    if not services:
        print('❌ مشکل: هیچ سرویسی گزارش نشده')
        print('   احتمالات:')
        print('   - سرویس‌ها درست راه‌اندازی نشده‌اند')
        print('   - فایل tetrashop_orchestrator.py مشکل دارد')
        print('   - ماژول‌های پایتون نصب نیستند')
        
except Exception as e:
    print(f'❌ API پاسخ نمی‌دهد: {e}')
    print('   راه‌حل‌ها:')
    print('   - سرویس را restart کن: ./stop.sh && ./launch.sh')
    print('   - پایتون را چک کن: python --version')
    print('   - فایل اصلی را بررسی کن')
"

echo ""
echo "🎯 پیشنهادات:"
echo "   - اگر سرویس‌ها صفر هستند، فایل tetrashop_orchestrator.py را بررسی کن"
echo "   - مطمئن شو همه ماژول‌های پایتون نصب شده‌اند"
echo "   - از ./launch.sh برای راه‌اندازی مجدد استفاده کن"
