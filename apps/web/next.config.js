/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  distDir: '.next',
  trailingSlash: true,
  images: {
    unoptimized: true
  },
  reactStrictMode: true
}

module.exports = nextConfig
