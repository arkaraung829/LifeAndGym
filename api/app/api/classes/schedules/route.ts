import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseQuery } from '@/lib/utils/validation';
import { DatabaseError } from '@/lib/utils/errors';

const schedulesQuerySchema = z.object({
  gymId: z.string().uuid('Invalid gym ID'),
  startDate: z.string(),
  endDate: z.string(),
});

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const query = parseQuery(searchParams, schedulesQuerySchema);

    const { data: schedules, error } = await supabaseAdmin
      .from(Tables.classSchedules)
      .select('*, classes(*)')
      .eq('gym_id', query.gymId)
      .gte('scheduled_at', query.startDate)
      .lte('scheduled_at', query.endDate)
      .order('scheduled_at');

    if (error) {
      throw new DatabaseError('Failed to fetch class schedules');
    }

    return successResponse({ schedules }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to fetch class schedules'), request);
  }
}
