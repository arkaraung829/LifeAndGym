import { NextRequest } from 'next/server';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { DatabaseError } from '@/lib/utils/errors';

export async function GET(request: NextRequest) {
  try {
    const { user } = await verifyAuth(request);

    const { data: membership, error } = await supabaseAdmin
      .from(Tables.memberships)
      .select('*, gyms!memberships_gym_id_fkey(*)')
      .eq('user_id', user.id)
      .eq('status', 'active')
      .maybeSingle();

    if (error) {
      throw new DatabaseError('Failed to fetch active membership');
    }

    return successResponse({ membership }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to fetch active membership'), request);
  }
}
