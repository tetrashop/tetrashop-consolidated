#!/bin/bash
echo "🏗️ در حال ایجاد سیستم یکپارچه Tetrashop..."

# ایجاد ساختار پوشه‌ها
mkdir -p {frontend,backend,deployment}/{gateway,shop,admin,api,services,cloudflare,config}

echo "✅ ساختار فایل‌ها ایجاد شد"
echo "📁 پوشه اصلی: ~/tetrashop-unified-system"
echo ""
echo "🎯 فایل‌های ایجاد شده:"
echo "   - deployment/cloudflare/unified-worker.js (فایل اصلی Cloudflare)"
echo "   - deployment/cloudflare/wrangler.toml (تنظیمات)"
echo "   - frontend/gateway/index.html (درگاه اصلی)"
echo "   - frontend/shop/shop.html (فروشگاه)"
echo "   - deployment/config/system-config.json (پیکربندی سیستم)"
echo ""
echo "🚀 برای دپلوی:"
echo "   کد unified-worker.js را در Cloudflare Worker کپی کنید"
