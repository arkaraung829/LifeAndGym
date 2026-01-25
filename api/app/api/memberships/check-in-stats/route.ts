import { NextRequest } from 'next/server';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { DatabaseError } from '@/lib/utils/errors';
import type { CheckIn } from '@/lib/supabase/types';

export async function GET(request: NextRequest) {
  try {
    const { user } = await verifyAuth(request);

    // Fetch all check-ins for the user
    const { data: checkIns, error } = await supabaseAdmin
      .from(Tables.checkIns)
      .select('*')
      .eq('user_id', user.id)
      .order('checked_in_at', { ascending: false });

    if (error) {
      throw new DatabaseError('Failed to fetch check-in stats');
    }

    const typedCheckIns = checkIns as CheckIn[];

    const now = new Date();
    const thisWeekStart = new Date(now);
    thisWeekStart.setDate(now.getDate() - now.getDay());
    thisWeekStart.setHours(0, 0, 0, 0);

    const thisMonthStart = new Date(now.getFullYear(), now.getMonth(), 1);

    // Calculate stats
    const thisWeek = typedCheckIns.filter(
      (c) => new Date(c.checked_in_at) >= thisWeekStart
    ).length;

    const thisMonth = typedCheckIns.filter(
      (c) => new Date(c.checked_in_at) >= thisMonthStart
    ).length;

    const completedCheckIns = typedCheckIns.filter((c) => c.duration_minutes != null);
    const totalMinutes = completedCheckIns.reduce(
      (sum, c) => sum + (c.duration_minutes || 0),
      0
    );

    const stats = {
      totalCheckIns: typedCheckIns.length,
      thisWeek,
      thisMonth,
      totalMinutes,
      averageDurationMinutes:
        completedCheckIns.length > 0
          ? Math.round(totalMinutes / completedCheckIns.length)
          : 0,
    };

    return successResponse({ stats }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to fetch check-in stats'), request);
  }
}
