#!/bin/bash

echo "⚡ استقرار فوری روی Cloudflare"
echo "============================"

# بررسی اینکه سرویس در حال اجراست
if ! curl -s http://localhost:8080/api/system/status > /dev/null; then
    echo "❌ سرویس در حال اجرا نیست"
    echo "📋 اول سرویس را اجرا کن:"
    echo "   python tetrashop_orchestrator.py"
    echo "   یا"
    echo "   ./start-api.sh"
    exit 1
fi

echo "✅ سرویس اصلی فعال است"

# دریافت آدرس IP محلی
IP=$(ip addr show | grep inet | grep -v 127.0.0.1 | grep -v ::1 | head -1 | awk '{print $2}' | cut -d'/' -f1)
if [ -z "$IP" ]; then
    IP="localhost"
fi

echo "🌐 آدرس محلی شما: http://$IP:8080"

# ایجاد فایل Worker با راهنمای کامل
cat > cloudflare-worker-final.js << 'CFEOF'
// 🔧 Cloudflare Worker برای تتراشاپ
// 📍 این کد را در dash.cloudflare.com پیست کن

export default {
    async fetch(request, env, ctx) {
        // ⚠️ مهم: این آدرس را با آدرس واقعی API خودت جایگزین کن!
        // اگر لینک عمومی داری، اینجا قرار بده
        // اگر نه، از آدرس localhost:8080 استفاده کن (فقط برای تست)
        const API_BASE_URL = "http://localhost:8080"; // 🔄 این را تغییر بده!
        
        const url = new URL(request.url);
        const pathname = url.pathname;
        const method = request.method;
        
        // 📋 مسیرهای API
        const apiPaths = [
            '/api/system/status',
            '/api/products',
            '/api/orders', 
            '/api/users',
            '/api/inventory'
        ];
        
        // 🌐 مدیریت CORS
        if (method === 'OPTIONS') {
            return new Response(null, {
                headers: {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
                    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
                }
            });
        }
        
        // 🏠 صفحه اصلی
        if (pathname === '/' || pathname === '') {
            return new Response(JSON.stringify({
                service: "Tetrashop API Gateway",
                version: "1.0.0",
                status: "active",
                message: "✅ API در حال اجراست",
                endpoints: apiPaths,
                instructions: "برای استفاده از endpoint های بالا اقدام کنید"
            }), {
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            });
        }
        
        // 🔍 بررسی مسیر API
        const isApiPath = apiPaths.some(path => pathname.startsWith(path));
        
        if (!isApiPath) {
            return new Response(JSON.stringify({
                status: 'error',
                message: 'مسیر API یافت نشد',
                available_endpoints: apiPaths,
                help: 'از مسیرهای موجود در لیست استفاده کنید'
            }), {
                status: 404,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            });
        }
        
        try {
            // 🔄 ارسال درخواست به API اصلی
            const targetUrl = API_BASE_URL + pathname + url.search;
            console.log('📞 ارسال درخواست به:', targetUrl);
            
            const response = await fetch(targetUrl, {
                method: method,
                headers: request.headers,
                body: method !== 'GET' && method !== 'HEAD' ? await request.text() : undefined
            });
            
            // ✨ افزودن CORS به پاسخ
            const modifiedResponse = new Response(response.body, response);
            modifiedResponse.headers.set('Access-Control-Allow-Origin', '*');
            modifiedResponse.headers.set('Cache-Control', 'no-cache');
            
            return modifiedResponse;
            
        } catch (error) {
            // ❌ مدیریت خطا
            return new Response(JSON.stringify({
                status: 'error',
                message: 'خطا در ارتباط با سرور',
                error: error.message,
                solution: 'آدرس API_BASE_URL را بررسی کنید'
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

echo "✅ فایل Cloudflare Worker ایجاد شد: cloudflare-worker-final.js"

# نمایش راهنمای کامل استقرار
echo ""
echo "🎯 راهنمای قدم‌به‌قدم استقرار:"
echo ""
echo "1. 🔧 فایل را آماده کن:"
echo "   فایل 'cloudflare-worker-final.js' ایجاد شد"
echo ""
echo "2. 🌐 برو به Cloudflare:"
echo "   - باز کن: https://dash.cloudflare.com"
echo "   - برو به: Workers & Pages"
echo "   - کلیک کن: Create Worker"
echo ""
echo "3. 📝 کپی کردن کد:"
echo "   - محتوای فایل cloudflare-worker-final.js را انتخاب کن"
echo "   - در ادیتور Cloudflare پیست کن"
echo ""
echo "4. ⚙️ تنظیم آدرس API (مهم!):"
echo "   در کد، این خط را پیدا کن:"
echo "   const API_BASE_URL = \"http://localhost:8080\";"
echo ""
echo "   🔄 این آدرسها را می‌توانی استفاده کنی:"
echo "   - برای تست: http://localhost:8080"
echo "   - برای شبکه محلی: http://$IP:8080"
echo "   - اگر لینک عمومی داری: آدرس لینک عمومی"
echo ""
echo "5. 🚀 استقرار:"
echo "   - Save and Deploy را بزن"
echo ""
echo "6. 🧪 تست:"
echo "   - آدرس worker.dev خودت رو باز کن"
echo "   - /api/system/status را تست کن"
echo ""
echo "📝 مثال:"
echo "   اگر worker تو این آدرس باشد:"
echo "   https://tetrashop-api.your-name.workers.dev"
echo "   این رو تست کن:"
echo "   https://tetrashop-api.your-name.workers.dev/api/system/status"
echo ""
echo "🎉 موفق باشی! API تو حالا روی کلود فلیر اجرا میشه"
