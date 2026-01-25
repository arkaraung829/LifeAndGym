import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseBody } from '@/lib/utils/validation';
import { NotFoundError, DatabaseError, ForbiddenError } from '@/lib/utils/errors';
import type { WorkoutLog } from '@/lib/supabase/types';

const completeSessionSchema = z.object({
  notes: z.string().optional(),
});

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { user } = await verifyAuth(request);
    const { id: sessionId } = await params;
    const body = await parseBody(request, completeSessionSchema);

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

    // Get all logs for this session to calculate stats
    const { data: logs } = await supabaseAdmin
      .from(Tables.workoutLogs)
      .select('*')
      .eq('session_id', sessionId);

    const typedLogs = (logs || []) as WorkoutLog[];

    // Calculate stats
    const totalSets = typedLogs.length;
    const totalReps = typedLogs
      .filter((log) => log.reps != null)
      .reduce((sum, log) => sum + (log.reps || 0), 0);
    const totalWeight = typedLogs
      .filter((log) => log.weight != null && log.reps != null)
      .reduce((sum, log) => sum + (log.weight || 0) * (log.reps || 0), 0);

    // Calculate duration
    const startedAt = new Date(session.started_at);
    const durationMinutes = Math.floor((Date.now() - startedAt.getTime()) / 60000);

    // Update session
    const { data: completedSession, error } = await supabaseAdmin
      .from(Tables.workoutSessions)
      .update({
        completed_at: new Date().toISOString(),
        duration_minutes: durationMinutes,
        total_sets: totalSets,
        total_reps: totalReps,
        total_weight: totalWeight,
        status: 'completed',
        notes: body.notes || session.notes,
      })
      .eq('id', sessionId)
      .select('*, workouts(*)')
      .single();

    if (error) {
      throw new DatabaseError('Failed to complete workout session');
    }

    return successResponse(
      {
        session: completedSession,
        stats: {
          durationMinutes,
          totalSets,
          totalReps,
          totalWeight,
        },
      },
      request
    );
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to complete workout session'), request);
  }
}
