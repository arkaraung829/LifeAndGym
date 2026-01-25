import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseBody } from '@/lib/utils/validation';
import { ValidationError, DatabaseError, ConflictError, NotFoundError } from '@/lib/utils/errors';
import { ErrorCodes } from '@/lib/utils/errors';

const checkInSchema = z.object({
  gymId: z.string().uuid(),
  membershipId: z.string().uuid(),
});

export async function POST(request: NextRequest) {
  try {
    const { user } = await verifyAuth(request);
    const body = await parseBody(request, checkInSchema);

    // Check if already checked in
    const { data: existingCheckIn } = await supabaseAdmin
      .from(Tables.checkIns)
      .select('*, gyms!check_ins_gym_id_fkey(*)')
      .eq('user_id', user.id)
      .is('checked_out_at', null)
      .maybeSingle();

    if (existingCheckIn) {
      throw new ConflictError(
        `Already checked in to ${existingCheckIn.gyms?.name || 'a gym'}`
      );
    }

    // Verify membership exists and is active
    const { data: membership, error: membershipError } = await supabaseAdmin
      .from(Tables.memberships)
      .select('*')
      .eq('id', body.membershipId)
      .eq('user_id', user.id)
      .eq('status', 'active')
      .single();

    if (membershipError || !membership) {
      throw new NotFoundError('Active membership');
    }

    // Create check-in
    const { data: checkIn, error } = await supabaseAdmin
      .from(Tables.checkIns)
      .insert({
        user_id: user.id,
        gym_id: body.gymId,
        membership_id: body.membershipId,
        checked_in_at: new Date().toISOString(),
      })
      .select('*, gyms!check_ins_gym_id_fkey(*)')
      .single();

    if (error) {
      throw new DatabaseError('Failed to check in');
    }

    return successResponse(
      {
        checkIn,
        message: 'Checked in successfully',
      },
      request,
      { status: 201 }
    );
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Check-in failed'), request);
  }
}
