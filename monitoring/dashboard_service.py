from flask import Flask, jsonify
import threading
import time
import requests
import psutil

app = Flask(__name__)

class DashboardService:
    def __init__(self):
        self.metrics_cache = {"status": "initializing"}
        self.update_interval = 10  # ثانیه
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
        
        # Intelligent Writer (5001)
        try:
            writer_response = requests.get("http://localhost:5001/metrics", timeout=3)
            services_data["intelligent_writer"] = writer_response.json()
            service_status["writer"] = "healthy"
        except:
            services_data["intelligent_writer"] = {"error": "Service unavailable"}
            service_status["writer"] = "unavailable"
        
        # Chess Engine (8765)
        try:
            chess_response = requests.get("http://localhost:8765/metrics", timeout=3)
            services_data["chess_engine"] = chess_response.json()
            service_status["chess"] = "healthy"
        except:
            services_data["chess_engine"] = {"error": "Service unavailable"}
            service_status["chess"] = "unavailable"
        
        # Natiq AI (8000)
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
                "overall_uptime": f"{(time.time() - self.start_time) / 3600:.2f} hours",
                "cpu_percent": psutil.cpu_percent(),
                "memory_usage": psutil.virtual_memory().percent,
                "disk_usage": psutil.disk_usage('/').percent
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
    return '''
    <html>
        <head>
            <title>Tetrashop Dashboard</title>
            <meta http-equiv="refresh" content="10">
            <style>
                body { font-family: Arial, sans-serif; margin: 20px; }
                .service { border: 1px solid #ddd; padding: 15px; margin: 10px 0; border-radius: 5px; }
                .healthy { background-color: #d4edda; }
                .unavailable { background-color: #f8d7da; }
            </style>
        </head>
        <body>
            <h1>🚀 Tetrashop Monitoring Dashboard</h1>
            <p>Auto-refreshing every 10 seconds</p>
            <div>
                <a href="/metrics">View Raw Metrics</a> | 
                <a href="/health">Health Check</a>
            </div>
        </body>
    </html>
    '''

if __name__ == '__main__':
    print("📊 Tetrashop Dashboard running on: http://localhost:3000")
    app.run(host='0.0.0.0', port=3000, debug=False)
