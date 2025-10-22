#!/bin/bash

echo "🚀 Tetrashop Production Deployment to Cloudflare"
echo "=============================================="

# بررسی وضعیت سرویس‌ها
echo "📊 Checking service status..."
STATUS=$(curl -s http://localhost:3030/api/status)
HEALTHY_COUNT=$(echo "$STATUS" | grep -o '"healthy_services":[0-9]*' | cut -d: -f2)
TOTAL_COUNT=$(echo "$STATUS" | grep -o '"total_services":[0-9]*' | cut -d: -f2)

if [ "$HEALTHY_COUNT" -eq "$TOTAL_COUNT" ]; then
    echo "✅ All $HEALTHY_COUNT services are healthy"
else
    echo "❌ Only $HEALTHY_COUNT out of $TOTAL_COUNT services are healthy"
    echo "Deployment aborted. Please fix service issues first."
    exit 1
fi

# بررسی پیش‌نیازهای Cloudflare
echo "🔍 Checking Cloudflare prerequisites..."

if ! command -v wrangler &> /dev/null; then
    echo "📦 Installing Wrangler CLI..."
    npm install -g wrangler
fi

if ! wrangler whoami &> /dev/null; then
    echo "🔐 Please login to Cloudflare:"
    wrangler login
fi

# استقرار
echo "☁️ Deploying to Cloudflare..."
wrangler publish

if [ $? -eq 0 ]; then
    echo "✅ Successfully deployed to Cloudflare Workers"
    
    # تنظیم routes
    echo "🛣️ Setting up routes..."
    wrangler routes add "tetrashop.yourdomain.com/*"
    wrangler routes add "api.tetrashop.yourdomain.com/*"
    
    # تست استقرار
    echo "🧪 Testing production deployment..."
    sleep 5
    
    # تست endpoint اصلی
    curl -s "https://tetrashop.yourdomain.com/" | grep -q "Tetrashop" && 
        echo "✅ Production endpoint working" || 
        echo "⚠️  Production endpoint check failed"
    
    echo ""
    echo "🎉 DEPLOYMENT SUCCESSFUL!"
    echo "🌐 Production URL: https://tetrashop.yourdomain.com"
    echo "🔧 API URL: https://api.tetrashop.yourdomain.com"
    echo "📊 Status: https://tetrashop.yourdomain.com/status"
    
else
    echo "❌ Deployment failed"
    exit 1
fi
