import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseQuery } from '@/lib/utils/validation';
import { DatabaseError, ValidationError } from '@/lib/utils/errors';

const classesQuerySchema = z.object({
  gymId: z.string().uuid('Invalid gym ID'),
});

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const query = parseQuery(searchParams, classesQuerySchema);

    const { data: classes, error } = await supabaseAdmin
      .from(Tables.classes)
      .select('*')
      .eq('gym_id', query.gymId)
      .eq('is_active', true)
      .order('name');

    if (error) {
      throw new DatabaseError('Failed to fetch classes');
    }

    return successResponse({ classes }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to fetch classes'), request);
  }
}
