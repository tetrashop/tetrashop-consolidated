#!/bin/bash

echo "🚀 راه‌اندازی فوری API"
echo "===================="

# پاکسازی
pkill -f "tetrashop_orchestrator.py" 2>/dev/null
sleep 1

# راه‌اندازی سرویس اصلی در پیش‌زمینه
echo "📦 اجرای سرویس اصلی..."
python tetrashop_orchestrator.py
