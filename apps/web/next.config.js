/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  compress: true,
  poweredByHeader: false,
  experimental: {
    optimizeCss: true,
  },
  images: {
    domains: ['assets.tetrashop.com'],
  },
}

module.exports = nextConfig
