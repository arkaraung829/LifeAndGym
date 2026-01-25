import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseQuery } from '@/lib/utils/validation';
import { DatabaseError, ValidationError } from '@/lib/utils/errors';

const searchSchema = z.object({
  q: z.string().min(1, 'Search query is required'),
  city: z.string().optional(),
});

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const query = parseQuery(searchParams, searchSchema);

    let dbQuery = supabaseAdmin
      .from(Tables.gyms)
      .select('*')
      .eq('is_active', true);

    // Search by name, city, or address
    dbQuery = dbQuery.or(
      `name.ilike.%${query.q}%,city.ilike.%${query.q}%,address.ilike.%${query.q}%`
    );

    // Optional city filter
    if (query.city) {
      dbQuery = dbQuery.eq('city', query.city);
    }

    const { data: gyms, error } = await dbQuery.order('name');

    if (error) {
      throw new DatabaseError('Failed to search gyms');
    }

    return successResponse({ gyms, query: query.q }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to search gyms'), request);
  }
}
