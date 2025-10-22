const http = require('http');

let total = 0;
let sales = 0;

console.log('🚀 شروع سیستم درآمدزایی...');

const server = http.createServer((req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Content-Type', 'application/json');
    
    console.log('📨 درخواست:', req.method, req.url);
    
    if (req.url === '/api/stats') {
        res.end(JSON.stringify({ totalRevenue: total, totalSales: sales }));
    }
    else if (req.url === '/api/sell' && req.method === 'POST') {
        total += 29000;
        sales += 1;
        console.log('💰 فروش جدید! درآمد کل:', total);
        res.end(JSON.stringify({ success: true, total: total }));
    }
    else {
        res.end(JSON.stringify({ message: 'سیستم فعال است' }));
    }
});

server.listen(3000, '0.0.0.0', () => {
    console.log('✅ سیستم درآمدزایی فعال شد!');
    console.log('📍 پورت: 3000');
});

server.on('error', (err) => {
    console.log('❌ خطا:', err.message);
});
