import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseBody, parseQuery } from '@/lib/utils/validation';
import { NotFoundError, DatabaseError } from '@/lib/utils/errors';

const workoutSchema = z.object({
  name: z.string().min(1, 'Name is required'),
  description: z.string().optional(),
  category: z.string().optional(),
  estimatedDuration: z.number().positive(),
  difficulty: z.enum(['beginner', 'intermediate', 'advanced']),
  targetMuscles: z.array(z.string()).optional(),
  isTemplate: z.boolean().default(false),
  isPublic: z.boolean().default(false),
  exercises: z.array(z.object({
    exerciseId: z.string().uuid(),
    orderIndex: z.number().int().min(0),
    sets: z.number().int().positive(),
    reps: z.number().int().positive().optional(),
    duration: z.number().positive().optional(),
    weight: z.number().positive().optional(),
    restSeconds: z.number().int().positive().optional(),
    notes: z.string().optional(),
  })).optional(),
});

const sessionSchema = z.object({
  workoutId: z.string().uuid().optional(),
  notes: z.string().optional(),
});

const logSetSchema = z.object({
  exerciseId: z.string().uuid(),
  setNumber: z.number().int().positive(),
  reps: z.number().int().positive().optional(),
  weight: z.number().positive().optional(),
  duration: z.number().positive().optional(),
  notes: z.string().optional(),
});

const exerciseSearchSchema = z.object({
  q: z.string().optional(),
  muscleGroup: z.string().optional(),
  exerciseType: z.string().optional(),
  difficulty: z.string().optional(),
});

function getRoute(subpath: string[]): string {
  return subpath.join('/');
}

