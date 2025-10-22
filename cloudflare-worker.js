// کد بالا اینجا قرار می‌گیرد
// cloudflare-worker.js - نسخه سازگار
export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const pathname = url.pathname;

    // CORS headers
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };

    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    // Route handling
    if (pathname === '/') {
      return this.serveHomePage();
    } else if (pathname.startsWith('/payment/')) {
      return this.handlePayment(pathname);
    } else if (pathname === '/api/revenue') {
      return this.serveRevenueAPI(request);
    } else {
      return new Response('مسیر پیدا نشد', { 
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'text/plain; charset=utf-8' }
      });
    }
  },

  serveHomePage() {
    const html = `<!DOCTYPE html>
<html dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>Tetrashop - Cloudflare</title>
    <style>
        body { font-family: Tahoma; margin: 0; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }
        .container { max-width: 1200px; margin: 0 auto; background: rgba(255,255,255,0.1); padding: 30px; border-radius: 15px; }
        .button { background: #00d4aa; color: white; padding: 15px 25px; border: none; border-radius: 8px; cursor: pointer; margin: 8px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Tetrashop - روی Cloudflare</h1>
        <h3>💰 مستقر شده با سرعت جهانی</h3>
        
        <div style="text-align: center;">
            <button class="button" onclick="buyProduct('premium')">💎 پریمیوم - 29,000 تومان</button>
            <button class="button" onclick="buyProduct('template')">🛍️ قالب - 49,000 تومان</button>
        </div>

        <div id="stats" style="background: rgba(255,255,255,0.2); padding: 20px; border-radius: 10px; margin: 20px 0;">
            <p>🌍 میزبان: <strong>Cloudflare Global Network</strong></p>
            <p>⚡ سرعت: <strong>بهینه‌شده</strong></p>
        </div>
    </div>

    <script>
        function buyProduct(type) {
            const prices = { premium: 29000, template: 49000 };
            const names = { premium: 'عضویت پریمیوم', template: 'قالب حرفه‌ای' };
            
            if(confirm(`آیا مایل به خرید "${names[type]}" به مبلغ ${prices[type].toLocaleString()} تومان هستید؟`)) {
                alert('✅ پرداخت در Cloudflare ثبت شد!');
                fetch('/api/revenue', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ product: type, amount: prices[type] })
                });
            }
        }

        // آپدیت آمار
        setInterval(() => {
            fetch('/api/revenue')
                .then(r => r.json())
                .then(data => {
                    document.getElementById('stats').innerHTML = `
                        <p>👥 بازدیدکنندگان: <strong>${data.visitors}</strong></p>
                        <p>💰 فروش: <strong>${data.sales} مورد</strong></p>
                        <p>🎯 درآمد: <strong>${data.revenue} تومان</strong></p>
                    `;
                });
        }, 5000);
    </script>
</body>
</html>`;

    return new Response(html, {
      headers: { 
        'Content-Type': 'text/html; charset=utf-8',
        'Access-Control-Allow-Origin': '*'
      }
    });
  },

  async handlePayment(pathname) {
    const productType = pathname.split('/')[2];
    
    const response = {
      status: 'success',
      message: 'پرداخت در Cloudflare ثبت شد',
      product: productType,
      trackingId: Math.random().toString(36).substr(2, 9).toUpperCase(),
      timestamp: new Date().toISOString()
    };

    return new Response(JSON.stringify(response, null, 2), {
      headers: { 
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*'
      }
    });
  },

  async serveRevenueAPI(request) {
    // شبیه‌سازی داده‌ها
    const stats = {
      visitors: Math.floor(Math.random() * 1000) + 50,
      sales: Math.floor(Math.random() * 20) + 5,
      revenue: (Math.floor(Math.random() * 1000000) + 500000).toLocaleString()
    };

    if (request.method === 'POST') {
      // ذخیره داده‌های پرداخت (در واقعیت باید در KV ذخیره شود)
      console.log('پرداخت جدید ثبت شد');
    }

    return new Response(JSON.stringify(stats, null, 2), {
      headers: { 
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*'
      }
    });
  }
}
