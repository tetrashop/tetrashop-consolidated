#!/usr/bin/env python3
from http.server import HTTPServer, SimpleHTTPRequestHandler
import json

class APIHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/api/status':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            response = {
                "status": "operational",
                "message": "API is running locally",
                "timestamp": "2024-01-01 12:00:00",
                "services": {
                    "main": "active",
                    "database": "connected"
                }
            }
            self.wfile.write(json.dumps(response).encode())
        else:
            super().do_GET()

print("🚀 سرور ساده در حال اجرا روی پورت 8000...")
print("📱 برو به: http://localhost:8000/api/status")
httpd = HTTPServer(('localhost', 8000), APIHandler)
httpd.serve_forever()