export async function handleGet(request: NextRequest, subpath: string[]) {
  try {
    const route = getRoute(subpath);

    if (route === '' || route === 'list') {
      return await handleListWorkouts(request);
    }
    if (route === 'exercises') {
      return await handleListExercises(request);
    }
    if (route === 'public') {
      return await handleListPublicWorkouts(request);
    }
    if (route === 'sessions/active') {
      return await handleGetActiveSession(request);
    }
    if (route === 'history') {
      return await handleGetWorkoutHistory(request);
    }
    if (route === 'stats') {
      return await handleGetWorkoutStats(request);
    }
    if (subpath.length === 1 && subpath[0].match(/^[0-9a-f-]{36}$/i)) {
      return await handleGetWorkout(request, subpath[0]);
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
      return await handleCreateWorkout(request);
    }
    if (route === 'sessions') {
      return await handleStartSession(request);
    }
    if (subpath.length === 3 && subpath[0] === 'sessions' && subpath[2] === 'log') {
      return await handleLogSet(request, subpath[1]);
    }
    if (subpath.length === 3 && subpath[0] === 'sessions' && subpath[2] === 'complete') {
      return await handleCompleteSession(request, subpath[1]);
    }
    if (subpath.length === 3 && subpath[0] === 'sessions' && subpath[2] === 'cancel') {
      return await handleCancelSession(request, subpath[1]);
    }

    return errorResponse(new NotFoundError('Endpoint'), request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Handler failed'), request);
  }
}

async function handleListExercises(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const query = parseQuery(searchParams, exerciseSearchSchema);

  let dbQuery = supabaseAdmin.from(Tables.exercises).select('*');

  if (query.q) {
    dbQuery = dbQuery.or(`name.ilike.%${query.q}%,description.ilike.%${query.q}%`);
  }
  if (query.muscleGroup) {
    dbQuery = dbQuery.contains('muscle_groups', [query.muscleGroup]);
  }
  if (query.exerciseType) {
    dbQuery = dbQuery.eq('exercise_type', query.exerciseType);
  }
  if (query.difficulty) {
    dbQuery = dbQuery.eq('difficulty', query.difficulty);
  }

  const { data: exercises, error } = await dbQuery.order('name');

  if (error) throw new DatabaseError('Failed to fetch exercises');
  return successResponse({ exercises }, request);
}

async function handleListWorkouts(request: NextRequest) {
  const { user } = await verifyAuth(request);

  const { data: workouts, error } = await supabaseAdmin
    .from(Tables.workouts)
    .select('*')
    .eq('user_id', user.id)
    .order('updated_at', { ascending: false });

  if (error) throw new DatabaseError('Failed to fetch workouts');
  return successResponse({ workouts }, request);
}

async function handleGetWorkout(request: NextRequest, workoutId: string) {
  const { user } = await verifyAuth(request);

  const { data: workout, error } = await supabaseAdmin
    .from(Tables.workouts)
    .select('*')
    .eq('id', workoutId)
    .or(`user_id.eq.${user.id},is_public.eq.true`)
    .single();

  if (error) {
    if (error.code === 'PGRST116') throw new NotFoundError('Workout');
    throw new DatabaseError('Failed to fetch workout');
  }

  return successResponse({ workout }, request);
}

async function handleListPublicWorkouts(request: NextRequest) {
  const { data: workouts, error } = await supabaseAdmin
    .from(Tables.workouts)
    .select('*')
    .eq('is_public', true)
    .eq('is_template', true)
    .order('name');

  if (error) throw new DatabaseError('Failed to fetch public workouts');
  return successResponse({ workouts }, request);
}

async function handleCreateWorkout(request: NextRequest) {
  const { user } = await verifyAuth(request);
  const body = await parseBody(request, workoutSchema);
  const now = new Date().toISOString();

  const { data: workout, error } = await supabaseAdmin
    .from(Tables.workouts)
    .insert({
      user_id: user.id,
      name: body.name,
      description: body.description,
      workout_type: body.category,
      estimated_duration_minutes: body.estimatedDuration,
      difficulty: body.difficulty,
      exercises: body.exercises || [],
      is_public: body.isPublic,
      is_template: body.isTemplate,
      created_at: now,
      updated_at: now,
    })
    .select()
    .single();

  if (error) throw new DatabaseError('Failed to create workout');

  return successResponse({ workout }, request, { status: 201 });
}

async function handleStartSession(request: NextRequest) {
  const { user } = await verifyAuth(request);
  const body = await parseBody(request, sessionSchema);

  // Check for existing active session (one without completed_at)
  const { data: existingSession } = await supabaseAdmin
    .from(Tables.workoutSessions)
    .select('*')
    .eq('user_id', user.id)
    .is('completed_at', null)
    .single();

  if (existingSession) {
    return successResponse({ session: existingSession, message: 'Existing session found' }, request);
  }

  const { data: session, error } = await supabaseAdmin
    .from(Tables.workoutSessions)
    .insert({
      user_id: user.id,
      workout_id: body.workoutId,
      notes: body.notes,
      name: body.workoutId ? '' : 'Quick Workout',
      started_at: new Date().toISOString(),
    })
    .select(`*, workout:${Tables.workouts}(*)`)
    .single();

  if (error) throw new DatabaseError('Failed to start session');
  return successResponse({ session }, request, { status: 201 });
}

async function handleGetActiveSession(request: NextRequest) {
  const { user } = await verifyAuth(request);

  const { data: session, error } = await supabaseAdmin
    .from(Tables.workoutSessions)
    .select(`*, workout:${Tables.workouts}(*), logs:${Tables.workoutLogs}(*)`)
    .eq('user_id', user.id)
    .is('completed_at', null)
    .single();

  if (error) {
    if (error.code === 'PGRST116') {
      return successResponse({ session: null }, request);
    }
    throw new DatabaseError('Failed to fetch active session');
  }

  return successResponse({ session }, request);
}

async function handleLogSet(request: NextRequest, sessionId: string) {
  const { user } = await verifyAuth(request);
  const body = await parseBody(request, logSetSchema);

  const { data: session, error: sessionError } = await supabaseAdmin
    .from(Tables.workoutSessions)
    .select('*')
    .eq('id', sessionId)
    .eq('user_id', user.id)
    .is('completed_at', null)
    .single();

  if (sessionError || !session) {
    throw new NotFoundError('Active session');
  }

  const { data: log, error } = await supabaseAdmin
    .from(Tables.workoutLogs)
    .insert({
      session_id: sessionId,
      exercise_id: body.exerciseId,
      set_number: body.setNumber,
      reps: body.reps,
      weight: body.weight,
      duration_seconds: body.duration,
      notes: body.notes,
      completed_at: new Date().toISOString(),
    })
    .select()
    .single();

  if (error) throw new DatabaseError('Failed to log set');
  return successResponse({ log }, request, { status: 201 });
}

async function handleCompleteSession(request: NextRequest, sessionId: string) {
  const { user } = await verifyAuth(request);

  const { data: session, error: sessionError } = await supabaseAdmin
    .from(Tables.workoutSessions)
    .select(`*, logs:${Tables.workoutLogs}(*)`)
    .eq('id', sessionId)
    .eq('user_id', user.id)
    .is('completed_at', null)
    .single();

  if (sessionError || !session) {
    throw new NotFoundError('Active session');
  }

  const completedAt = new Date();
  const startedAt = new Date(session.started_at);
  const durationMinutes = Math.round((completedAt.getTime() - startedAt.getTime()) / 60000);

  const logs = session.logs || [];
  const totalSets = logs.length;
  const totalReps = logs.reduce((sum: number, l: { reps?: number }) => sum + (l.reps || 0), 0);
  const totalVolume = logs.reduce((sum: number, l: { weight?: number; reps?: number }) => sum + ((l.weight || 0) * (l.reps || 1)), 0);

  const { data: updatedSession, error } = await supabaseAdmin
    .from(Tables.workoutSessions)
    .update({
      completed_at: completedAt.toISOString(),
      duration_minutes: durationMinutes,
      total_sets: totalSets,
      total_reps: totalReps,
      total_volume: totalVolume,
      status: 'completed',
    })
    .eq('id', sessionId)
    .select(`*, workout:${Tables.workouts}(*)`)
    .single();

  if (error) throw new DatabaseError('Failed to complete session');
  return successResponse({ session: updatedSession }, request);
}

async function handleCancelSession(request: NextRequest, sessionId: string) {
  const { user } = await verifyAuth(request);

  const { data: session, error: sessionError } = await supabaseAdmin
    .from(Tables.workoutSessions)
    .select('*')
    .eq('id', sessionId)
    .eq('user_id', user.id)
    .is('completed_at', null)
    .single();

  if (sessionError || !session) {
    throw new NotFoundError('Active session');
  }

  const { data: cancelledSession, error } = await supabaseAdmin
    .from(Tables.workoutSessions)
    .update({
      status: 'cancelled',
      completed_at: new Date().toISOString(),
    })
    .eq('id', sessionId)
    .select()
    .single();

  if (error) throw new DatabaseError('Failed to cancel session');
  return successResponse({ session: cancelledSession, message: 'Session cancelled successfully' }, request);
}

async function handleGetWorkoutHistory(request: NextRequest) {
  const { user } = await verifyAuth(request);
  const searchParams = request.nextUrl.searchParams;
  const limit = parseInt(searchParams.get('limit') || '20');
  const offset = parseInt(searchParams.get('offset') || '0');
  const startDate = searchParams.get('startDate');
  const endDate = searchParams.get('endDate');

  let dbQuery = supabaseAdmin
    .from(Tables.workoutSessions)
    .select(`*, workout:${Tables.workouts}(*)`, { count: 'exact' })
    .eq('user_id', user.id)
    .not('completed_at', 'is', null);

  if (startDate) {
    const start = new Date(startDate);
    start.setHours(0, 0, 0, 0);
    dbQuery = dbQuery.gte('completed_at', start.toISOString());
  }
  if (endDate) {
    const end = new Date(endDate);
    end.setHours(23, 59, 59, 999);
    dbQuery = dbQuery.lte('completed_at', end.toISOString());
  }

  const { data: sessions, error, count } = await dbQuery
    .order('completed_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) throw new DatabaseError('Failed to fetch workout history');
  return successResponse({ sessions, total: count }, request);
}

async function handleGetWorkoutStats(request: NextRequest) {
  const { user } = await verifyAuth(request);

  const { data: sessions, error } = await supabaseAdmin
    .from(Tables.workoutSessions)
    .select('duration_minutes, total_sets, total_reps, total_volume, completed_at')
    .eq('user_id', user.id)
    .not('completed_at', 'is', null);

  if (error) throw new DatabaseError('Failed to fetch workout stats');

  const totalWorkouts = sessions?.length || 0;
  const totalMinutes = sessions?.reduce((sum, s) => sum + (s.duration_minutes || 0), 0) || 0;
  const totalSets = sessions?.reduce((sum, s) => sum + (s.total_sets || 0), 0) || 0;
  const totalReps = sessions?.reduce((sum, s) => sum + (s.total_reps || 0), 0) || 0;
  const totalVolume = sessions?.reduce((sum, s) => sum + (Number(s.total_volume) || 0), 0) || 0;

  const weekAgo = new Date();
  weekAgo.setDate(weekAgo.getDate() - 7);
  const workoutsThisWeek = sessions?.filter(s => s.completed_at && new Date(s.completed_at) >= weekAgo).length || 0;

  return successResponse({
    stats: {
      totalWorkouts,
      totalMinutes,
      totalSets,
      totalReps,
      totalWeightLifted: totalVolume,
      workoutsThisWeek,
      averageDurationMinutes: totalWorkouts > 0 ? Math.round(totalMinutes / totalWorkouts) : 0,
    },
  }, request);
}
