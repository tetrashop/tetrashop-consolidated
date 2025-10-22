from flask import Flask, jsonify
import requests
import time
import threading

app = Flask(__name__)

class VisualStatusChecker:
    def __init__(self):
        self.services = {
            "intelligent_writer": {"url": "http://localhost:5001", "port": 5001, "status": "checking", "response_time": 0},
            "chess_engine": {"url": "http://localhost:8765", "port": 8765, "status": "checking", "response_time": 0},
            "natiq_ai": {"url": "http://localhost:8000", "port": 8000, "status": "checking", "response_time": 0},
            "main_dashboard": {"url": "http://localhost:3000", "port": 3000, "status": "checking", "response_time": 0},
            "orchestrator": {"url": "http://localhost:8080", "port": 8080, "status": "checking", "response_time": 0}
        }
        self.last_update = time.time()
    
    def check_all_services(self):
        for service_name, service_info in self.services.items():
            try:
                start_time = time.time()
                response = requests.get(f"{service_info['url']}/health", timeout=5)
                response_time = round((time.time() - start_time) * 1000, 2)
                
                if response.status_code == 200:
                    self.services[service_name]["status"] = "healthy"
                    self.services[service_name]["response_time"] = response_time
                    self.services[service_name]["details"] = response.json()
                else:
                    self.services[service_name]["status"] = "unhealthy"
                    self.services[service_name]["response_time"] = response_time
            except Exception as e:
                self.services[service_name]["status"] = "offline"
                self.services[service_name]["response_time"] = 0
                self.services[service_name]["error"] = str(e)
        
        self.last_update = time.time()
    
    def get_visual_status(self):
        healthy_count = sum(1 for s in self.services.values() if s["status"] == "healthy")
        total_count = len(self.services)
        
        return {
            "overall_status": "fully_operational" if healthy_count == total_count else "partially_operational",
            "healthy_services": healthy_count,
            "total_services": total_count,
            "services": self.services,
            "last_updated": time.strftime("%Y-%m-%d %H:%M:%S"),
            "uptime": f"{(time.time() - self.start_time) / 3600:.2f} hours"
        }

status_checker = VisualStatusChecker()
status_checker.start_time = time.time()

# بررسی اولیه
status_checker.check_all_services()

# بروزرسانی خودکار هر 15 ثانیه
def auto_update():
    while True:
        status_checker.check_all_services()
        time.sleep(15)

update_thread = threading.Thread(target=auto_update)
update_thread.daemon = True
update_thread.start()

