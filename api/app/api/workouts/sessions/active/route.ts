import { NextRequest } from 'next/server';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { DatabaseError } from '@/lib/utils/errors';

export async function GET(request: NextRequest) {
  try {
    const { user } = await verifyAuth(request);

    const { data: session, error } = await supabaseAdmin
      .from(Tables.workoutSessions)
      .select('*, workouts(*)')
      .eq('user_id', user.id)
      .eq('status', 'in_progress')
      .maybeSingle();

    if (error) {
      throw new DatabaseError('Failed to fetch active session');
    }

    // If session exists, also get the logs
    let logs = null;
    if (session) {
      const { data: sessionLogs } = await supabaseAdmin
        .from(Tables.workoutLogs)
        .select('*')
        .eq('session_id', session.id)
        .order('completed_at', { ascending: true });

      logs = sessionLogs;
    }

    return successResponse({ session, logs }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to fetch active session'), request);
  }
}
