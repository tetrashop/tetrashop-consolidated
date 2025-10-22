#!/bin/bash

echo "🚀 استقرار سریع تتراشاپ"
echo "======================"

# دادن دسترسی اجرا
chmod +x tetrashop-manager.sh

echo "🔧 بررسی پیش‌نیازها..."
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

# راه‌اندازی سیستم
echo "🔧 راه‌اندازی سیستم..."
./tetrashop-manager.sh start

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 سیستم با موفقیت راه‌اندازی شد!"
    echo ""
    echo "📋 قدم بعدی:"
    echo "برای استقرار روی Cloudflare اجرا کن:"
    echo "  ./tetrashop-manager.sh deploy"
    echo ""
    if [ -f ".public_url" ]; then
        echo "🌐 لینک عمومی تو: $(cat .public_url)"
        echo "🧪 تست کن: curl $(cat .public_url)/api/system/status"
    fi
else
    echo ""
    echo "❌ خطا در راه‌اندازی سیستم"
    echo ""
    echo "📋 عیب‌یابی:"
    echo "1. دستی اجرا کن: python tetrashop_orchestrator.py"
    echo "2. بررسی کن پورت 8080 آزاد باشد"
    echo "3. لاگ رو چک کن: cat tetrashop.log"
fi
