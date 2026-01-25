import { NextRequest } from 'next/server';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { DatabaseError } from '@/lib/utils/errors';

export async function GET(request: NextRequest) {
  try {
    const { data: gyms, error } = await supabaseAdmin
      .from(Tables.gyms)
      .select('*')
      .eq('is_active', true)
      .order('name');

    if (error) {
      throw new DatabaseError('Failed to fetch gyms');
    }

    return successResponse({ gyms }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to fetch gyms'), request);
  }
}
