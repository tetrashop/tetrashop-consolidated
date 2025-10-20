export default function Layout({ children }) {
  return (
    <html dir="rtl">
      <body>
        <header>تتورشاپ - فروشگاه آنلاین</header>
        <main>{children}</main>
      </body>
    </html>
  )
}
