# 🛍️ Tetrashop Monorepo

ساختار یکپارچه‌شده پروژه‌های تتورشاپ

## 🏗️ ساختار پروژه


## 🚀 شروع سریع

```bash
npm install
npm run dev

### مرحله ۲: **ایجاد پکیج‌های مشترک**

```bash
# ایجاد پکیج UI
mkdir -p packages/ui
cat > packages/ui/package.json << 'EOF'
{
  "name": "@tetrashop/ui",
  "version": "1.0.0",
  "type": "module",
  "main": "index.js",
  "types": "index.d.ts"
}
