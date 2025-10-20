import React from 'react'

export default function Home() {
  return (
    <div style={{ 
      padding: '2rem', 
      textAlign: 'center',
      fontFamily: 'Arial, sans-serif',
      direction: 'rtl'
    }}>
      <h1>🛍️ تتورشاپ - فروشگاه آنلاین</h1>
      <p>با Cloudflare Pages راه‌اندازی شد ✅</p>
      <div style={{ marginTop: '2rem' }}>
        <button style={{
          padding: '10px 20px',
          backgroundColor: '#0070f3',
          color: 'white',
          border: 'none',
          borderRadius: '5px',
          cursor: 'pointer'
        }}>
          شروع خرید
        </button>
      </div>
      <footer style={{ marginTop: '3rem', fontSize: '0.9rem', color: '#666' }}>
        آدرس: https://tetrashop.pages.dev
      </footer>
    </div>
  )
}
