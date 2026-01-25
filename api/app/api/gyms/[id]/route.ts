import { NextRequest } from 'next/server';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { NotFoundError, DatabaseError } from '@/lib/utils/errors';

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;

    const { data: gym, error } = await supabaseAdmin
      .from(Tables.gyms)
      .select('*')
      .eq('id', id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        throw new NotFoundError('Gym');
      }
      throw new DatabaseError('Failed to fetch gym');
    }

    return successResponse({ gym }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to fetch gym'), request);
  }
}
