const http = require('http');
let revenue = { total: 0, sales: 0 };
const server = http.createServer((req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Content-Type', 'application/json');
    if (req.url === '/api/stats') {
        res.end(JSON.stringify(revenue));
    } else if (req.url === '/api/sell' && req.method === 'POST') {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            revenue.total += 29000;
            revenue.sales += 1;
            console.log("💰 فروش جدید! درآمد کل:", revenue.total);
            res.end(JSON.stringify({ success: true, total: revenue.total }));
        });
    } else {
        res.end(JSON.stringify({ message: "سیستم فعال است" }));
    }
});
server.listen(3000, () => {
    console.log('🚀 سیستم درآمدزایی: http://localhost:3000');
});
