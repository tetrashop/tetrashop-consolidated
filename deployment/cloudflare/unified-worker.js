// محتوای کامل کد Worker اینجا قرار می‌گیرد
// کلودفلیر ورکر یکپارچه - کپی و پیست کن
export default {
    async fetch(request, env, ctx) {
        const router = new UnifiedRouter();
        const corsHeaders = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        };

        if (request.method === 'OPTIONS') {
            return new Response(null, { headers: corsHeaders });
        }

        try {
            const response = await router.route(request);
            const modifiedResponse = new Response(response.body, response);
            Object.entries(corsHeaders).forEach(([key, value]) => {
                modifiedResponse.headers.set(key, value);
            });
            return modifiedResponse;
        } catch (error) {
            return new Response(JSON.stringify({
                error: 'خطای سرور',
                message: error.message,
                timestamp: new Date().toISOString()
            }), { status: 500, headers: { 'Content-Type': 'application/json; charset=utf-8', ...corsHeaders } });
        }
    }
}

class UnifiedRouter {
    constructor() {
        this.routes = {
            '/': this.serveGateway.bind(this),
            '/shop': this.serveShop.bind(this),
            '/admin': this.serveAdmin.bind(this),
            '/api/status': this.serveSystemStatus.bind(this),
            '/api/revenue': this.serveRevenue.bind(this),
            '/api/products': this.serveProducts.bind(this),
            '/api/payment': this.handlePayment.bind(this)
        };
    }

    async route(request) {
        const url = new URL(request.url);
        const pathname = url.pathname;
        
        console.log(`📨 درخواست: ${request.method} ${pathname}`);

        for (const [route, handler] of Object.entries(this.routes)) {
            if (pathname === route || pathname.startsWith(route + '/')) {
                return await handler(request);
            }
        }
        
        return new Response(JSON.stringify({
            error: 'مسیر پیدا نشد',
            available_routes: Object.keys(this.routes),
            timestamp: new Date().toISOString()
        }), { status: 404, headers: { 'Content-Type': 'application/json; charset=utf-8' } });
    }

    serveGateway() {
        const html = `<!DOCTYPE html>
<html dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>🚀 Tetrashop - سیستم یکپارچه</title>
    <style>
        body { font-family: Tahoma; margin: 0; padding: 20px; 
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                color: white; text-align: center; }
        .container { max-width: 800px; margin: 50px auto; 
                     background: rgba(255,255,255,0.1); 
                     padding: 40px; border-radius: 15px; }
        .button { background: #00d4aa; color: white; padding: 15px 30px; 
                  border: none; border-radius: 8px; cursor: pointer; 
                  font-size: 18px; margin: 10px; }
        .status { background: rgba(255,255,255,0.2); padding: 20px; 
                  border-radius: 10px; margin: 20px 0; }
        .nav { display: flex; justify-content: center; gap: 10px; margin: 20px 0; flex-wrap: wrap; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Tetrashop - سیستم یکپارچه فعال شد!</h1>
        <div class="status">
            <h3>✅ وضعیت: فعال و یکپارچه</h3>
            <p>🎯 تمام کامپوننت‌ها با هم کار می‌کنند</p>
            <p>🌍 میزبان: Cloudflare Global Network</p>
            <p>🕒 زمان: ${new Date().toLocaleString('fa-IR')}</p>
        </div>
        
        <div class="nav">
            <button class="button" onclick="testSystem()">تست سیستم یکپارچه</button>
            <button class="button" onclick="loadShop()">ورود به فروشگاه</button>
            <button class="button" onclick="checkRevenue()">بررسی درآمد</button>
        </div>

        <div style="margin-top: 30px; text-align: left; background: rgba(255,255,255,0.15); padding: 20px; border-radius: 10px;">
            <h4>🎯 مسیرهای موجود در سیستم یکپارچه:</h4>
            <p><code>/</code> - صفحه اصلی (همین صفحه)</p>
            <p><code>/shop</code> - سیستم فروشگاه کامل</p>
            <p><code>/admin</code> - پنل مدیریت یکپارچه</p>
            <p><code>/api/status</code> - وضعیت لحظه‌ای سیستم</p>
            <p><code>/api/revenue</code> - اطلاعات درآمد زنده</p>
            <p><code>/api/products</code> - لیست محصولات</p>
            <p><code>/api/payment</code> - سیستم پرداخت</p>
        </div>
    </div>
    <script>
        function testSystem() {
            fetch('/api/status')
                .then(r => r.json())
                .then(data => {
                    alert('✅ سیستم یکپارچه کار می‌کند!\\nوضعیت: ' + data.status + '\\nورژن: ' + data.version);
                })
                .catch(err => {
                    alert('❌ خطا در سیستم: ' + err.message);
                });
        }
        
        function loadShop() {
            window.open('/shop', '_blank');
        }
        
        function checkRevenue() {
            fetch('/api/revenue')
                .then(r => r.json())
                .then(data => {
                    alert('💰 درآمد روزانه: ' + data.revenue.daily.toLocaleString() + ' تومان\\nرشد: ' + data.growth);
                });
        }
        
        // تست خودکار هنگام بارگذاری
        setTimeout(testSystem, 1000);
    </script>
</body>
</html>`;
        
        return new Response(html, { headers: { 'Content-Type': 'text/html; charset=utf-8' } });
    }

