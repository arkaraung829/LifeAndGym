import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseQuery } from '@/lib/utils/validation';
import { DatabaseError } from '@/lib/utils/errors';

const exerciseQuerySchema = z.object({
  q: z.string().optional(),
  muscleGroup: z.string().optional(),
  type: z.string().optional(),
  limit: z.coerce.number().int().positive().max(100).default(50),
});

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const query = parseQuery(searchParams, exerciseQuerySchema);

    let dbQuery = supabaseAdmin
      .from(Tables.exercises)
      .select('*')
      .order('name');

    // Search by name
    if (query.q) {
      dbQuery = dbQuery.ilike('name', `%${query.q}%`);
    }

    // Filter by muscle group
    if (query.muscleGroup) {
      dbQuery = dbQuery.contains('muscle_groups', [query.muscleGroup]);
    }

    // Filter by exercise type
    if (query.type) {
      dbQuery = dbQuery.eq('exercise_type', query.type);
    }

    const { data: exercises, error } = await dbQuery.limit(query.limit);

    if (error) {
      throw new DatabaseError('Failed to fetch exercises');
    }

    return successResponse({ exercises }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to fetch exercises'), request);
  }
}
