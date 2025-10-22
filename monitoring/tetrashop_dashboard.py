import time
import psutil
from datetime import datetime

class TetrashopDashboard:
    def __init__(self, chess_engine=None, intelligent_writer=None, natiq_ai=None):
        self.chess = chess_engine
        self.writer = intelligent_writer
        self.natiq = natiq_ai
        self.start_time = time.time()
    
    def get_real_time_metrics(self):
        return {
            "chess_engine": {
                "active_games": self.chess.get_active_games_count() if self.chess else 0,
                "move_accuracy": self.chess.get_accuracy_metrics() if self.chess else {"accuracy": 0},
                "response_time": self.chess.get_response_time() if self.chess else {"avg_response_ms": 0}
            },
            "intelligent_writer": {
                "content_generated": self.writer.get_generation_stats() if self.writer else {"total_generated": 0},
                "quality_scores": self.writer.get_quality_metrics() if self.writer else {"score": 0},
                "seo_optimization": self.writer.get_seo_performance() if self.writer else {"score": 0}
            },
            "natiq_ai": {
                "synthesis_requests": self.natiq.get_request_stats() if self.natiq else {"total_requests": 0},
                "voice_quality": self.natiq.get_quality_metrics() if self.natiq else {"quality_score": 0},
                "processing_speed": self.natiq.get_processing_speed() if self.natiq else {"avg_processing_ms": 0}
            },
            "system_health": {
                "overall_uptime": self.get_uptime_percentage(),
                "resource_usage": self.get_resource_metrics(),
                "error_rates": self.get_error_rates()
            }
        }
    
    def get_uptime_percentage(self):
        uptime = time.time() - self.start_time
        return f"{(uptime / 3600):.2f} hours"
    
    def get_resource_metrics(self):
        return {
            "cpu_percent": psutil.cpu_percent(),
            "memory_usage": psutil.virtual_memory().percent,
            "disk_usage": psutil.disk_usage('/').percent
        }
    
    def get_error_rates(self):
        return {
            "chess_errors": 0,
            "writer_errors": 0,
            "natiq_errors": 0
        }

if __name__ == "__main__":
    dashboard = TetrashopDashboard()
    print("Dashboard created successfully")
