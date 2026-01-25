/** @type {import('next').NextConfig} */
const nextConfig = {
  // Enable experimental features for better API routes
  experimental: {
    serverComponentsExternalPackages: ['@supabase/supabase-js'],
  },
};

export default nextConfig;