    serveShop() {
        const shopHtml = `<!DOCTYPE html>
<html dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>🛍️ فروشگاه Tetrashop - سیستم یکپارچه</title>
    <style>
        body { font-family: Tahoma; margin: 0; padding: 20px; 
                background: linear-gradient(135deg, #ff6b6b 0%, #feca57 100%); 
                color: #333; }
        .container { max-width: 1000px; margin: 0 auto; 
                     background: rgba(255,255,255,0.95); 
                     padding: 30px; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }
        .product { background: white; padding: 20px; margin: 15px 0; 
                   border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); 
                   border-right: 5px solid #00d4aa; }
        .button { background: #00d4aa; color: white; padding: 12px 20px; 
                  border: none; border-radius: 8px; cursor: pointer; 
                  margin: 5px; transition: all 0.3s; }
        .button:hover { background: #00b894; transform: translateY(-2px); }
        .header { text-align: center; margin-bottom: 30px; }
        .back-btn { background: #667eea; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <button class="button back-btn" onclick="window.history.back()">← بازگشت به صفحه اصلی</button>
        
        <div class="header">
            <h1>🛍️ فروشگاه Tetrashop - سیستم یکپارچه</h1>
            <p>✅ متصل به سیستم مرکزی - معماری یکپارچه</p>
        </div>
        
        <div id="products">
            <h3>🎯 محصولات موجود:</h3>
            <p>در حال بارگذاری محصولات از سیستم یکپارچه...</p>
        </div>
    </div>

    <script>
        // بارگذاری محصولات از API یکپارچه
        fetch('/api/products')
            .then(r => r.json())
            .then(products => {
                const container = document.getElementById('products');
                container.innerHTML = '<h3>🎯 محصولات موجود (' + products.length + ' مورد):</h3>';
                
                products.forEach(product => {
                    const productDiv = document.createElement('div');
                    productDiv.className = 'product';
                    productDiv.innerHTML = \`
                        <h4>\${product.name}</h4>
                        <p>💰 قیمت: <strong>\${product.price.toLocaleString()} تومان</strong></p>
                        <p>📦 موجودی: \${product.stock} عدد</p>
                        <button class="button" onclick="buyProduct(\${product.id}, '\${product.name}', \${product.price})">
                            🛒 خرید محصول
                        </button>
                    \`;
                    container.appendChild(productDiv);
                });
            })
            .catch(error => {
                document.getElementById('products').innerHTML = 
                    '<p style="color: red;">❌ خطا در بارگذاری محصولات: ' + error.message + '</p>';
            });

        function buyProduct(productId, productName, productPrice) {
            if(confirm('آیا مایل به خرید "' + productName + '" به مبلغ ' + productPrice.toLocaleString() + ' تومان هستید؟')) {
                fetch('/api/payment', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ 
                        productId: productId,
                        productName: productName,
                        amount: productPrice 
                    })
                })
                .then(r => r.json())
                .then(result => {
                    alert('✅ پرداخت موفق!\\nشماره پیگیری: ' + result.id + '\\n' + result.message);
                })
                .catch(error => {
                    alert('❌ خطا در پرداخت: ' + error.message);
                });
            }
        }
        
        // تست اتصال به سیستم مرکزی
        fetch('/api/status')
            .then(r => r.json())
            .then(status => {
                console.log('✅ متصل به سیستم یکپارچه:', status.system);
            });
    </script>
</body>
</html>`;
        
        return new Response(shopHtml, { headers: { 'Content-Type': 'text/html; charset=utf-8' } });
    }

