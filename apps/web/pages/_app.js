export default function MyApp({ Component, pageProps }) {
  return (
    <>
      <head>
        <title>تتورشاپ - فروشگاه آنلاین</title>
        <meta name="description" content="بهترین فروشگاه آنلاین با قیمت‌های مناسب" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta charSet="utf-8" />
      </head>
      <Component {...pageProps} />
    </>
  )
}
