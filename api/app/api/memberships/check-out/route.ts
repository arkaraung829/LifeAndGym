import { NextRequest } from 'next/server';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { NotFoundError, DatabaseError } from '@/lib/utils/errors';

export async function POST(request: NextRequest) {
  try {
    const { user } = await verifyAuth(request);

    // Find current check-in
    const { data: currentCheckIn, error: findError } = await supabaseAdmin
      .from(Tables.checkIns)
      .select('*')
      .eq('user_id', user.id)
      .is('checked_out_at', null)
      .single();

    if (findError || !currentCheckIn) {
      throw new NotFoundError('Active check-in');
    }

    // Calculate duration
    const checkedInAt = new Date(currentCheckIn.checked_in_at);
    const now = new Date();
    const durationMinutes = Math.floor((now.getTime() - checkedInAt.getTime()) / 60000);

    // Update check-in with checkout time and duration
    const { data: checkIn, error } = await supabaseAdmin
      .from(Tables.checkIns)
      .update({
        checked_out_at: now.toISOString(),
        duration_minutes: durationMinutes,
      })
      .eq('id', currentCheckIn.id)
      .select('*, gyms!check_ins_gym_id_fkey(*)')
      .single();

    if (error) {
      throw new DatabaseError('Failed to check out');
    }

    return successResponse(
      {
        checkIn,
        message: 'Checked out successfully',
        durationMinutes,
      },
      request
    );
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Check-out failed'), request);
  }
}
