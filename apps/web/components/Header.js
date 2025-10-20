export default function Header() {
  return (
    <header style={{
      padding: '1rem 2rem',
      backgroundColor: '#1a202c',
      color: 'white',
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center'
    }}>
      <h1 style={{ margin: 0 }}>🛍️ تتورشاپ</h1>
      <nav>
        <button style={{
          padding: '8px 16px',
          margin: '0 5px',
          backgroundColor: 'transparent',
          color: 'white',
          border: '1px solid white',
          borderRadius: '5px',
          cursor: 'pointer'
        }}>
          سبد خرید
        </button>
      </nav>
    </header>
  )
}
