import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseBody } from '@/lib/utils/validation';
import { DatabaseError } from '@/lib/utils/errors';

const createWorkoutSchema = z.object({
  name: z.string().min(1),
  description: z.string().optional(),
  category: z.string().optional(),
  estimatedDuration: z.number().int().positive(),
  difficulty: z.enum(['beginner', 'intermediate', 'advanced']),
  targetMuscles: z.array(z.string()).optional(),
  isTemplate: z.boolean().default(false),
  isPublic: z.boolean().default(false),
});

export async function GET(request: NextRequest) {
  try {
    const { user } = await verifyAuth(request);

    const { data: workouts, error } = await supabaseAdmin
      .from(Tables.workouts)
      .select('*')
      .eq('user_id', user.id)
      .order('created_at', { ascending: false });

    if (error) {
      throw new DatabaseError('Failed to fetch workouts');
    }

    return successResponse({ workouts }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to fetch workouts'), request);
  }
}

export async function POST(request: NextRequest) {
  try {
    const { user } = await verifyAuth(request);
    const body = await parseBody(request, createWorkoutSchema);

    const { data: workout, error } = await supabaseAdmin
      .from(Tables.workouts)
      .insert({
        user_id: user.id,
        name: body.name,
        description: body.description,
        category: body.category,
        estimated_duration: body.estimatedDuration,
        difficulty: body.difficulty,
        target_muscles: body.targetMuscles,
        is_template: body.isTemplate,
        is_public: body.isPublic,
      })
      .select()
      .single();

    if (error) {
      throw new DatabaseError('Failed to create workout');
    }

    return successResponse({ workout }, request, { status: 201 });
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to create workout'), request);
  }
}
