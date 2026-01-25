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

function getPath(params: { path?: string[] }): string {
  return params.path?.join('/') || '';
}

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ path?: string[] }> }
) {
  try {
    const { path } = await params;
    const route = getPath({ path });

    if (route === '' || route === 'list') {
      return handleListWorkouts(request);
    }
    if (route === 'exercises') {
      return handleListExercises(request);
    }
    if (route === 'public') {
      return handleListPublicWorkouts(request);
    }
    if (route === 'sessions/active') {
      return handleGetActiveSession(request);
    }
    if (route === 'history') {
      return handleGetWorkoutHistory(request);
    }
    if (route === 'stats') {
      return handleGetWorkoutStats(request);
    }
    // Check for workout by ID
    if (path?.length === 1 && path[0].match(/^[0-9a-f-]{36}$/i)) {
      return handleGetWorkout(request, path[0]);
    }

    return errorResponse(new NotFoundError('Endpoint'), request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Request failed'), request);
  }
}

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ path?: string[] }> }
) {
  try {
    const { path } = await params;
    const route = getPath({ path });

    if (route === '' || route === 'create') {
      return handleCreateWorkout(request);
    }
    if (route === 'sessions') {
      return handleStartSession(request);
    }
    // Handle sessions/[id]/log
    if (path?.length === 3 && path[0] === 'sessions' && path[2] === 'log') {
      return handleLogSet(request, path[1]);
    }
    // Handle sessions/[id]/complete
    if (path?.length === 3 && path[0] === 'sessions' && path[2] === 'complete') {
      return handleCompleteSession(request, path[1]);
    }

    return errorResponse(new NotFoundError('Endpoint'), request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Request failed'), request);
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
    .select(`*, exercises:${Tables.workoutExercises}(*, exercise:${Tables.exercises}(*))`)
    .eq('user_id', user.id)
    .order('updated_at', { ascending: false });

  if (error) throw new DatabaseError('Failed to fetch workouts');
  return successResponse({ workouts }, request);
}

async function handleGetWorkout(request: NextRequest, workoutId: string) {
  const { user } = await verifyAuth(request);

  const { data: workout, error } = await supabaseAdmin
    .from(Tables.workouts)
    .select(`*, exercises:${Tables.workoutExercises}(*, exercise:${Tables.exercises}(*))`)
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
    .select(`*, exercises:${Tables.workoutExercises}(*, exercise:${Tables.exercises}(*))`)
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

  // Create workout
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
      is_public: body.isPublic,
      is_template: false,
      created_at: now,
      updated_at: now,
    })
    .select()
    .single();

  if (error) throw new DatabaseError('Failed to create workout');

  // Add exercises if provided
  if (body.exercises && body.exercises.length > 0) {
    const exerciseData = body.exercises.map((e) => ({
      workout_id: workout.id,
      exercise_id: e.exerciseId,
      order_index: e.orderIndex,
      sets: e.sets,
      reps: e.reps,
      duration: e.duration,
      weight: e.weight,
      rest_seconds: e.restSeconds,
      notes: e.notes,
    }));

    const { error: exerciseError } = await supabaseAdmin
      .from(Tables.workoutExercises)
      .insert(exerciseData);

    if (exerciseError) throw new DatabaseError('Failed to add exercises to workout');
  }

  // Fetch complete workout with exercises
  const { data: completeWorkout } = await supabaseAdmin
    .from(Tables.workouts)
    .select(`*, exercises:${Tables.workoutExercises}(*, exercise:${Tables.exercises}(*))`)
    .eq('id', workout.id)
    .single();

  return successResponse({ workout: completeWorkout }, request, { status: 201 });
}

