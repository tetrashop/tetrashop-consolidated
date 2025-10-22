#!/bin/bash

echo "🎯 RENDER.COM DEPLOYMENT"
echo "========================"

echo "📁 Files ready for Render:"
echo "✅ tetrashop_orchestrator.py (Main API)"
echo "✅ requirements.txt (Dependencies)" 
echo "✅ render.yaml (Configuration)"
echo ""

echo "🚀 Steps to deploy on Render:"
echo "1. Go to https://render.com"
echo "2. Sign up with GitHub"
echo "3. Click 'New Web Service'"
echo "4. Connect your GitHub repository"
echo "5. Select branch: main"
echo "6. Build Command: pip install -r requirements.txt"
echo "7. Start Command: python tetrashop_orchestrator.py"
echo "8. Click 'Create Web Service'"
echo "9. Wait for deployment (5-10 minutes)"
echo "10. Your API will be live at: https://tetrashop-api.onrender.com"
echo ""
echo "⚡ Quick start - push to GitHub first!"
