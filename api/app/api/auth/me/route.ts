import { NextRequest } from 'next/server';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { NotFoundError, DatabaseError } from '@/lib/utils/errors';

export async function GET(request: NextRequest) {
  try {
    const { user } = await verifyAuth(request);

    // Fetch user profile
    const { data: profile, error } = await supabaseAdmin
      .from(Tables.users)
      .select('*')
      .eq('id', user.id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        // User profile not found - might be OAuth user, create profile
        return await createOAuthProfile(request, user.id, user.email);
      }
      throw new DatabaseError('Failed to fetch user profile');
    }

    return successResponse({ user: profile }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to get user'), request);
  }
}

async function createOAuthProfile(request: NextRequest, userId: string, email: string) {
  // Get user metadata from auth
  const { data: authData } = await supabaseAdmin.auth.admin.getUserById(userId);

  const fullName = authData?.user?.user_metadata?.full_name ||
    authData?.user?.user_metadata?.name ||
    email.split('@')[0];
  const avatarUrl = authData?.user?.user_metadata?.avatar_url ||
    authData?.user?.user_metadata?.picture;

  const now = new Date().toISOString();

  const { data: profile, error } = await supabaseAdmin
    .from(Tables.users)
    .insert({
      id: userId,
      email,
      full_name: fullName,
      avatar_url: avatarUrl,
      created_at: now,
      updated_at: now,
    })
    .select()
    .single();

  if (error) {
    throw new DatabaseError('Failed to create user profile');
  }

  return successResponse({ user: profile }, request, { status: 201 });
}
