#!/bin/bash

echo "☁️ استقرار سریع روی Cloudflare"
echo "============================="

# بررسی prerequisites
echo "🔍 بررسی پیش‌نیازها..."
if ! command -v git &> /dev/null; then
    echo "📥 نصب Git..."
    pkg install git -y
fi

# ایجاد ریپوی Git اگر وجود ندارد
if [ ! -d ".git" ]; then
    echo "📦 راه‌اندازی Git..."
    git init
    git config user.email "deploy@tetrashop.com"
    git config user.name "Tetrashop Deployer"
    git add .
    git commit -m "deploy: Tetrashop API v1.0.0"
    echo "✅ Git راه‌اندازی شد"
fi

# ایجاد فایل‌های استقرار
echo "📁 ایجاد فایل‌های استقرار..."

# ایجاد GitHub Actions برای Cloudflare
mkdir -p .github/workflows

cat > .github/workflows/cloudflare-deploy.yml << 'GH_EOF'
name: Deploy to Cloudflare Workers

on:
  push:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write
      
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          
      - name: Deploy to Cloudflare Workers
        uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          command: deploy
          workingDirectory: '.'
GH_EOF

# ایجاد package.json برای Cloudflare
cat > package.json << 'PKG_EOF'
{
  "name": "tetrashop-cloudflare-worker",
  "version": "1.0.0",
  "description": "Tetrashop API Gateway - Cloudflare Worker",
  "main": "cloudflare-worker-optimized.js",
  "scripts": {
    "deploy": "wrangler deploy",
    "dev": "wrangler dev"
  },
  "keywords": ["api", "gateway", "tetrashop"],
  "author": "Tetrashop Team",
  "license": "MIT"
}
PKG_EOF

echo "✅ فایل‌های استقرار ایجاد شدند"
echo ""
echo "🚀 مراحل استقرار:"
echo "1. ایجاد repository در GitHub:"
echo "   https://github.com/new"
echo "   نام: tetrashop-api"
echo ""
echo "2. اتصال و آپلود کد:"
echo "   git remote add origin https://github.com/USERNAME/tetrashop-api.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "3. تنظیم secrets در GitHub:"
echo "   Settings → Secrets and variables → Actions"
echo "   اضافه کردن:"
echo "   - CLOUDFLARE_ACCOUNT_ID"
echo "   - CLOUDFLARE_API_TOKEN"
echo ""
echo "4. اتوماتیک مستقر می‌شود! 🎉"
echo ""
echo "📞 راهنمای کامل در: DEPLOYMENT_GUIDE.md"
