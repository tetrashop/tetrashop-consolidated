# 🚀 راهنمای استقرار کامل تتراشاپ

## معماری سیستم


## مراحل استقرار

### مرحله ۱: راه‌اندازی محلی (Termux)
```bash
# دادن دسترسی اجرا
chmod +x tetrashop-manager.sh quick-cloudflare-deploy.sh

# راه‌اندازی سیستم
./tetrashop-manager.sh start

# تست سلامت
./tetrashop-manager.sh test
./quick-cloudflare-deploy.sh
# راه‌اندازی مجدد
./tetrashop-manager.sh restart

# یا فقط سرویس اصلی
python tetrashop_orchestrator.py
cd /data/data/com.termux/files/home/tetrashop-consolidated

# پاکسازی فایل‌های قبلی
rm -f tetrashop-manager.sh quick-cloudflare-deploy.sh system-config.json DEPLOYMENT_GUIDE.md

# ایجاد سیستم مدیریت کاملاً جدید
cat > tetrashop-manager.sh << 'EOF'
#!/bin/bash

echo "🕋 بسم الله الرحمن الرحیم"
echo "🚀 مدیر یکپارچه تتراشاپ v2.0"
echo "============================="

# متغیرهای اصلی
MAIN_API="tetrashop_orchestrator.py"
PORT=8080
LOG_FILE="tetrashop.log"

# رنگ‌های خروجی
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# تابع نمایش پیام
log_info() { echo -e "${BLUE}ℹ️ $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# تابع بررسی وضعیت
check_system_status() {
    log_info "بررسی وضعیت سیستم..."
    
    # بررسی سرویس اصلی
    if pgrep -f "$MAIN_API" > /dev/null; then
        log_success "سرویس اصلی در حال اجراست (PID: $(pgrep -f "$MAIN_API"))"
    else
        log_error "سرویس اصلی متوقف است"
        return 1
    fi
    
    # بررسی پورت
    if netstat -tulpn 2>/dev/null | grep ":$PORT" > /dev/null; then
        log_success "پورت $PORT باز است"
    else
        log_error "پورت $PORT بسته است"
        return 1
    fi
    
    # تست API
    if curl -s -m 5 "http://localhost:$PORT/api/system/status" > /dev/null; then
        log_success "API پاسخ می‌دهد"
        curl -s "http://localhost:$PORT/api/system/status" | python -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print('📊 سرویس‌های سالم: {}/{}'.format(data.get('healthy_services', 0), data.get('total_services', 0)))
    print('🕒 زمان: {}'.format(data.get('timestamp', 'unknown')))
except Exception as e:
    print('⚠️ خطا در خواندن پاسخ API: {}'.format(e))
"
    else
        log_error "API پاسخ نمی‌دهد"
        return 1
    fi
    return 0
}

# تابع راه‌اندازی سرویس
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

# تابع راه‌اندازی Ngrok
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

# تابع استقرار Cloudflare
deploy_cloudflare() {
    log_info "آماده‌سازی برای Cloudflare..."
    
    # ایجاد فایل Worker
    cat > "cloudflare-worker.js" << 'WORKEREOF'
export default {
    async fetch(request, env, ctx) {
        // این آدرس باید با لینک Ngrok جایگزین شود
        const ORIGIN_API = "YOUR_NGROK_URL_HERE";
        
        const url = new URL(request.url);
        const path = url.pathname;
        const method = request.method;
        
        // هندل کردن CORS
        if (method === 'OPTIONS') {
            return new Response(null, {
                headers: {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
                    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
                }
            });
        }
        
        // روت‌های API
        const apiRoutes = {
            '/api/system/status': '/api/system/status',
            '/api/products': '/api/products', 
            '/api/orders': '/api/orders',
            '/api/users': '/api/users',
            '/api/inventory': '/api/inventory'
        };
        
        // پیدا کردن مسیر
        let targetPath = apiRoutes[path] || path;
        
        try {
            const response = await fetch(ORIGIN_API + targetPath, {
                method: method,
                headers: request.headers,
                body: method !== 'GET' && method !== 'HEAD' ? await request.text() : undefined,
            });
            
            const modifiedResponse = new Response(response.body, response);
            modifiedResponse.headers.set('Access-Control-Allow-Origin', '*');
            modifiedResponse.headers.set('Cache-Control', 'no-cache');
            
            return modifiedResponse;
            
        } catch (error) {
            return new Response(JSON.stringify({
                status: 'error',
                message: 'سرویس موقتاً در دسترس نیست',
                error: error.message
            }), {
                status: 503,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            });
        }
    }
}
WORKEREOF

    # ایجاد پیکربندی
    cat > "wrangler.toml" << 'WRANGLEREOF'
name = "tetrashop-api"
compatibility_date = "2024-01-01"
compatibility_flags = ["nodejs_compat"]

[env.production]
workers_dev = true
WRANGLEREOF

    log_success "فایل‌های Cloudflare ایجاد شدند"
    echo ""
    log_info "📋 مراحل استقرار:"
    echo "1. لینک Ngrok را در فایل cloudflare-worker.js جایگزین کن"
    echo "2. به آدرس dash.cloudflare.com برو"
    echo "3. Workers & Pages → Create Worker"
    echo "4. کد cloudflare-worker.js را کپی کن"
    echo "5. Deploy را بزن"
    echo ""
    log_info "🎯 لینک Ngrok تو: $(cat .public_url 2>/dev/null || echo 'اول start را اجرا کن')"
}

# تابع نمایش وضعیت
show_status() {
    echo ""
    log_info "📊 وضعیت فعلی سیستم:"
    echo "===================="
    
    # وضعیت سرویس اصلی
    if [ -f ".main_pid" ] && ps -p $(cat ".main_pid") > /dev/null; then
        log_success "سرویس اصلی: فعال"
    else
        log_error "سرویس اصلی: غیرفعال"
    fi
    
    # وضعیت Ngrok
    if [ -f ".ngrok_pid" ] && ps -p $(cat ".ngrok_pid") > /dev/null; then
        log_success "Ngrok: فعال"
        if [ -f ".public_url" ]; then
            log_info "لینک عمومی: $(cat ".public_url")"
        fi
    else
        log_error "Ngrok: غیرفعال"
    fi
    
    # تست API
    if curl -s -m 3 "http://localhost:$PORT/api/system/status" > /dev/null; then
        log_success "API محلی: پاسخگو"
    else
        log_error "API محلی: غیرپاسخگو"
    fi
}

# تابع متوقف کردن
stop_services() {
    log_info "توقف سرویس‌ها..."
    pkill -f "$MAIN_API" 2>/dev/null
    pkill ngrok 2>/dev/null
    rm -f ".main_pid" ".ngrok_pid" ".public_url"
    log_success "همه سرویس‌ها متوقف شدند"
}

# مدیریت آرگومان‌ها
case "$1" in
    "start")
        if start_services; then
            start_ngrok
            show_status
        else
            log_error "خطا در راه‌اندازی سرویس‌ها"
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
            log_error "سیستم آماده استقرار نیست. اول './tetrashop-manager.sh start' را اجرا کن"
        fi
        ;;
    "test")
        check_system_status
        ;;
    *)
        echo "🔧使用方法:"
        echo "  ./tetrashop-manager.sh start    - راه‌اندازی سیستم"
        echo "  ./tetrashop-manager.sh stop     - توقف سیستم"
        echo "  ./tetrashop-manager.sh restart  - راه‌اندازی مجدد"
        echo "  ./tetrashop-manager.sh status   - نمایش وضعیت"
        echo "  ./tetrashop-manager.sh test     - تست سلامت"
        echo "  ./tetrashop-manager.sh deploy   - آماده‌سازی استقرار Cloudflare"
        echo ""
        echo "📞 برای کمک: سیستم لاگ در $LOG_FILE"
        ;;
esac

echo ""
log_info "مدیر یکپارچه تتراشاپ - ما شالله برکت داشته باشد"
