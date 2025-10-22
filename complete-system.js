const http = require('http');
const fs = require('fs');
const path = require('path');

// داده‌های درآمد
let revenue = {
    total: 0,
    sales: 0
};

// ایجاد سرور
const server = http.createServer((req, res) => {
    console.log('📨 درخواست:', req.method, req.url);
    
    // تنظیم هدرهای CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }
    
    if (req.url === '/' || req.url === '/shop.html') {
        // ارسال صفحه وب
        const html = `
<!DOCTYPE html>
<html dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>فروشگاه کامل</title>
    <style>
        body { 
            font-family: Tahoma; 
            margin: 20px; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            max-width: 500px;
            margin: 0 auto;
            background: rgba(255,255,255,0.1);
            padding: 30px;
            border-radius: 15px;
            backdrop-filter: blur(10px);
        }
        button {
            background: #28a745;
            color: white;
            padding: 15px 25px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 18px;
            margin: 10px 0;
            width: 100%;
        }
        button:hover {
            background: #218838;
        }
        .stats {
            background: rgba(255,255,255,0.2);
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            text-align: center;
        }
        .status {
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
            text-align: center;
        }
        .connected {
            background: rgba(40, 167, 69, 0.3);
            border: 2px solid #28a745;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🛍️ فروشگاه کامل</h1>
        
        <div id="status" class="status connected">
            ✅ سیستم فعال و متصل است
        </div>
        
        <div class="stats">
            <h3>📊 آمار زنده</h3>
            <p>درآمد کل: <strong><span id="money">0</span> تومان</strong></p>
            <p>تعداد فروش: <strong><span id="sales">0</span> مورد</strong></p>
        </div>
        
        <button onclick="makeSale()">
            💰 خرید محصول (29,000 تومان)
        </button>
    </div>

    <script>
        async function makeSale() {
            try {
                const response = await fetch('/api/sell', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({})
                });
                
                const result = await response.json();
                
                if (result.success) {
                    // بروزرسانی آمار
                    document.getElementById('money').textContent = result.total.toLocaleString();
                    document.getElementById('sales').textContent = result.sales;
                    
                    alert('✅ خرید موفق!\\n💰 درآمد کل: ' + result.total.toLocaleString() + ' تومان');
                }
            } catch (error) {
                alert('❌ خطا در خرید');
            }
        }
        
        // بارگذاری اولیه آمار
        fetch('/api/stats')
            .then(response => response.json())
            .then(data => {
                document.getElementById('money').textContent = data.total.toLocaleString();
                document.getElementById('sales').textContent = data.sales;
            });
            
        // بروزرسانی خودکار هر 2 ثانیه
        setInterval(() => {
            fetch('/api/stats')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('money').textContent = data.total.toLocaleString();
                    document.getElementById('sales').textContent = data.sales;
                });
        }, 2000);
    </script>
</body>
</html>`;
        
        res.writeHead(200, {'Content-Type': 'text/html; charset=utf-8'});
        res.end(html);
    }
    else if (req.url === '/api/stats') {
        // ارسال آمار
        res.writeHead(200, {'Content-Type': 'application/json'});
        res.end(JSON.stringify({
            total: revenue.total,
            sales: revenue.sales
        }));
    }
    else if (req.url === '/api/sell' && req.method === 'POST') {
        // پردازش فروش
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            revenue.total += 29000;
            revenue.sales += 1;
            
            console.log('💰 فروش جدید! درآمد کل:', revenue.total);
            
            res.writeHead(200, {'Content-Type': 'application/json'});
            res.end(JSON.stringify({
                success: true,
                total: revenue.total,
                sales: revenue.sales
            }));
        });
    }
    else {
        res.writeHead(404);
        res.end('صفحه یافت نشد');
    }
});

// راه‌اندازی سرور
const PORT = 8080;
server.listen(PORT, '0.0.0.0', () => {
    console.log('🚀 ================================');
    console.log('✅ سیستم کامل فروشگاه فعال شد!');
    console.log('📍 آدرس: http://localhost:' + PORT);
    console.log('💰 سیستم درآمدزایی: فعال');
    console.log('🛍️ صفحه فروش: فعال');
    console.log('🚀 ================================');
});

server.on('error', (err) => {
    console.log('❌ خطا در راه‌اندازی سرور:', err.message);
});
