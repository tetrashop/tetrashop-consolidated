import http from 'http';

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ message: 'Tetrashop API Server' }));
});

server.listen(3001, () => {
  console.log('Backend server running on port 3001');
});
