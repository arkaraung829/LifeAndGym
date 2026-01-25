import { NextRequest } from 'next/server';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { DatabaseError } from '@/lib/utils/errors';
import type { WorkoutSession } from '@/lib/supabase/types';

export async function GET(request: NextRequest) {
  try {
    const { user } = await verifyAuth(request);

    // Fetch all workout sessions
    const { data: sessions, error } = await supabaseAdmin
      .from(Tables.workoutSessions)
      .select('*')
      .eq('user_id', user.id)
      .order('started_at', { ascending: false });

    if (error) {
      throw new DatabaseError('Failed to fetch workout stats');
    }

    const typedSessions = sessions as WorkoutSession[];
    const completedSessions = typedSessions.filter((s) => s.status === 'completed');

    const now = new Date();
    const thisWeekStart = new Date(now);
    thisWeekStart.setDate(now.getDate() - now.getDay());
    thisWeekStart.setHours(0, 0, 0, 0);

    const thisMonthStart = new Date(now.getFullYear(), now.getMonth(), 1);

    // Calculate stats
    const totalWorkouts = completedSessions.length;
    const totalMinutes = completedSessions.reduce(
      (sum, s) => sum + (s.duration_minutes || 0),
      0
    );
    const totalSets = completedSessions.reduce(
      (sum, s) => sum + (s.total_sets || 0),
      0
    );
    const totalReps = completedSessions.reduce(
      (sum, s) => sum + (s.total_reps || 0),
      0
    );
    const totalWeight = completedSessions.reduce(
      (sum, s) => sum + (s.total_weight || 0),
      0
    );

    // This week stats
    const thisWeekSessions = completedSessions.filter(
      (s) => new Date(s.started_at) >= thisWeekStart
    );
    const thisWeekWorkouts = thisWeekSessions.length;
    const thisWeekMinutes = thisWeekSessions.reduce(
      (sum, s) => sum + (s.duration_minutes || 0),
      0
    );

    // This month stats
    const thisMonthSessions = completedSessions.filter(
      (s) => new Date(s.started_at) >= thisMonthStart
    );
    const thisMonthWorkouts = thisMonthSessions.length;

    const stats = {
      totalWorkouts,
      totalMinutes,
      totalSets,
      totalReps,
      totalWeight,
      thisWeekWorkouts,
      thisWeekMinutes,
      thisMonthWorkouts,
      averageDuration:
        totalWorkouts > 0 ? Math.round(totalMinutes / totalWorkouts) : 0,
    };

    return successResponse({ stats }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to fetch workout stats'), request);
  }
}
