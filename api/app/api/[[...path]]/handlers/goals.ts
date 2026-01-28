import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseBody } from '@/lib/utils/validation';
import { NotFoundError, DatabaseError, ValidationError } from '@/lib/utils/errors';

// Zod schemas
const createGoalSchema = z.object({
  name: z.string().min(1, 'Name is required').max(100, 'Name must be 100 characters or less'),
  description: z.string().optional(),
  type: z.enum(['weight_loss', 'muscle_gain', 'strength', 'endurance', 'flexibility', 'body_fat', 'consistency']),
  targetValue: z.number().positive('Target value must be positive'),
  currentValue: z.number().nonnegative('Current value must be non-negative').default(0),
  unit: z.string().min(1, 'Unit is required').max(20, 'Unit must be 20 characters or less'),
  startDate: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid start date'),
  targetDate: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid target date'),
});

const updateProgressSchema = z.object({
  currentValue: z.number().nonnegative('Current value must be non-negative'),
});

function getRoute(subpath: string[]): string {
  return subpath.join('/');
}

export async function handleGet(request: NextRequest, subpath: string[]) {
  try {
    const route = getRoute(subpath);

    if (route === '' || route === 'list') {
      return await handleGetGoals(request);
    }
    if (subpath.length === 1 && subpath[0].match(/^[0-9a-f-]{36}$/i)) {
      return await handleGetGoal(request, subpath[0]);
    }

    return errorResponse(new NotFoundError('Endpoint'), request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Handler failed'), request);
  }
}

export async function handlePost(request: NextRequest, subpath: string[]) {
  try {
    const route = getRoute(subpath);

    if (route === '' || route === 'create') {
      return await handleCreateGoal(request);
    }

    return errorResponse(new NotFoundError('Endpoint'), request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Handler failed'), request);
  }
}

export async function handlePatch(request: NextRequest, subpath: string[]) {
  try {
    if (subpath.length === 2 && subpath[1] === 'progress') {
      return await handleUpdateProgress(request, subpath[0]);
    }
    if (subpath.length === 1 && subpath[0].match(/^[0-9a-f-]{36}$/i)) {
      return await handleUpdateGoal(request, subpath[0]);
    }

    return errorResponse(new NotFoundError('Endpoint'), request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Handler failed'), request);
  }
}

export async function handleDelete(request: NextRequest, subpath: string[]) {
  try {
    if (subpath.length === 1 && subpath[0].match(/^[0-9a-f-]{36}$/i)) {
      return await handleDeleteGoal(request, subpath[0]);
    }

    return errorResponse(new NotFoundError('Endpoint'), request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Handler failed'), request);
  }
}

async function handleGetGoals(request: NextRequest) {
  const { user } = await verifyAuth(request);

  const { data: goals, error } = await supabaseAdmin
    .from(Tables.goals)
    .select('*')
    .eq('user_id', user.id)
    .order('created_at', { ascending: false });

  if (error) throw new DatabaseError('Failed to fetch goals');
  return successResponse({ goals }, request);
}

async function handleGetGoal(request: NextRequest, goalId: string) {
  const { user } = await verifyAuth(request);

  const { data: goal, error } = await supabaseAdmin
    .from(Tables.goals)
    .select('*')
    .eq('id', goalId)
    .eq('user_id', user.id)
    .single();

  if (error) {
    if (error.code === 'PGRST116') throw new NotFoundError('Goal');
    throw new DatabaseError('Failed to fetch goal');
  }

  return successResponse({ goal }, request);
}

async function handleCreateGoal(request: NextRequest) {
  const { user } = await verifyAuth(request);
  const body = await parseBody(request, createGoalSchema);

  // Validate targetDate is after startDate
  const startDate = new Date(body.startDate);
  const targetDate = new Date(body.targetDate);

  if (targetDate <= startDate) {
    throw new ValidationError('Target date must be after start date');
  }

  const now = new Date().toISOString();

  const { data: goal, error } = await supabaseAdmin
    .from(Tables.goals)
    .insert({
      user_id: user.id,
      name: body.name,
      description: body.description,
      type: body.type,
      target_value: body.targetValue,
      current_value: body.currentValue,
      unit: body.unit,
      start_date: body.startDate,
      target_date: body.targetDate,
      status: 'active',
      created_at: now,
      updated_at: now,
    })
    .select()
    .single();

  if (error) throw new DatabaseError('Failed to create goal');

  return successResponse({ goal }, request, { status: 201 });
}

async function handleUpdateProgress(request: NextRequest, goalId: string) {
  const { user } = await verifyAuth(request);
  const body = await parseBody(request, updateProgressSchema);

  // First, verify the goal exists and belongs to the user
  const { data: existingGoal, error: fetchError } = await supabaseAdmin
    .from(Tables.goals)
    .select('*')
    .eq('id', goalId)
    .eq('user_id', user.id)
    .single();

  if (fetchError || !existingGoal) {
    throw new NotFoundError('Goal');
  }

  const now = new Date().toISOString();

  // Check if goal should be marked as completed
  const shouldComplete = body.currentValue >= existingGoal.target_value;
  const newStatus = shouldComplete ? 'completed' : existingGoal.status;

  const { data: goal, error } = await supabaseAdmin
    .from(Tables.goals)
    .update({
      current_value: body.currentValue,
      status: newStatus,
      updated_at: now,
    })
    .eq('id', goalId)
    .eq('user_id', user.id)
    .select()
    .single();

  if (error) throw new DatabaseError('Failed to update goal progress');

  return successResponse({ goal }, request);
}

async function handleUpdateGoal(request: NextRequest, goalId: string) {
  const { user } = await verifyAuth(request);
  const body = await parseBody(request, createGoalSchema.partial());

  // First, verify the goal exists and belongs to the user
  const { data: existingGoal, error: fetchError } = await supabaseAdmin
    .from(Tables.goals)
    .select('*')
    .eq('id', goalId)
    .eq('user_id', user.id)
    .single();

  if (fetchError || !existingGoal) {
    throw new NotFoundError('Goal');
  }

  // Validate dates if both are being updated or one is being updated
  if (body.startDate || body.targetDate) {
    const startDate = new Date(body.startDate || existingGoal.start_date);
    const targetDate = new Date(body.targetDate || existingGoal.target_date);

    if (targetDate <= startDate) {
      throw new ValidationError('Target date must be after start date');
    }
  }

  const now = new Date().toISOString();
  const updateData: Record<string, unknown> = {
    updated_at: now,
  };

  if (body.name !== undefined) updateData.name = body.name;
  if (body.description !== undefined) updateData.description = body.description;
  if (body.type !== undefined) updateData.type = body.type;
  if (body.targetValue !== undefined) updateData.target_value = body.targetValue;
  if (body.currentValue !== undefined) updateData.current_value = body.currentValue;
  if (body.unit !== undefined) updateData.unit = body.unit;
  if (body.startDate !== undefined) updateData.start_date = body.startDate;
  if (body.targetDate !== undefined) updateData.target_date = body.targetDate;

  const { data: goal, error } = await supabaseAdmin
    .from(Tables.goals)
    .update(updateData)
    .eq('id', goalId)
    .eq('user_id', user.id)
    .select()
    .single();

  if (error) throw new DatabaseError('Failed to update goal');

  return successResponse({ goal }, request);
}

async function handleDeleteGoal(request: NextRequest, goalId: string) {
  const { user } = await verifyAuth(request);

  // First, verify the goal exists and belongs to the user
  const { data: existingGoal, error: fetchError } = await supabaseAdmin
    .from(Tables.goals)
    .select('id')
    .eq('id', goalId)
    .eq('user_id', user.id)
    .single();

  if (fetchError || !existingGoal) {
    throw new NotFoundError('Goal');
  }

  const { error } = await supabaseAdmin
    .from(Tables.goals)
    .delete()
    .eq('id', goalId)
    .eq('user_id', user.id);

  if (error) throw new DatabaseError('Failed to delete goal');

  return successResponse({ message: 'Goal deleted successfully' }, request);
}
