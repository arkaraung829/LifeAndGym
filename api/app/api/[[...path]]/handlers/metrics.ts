import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseBody, parseQuery } from '@/lib/utils/validation';
import { NotFoundError, DatabaseError } from '@/lib/utils/errors';

// Zod schemas
const measurementsSchema = z.object({
  chest: z.number().positive('Chest measurement must be positive').optional(),
  waist: z.number().positive('Waist measurement must be positive').optional(),
  hips: z.number().positive('Hips measurement must be positive').optional(),
  arms: z.number().positive('Arms measurement must be positive').optional(),
  thighs: z.number().positive('Thighs measurement must be positive').optional(),
});

const createMetricsSchema = z.object({
  recordedAt: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid recorded date'),
  weight: z.number().positive('Weight must be positive').optional(),
  weightUnit: z.string().default('kg').optional(),
  bodyFat: z.number().min(0, 'Body fat must be at least 0').max(100, 'Body fat must be at most 100').optional(),
  muscleMass: z.number().positive('Muscle mass must be positive').optional(),
  bmi: z.number().positive('BMI must be positive').optional(),
  measurements: measurementsSchema.optional(),
  notes: z.string().max(500, 'Notes must be 500 characters or less').optional(),
});

const updateMetricsSchema = createMetricsSchema;

const getMetricsQuerySchema = z.object({
  startDate: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid start date').optional(),
  endDate: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid end date').optional(),
});

const getTrendsQuerySchema = z.object({
  days: z.coerce.number().int().positive().default(30),
});

function getRoute(subpath: string[]): string {
  return subpath.join('/');
}

