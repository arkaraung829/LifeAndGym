import { NextRequest } from 'next/server';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { DatabaseError } from '@/lib/utils/errors';

export async function GET(request: NextRequest) {
  try {
    const { user } = await verifyAuth(request);

    const { data: checkIn, error } = await supabaseAdmin
      .from(Tables.checkIns)
      .select('*, gyms!check_ins_gym_id_fkey(*)')
      .eq('user_id', user.id)
      .is('checked_out_at', null)
      .order('checked_in_at', { ascending: false })
      .maybeSingle();

    if (error) {
      throw new DatabaseError('Failed to fetch current check-in');
    }

    return successResponse({ checkIn }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to fetch current check-in'), request);
  }
}
