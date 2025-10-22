from flask import Flask, jsonify
import threading
import time
import requests

app = Flask(__name__)

class DashboardService:
    def __init__(self):
        self.metrics_cache = {"status": "initializing"}
        self.update_interval = 10
        self.start_time = time.time()
        
    def start_background_updates(self):
        def update_loop():
            while True:
                try:
                    self.metrics_cache = self.collect_metrics()
                except Exception as e:
                    self.metrics_cache = {"error": str(e)}
                time.sleep(self.update_interval)
        
        thread = threading.Thread(target=update_loop)
        thread.daemon = True
        thread.start()
    
    def collect_metrics(self):
        services_data = {}
        service_status = {}
        
        # Intelligent Writer
        try:
            writer_response = requests.get("http://localhost:5001/metrics", timeout=3)
            services_data["intelligent_writer"] = writer_response.json()
            service_status["writer"] = "healthy"
        except:
            services_data["intelligent_writer"] = {"error": "Service unavailable"}
            service_status["writer"] = "unavailable"
        
        # Chess Engine
        try:
            chess_response = requests.get("http://localhost:8765/metrics", timeout=3)
            services_data["chess_engine"] = chess_response.json()
            service_status["chess"] = "healthy"
        except:
            services_data["chess_engine"] = {"error": "Service unavailable"}
            service_status["chess"] = "unavailable"
        
        # Natiq AI
        try:
            natiq_response = requests.get("http://localhost:8000/metrics", timeout=3)
            services_data["natiq_ai"] = natiq_response.json()
            service_status["natiq"] = "healthy"
        except:
            services_data["natiq_ai"] = {"error": "Service unavailable"}
            service_status["natiq"] = "unavailable"
        
        return {
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "services": services_data,
            "service_status": service_status,
            "system_health": {
                "overall_uptime": f"{(time.time() - self.start_time) / 3600:.2f} hours"
            }
        }

dashboard_service = DashboardService()
dashboard_service.start_background_updates()

@app.route('/metrics')
def get_metrics():
    return jsonify(dashboard_service.metrics_cache)

@app.route('/health')
def health_check():
    return jsonify({"status": "healthy", "service": "Tetrashop Dashboard"})

@app.route('/')
def dashboard_home():
    status = dashboard_service.metrics_cache.get('service_status', {})
    
    html = '''
    <html>
        <head>
            <title>Tetrashop Dashboard</title>
            <meta http-equiv="refresh" content="10">
            <style>
                body { font-family: Arial, sans-serif; margin: 20px; }
                .service { border: 1px solid #ddd; padding: 15px; margin: 10px 0; border-radius: 5px; }
                .healthy { background-color: #d4edda; border-left: 5px solid #28a745; }
                .unavailable { background-color: #f8d7da; border-left: 5px solid #dc3545; }
                .container { max-width: 800px; margin: 0 auto; }
                .status-badge { padding: 5px 10px; border-radius: 3px; color: white; }
                .healthy-badge { background-color: #28a745; }
                .unavailable-badge { background-color: #dc3545; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🚀 Tetrashop Monitoring Dashboard</h1>
                <p>Auto-refreshing every 10 seconds | Last update: ''' + dashboard_service.metrics_cache.get('timestamp', 'N/A') + '''</p>
                
                <div class="service ''' + ('healthy' if status.get('writer') == 'healthy' else 'unavailable') + '''">
                    <h3>🤖 Intelligent Writer</h3>
                    <span class="status-badge ''' + ('healthy-badge' if status.get('writer') == 'healthy' else 'unavailable-badge') + '''">
                        ''' + status.get('writer', 'unknown').upper() + '''
                    </span>
                    <p>Port: 5001 | <a href="http://localhost:5001/health" target="_blank">Health Check</a></p>
                </div>
                
                <div class="service ''' + ('healthy' if status.get('chess') == 'healthy' else 'unavailable') + '''">
                    <h3>♟️ Chess Engine</h3>
                    <span class="status-badge ''' + ('healthy-badge' if status.get('chess') == 'healthy' else 'unavailable-badge') + '''">
                        ''' + status.get('chess', 'unknown').upper() + '''
                    </span>
                    <p>Port: 8765 | <a href="http://localhost:8765/health" target="_blank">Health Check</a></p>
                </div>
                
                <div class="service ''' + ('healthy' if status.get('natiq') == 'healthy' else 'unavailable') + '''">
                    <h3>🗣️ Natiq AI</h3>
                    <span class="status-badge ''' + ('healthy-badge' if status.get('natiq') == 'healthy' else 'unavailable-badge') + '''">
                        ''' + status.get('natiq', 'unknown').upper() + '''
                    </span>
                    <p>Port: 8000 | <a href="http://localhost:8000/health" target="_blank">Health Check</a></p>
                </div>
                
                <div style="margin-top: 20px;">
                    <a href="/metrics" target="_blank">📊 View Raw Metrics</a> | 
                    <a href="/health">❤️ Health Check</a>
                </div>
            </div>
        </body>
    </html>
    '''
    return html

if __name__ == '__main__':
    print("📊 Tetrashop Dashboard running on: http://localhost:3000")
    app.run(host='0.0.0.0', port=3000, debug=False)