async function handleStartSession(request: NextRequest) {
  const { user } = await verifyAuth(request);
  const body = await parseBody(request, sessionSchema);

  // Check for existing active session
  const { data: existingSession } = await supabaseAdmin
    .from(Tables.workoutSessions)
    .select('*')
    .eq('user_id', user.id)
    .eq('status', 'in_progress')
    .single();

  if (existingSession) {
    return successResponse({ session: existingSession, message: 'Existing session found' }, request);
  }

  const { data: session, error } = await supabaseAdmin
    .from(Tables.workoutSessions)
    .insert({
      user_id: user.id,
      workout_id: body.workoutId,
      started_at: new Date().toISOString(),
      status: 'in_progress',
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
    .eq('status', 'in_progress')
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

  // Verify session belongs to user and is active
  const { data: session, error: sessionError } = await supabaseAdmin
    .from(Tables.workoutSessions)
    .select('*')
    .eq('id', sessionId)
    .eq('user_id', user.id)
    .eq('status', 'in_progress')
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
      duration: body.duration,
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

  // Verify session belongs to user and is active
  const { data: session, error: sessionError } = await supabaseAdmin
    .from(Tables.workoutSessions)
    .select(`*, logs:${Tables.workoutLogs}(*)`)
    .eq('id', sessionId)
    .eq('user_id', user.id)
    .eq('status', 'in_progress')
    .single();

  if (sessionError || !session) {
    throw new NotFoundError('Active session');
  }

  const completedAt = new Date();
  const startedAt = new Date(session.started_at);
  const durationMinutes = Math.round((completedAt.getTime() - startedAt.getTime()) / 60000);

  // Calculate totals from logs
  const logs = session.logs || [];
  const totalSets = logs.length;
  const totalReps = logs.reduce((sum: number, l: { reps?: number }) => sum + (l.reps || 0), 0);
  const totalWeight = logs.reduce((sum: number, l: { weight?: number; reps?: number }) => sum + ((l.weight || 0) * (l.reps || 1)), 0);

  const { data: updatedSession, error } = await supabaseAdmin
    .from(Tables.workoutSessions)
    .update({
      completed_at: completedAt.toISOString(),
      duration_minutes: durationMinutes,
      total_sets: totalSets,
      total_reps: totalReps,
      total_weight: totalWeight,
      status: 'completed',
    })
    .eq('id', sessionId)
    .select(`*, workout:${Tables.workouts}(*)`)
    .single();

  if (error) throw new DatabaseError('Failed to complete session');
  return successResponse({ session: updatedSession }, request);
}

async function handleGetWorkoutHistory(request: NextRequest) {
  const { user } = await verifyAuth(request);
  const searchParams = request.nextUrl.searchParams;
  const limit = parseInt(searchParams.get('limit') || '20');
  const offset = parseInt(searchParams.get('offset') || '0');

  const { data: sessions, error, count } = await supabaseAdmin
    .from(Tables.workoutSessions)
    .select(`*, workout:${Tables.workouts}(*)`, { count: 'exact' })
    .eq('user_id', user.id)
    .eq('status', 'completed')
    .order('completed_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) throw new DatabaseError('Failed to fetch workout history');
  return successResponse({ sessions, total: count }, request);
}

async function handleGetWorkoutStats(request: NextRequest) {
  const { user } = await verifyAuth(request);

  const { data: sessions, error } = await supabaseAdmin
    .from(Tables.workoutSessions)
    .select('duration_minutes, total_sets, total_reps, total_weight, completed_at')
    .eq('user_id', user.id)
    .eq('status', 'completed');

  if (error) throw new DatabaseError('Failed to fetch workout stats');

  const totalWorkouts = sessions?.length || 0;
  const totalMinutes = sessions?.reduce((sum, s) => sum + (s.duration_minutes || 0), 0) || 0;
  const totalSets = sessions?.reduce((sum, s) => sum + (s.total_sets || 0), 0) || 0;
  const totalReps = sessions?.reduce((sum, s) => sum + (s.total_reps || 0), 0) || 0;
  const totalWeight = sessions?.reduce((sum, s) => sum + (s.total_weight || 0), 0) || 0;

  // Calculate workouts this week
  const weekAgo = new Date();
  weekAgo.setDate(weekAgo.getDate() - 7);
  const workoutsThisWeek = sessions?.filter(s => s.completed_at && new Date(s.completed_at) >= weekAgo).length || 0;

  return successResponse({
    stats: {
      totalWorkouts,
      totalMinutes,
      totalSets,
      totalReps,
      totalWeightLifted: totalWeight,
      workoutsThisWeek,
      averageDurationMinutes: totalWorkouts > 0 ? Math.round(totalMinutes / totalWorkouts) : 0,
    },
  }, request);
}
