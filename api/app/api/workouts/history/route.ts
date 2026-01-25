import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseQuery } from '@/lib/utils/validation';
import { DatabaseError } from '@/lib/utils/errors';

const historySchema = z.object({
  limit: z.coerce.number().int().positive().max(100).default(20),
  startDate: z.string().optional(),
  endDate: z.string().optional(),
});

export async function GET(request: NextRequest) {
  try {
    const { user } = await verifyAuth(request);
    const searchParams = request.nextUrl.searchParams;
    const query = parseQuery(searchParams, historySchema);

    let dbQuery = supabaseAdmin
      .from(Tables.workoutSessions)
      .select('*, workouts(*)')
      .eq('user_id', user.id)
      .order('started_at', { ascending: false })
      .limit(query.limit);

    if (query.startDate) {
      dbQuery = dbQuery.gte('started_at', query.startDate);
    }

    if (query.endDate) {
      dbQuery = dbQuery.lte('started_at', query.endDate);
    }

    const { data: sessions, error } = await dbQuery;

    if (error) {
      throw new DatabaseError('Failed to fetch workout history');
    }

    return successResponse({ sessions }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to fetch workout history'), request);
  }
}
