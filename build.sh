#!/bin/bash
echo "📦 Building Tetrashop project..."

cd apps/web
echo "Installing dependencies..."
npm install

echo "Building Next.js app..."
npm run build

echo "✅ Build completed successfully!"
