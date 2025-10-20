export default function Home() {
  return (
    <html dir="rtl">
      <head>
        <title>تتورشاپ - فروشگاه آنلاین</title>
        <meta charSet="utf-8" />
      </head>
      <body style={{ 
        margin: 0, 
        padding: '2rem', 
        fontFamily: 'Arial, sans-serif',
        textAlign: 'center',
        direction: 'rtl'
      }}>
        <h1>🛍️ تتورشاپ</h1>
        <p>فروشگاه آنلاین - به زودی...</p>
        <div style={{ marginTop: '2rem' }}>
          <button style={{
            padding: '10px 20px',
            backgroundColor: '#28a745',
            color: 'white',
            border: 'none',
            borderRadius: '5px',
            cursor: 'pointer',
            fontSize: '16px'
          }}>
            ورود به فروشگاه
          </button>
        </div>
      </body>
    </html>
  )
}
