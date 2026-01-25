import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseBody } from '@/lib/utils/validation';
import { ConflictError, DatabaseError } from '@/lib/utils/errors';

const startSessionSchema = z.object({
  workoutId: z.string().uuid().optional(),
  notes: z.string().optional(),
});

export async function POST(request: NextRequest) {
  try {
    const { user } = await verifyAuth(request);
    const body = await parseBody(request, startSessionSchema);

    // Check if user has an active session
    const { data: existingSession } = await supabaseAdmin
      .from(Tables.workoutSessions)
      .select('*')
      .eq('user_id', user.id)
      .eq('status', 'in_progress')
      .maybeSingle();

    if (existingSession) {
      throw new ConflictError('You already have an active workout session');
    }

    const { data: session, error } = await supabaseAdmin
      .from(Tables.workoutSessions)
      .insert({
        user_id: user.id,
        workout_id: body.workoutId,
        started_at: new Date().toISOString(),
        status: 'in_progress',
        notes: body.notes,
      })
      .select('*, workouts(*)')
      .single();

    if (error) {
      throw new DatabaseError('Failed to start workout session');
    }

    return successResponse({ session }, request, { status: 201 });
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to start workout session'), request);
  }
}
