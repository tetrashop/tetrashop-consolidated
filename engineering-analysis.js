console.log("🔍 شروع تحلیل مهندسی پروژه Tetrashop...\n");

const fs = require('fs');
const path = require('path');

class EngineeringAnalyzer {
  constructor() {
    this.projectRoot = process.cwd();
  }

  analyze() {
    console.log("📊 تحلیل ساختار پروژه:");
    
    try {
      const files = this.scanProject();
      const metrics = this.calculateMetrics(files);
      this.generateReport(metrics);
    } catch (error) {
      console.log("❌ خطا در تحلیل:", error.message);
    }
  }

  scanProject() {
    const files = [];
    
    function scanDir(dir) {
      try {
        const items = fs.readdirSync(dir);
        
        for (const item of items) {
          if (item.startsWith('.') || item === 'node_modules') continue;
          
          const fullPath = path.join(dir, item);
          const stat = fs.statSync(fullPath);
          
          if (stat.isDirectory()) {
            scanDir(fullPath);
          } else if (stat.isFile() && 
            (item.endsWith('.js') || item.endsWith('.html') || 
             item.endsWith('.json') || item.endsWith('.md'))) {
            files.push({
              name: item,
              path: fullPath,
              size: stat.size,
              type: path.extname(item)
            });
          }
        }
      } catch (error) {
        // Skip directories that can't be read
      }
    }

    scanDir(this.projectRoot);
    return files;
  }

  calculateMetrics(files) {
    const jsFiles = files.filter(f => f.type === '.js');
    const htmlFiles = files.filter(f => f.type === '.html');
    
    return {
      totalFiles: files.length,
      jsFiles: jsFiles.length,
      htmlFiles: htmlFiles.length,
      totalSize: files.reduce((sum, f) => sum + f.size, 0),
      hasPackageJson: files.some(f => f.name === 'package.json'),
      hasServer: files.some(f => f.name.includes('server') || f.name.includes('app'))
    };
  }

  generateReport(metrics) {
    console.log("📈 نتایج تحلیل:");
    console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    console.log(`📁 مجموع فایل‌ها: ${metrics.totalFiles}`);
    console.log(`⚡ فایل‌های JavaScript: ${metrics.jsFiles}`);
    console.log(`🌐 فایل‌های HTML: ${metrics.htmlFiles}`);
    console.log(`📦 package.json: ${metrics.hasPackageJson ? '✅ موجود' : '❌ مفقود'}`);
    console.log(`🚀 سرور: ${metrics.hasServer ? '✅ شناسایی شد' : '❌ نیازمند ایجاد'}`);
    console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    
    console.log("\n🎯 توصیه‌های فوری:");
    console.log("1. ایجاد سرور یکپارچه با Express");
    console.log("2. اضافه کردن سیستم درآمدزایی");
    console.log("3. بهینه‌سازی برای Cloudflare");
    console.log("4. ایجاد داشبورد مدیریت");
  }
}

// اجرای تحلیل
new EngineeringAnalyzer().analyze();
