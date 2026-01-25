import { createClient, SupabaseClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.SUPABASE_URL!;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

if (!supabaseUrl) {
  throw new Error('Missing SUPABASE_URL environment variable');
}

if (!supabaseServiceKey) {
  throw new Error('Missing SUPABASE_SERVICE_ROLE_KEY environment variable');
}

// Admin client with service role key - bypasses RLS
export const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
});

// Anon client for public operations
export const supabaseAnon = createClient(supabaseUrl, supabaseAnonKey);

// Create a client for a specific user's JWT
export function createUserClient(accessToken: string): SupabaseClient {
  return createClient(supabaseUrl, supabaseAnonKey, {
    global: {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    },
  });
}

// Database table names
export const Tables = {
  users: 'users',
  gyms: 'gyms',
  memberships: 'memberships',
  checkIns: 'check_ins',
  trainers: 'trainers',
  classes: 'classes',
  classSchedules: 'class_schedules',
  bookings: 'bookings',
  exercises: 'exercises',
  workouts: 'workouts',
  workoutSessions: 'workout_sessions',
  workoutLogs: 'workout_logs',
  goals: 'goals',
  bodyMetrics: 'body_metrics',
  trainingPlans: 'training_plans',
  userTrainingPlans: 'user_training_plans',
  notifications: 'notifications',
} as const;
