import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseBody } from '@/lib/utils/validation';
import { NotFoundError, DatabaseError, ForbiddenError } from '@/lib/utils/errors';

const logSetSchema = z.object({
  exerciseId: z.string().uuid(),
  setNumber: z.number().int().positive(),
  reps: z.number().int().positive().optional(),
  weight: z.number().positive().optional(),
  duration: z.number().int().positive().optional(),
  notes: z.string().optional(),
});

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { user } = await verifyAuth(request);
    const { id: sessionId } = await params;
    const body = await parseBody(request, logSetSchema);

    // Verify session exists and belongs to user
    const { data: session, error: sessionError } = await supabaseAdmin
      .from(Tables.workoutSessions)
      .select('*')
      .eq('id', sessionId)
      .single();

    if (sessionError || !session) {
      throw new NotFoundError('Workout session');
    }

    if (session.user_id !== user.id) {
      throw new ForbiddenError('You do not own this session');
    }

    if (session.status !== 'in_progress') {
      throw new ForbiddenError('Session is not in progress');
    }

    const { data: log, error } = await supabaseAdmin
      .from(Tables.workoutLogs)
      .insert({
        session_id: sessionId,
        exercise_id: body.exerciseId,
        set_number: body.setNumber,
        reps: body.reps,
        weight: body.weight,
        duration: body.duration,
        notes: body.notes,
        completed_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (error) {
      throw new DatabaseError('Failed to log workout set');
    }

    return successResponse({ log }, request, { status: 201 });
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to log workout set'), request);
  }
}
