import Header from '../components/Header'

export default function Products() {
  const products = [
    { id: 1, name: 'لپ‌تاپ ایسوس', price: '۱۵,۰۰۰,۰۰۰ تومان' },
    { id: 2, name: 'هدفون سونی', price: '۲,۵۰۰,۰۰۰ تومان' },
    { id: 3, name: 'ماوس گیمینگ', price: '۸۰۰,۰۰۰ تومان' }
  ]

  return (
    <div style={{ direction: 'rtl' }}>
      <Header />
      <div style={{ padding: '2rem' }}>
        <h2>📦 محصولات ما</h2>
        <div style={{ display: 'grid', gap: '1rem', marginTop: '2rem' }}>
          {products.map(product => (
            <div key={product.id} style={{
              padding: '1rem',
              border: '1px solid #ddd',
              borderRadius: '8px',
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center'
            }}>
              <span>{product.name}</span>
              <div>
                <span style={{ fontWeight: 'bold' }}>{product.price}</span>
                <button style={{
                  marginRight: '1rem',
                  padding: '5px 10px',
                  backgroundColor: '#0070f3',
                  color: 'white',
                  border: 'none',
                  borderRadius: '5px',
                  cursor: 'pointer'
                }}>
                  افزودن به سبد
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
