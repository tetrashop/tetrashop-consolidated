#!/bin/bash

# متغیرهای اصلی
MAIN_API="tetrashop_orchestrator.py"
PORT=8080
LOG_FILE="tetrashop.log"

# رنگ‌ها
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️ $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

check_system_status() {
    log_info "بررسی وضعیت سیستم..."
    
    # بررسی سرویس اصلی
    if pgrep -f "$MAIN_API" > /dev/null; then
        log_success "سرویس اصلی در حال اجراست"
    else
        log_error "سرویس اصلی متوقف است"
        return 1
    fi
    
    # تست API
    if curl -s -m 5 "http://localhost:$PORT/api/system/status" > /dev/null; then
        log_success "API پاسخ می‌دهد"
        return 0
    else
        log_error "API پاسخ نمی‌دهد"
        return 1
    fi
}

start_services() {
    log_info "راه‌اندازی سرویس‌ها..."
    
    # توقف سرویس‌های قبلی
    pkill -f "$MAIN_API" 2>/dev/null
    pkill ngrok 2>/dev/null
    
    # راه‌اندازی سرویس اصلی
    log_info "اجرای سرویس اصلی..."
    python "$MAIN_API" > "$LOG_FILE" 2>&1 &
    echo $! > ".main_pid"
    
    # منتظر راه‌اندازی
    log_info "منتظر راه‌اندازی سرویس..."
    for i in {1..10}; do
        if curl -s "http://localhost:$PORT/api/system/status" > /dev/null; then
            log_success "سرویس اصلی پس از $i ثانیه راه‌اندازی شد"
            return 0
        fi
        sleep 1
    done
    log_error "تایم‌اوت در راه‌اندازی سرویس"
    return 1
}

start_ngrok() {
    log_info "راه‌اندازی Ngrok..."
    
    # بررسی نصب ngrok
    if ! command -v ngrok &> /dev/null; then
        log_warning "نصب Ngrok..."
        pkg install ngrok -y
    fi
    
    # راه‌اندازی ngrok
    pkill ngrok 2>/dev/null
    ngrok http $PORT > ".ngrok.log" 2>&1 &
    echo $! > ".ngrok_pid"
    
    # منتظر راه‌اندازی
    log_info "دریافت لینک عمومی..."
    for i in {1..15}; do
        NGROK_URL=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null | python -c "
import json, sys
try:
    data = json.load(sys.stdin)
    for tunnel in data['tunnels']:
        if tunnel['proto'] == 'https':
            print(tunnel['public_url'])
            break
except:
    pass
")
        
        if [ ! -z "$NGROK_URL" ]; then
            log_success "لینک عمومی: $NGROK_URL"
            echo "$NGROK_URL" > ".public_url"
            return 0
        fi
        sleep 1
    done
    log_error "تایم‌اوت در دریافت لینک Ngrok"
    return 1
}

deploy_cloudflare() {
    log_info "آماده‌سازی برای Cloudflare..."
    
    # ایجاد فایل Worker ساده
    cat > cloudflare-worker.js << 'CFEOF'
export default {
    async fetch(request) {
        const ORIGIN_API = "REPLACE_WITH_NGROK_URL";
        
        const url = new URL(request.url);
        const path = url.pathname;
        
        // روت‌های API
        const routes = {
            '/api/system/status': '/api/system/status',
            '/api/products': '/api/products',
            '/api/orders': '/api/orders',
            '/api/users': '/api/users',
            '/api/inventory': '/api/inventory'
        };
        
        let targetPath = routes[path] || path;
        
        try {
            const response = await fetch(ORIGIN_API + targetPath, {
                method: request.method,
                headers: request.headers,
            });
            
            const newResponse = new Response(response.body, response);
            newResponse.headers.set('Access-Control-Allow-Origin', '*');
            return newResponse;
            
        } catch (error) {
            return new Response(JSON.stringify({
                status: 'error',
                message: 'Service unavailable'
            }), {
                status: 503,
                headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }
            });
        }
    }
}
CFEOF

    log_success "فایل Cloudflare Worker ایجاد شد"
    echo ""
    log_info "📋 مراحل استقرار:"
    echo "1. لینک Ngrok فعلی: $(cat .public_url 2>/dev/null || echo 'نامشخص')"
    echo "2. فایل cloudflare-worker.js را باز کن"
    echo "3. REPLACE_WITH_NGROK_URL را با لینک Ngrok جایگزین کن"
    echo "4. به dash.cloudflare.com برو"
    echo "5. Workers & Pages → Create Worker"
    echo "6. کد را کپی کن و Deploy بزن"
}

show_status() {
    echo ""
    log_info "📊 وضعیت فعلی سیستم:"
    echo "===================="
    
    if [ -f ".main_pid" ] && ps -p $(cat ".main_pid") > /dev/null; then
        log_success "سرویس اصلی: فعال"
    else
        log_error "سرویس اصلی: غیرفعال"
    fi
    
    if [ -f ".ngrok_pid" ] && ps -p $(cat ".ngrok_pid") > /dev/null; then
        log_success "Ngrok: فعال"
        if [ -f ".public_url" ]; then
            log_info "لینک عمومی: $(cat ".public_url")"
        fi
    else
        log_error "Ngrok: غیرفعال"
    fi
}

stop_services() {
    log_info "توقف سرویس‌ها..."
    pkill -f "$MAIN_API" 2>/dev/null
    pkill ngrok 2>/dev/null
    rm -f ".main_pid" ".ngrok_pid" ".public_url"
    log_success "همه سرویس‌ها متوقف شدند"
}

# مدیریت دستورات
case "$1" in
    "start")
        echo "🕋 بسم الله الرحمن الرحیم"
        echo "🚀 مدیر تتراشاپ v2.0"
        if start_services; then
            start_ngrok
            show_status
        else
            log_error "خطا در راه‌اندازی"
            exit 1
        fi
        ;;
    "stop")
        stop_services
        ;;
    "status")
        show_status
        ;;
    "restart")
        stop_services
        sleep 2
        start_services
        start_ngrok
        show_status
        ;;
    "deploy")
        if check_system_status; then
            deploy_cloudflare
        else
            log_error "سیستم آماده نیست. اول start را اجرا کن"
        fi
        ;;
    "test")
        check_system_status
        ;;
    *)
        echo "🔧使用方法:"
        echo "  ./tetrashop-manager.sh start    - راه‌اندازی"
        echo "  ./tetrashop-manager.sh stop     - توقف"
        echo "  ./tetrashop-manager.sh status   - وضعیت"
        echo "  ./tetrashop-manager.sh deploy   - استقرار Cloudflare"
        echo "  ./tetrashop-manager.sh test     - تست سلامت"
        ;;
esac

echo ""
log_info "ما شالله برکت داشته باشد"
