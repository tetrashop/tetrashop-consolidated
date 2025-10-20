export default function Home() {
  return (
    <div style={{ 
      padding: '2rem', 
      textAlign: 'center', 
      direction: 'rtl',
      fontFamily: 'Arial, sans-serif'
    }}>
      <h1>🛍️ تتورشاپ - کامل</h1>
      <p style={{ color: 'green', fontWeight: 'bold' }}>✅ پروژه اصلی با ساختار پوشه‌ای - راه‌اندازی شد</p>
      
      <div style={{ marginTop: '2rem' }}>
        <button style={{
          padding: '12px 24px',
          backgroundColor: '#0070f3',
          color: 'white',
          border: 'none',
          borderRadius: '8px',
          fontSize: '16px',
          cursor: 'pointer'
        }}>
          ورود به فروشگاه
        </button>
      </div>

      <div style={{ 
        marginTop: '3rem', 
        padding: '1rem', 
        backgroundColor: '#f5f5f5',
        borderRadius: '8px',
        fontSize: '14px'
      }}>
        <p>ساختار: <code>apps/web/</code></p>
        <p>آدرس: <strong>https://tetrashop-complete.vercel.app</strong></p>
      </div>
    </div>
  )
}
