import { NextRequest } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase/client';
import { ApiError, UnauthorizedError } from '@/lib/utils/errors';

export interface AuthUser {
  id: string;
  email: string;
  role?: string;
}

export interface AuthResult {
  user: AuthUser;
  accessToken: string;
}

// Extract and verify JWT from Authorization header
export async function verifyAuth(request: NextRequest): Promise<AuthResult> {
  const authHeader = request.headers.get('authorization');

  if (!authHeader) {
    throw new UnauthorizedError('Missing authorization header');
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0].toLowerCase() !== 'bearer') {
    throw new UnauthorizedError('Invalid authorization header format');
  }

  const accessToken = parts[1];

  try {
    // Verify the JWT using Supabase
    const { data, error } = await supabaseAdmin.auth.getUser(accessToken);

    if (error || !data.user) {
      throw new UnauthorizedError('Invalid or expired token');
    }

    return {
      user: {
        id: data.user.id,
        email: data.user.email || '',
        role: data.user.role,
      },
      accessToken,
    };
  } catch (e) {
    if (e instanceof ApiError) {
      throw e;
    }
    throw new UnauthorizedError('Token verification failed');
  }
}

// Optional auth - returns null if not authenticated
export async function verifyAuthOptional(request: NextRequest): Promise<AuthResult | null> {
  const authHeader = request.headers.get('authorization');

  if (!authHeader) {
    return null;
  }

  try {
    return await verifyAuth(request);
  } catch {
    return null;
  }
}
