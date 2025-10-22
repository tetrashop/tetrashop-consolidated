#!/bin/bash

echo "🚀 Preparing to deploy to GitHub..."

# بررسی وضعیت git
if [ ! -d ".git" ]; then
    echo "📦 Initializing Git repository..."
    git init
    git add .
    git commit -m "Initial commit: Tetrashop API"
    
    echo "🌐 Please create a new repository on GitHub and run:"
    echo "   git remote add origin https://github.com/yourusername/tetrashop-api.git"
    echo "   git push -u origin main"
else
    echo "✅ Git repository already initialized"
    git status
fi

echo ""
echo "📋 Deployment Checklist:"
echo "1. ✅ Code prepared for GitHub"
echo "2. ⬜ Create repository on GitHub"
echo "3. ⬜ Add repository as remote origin"
echo "4. ⬜ Push code to GitHub"
echo "5. ⬜ Set secrets in GitHub:"
echo "   - CLOUDFLARE_API_TOKEN"
echo "   - CLOUDFLARE_ACCOUNT_ID"
echo "6. ⬜ GitHub Actions will auto-deploy"
echo ""
echo "🔑 To get Cloudflare API Token:"
echo "   - Go to Cloudflare Dashboard → My Profile → API Tokens"
echo "   - Create token with 'Edit Workers' permission"
echo ""
echo "📚 Quick commands for next steps:"
echo "   git remote add origin https://github.com/yourusername/tetrashop-api.git"
echo "   git branch -M main"
echo "   git push -u origin main"
