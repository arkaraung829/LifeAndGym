import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseBody } from '@/lib/utils/validation';
import { DatabaseError } from '@/lib/utils/errors';

const onboardingSchema = z.object({
  fitnessLevel: z.enum(['beginner', 'intermediate', 'advanced']),
  fitnessGoals: z.array(z.string()).min(1, 'Select at least one goal'),
  gender: z.enum(['male', 'female', 'other']).optional(),
  heightCm: z.number().positive().optional(),
  dateOfBirth: z.string().optional(),
});

export async function POST(request: NextRequest) {
  try {
    const { user } = await verifyAuth(request);
    const body = await parseBody(request, onboardingSchema);

    const updates = {
      fitness_level: body.fitnessLevel,
      fitness_goals: body.fitnessGoals,
      gender: body.gender,
      height_cm: body.heightCm,
      date_of_birth: body.dateOfBirth,
      onboarding_completed: true,
      updated_at: new Date().toISOString(),
    };

    const { data: profile, error } = await supabaseAdmin
      .from(Tables.users)
      .update(updates)
      .eq('id', user.id)
      .select()
      .single();

    if (error) {
      throw new DatabaseError('Failed to complete onboarding');
    }

    return successResponse(
      {
        user: profile,
        message: 'Onboarding completed successfully',
      },
      request
    );
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to complete onboarding'), request);
  }
}