@app.route('/')
def visual_dashboard():
    status = status_checker.get_visual_status()
    
    # HTML با طراحی زیبا
    html = f'''
    <!DOCTYPE html>
    <html lang="fa">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>🚀 Tetrashop - Visual Status Dashboard</title>
        <style>
            * {{
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }}
            body {{
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                padding: 20px;
            }}
            .container {{
                max-width: 1200px;
                margin: 0 auto;
            }}
            .header {{
                text-align: center;
                color: white;
                margin-bottom: 30px;
                padding: 20px;
                background: rgba(255,255,255,0.1);
                border-radius: 15px;
                backdrop-filter: blur(10px);
            }}
            .header h1 {{
                font-size: 2.5em;
                margin-bottom: 10px;
            }}
            .status-summary {{
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 20px;
                margin-bottom: 30px;
            }}
            .summary-card {{
                background: white;
                padding: 25px;
                border-radius: 15px;
                text-align: center;
                box-shadow: 0 10px 30px rgba(0,0,0,0.2);
                transition: transform 0.3s ease;
            }}
            .summary-card:hover {{
                transform: translateY(-5px);
            }}
            .summary-card.healthy {{
                border-left: 5px solid #10b981;
            }}
            .summary-card.warning {{
                border-left: 5px solid #f59e0b;
            }}
            .summary-card.critical {{
                border-left: 5px solid #ef4444;
            }}
            .services-grid {{
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                gap: 20px;
            }}
            .service-card {{
                background: white;
                padding: 20px;
                border-radius: 12px;
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            }}
            .service-header {{
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 15px;
            }}
            .service-name {{
                font-weight: bold;
                font-size: 1.2em;
            }}
            .status-badge {{
                padding: 5px 12px;
                border-radius: 20px;
                font-size: 0.9em;
                font-weight: bold;
            }}
            .status-healthy {{
                background: #10b981;
                color: white;
            }}
            .status-unhealthy {{
                background: #ef4444;
                color: white;
            }}
            .status-offline {{
                background: #6b7280;
                color: white;
            }}
            .service-details {{
                color: #6b7280;
                font-size: 0.9em;
            }}
            .response-time {{
                margin-top: 10px;
                padding: 8px;
                background: #f3f4f6;
                border-radius: 6px;
                text-align: center;
                font-weight: bold;
            }}
            .last-updated {{
                text-align: center;
                color: white;
                margin-top: 30px;
                opacity: 0.8;
            }}
            .api-test-buttons {{
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 10px;
                margin-top: 20px;
            }}
            .test-button {{
                padding: 10px;
                background: #3b82f6;
                color: white;
                border: none;
                border-radius: 6px;
                cursor: pointer;
                transition: background 0.3s;
            }}
            .test-button:hover {{
                background: #2563eb;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🚀 Tetrashop Status Dashboard</h1>
                <p>Real-time Service Monitoring</p>
            </div>
            
            <div class="status-summary">
                <div class="summary-card {('healthy' if status['overall_status'] == 'fully_operational' else 'warning' if status['healthy_services'] > 0 else 'critical')}">
                    <h2>📊 Overall Status</h2>
                    <p style="font-size: 2em; font-weight: bold; margin: 10px 0;">
                        {status['healthy_services']}/{status['total_services']}
                    </p>
                    <p>{status['overall_status'].replace('_', ' ').title()}</p>
                </div>
                
                <div class="summary-card">
                    <h2>🕒 Uptime</h2>
                    <p style="font-size: 1.5em; font-weight: bold; margin: 10px 0;">
                        {status['uptime']}
                    </p>
                    <p>System Running</p>
                </div>
                
                <div class="summary-card">
                    <h2>🔄 Last Check</h2>
                    <p style="font-size: 1.2em; font-weight: bold; margin: 10px 0;">
                        {status['last_updated']}
                    </p>
                    <p>Auto-refresh: 15s</p>
                </div>
            </div>
            
            <div class="services-grid">
    '''
    
    # اضافه کردن کارت هر سرویس
    for service_name, service_info in status['services'].items():
        status_class = f"status-{service_info['status']}"
        status_text = service_info['status'].title()
        
        html += f'''
                <div class="service-card">
                    <div class="service-header">
                        <div class="service-name">
                            {service_name.replace('_', ' ').title()}
                        </div>
                        <div class="status-badge {status_class}">
                            {status_text}
                        </div>
                    </div>
                    <div class="service-details">
                        <p><strong>Port:</strong> {service_info['port']}</p>
                        <p><strong>URL:</strong> {service_info['url']}</p>
                        {f'<p><strong>Response Time:</strong> {service_info["response_time"]}ms</p>' if service_info['response_time'] > 0 else ''}
                        {f'<p><strong>Error:</strong> {service_info.get("error", "")}</p>' if service_info['status'] == 'offline' else ''}
                    </div>
                    <div class="response-time">
                        {service_info['response_time']}ms response
                    </div>
                </div>
        '''
    
    html += '''
            </div>
            
            <div class="api-test-buttons">
                <button class="test-button" onclick="testAPI('content')">Test Content Generation</button>
                <button class="test-button" onclick="testAPI('chess')">Test Chess Engine</button>
                <button class="test-button" onclick="testAPI('status')">Test System Status</button>
            </div>
            
            <div class="last-updated">
                <p>Last Updated: ''' + status['last_updated'] + ''' | Auto-refreshing...</p>
            </div>
        </div>
        
        <script>
            // Auto-refresh page every 15 seconds
            setTimeout(() => {
                window.location.reload();
            }, 15000);
            
            function testAPI(type) {
                let url, data;
                
                switch(type) {
                    case 'content':
                        url = 'http://localhost:8080/api/orchestrate/content';
                        data = {
                            topic: 'Test from Dashboard',
                            content_type: 'مقاله وبلاگ',
                            style: 'رسمی',
                            generate_audio: false
                        };
                        break;
                    case 'chess':
                        url = 'http://localhost:8080/api/orchestrate/chess';
                        data = {
                            move: 'e2e4',
                            player: 'white'
                        };
                        break;
                    case 'status':
                        url = 'http://localhost:8080/api/system/status';
                        data = {};
                        break;
                }
                
                fetch(url, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: type === 'status' ? null : JSON.stringify(data)
                })
                .then(response => response.json())
                .then(data => {
                    alert('API Test Successful! Check console for details.');
                    console.log('API Response:', data);
                })
                .catch(error => {
                    alert('API Test Failed: ' + error.message);
                });
            }
        </script>
    </body>
    </html>
    '''
    
    return html

@app.route('/api/status')
def api_status():
    return jsonify(status_checker.get_visual_status())

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "service": "Visual Status Dashboard"})

if __name__ == '__main__':
    print("👁️ Visual Status Dashboard running on: http://localhost:3030")
    app.run(host='0.0.0.0', port=3030, debug=False)
