import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseQuery } from '@/lib/utils/validation';
import { DatabaseError } from '@/lib/utils/errors';

const historySchema = z.object({
  limit: z.coerce.number().int().positive().max(100).default(50),
  startDate: z.string().optional(),
  endDate: z.string().optional(),
});

export async function GET(request: NextRequest) {
  try {
    const { user } = await verifyAuth(request);
    const searchParams = request.nextUrl.searchParams;
    const query = parseQuery(searchParams, historySchema);

    let dbQuery = supabaseAdmin
      .from(Tables.checkIns)
      .select('*, gyms!check_ins_gym_id_fkey(*)')
      .eq('user_id', user.id)
      .order('checked_in_at', { ascending: false })
      .limit(query.limit);

    if (query.startDate) {
      dbQuery = dbQuery.gte('checked_in_at', query.startDate);
    }

    if (query.endDate) {
      dbQuery = dbQuery.lte('checked_in_at', query.endDate);
    }

    const { data: checkIns, error } = await dbQuery;

    if (error) {
      throw new DatabaseError('Failed to fetch check-in history');
    }

    return successResponse({ checkIns }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to fetch check-in history'), request);
  }
}
