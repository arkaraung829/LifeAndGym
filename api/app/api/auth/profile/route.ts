import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseBody } from '@/lib/utils/validation';
import { DatabaseError } from '@/lib/utils/errors';

const updateProfileSchema = z.object({
  fullName: z.string().min(2).optional(),
  phone: z.string().optional(),
  gender: z.enum(['male', 'female', 'other']).optional(),
  dateOfBirth: z.string().optional(),
  heightCm: z.number().positive().optional(),
  avatarUrl: z.string().url().optional(),
}).partial();

export async function PATCH(request: NextRequest) {
  try {
    const { user } = await verifyAuth(request);
    const body = await parseBody(request, updateProfileSchema);

    // Map camelCase to snake_case for database
    const updates: Record<string, unknown> = {
      updated_at: new Date().toISOString(),
    };

    if (body.fullName !== undefined) updates.full_name = body.fullName;
    if (body.phone !== undefined) updates.phone = body.phone;
    if (body.gender !== undefined) updates.gender = body.gender;
    if (body.dateOfBirth !== undefined) updates.date_of_birth = body.dateOfBirth;
    if (body.heightCm !== undefined) updates.height_cm = body.heightCm;
    if (body.avatarUrl !== undefined) updates.avatar_url = body.avatarUrl;

    const { data: profile, error } = await supabaseAdmin
      .from(Tables.users)
      .update(updates)
      .eq('id', user.id)
      .select()
      .single();

    if (error) {
      throw new DatabaseError('Failed to update profile');
    }

    return successResponse({ user: profile }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to update profile'), request);
  }
}

export async function GET(request: NextRequest) {
  try {
    const { user } = await verifyAuth(request);

    const { data: profile, error } = await supabaseAdmin
      .from(Tables.users)
      .select('*')
      .eq('id', user.id)
      .single();

    if (error) {
      throw new DatabaseError('Failed to fetch profile');
    }

    return successResponse({ user: profile }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to get profile'), request);
  }
}
