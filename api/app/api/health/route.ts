import { NextRequest, NextResponse } from 'next/server';
import { getCorsHeaders } from '@/lib/middleware/cors';

export async function GET(request: NextRequest) {
  return NextResponse.json(
    {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      version: process.env.npm_package_version || '1.0.0',
    },
    {
      status: 200,
      headers: getCorsHeaders(request),
    }
  );
}
