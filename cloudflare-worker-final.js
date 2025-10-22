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
