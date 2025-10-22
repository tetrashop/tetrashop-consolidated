#!/bin/bash

echo "☁️ استقرار ساده روی Cloudflare"
echo "============================="

# بررسی وضعیت
if ! curl -s http://localhost:8080/api/system/status > /dev/null; then
    echo "❌ سرویس فعال نیست. اول اجرا کن: ./final-launch.sh"
    exit 1
fi

echo "✅ سرویس اصلی فعال است"

# دریافت آدرس عمومی یا محلی
if [ -f ".public_url" ]; then
    API_URL=$(cat .public_url)
    echo "🎯 لینک عمومی: $API_URL"
else
    API_URL="http://localhost:8080"
    echo "⚠️ از آدرس محلی استفاده می‌شود: $API_URL"
    echo "💡 بعداً می‌تونی در Cloudflare آدرس رو تغییر بدی"
fi

# ایجاد فایل Worker ساده‌تر
cat > cloudflare-worker-simple.js << 'CFEOF'
export default {
    async fetch(request) {
        // آدرس API - این رو با آدرس واقعی عوض کن
        const API_BASE_URL = "REPLACE_WITH_ACTUAL_URL";
        
        const url = new URL(request.url);
        const path = url.pathname;
        
        // مسیرهای اصلی
        const routes = {
            '/': 'info',
            '/api/system/status': 'status',
            '/api/products': 'products',
            '/api/orders': 'orders',
            '/api/users': 'users',
            '/api/inventory': 'inventory'
        };
        
        // صفحه اصلی
        if (path === '/' || path === '') {
            return new Response(JSON.stringify({
                service: "Tetrashop API",
                status: "active",
                message: "API Gateway is working",
                endpoints: Object.keys(routes)
            }), {
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            });
        }
        
        // CORS برای OPTIONS
        if (request.method === 'OPTIONS') {
            return new Response(null, {
                headers: {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
                    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
                }
            });
        }
        
        try {
            const response = await fetch(API_BASE_URL + path + url.search, {
                method: request.method,
                headers: request.headers,
                body: request.method !== 'GET' ? await request.text() : undefined
            });
            
            const newResponse = new Response(response.body, response);
            newResponse.headers.set('Access-Control-Allow-Origin', '*');
            return newResponse;
            
        } catch (error) {
            return new Response(JSON.stringify({
                error: "Service unavailable",
                message: "Check API_BASE_URL in Cloudflare dashboard"
            }), {
                status: 503,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            });
        }
    }
}
CFEOF

echo "✅ فایل Cloudflare Worker ایجاد شد"

# راهنمای استقرار
echo ""
echo "📋 مراحل استقرار:"
echo ""
echo "1. 🔧 آماده‌سازی فایل:"
echo "   فایل cloudflare-worker-simple.js را باز کن"
echo "   این خط را پیدا کن:"
echo "   const API_BASE_URL = \"REPLACE_WITH_ACTUAL_URL\";"
echo ""

if [ -f ".public_url" ]; then
    echo "2. 🔗 جایگزینی لینک:"
    echo "   با این لینک جایگزین کن:"
    echo "   const API_BASE_URL = \"$API_URL\";"
else
    echo "2. 🔗 استفاده از آدرس محلی (موقت):"
    echo "   با این آدرس جایگزین کن:"
    echo "   const API_BASE_URL = \"$API_URL\";"
    echo "   💡 بعداً می‌تونی آدرس عمومی رو جایگزین کنی"
fi

echo ""
echo "3. 🌐 استقرار در Cloudflare:"
echo "   - به https://dash.cloudflare.com برو"
echo "   - Workers & Pages → Create Worker"
echo "   - کد رو کپی و پیست کن"
echo "   - Save and Deploy رو بزن"
echo ""
echo "4. 🧪 تست:"
echo "   آدرس worker.dev خودت رو تست کن"
echo ""
echo "🎉 تمام! API تو روی اینترنت در دسترسه"
