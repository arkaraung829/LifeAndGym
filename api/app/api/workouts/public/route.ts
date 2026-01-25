import { NextRequest } from 'next/server';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { DatabaseError } from '@/lib/utils/errors';

export async function GET(request: NextRequest) {
  try {
    const { data: workouts, error } = await supabaseAdmin
      .from(Tables.workouts)
      .select('*')
      .eq('is_public', true)
      .eq('is_template', true)
      .order('created_at', { ascending: false });

    if (error) {
      throw new DatabaseError('Failed to fetch public workouts');
    }

    return successResponse({ workouts }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to fetch public workouts'), request);
  }
}
