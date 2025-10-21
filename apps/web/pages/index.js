import Header from '../components/Header';

export default function Home() {
  return (
    <div>
      <Header />
      <main style={{ padding: '20px' }}>
        <h1>خوش آمدید به تتراشاپ</h1>
        <p>این صفحه اصلی فروشگاه ماست</p>
        <div style={{ marginTop: '20px' }}>
          <a href="/products" style={{ marginRight: '15px' }}>مشاهده محصولات</a>
          <a href="/login" style={{ color: 'blue' }}>ورود به حساب کاربری</a>
        </div>
      </main>
    </div>
  );
}
