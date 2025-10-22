#!/bin/bash

echo "📊 وضعیت لحظه‌ای تتراشاپ"
echo "========================"

# رنگ‌ها
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# بررسی سرویس اصلی
if [ -f ".main_pid" ] && ps -p $(cat ".main_pid") > /dev/null; then
    echo -e "${GREEN}✅ سرویس اصلی: فعال${NC}"
else
    echo -e "${RED}❌ سرویس اصلی: غیرفعال${NC}"
fi

# بررسی LocalTunnel
if [ -f ".lt_pid" ] && ps -p $(cat ".lt_pid") > /dev/null; then
    echo -e "${GREEN}✅ LocalTunnel: فعال${NC}"
    if [ -f ".public_url" ]; then
        echo -e "${BLUE}🌐 لینک عمومی: $(cat .public_url)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ LocalTunnel: غیرفعال${NC}"
fi

# تست API
echo -e "${BLUE}🧪 تست API...${NC}"
curl -s -m 5 http://localhost:8080/api/system/status | python -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print('✅ API پاسخ می‌دهد:')
    print(f'   وضعیت: {data.get(\"status\", \"unknown\")}')
    print(f'   سرویس‌ها: {data.get(\"healthy_services\", 0)}/{data.get(\"total_services\", 0)}')
    
    services = data.get('services', {})
    if services:
        print('   سرویس‌های فعال:')
        for service, status in services.items():
            print(f'     - {service}: {status}')
            
except Exception as e:
    print('❌ API پاسخ نمی‌دهد')
    print(f'   خطا: {e}')
"

echo ""
echo -e "${BLUE}🔗 آدرس‌های مهم:${NC}"
echo "   محلی: http://localhost:8080"
if [ -f ".public_url" ]; then
    echo "   عمومی: $(cat .public_url)"
fi
