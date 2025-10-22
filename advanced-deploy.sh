#!/bin/bash

echo "☁️ استقرار پیشرفته روی Cloudflare"
echo "================================"

# بررسی وضعیت
if [ ! -f ".current_port" ]; then
    echo "❌ سرویس در حال اجرا نیست. اول اجرا کن: ./simple-start.sh"
    exit 1
fi

PORT=$(cat .current_port)
API_URL="http://localhost:$PORT"

echo "✅ سرویس روی پورت $PORT در حال اجراست"

# ایجاد فایل Worker پیشرفته
cat > cloudflare-worker-advanced.js << 'CFEOF'
export default {
    async fetch(request, env, ctx) {
        // این آدرس باید بعداً در Cloudflare Dashboard جایگزین شود
        // برای تست از آدرس موقت استفاده می‌کنیم
        const API_BASE_URL = "https://your-actual-api-url.com"; // جایگزین کن
        
        const url = new URL(request.url);
        const pathname = url.pathname;
        const method = request.method;
        
        // لیست کامل مسیرهای API
        const apiEndpoints = {
            // سیستم
            '/api/system/status': 'وضعیت سیستم',
            '/api/system/health': 'سلامت سرویس‌ها',
            
            // محصولات
            '/api/products': 'مدیریت محصولات',
            '/api/products/list': 'لیست محصولات',
            '/api/products/add': 'افزودن محصول',
            
            // سفارشات
            '/api/orders': 'مدیریت سفارشات',
            '/api/orders/create': 'ایجاد سفارش',
            '/api/orders/list': 'لیست سفارشات',
            
            // کاربران
            '/api/users': 'مدیریت کاربران',
            '/api/users/register': 'ثبت نام',
            '/api/users/login': 'ورود',
            
            // موجودی
            '/api/inventory': 'مدیریت موجودی',
            '/api/inventory/update': 'بروزرسانی موجودی'
        };
        
        // هندل کردن CORS
        if (method === 'OPTIONS') {
            return new Response(null, {
                headers: {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
                    'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-API-Key',
                    'Access-Control-Max-Age': '86400',
                }
            });
        }
        
        // اگر مسیر اصلی است
        if (pathname === '/' || pathname === '') {
            return new Response(JSON.stringify({
                name: 'Tetrashop API Gateway',
                version: '1.0.0',
                status: 'active',
                endpoints: Object.keys(apiEndpoints),
                documentation: 'برای اطلاعات بیشتر به مستندات مراجعه کنید'
            }), {
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            });
        }
        
        // اگر مسیر API است
        const isApiPath = Object.keys(apiEndpoints).some(path => pathname.startsWith(path));
        
        if (!isApiPath) {
            return new Response(JSON.stringify({
                status: 'error',
                message: 'مسیر API یافت نشد',
                available_endpoints: apiEndpoints,
                usage: 'از مسیرهای موجود در available_endpoints استفاده کنید'
            }), {
                status: 404,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            });
        }
        
        try {
            // ساخت درخواست به API اصلی
            const targetUrl = API_BASE_URL + pathname + url.search;
            const requestOptions = {
                method: method,
                headers: {},
                body: method !== 'GET' && method !== 'HEAD' ? await request.text() : undefined
            };
            
            // کپی هدرهای مفید
            const usefulHeaders = ['content-type', 'authorization', 'x-api-key', 'user-agent'];
            for (const [key, value] of request.headers) {
                if (usefulHeaders.includes(key.toLowerCase())) {
                    requestOptions.headers[key] = value;
                }
            }
            
            const response = await fetch(targetUrl, requestOptions);
            
            // ساخت پاسخ با CORS
            const responseBody = await response.text();
            const modifiedResponse = new Response(responseBody, {
                status: response.status,
                statusText: response.statusText,
                headers: {
                    'Content-Type': response.headers.get('Content-Type') || 'application/json',
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
                    'Cache-Control': 'no-cache, no-store, must-revalidate'
                }
            });
            
            return modifiedResponse;
            
        } catch (error) {
            return new Response(JSON.stringify({
                status: 'error',
                message: 'سرویس موقتاً در دسترس نیست',
                error: error.message,
                timestamp: new Date().toISOString()
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

echo "✅ فایل Cloudflare Worker پیشرفته ایجاد شد"
echo ""
echo "📋 راهنمای استقرار:"
echo ""
echo "1. 🚀 فعلاً از API محلی استفاده کن:"
echo "   curl http://localhost:$PORT/api/system/status"
echo ""
echo "2. 🌐 برای استقرار Cloudflare:"
echo "   - فایل cloudflare-worker-advanced.js را باز کن"
echo "   - متغیر API_BASE_URL را با آدرس واقعی API جایگزین کن"
echo "   - به https://dash.cloudflare.com برو"
echo "   - Workers → Create Worker"
echo "   - کد را کپی و پیست کن"
echo "   - Deploy را بزن"
echo ""
echo "3. 🔧 آدرس‌های قابل استفاده:"
echo "   - آدرس Ngrok (اگر داشته باشی)"
echo "   - آدرس Render.com (اگر مستقر کنی)"
echo "   - آدرس Heroku (اگر مستقر کنی)"
echo "   - هر آدرس عمومی دیگر"
echo ""
echo "🎯 سیستم فعلاً روی پورت $PORT در دسترس است"
