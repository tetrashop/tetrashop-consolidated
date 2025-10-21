import Header from '../components/Header';

const products = [
  { id: 1, name: 'لپ تاپ ایسوس', price: '۱۵,۰۰۰,۰۰۰ تومان' },
  { id: 2, name: 'هدفون سونی', price: '۲,۵۰۰,۰۰۰ تومان' },
  { id: 3, name: 'ماوس گیمینگ', price: '۸۰۰,۰۰۰ تومان' }
];

export default function Products() {
  return (
    <div>
      <Header />
      <main style={{ padding: '20px' }}>
        <h1>محصولات ما</h1>
        <div style={{ display: 'grid', gap: '20px', marginTop: '20px' }}>
          {products.map(product => (
            <div key={product.id} style={{ 
              border: '1px solid #ddd', 
              padding: '15px', 
              borderRadius: '8px' 
            }}>
              <h3>{product.name}</h3>
              <p>قیمت: {product.price}</p>
              <button style={{
                background: 'green',
                color: 'white',
                border: 'none',
                padding: '8px 15px',
                borderRadius: '4px',
                cursor: 'pointer'
              }}>
                افزودن به سبد خرید
              </button>
            </div>
          ))}
        </div>
        <p style={{ marginTop: '20px' }}>
          <a href="/">بازگشت به خانه</a>
        </p>
      </main>
    </div>
  );
}
