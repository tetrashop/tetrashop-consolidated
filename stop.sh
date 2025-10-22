#!/bin/bash

echo "🛑 توقف سرویس‌های تتراشاپ..."
pkill -f "tetrashop_orchestrator.py" 2>/dev/null
pkill ngrok 2>/dev/null
pkill node 2>/dev/null
rm -f .main_pid .ngrok_pid .lt_pid .public_url .current_port
echo "✅ همه سرویس‌ها متوقف شدند"
