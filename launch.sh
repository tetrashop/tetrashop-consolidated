#!/bin/bash

echo "🕋 بسم الله الرحمن الرحیم"
echo "🚀 راه‌اندازی کامل تتراشاپ v3.0"
echo "================================"

# رنگ‌ها
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}📝 $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

# بررسی پیش‌نیازها
log "بررسی پیش‌نیازها..."

if ! command -v python &> /dev/null; then
    error "پایتون نصب نیست. نصب کن: pkg install python"
    exit 1
fi

if [ ! -f "tetrashop_orchestrator.py" ]; then
    error "فایل اصلی tetrashop_orchestrator.py پیدا نشد"
    exit 1
fi

success "پیش‌نیازها بررسی شدند"

# آزاد کردن پورت 8080
log "آزاد کردن پورت 8080..."
fuser -k 8080/tcp 2>/dev/null
sleep 2

# راه‌اندازی سرویس اصلی
log "راه‌اندازی سرویس اصلی تتراشاپ..."
python tetrashop_orchestrator.py > tetrashop.log 2>&1 &
MAIN_PID=$!
echo $MAIN_PID > .main_pid

# منتظر راه‌اندازی
log "منتظر راه‌اندازی سرویس..."
for i in {1..20}; do
    if curl -s http://localhost:8080/api/system/status > /dev/null; then
        success "سرویس اصلی پس از $i ثانیه راه‌اندازی شد"
        break
    fi
    sleep 1
    if [ $i -eq 20 ]; then
        error "تایم‌اوت در راه‌اندازی سرویس"
        echo "📋 لاگ خطاها:"
        tail -n 20 tetrashop.log
        exit 1
    fi
done

# تست کامل API
log "تست کامل API..."
curl -s http://localhost:8080/api/system/status | python -c "
import json, sys, datetime
try:
    data = json.load(sys.stdin)
    print('${GREEN}✅ وضعیت سیستم:${NC}')
    print(f'   وضعیت: {data.get(\"status\", \"unknown\")}')
    print(f'   سرویس‌های سالم: {data.get(\"healthy_services\", 0)}/{data.get(\"total_services\", 0)}')
    print(f'   زمان: {data.get(\"timestamp\", \"unknown\")}')
    
    # بررسی جزئیات سرویس‌ها
    services = data.get('services', {})
    if services:
        print('${BLUE}🔍 سرویس‌های فعال:${NC}')
        for service, status in services.items():
            print(f'   - {service}: {status}')
    else:
        print('${YELLOW}⚠️ هیچ سرویسی گزارش نشده${NC}')
        
except Exception as e:
    print(f'${RED}❌ خطا در تست API: {e}${NC}')
"

# راه‌اندازی LocalTunnel (جایگزین Ngrok)
log "راه‌اندازی LocalTunnel..."
npx localtunnel --port 8080 > .localtunnel.log 2>&1 &
LT_PID=$!
echo $LT_PID > .lt_pid

log "منتظر لینک عمومی (15 ثانیه)..."
sleep 15

# دریافت لینک
if [ -f ".localtunnel.log" ]; then
    LT_URL=$(grep -o "https://.*\.loca\.lt" .localtunnel.log | head -1)
    if [ ! -z "$LT_URL" ]; then
        success "لینک عمومی: $LT_URL"
        echo "$LT_URL" > .public_url
        
        # تست لینک عمومی
        log "تست لینک عمومی..."
        curl -s "$LT_URL/api/system/status" | python -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print('${GREEN}✅ لینک عمومی کار می‌کند!${NC}')
    print(f'   وضعیت: {data.get(\"status\", \"unknown\")}')
except:
    print('${YELLOW}⚠️ لینک عمومی پاسخ نمی‌دهد${NC}')
"
    else
        warning "LocalTunnel لینک تولید نکرد"
    fi
fi

# نمایش وضعیت نهایی
echo ""
success "🎉 راه‌اندازی کامل شد!"
echo ""
echo "${BLUE}📊 وضعیت سیستم:${NC}"
echo "   ${GREEN}✅ سرویس اصلی:${NC} فعال (PID: $MAIN_PID)"
echo "   ${GREEN}🌐 API محلی:${NC} http://localhost:8080"

if [ -f ".public_url" ]; then
    echo "   ${GREEN}🌍 لینک عمومی:${NC} $(cat .public_url)"
else
    echo "   ${YELLOW}⚠️ لینک عمومی:${NC} در دسترس نیست"
fi

echo ""
echo "${BLUE}🎯 دستورات مفید:${NC}"
echo "   وضعیت: ./status.sh"
echo "   توقف: ./stop.sh"
echo "   استقرار: ./deploy.sh"
echo "   دیباگ: ./debug.sh"

echo ""
echo "${GREEN}🕋 ما شالله سیستم پربرکت باشد!${NC}"
