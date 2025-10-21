import Header from '../components/Header';

export default function Login() {
  return (
    <div>
      <Header />
      <main style={{ padding: '20px', maxWidth: '400px', margin: '0 auto' }}>
        <h1>ورود به حساب کاربری</h1>
        <form>
          <div style={{ marginBottom: '15px' }}>
            <label>ایمیل:</label>
            <input 
              type="email" 
              style={{ width: '100%', padding: '8px', marginTop: '5px' }}
              placeholder="example@email.com"
            />
          </div>
          <div style={{ marginBottom: '15px' }}>
            <label>رمز عبور:</label>
            <input 
              type="password" 
              style={{ width: '100%', padding: '8px', marginTop: '5px' }}
              placeholder="••••••••"
            />
          </div>
          <button 
            type="submit"
            style={{ 
              width: '100%', 
              padding: '10px', 
              background: 'blue', 
              color: 'white', 
              border: 'none',
              cursor: 'pointer'
            }}
          >
            ورود
          </button>
        </form>
        <p style={{ marginTop: '15px', textAlign: 'center' }}>
          <a href="/">بازگشت به خانه</a>
        </p>
      </main>
    </div>
  );
}
