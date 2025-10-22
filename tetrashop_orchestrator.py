from flask import Flask, jsonify, request
import requests
import time

app = Flask(__name__)

class TetrashopOrchestrator:
    def __init__(self):
        self.services = {
            "writer": "http://localhost:5001",
            "chess": "http://localhost:8765", 
            "natiq": "http://localhost:8000"
        }
    
    def unified_content_workflow(self, topic, content_type="مقاله وبلاگ", style="رسمی", generate_audio=True):
        """گردش کار یکپارچه: تولید محتوا → سنتز صدا"""
        try:
            # مرحله ۱: تولید محتوا
            content_response = requests.post(
                f"{self.services['writer']}/api/generate",
                json={"topic": topic, "content_type": content_type, "style": style},
                timeout=10
            )
            
            if content_response.status_code != 200:
                return {"error": "Content generation failed"}
            
            content_data = content_response.json()
            result = {"content_pipeline": content_data}
            
            # مرحله ۲: سنتز صدا (اختیاری)
            if generate_audio and "content" in content_data:
                audio_response = requests.post(
                    f"{self.services['natiq']}/api/synthesize",
                    json={"text": content_data["content"], "voice_type": "professional"},
                    timeout=10
                )
                
                if audio_response.status_code == 200:
                    result["audio_pipeline"] = audio_response.json()
            
            # مرحله ۳: جمع‌آوری متریک‌ها
            result["metrics"] = self.get_system_metrics()
            
            return result
            
        except Exception as e:
            return {"error": f"Workflow failed: {str(e)}"}
    
    def chess_analysis_workflow(self, move_data, analyze=True):
        """گردش کار تحلیل شطرنج"""
        try:
            # پردازش حرکت
            move_response = requests.post(
                f"{self.services['chess']}/api/move",
                json=move_data,
                timeout=10
            )
            
            result = {"chess_pipeline": move_response.json()}
            
            return result
            
        except Exception as e:
            return {"error": f"Chess workflow failed: {str(e)}"}
    
    def get_system_metrics(self):
        """جمع‌آوری متریک‌های تمام سرویس‌ها"""
        metrics = {}
        for service_name, service_url in self.services.items():
            try:
                response = requests.get(f"{service_url}/metrics", timeout=5)
                metrics[service_name] = response.json()
            except:
                metrics[service_name] = {"error": "Unavailable"}
        
        return metrics

orchestrator = TetrashopOrchestrator()

# API Endpoints
@app.route('/api/orchestrate/content', methods=['POST'])
def orchestrate_content():
    """API یکپارچه برای تولید محتوا و صدا"""
    data = request.get_json()
    result = orchestrator.unified_content_workflow(
        topic=data.get('topic', ''),
        content_type=data.get('content_type', 'مقاله وبلاگ'),
        style=data.get('style', 'رسمی'),
        generate_audio=data.get('generate_audio', True)
    )
    return jsonify(result)

@app.route('/api/orchestrate/chess', methods=['POST'])
def orchestrate_chess():
    """API یکپارچه برای شطرنج"""
    data = request.get_json()
    result = orchestrator.chess_analysis_workflow(data)
    return jsonify(result)

@app.route('/api/system/status')
def system_status():
    """وضعیت کلی سیستم"""
    metrics = orchestrator.get_system_metrics()
    return jsonify({
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "services": metrics,
        "status": "operational" if all(
            'error' not in metrics[service] 
            for service in ['writer', 'chess', 'natiq']
        ) else "degraded"
    })

@app.route('/health')
def health_check():
    return jsonify({"status": "healthy", "service": "Tetrashop Orchestrator"})

if __name__ == '__main__':
    print("🎯 Tetrashop Orchestrator running on: http://localhost:8080")
    app.run(host='0.0.0.0', port=8080, debug=False)
