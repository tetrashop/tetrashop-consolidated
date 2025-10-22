#!/bin/bash

echo "☁️ استقرار روی Cloudflare"
echo "========================"

# بررسی وضعیت سیستم
echo "🔍 بررسی وضعیت سیستم..."
if ! curl -s http://localhost:8080/api/system/status > /dev/null; then
    echo "❌ سرویس اصلی در حال اجرا نیست. اول اجرا کن: ./start-now.sh"
    exit 1
fi

# ایجاد فایل Worker برای Cloudflare
cat > cloudflare-worker.js << 'CFEOF'
export default {
    async fetch(request, env, ctx) {
        // آدرس API اصلی - بعداً در Dashboard جایگزین کن
        const API_BASE_URL = "https://YOUR_NGROK_URL.ngrok.io";
        
        const url = new URL(request.url);
        const pathname = url.pathname;
        
        // مسیرهای API
        const apiPaths = [
            '/api/system/status',
            '/api/products', 
            '/api/orders',
            '/api/users',
            '/api/inventory'
        ];
        
        // بررسی اگر مسیر API است
        const isApiPath = apiPaths.some(path => pathname.startsWith(path));
        
        if (!isApiPath) {
            return new Response(JSON.stringify({
                status: 'error',
                message: 'مسیر پیدا نشد',
                available_paths: apiPaths
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
            const apiUrl = API_BASE_URL + pathname + url.search;
            const response = await fetch(apiUrl, {
                method: request.method,
                headers: request.headers,
                body: request.method !== 'GET' ? await request.text() : undefined
            });
            
            // کپی پاسخ با هدرهای CORS
            const modifiedResponse = new Response(response.body, response);
            modifiedResponse.headers.set('Access-Control-Allow-Origin', '*');
            modifiedResponse.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
            modifiedResponse.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
            
            return modifiedResponse;
            
        } catch (error) {
            return new Response(JSON.stringify({
                status: 'error',
                message: 'خطا در ارتباط با سرور',
                error: error.message
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
echo ""
echo "📋 مراحل استقرار:"
echo ""
echo "1. 🔄 اگر Ngrok دارید:"
echo "   - ./start-now.sh را اجرا کن"
echo "   - لینک Ngrok را کپی کن"
echo "   - در cloudflare-worker.js، YOUR_NGROK_URL را جایگزین کن"
echo ""
echo "2. 🌐 رفتن به Cloudflare:"
echo "   - به https://dash.cloudflare.com برو"
echo "   - Workers & Pages → Create Worker"
echo ""
echo "3. 📝 کپی کردن کد:"
echo "   - محتوای cloudflare-worker.js را کپی کن"
echo "   - در ادیتور Cloudflare پیست کن"
echo ""
echo "4. 🚀 استقرار:"
echo "   - Save and Deploy را بزن"
echo ""
echo "5. 🔗 استفاده:"
echo "   - از آدرس worker.dev استفاده کن"
echo "   - مثال: https://tetrashop-api.your-subdomain.workers.dev/api/system/status"
echo ""
echo "🎯 نکته: اگر Ngrok ندارید، می‌توانی بعداً آدرس واقعی را جایگزین کنی"
