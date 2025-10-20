#!/bin/bash
echo "🚀 Starting Tetrashop build..."

cd apps/web
echo "📦 Installing dependencies..."
npm install

echo "🔨 Building Next.js application..."
npm run build

echo "✅ Build completed successfully!"

# بررسی خروجی build
if [ -d ".next" ]; then
    echo "📁 Build output detected: .next directory exists"
    ls -la .next/
else
    echo "❌ Build output not found!"
    exit 1
fi