    async serveAdmin() {
        const adminData = {
            system: 'Tetrashop Unified Admin Panel',
            status: 'active',
            timestamp: new Date().toISOString(),
            integrated: true,
            components: [
                { name: 'مدیریت کاربران', status: 'active', endpoint: '/admin/users' },
                { name: 'مدیریت محصولات', status: 'active', endpoint: '/admin/products' },
                { name: 'مدیریت سفارشات', status: 'active', endpoint: '/admin/orders' },
                { name: 'آنالیتیکس', status: 'active', endpoint: '/admin/analytics' },
                { name: 'سیستم پرداخت', status: 'active', endpoint: '/api/payment' }
            ],
            statistics: {
                total_users: 156,
                total_products: 5,
                total_orders: 89,
                total_revenue: 12500000,
                active_sessions: 23
            },
            performance: {
                response_time: '45ms',
                uptime: '99.9%',
                memory_usage: '64MB'
            }
        };
        
        return new Response(JSON.stringify(adminData, null, 2), {
            headers: { 'Content-Type': 'application/json; charset=utf-8' }
        });
    }

    serveSystemStatus() {
        const statusData = {
            timestamp: new Date().toISOString(),
            status: 'fully_integrated',
            system: 'Tetrashop Unified Architecture',
            version: '1.0.0',
            integrated_components: 7,
            components: {
                frontend: { 
                    status: 'active', 
                    version: '1.0.0',
                    features: ['gateway', 'shop', 'admin', 'dashboard'],
                    integrated: true
                },
                backend: { 
                    status: 'active', 
                    version: '1.0.0',
                    features: ['api', 'payment', 'inventory', 'auth'],
                    integrated: true
                },
                services: { 
                    status: 'active', 
                    version: '1.0.0',
                    features: ['notification', 'analytics', 'storage'],
                    integrated: true
                }
            },
            performance: {
                uptime: '99.9%',
                response_time: '45ms',
                active_users: 156,
                requests_24h: 1245,
                integrated: true
            },
            message: '✅ تمام سیستم‌ها یکپارچه و فعال هستند'
        };
        
        return new Response(JSON.stringify(statusData, null, 2), {
            headers: { 'Content-Type': 'application/json; charset=utf-8' }
        });
    }

    serveRevenue() {
        const revenueData = {
            timestamp: new Date().toISOString(),
            period: 'daily',
            revenue: {
                daily: Math.floor(Math.random() * 1000000) + 500000,
                weekly: Math.floor(Math.random() * 5000000) + 2000000,
                monthly: Math.floor(Math.random() * 20000000) + 10000000
            },
            currency: 'تومان',
            growth: '+15.2%',
            integrated: true
        };
        
        return new Response(JSON.stringify(revenueData, null, 2), {
            headers: { 'Content-Type': 'application/json; charset=utf-8' }
        });
    }

    serveProducts() {
        const products = [
            { id: 1, name: '💎 عضویت پریمیوم', price: 29000, category: 'subscription', stock: 50 },
            { id: 2, name: '🛍️ قالب حرفه‌ای', price: 49000, category: 'template', stock: 25 },
            { id: 3, name: '📚 دوره آموزشی', price: 79000, category: 'course', stock: 30 },
            { id: 4, name: '🎯 مشاوره تخصصی', price: 99000, category: 'consulting', stock: 15 },
            { id: 5, name: '🚀 سیستم یکپارچه', price: 149000, category: 'system', stock: 10 }
        ];
        
        return new Response(JSON.stringify(products, null, 2), {
            headers: { 'Content-Type': 'application/json; charset=utf-8' }
        });
    }

    async handlePayment(request) {
        if (request.method === 'POST') {
            try {
                const body = await request.json();
                const paymentData = {
                    id: 'TRX-' + Math.random().toString(36).substr(2, 9).toUpperCase(),
                    productId: body.productId,
                    productName: body.productName,
                    amount: body.amount || 29000,
                    status: 'completed',
                    timestamp: new Date().toISOString(),
                    message: 'پرداخت با موفقیت ثبت شد',
                    integrated: true,
                    system: 'Tetrashop Unified Payment'
                };
                
                // شبیه‌سازی ذخیره در سیستم یکپارچه
                console.log('💳 پرداخت ثبت شد:', paymentData);
                
                return new Response(JSON.stringify(paymentData, null, 2), {
                    headers: { 'Content-Type': 'application/json; charset=utf-8' }
                });
            } catch (error) {
                return new Response(JSON.stringify({
                    error: 'خطا در پردازش پرداخت',
                    message: error.message,
                    integrated: false
                }), {
                    status: 400,
                    headers: { 'Content-Type': 'application/json; charset=utf-8' }
                });
            }
        }
        
        return new Response(JSON.stringify({
            message: 'سیستم پرداخت Tetrashop - یکپارچه',
            status: 'active',
            integrated: true,
            supported_methods: ['POST']
        }), {
            headers: { 'Content-Type': 'application/json; charset=utf-8' }
        });
    }
}
// (همان کد کامل 400 خطی که دادم)
