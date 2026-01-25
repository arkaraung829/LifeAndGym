import { NextRequest, NextResponse } from 'next/server';
import { errorResponse } from '@/lib/utils/response';
import { NotFoundError } from '@/lib/utils/errors';

// Import handlers from domain modules
import * as auth from './handlers/auth';
import * as gyms from './handlers/gyms';
import * as memberships from './handlers/memberships';
import * as workouts from './handlers/workouts';
import * as classes from './handlers/classes';

// Helper to return JSON error for debugging
function jsonError(message: string, error?: unknown) {
  return NextResponse.json(
    {
      success: false,
      error: message,
      details: error instanceof Error ? error.message : String(error)
    },
    { status: 500 }
  );
}

function parsePath(params: { path?: string[] }): { domain: string; subpath: string[] } {
  const path = params.path || [];
  return {
    domain: path[0] || '',
    subpath: path.slice(1),
  };
}

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ path?: string[] }> }
) {
  try {
    const { path } = await params;
    const { domain, subpath } = parsePath({ path });

    switch (domain) {
      case 'health':
        return new Response(JSON.stringify({ status: 'ok', timestamp: new Date().toISOString() }), {
          headers: { 'Content-Type': 'application/json' },
        });
      case 'auth':
        return auth.handleGet(request, subpath);
      case 'gyms':
        return gyms.handleGet(request, subpath);
      case 'memberships':
        return memberships.handleGet(request, subpath);
      case 'workouts':
        return workouts.handleGet(request, subpath);
      case 'classes':
        return classes.handleGet(request, subpath);
      default:
        return errorResponse(new NotFoundError('Endpoint'), request);
    }
  } catch (error) {
    console.error('GET Error:', error);
    return jsonError('GET handler failed', error);
  }
}

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ path?: string[] }> }
) {
  try {
    const { path } = await params;
    const { domain, subpath } = parsePath({ path });

    switch (domain) {
      case 'auth':
        return auth.handlePost(request, subpath);
      case 'memberships':
        return memberships.handlePost(request, subpath);
      case 'workouts':
        return workouts.handlePost(request, subpath);
      case 'classes':
        return classes.handlePost(request, subpath);
      default:
        return errorResponse(new NotFoundError('Endpoint'), request);
    }
  } catch (error) {
    console.error('POST Error:', error);
    return jsonError('POST handler failed', error);
  }
}

export async function PATCH(
  request: NextRequest,
  { params }: { params: Promise<{ path?: string[] }> }
) {
  try {
    const { path } = await params;
    const { domain, subpath } = parsePath({ path });

    switch (domain) {
      case 'auth':
        return auth.handlePatch(request, subpath);
      default:
        return errorResponse(new NotFoundError('Endpoint'), request);
    }
  } catch (error) {
    console.error('PATCH Error:', error);
    return jsonError('PATCH handler failed', error);
  }
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ path?: string[] }> }
) {
  try {
    return errorResponse(new NotFoundError('Endpoint'), request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Request failed'), request);
  }
}