export async function handleGet(request: NextRequest, subpath: string[]) {
  try {
    const route = getRoute(subpath);

    if (route === '' || route === 'list') {
      return await handleGetMetrics(request);
    }
    if (route === 'trends') {
      return await handleGetTrends(request);
    }
    if (subpath.length === 1 && subpath[0].match(/^[0-9a-f-]{36}$/i)) {
      return await handleGetMetric(request, subpath[0]);
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
      return await handleCreateMetric(request);
    }

    return errorResponse(new NotFoundError('Endpoint'), request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Handler failed'), request);
  }
}

export async function handlePatch(request: NextRequest, subpath: string[]) {
  try {
    if (subpath.length === 1 && subpath[0].match(/^[0-9a-f-]{36}$/i)) {
      return await handleUpdateMetric(request, subpath[0]);
    }

    return errorResponse(new NotFoundError('Endpoint'), request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Handler failed'), request);
  }
}

export async function handleDelete(request: NextRequest, subpath: string[]) {
  try {
    if (subpath.length === 1 && subpath[0].match(/^[0-9a-f-]{36}$/i)) {
      return await handleDeleteMetric(request, subpath[0]);
    }

    return errorResponse(new NotFoundError('Endpoint'), request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Handler failed'), request);
  }
}

async function handleGetMetrics(request: NextRequest) {
  const { user } = await verifyAuth(request);

  const { searchParams } = new URL(request.url);
  const query = parseQuery(searchParams, getMetricsQuerySchema);

  let queryBuilder = supabaseAdmin
    .from(Tables.bodyMetrics)
    .select('*')
    .eq('user_id', user.id);

  // Apply date filters if provided
  if (query.startDate) {
    queryBuilder = queryBuilder.gte('recorded_at', query.startDate);
  }
  if (query.endDate) {
    queryBuilder = queryBuilder.lte('recorded_at', query.endDate);
  }

  const { data: metrics, error } = await queryBuilder.order('recorded_at', { ascending: false });

  if (error) throw new DatabaseError('Failed to fetch body metrics');
  return successResponse({ metrics }, request);
}

async function handleGetMetric(request: NextRequest, metricId: string) {
  const { user } = await verifyAuth(request);

  const { data: metric, error } = await supabaseAdmin
    .from(Tables.bodyMetrics)
    .select('*')
    .eq('id', metricId)
    .eq('user_id', user.id)
    .single();

  if (error) {
    if (error.code === 'PGRST116') throw new NotFoundError('Body metric');
    throw new DatabaseError('Failed to fetch body metric');
  }

  return successResponse({ metric }, request);
}

async function handleCreateMetric(request: NextRequest) {
  const { user } = await verifyAuth(request);
  const body = await parseBody(request, createMetricsSchema);

  const now = new Date().toISOString();

  const { data: metric, error } = await supabaseAdmin
    .from(Tables.bodyMetrics)
    .insert({
      user_id: user.id,
      recorded_at: body.recordedAt,
      weight: body.weight,
      weight_unit: body.weightUnit || 'kg',
      body_fat: body.bodyFat,
      muscle_mass: body.muscleMass,
      bmi: body.bmi,
      measurements: body.measurements,
      notes: body.notes,
      created_at: now,
      updated_at: now,
    })
    .select()
    .single();

  if (error) throw new DatabaseError('Failed to create body metric');

  return successResponse({ metric }, request, { status: 201 });
}

async function handleUpdateMetric(request: NextRequest, metricId: string) {
  const { user } = await verifyAuth(request);
  const body = await parseBody(request, updateMetricsSchema.partial());

  // First, verify the metric exists and belongs to the user
  const { data: existingMetric, error: fetchError } = await supabaseAdmin
    .from(Tables.bodyMetrics)
    .select('id')
    .eq('id', metricId)
    .eq('user_id', user.id)
    .single();

  if (fetchError || !existingMetric) {
    throw new NotFoundError('Body metric');
  }

  const now = new Date().toISOString();
  const updateData: Record<string, unknown> = {
    updated_at: now,
  };

  if (body.recordedAt !== undefined) updateData.recorded_at = body.recordedAt;
  if (body.weight !== undefined) updateData.weight = body.weight;
  if (body.weightUnit !== undefined) updateData.weight_unit = body.weightUnit;
  if (body.bodyFat !== undefined) updateData.body_fat = body.bodyFat;
  if (body.muscleMass !== undefined) updateData.muscle_mass = body.muscleMass;
  if (body.bmi !== undefined) updateData.bmi = body.bmi;
  if (body.measurements !== undefined) updateData.measurements = body.measurements;
  if (body.notes !== undefined) updateData.notes = body.notes;

  const { data: metric, error } = await supabaseAdmin
    .from(Tables.bodyMetrics)
    .update(updateData)
    .eq('id', metricId)
    .eq('user_id', user.id)
    .select()
    .single();

  if (error) throw new DatabaseError('Failed to update body metric');

  return successResponse({ metric }, request);
}

async function handleDeleteMetric(request: NextRequest, metricId: string) {
  const { user } = await verifyAuth(request);

  // First, verify the metric exists and belongs to the user
  const { data: existingMetric, error: fetchError } = await supabaseAdmin
    .from(Tables.bodyMetrics)
    .select('id')
    .eq('id', metricId)
    .eq('user_id', user.id)
    .single();

  if (fetchError || !existingMetric) {
    throw new NotFoundError('Body metric');
  }

  const { error } = await supabaseAdmin
    .from(Tables.bodyMetrics)
    .delete()
    .eq('id', metricId)
    .eq('user_id', user.id);

  if (error) throw new DatabaseError('Failed to delete body metric');

  return successResponse({ message: 'Body metric deleted successfully' }, request);
}

async function handleGetTrends(request: NextRequest) {
  const { user } = await verifyAuth(request);

  const { searchParams } = new URL(request.url);
  const query = parseQuery(searchParams, getTrendsQuerySchema);

  // Calculate startDate based on days parameter
  const now = new Date();
  const startDate = new Date(now.getTime() - query.days * 24 * 60 * 60 * 1000);
  const startDateString = startDate.toISOString();

  const { data: metrics, error } = await supabaseAdmin
    .from(Tables.bodyMetrics)
    .select('recorded_at, weight, body_fat')
    .eq('user_id', user.id)
    .gte('recorded_at', startDateString)
    .order('recorded_at', { ascending: true });

  if (error) throw new DatabaseError('Failed to fetch body metrics trends');

  // Calculate trends
  const weightTrend = metrics
    .filter((m) => m.weight !== null && m.weight !== undefined)
    .map((m) => ({
      date: m.recorded_at,
      value: m.weight,
    }));

  const bodyFatTrend = metrics
    .filter((m) => m.body_fat !== null && m.body_fat !== undefined)
    .map((m) => ({
      date: m.recorded_at,
      value: m.body_fat,
    }));

  return successResponse(
    {
      weightTrend,
      bodyFatTrend,
    },
    request
  );
}
