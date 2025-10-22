#!/bin/bash

echo "☁️ استقرار روی Cloudflare"
echo "========================"

# بررسی وضعیت
if ! curl -s http://localhost:8080/api/system/status > /dev/null; then
    echo "❌ سرویس اصلی در حال اجرا نیست. اول اجرا کن: ./run.sh"
    exit 1
fi

echo "✅ سرویس اصلی فعال است"

# ایجاد فایل Worker بهینه
cat > cloudflare-worker.js << 'CFEOF'
export default {
    async fetch(request, env, ctx) {
        // آدرس API اصلی - این را با آدرس واقعی جایگزین کن
        // اگر لینک عمومی داری، جایگزین کن. در غیر این صورت بعداً در Dashboard جایگزین می‌کنی
        const API_BASE_URL = "REPLACE_WITH_YOUR_ACTUAL_URL";
        
        const url = new URL(request.url);
        const pathname = url.pathname;
        const method = request.method;
        
        // مسیرهای API
        const apiPaths = [
            '/api/system/status',
            '/api/products',
            '/api/orders', 
            '/api/users',
            '/api/inventory'
        ];
        
        // هندل کردن CORS
        if (method === 'OPTIONS') {
            return new Response(null, {
                headers: {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
                    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
                }
            });
        }
        
        // صفحه اصلی - اطلاعات API
        if (pathname === '/' || pathname === '') {
            return new Response(JSON.stringify({
                service: "Tetrashop API Gateway",
                version: "4.0",
                status: "active",
                message: "API در حال اجراست. برای اطلاعات بیشتر به مستندات مراجعه کنید.",
                endpoints: apiPaths,
                usage: "از endpoint های بالا استفاده کنید"
            }), {
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            });
        }
        
        // بررسی اگر مسیر API است
        const isApiPath = apiPaths.some(path => pathname.startsWith(path));
        
        if (!isApiPath) {
            return new Response(JSON.stringify({
                status: 'error',
                message: 'مسیر API یافت نشد',
                available_endpoints: apiPaths,
                help: 'برای اطلاعات بیشتر به / مراجعه کنید'
            }), {
                status: 404,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            });
        }
        
        try {
            const targetUrl = API_BASE_URL + pathname + url.search;
            const response = await fetch(targetUrl, {
                method: method,
                headers: request.headers,
                body: method !== 'GET' && method !== 'HEAD' ? await request.text() : undefined
            });
            
            const modifiedResponse = new Response(response.body, response);
            modifiedResponse.headers.set('Access-Control-Allow-Origin', '*');
            modifiedResponse.headers.set('Cache-Control', 'no-cache');
            
            return modifiedResponse;
            
        } catch (error) {
            return new Response(JSON.stringify({
                status: 'error',
                message: 'سرویس موقتاً در دسترس نیست',
                error: error.message,
                solution: 'آدرس API_BASE_URL را در cloudflare-worker.js بررسی کنید'
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
echo "📋 راهنمای استقرار:"
echo ""

if [ -f ".public_url" ]; then
    ACTUAL_URL=$(cat .public_url)
    echo "🎯 لینک عمومی شما: $ACTUAL_URL"
    echo ""
    echo "مراحل:"
    echo "1. فایل cloudflare-worker.js را باز کن"
    echo "2. این خط را پیدا کن:"
    echo "   const API_BASE_URL = \"REPLACE_WITH_YOUR_ACTUAL_URL\";"
    echo "3. با لینک زیر جایگزین کن:"
    echo "   const API_BASE_URL = \"$ACTUAL_URL\";"
else
    echo "⚠️ لینک عمومی موجود نیست"
    echo "می‌توانی همین حالا استقرار کنی و بعداً آدرس را جایگزین کنی:"
    echo ""
    echo "یا اول لینک عمومی بگیر:"
    echo "./run.sh"
fi

echo ""
echo "4. به https://dash.cloudflare.com برو"
echo "5. Workers & Pages → Create Worker"
echo "6. کل محتوای cloudflare-worker.js را کپی کن"
echo "7. در ادیتور Cloudflare پیست کن"
echo "8. Save and Deploy را بزن"
echo ""
echo "🎉 کار تمام است! API تو روی Cloudflare اجرا می‌شه"
echo ""
echo "💡 نکته: بعد از استقرار، می‌توانی آدرس worker.dev خودت رو تست کنی"
