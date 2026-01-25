import { NextRequest, NextResponse } from 'next/server';
import { handleCorsPreflightRequest, addCorsHeaders } from '@/lib/middleware/cors';

export function middleware(request: NextRequest) {
  // Handle CORS preflight requests
  if (request.method === 'OPTIONS') {
    return handleCorsPreflightRequest(request);
  }

  // Add CORS headers to all responses
  const response = NextResponse.next();
  return addCorsHeaders(response, request);
}

export const config = {
  matcher: '/api/:path*',
};
