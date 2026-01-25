// Database types for Supabase tables

export interface User {
  id: string;
  email: string;
  full_name: string;
  avatar_url?: string;
  phone?: string;
  gender?: string;
  date_of_birth?: string;
  height_cm?: number;
  fitness_level?: string;
  fitness_goals?: string[];
  onboarding_completed: boolean;
  created_at: string;
  updated_at: string;
}

export interface Gym {
  id: string;
  name: string;
  slug: string;
  address: string;
  city: string;
  country: string;
  phone?: string;
  email?: string;
  latitude?: number;
  longitude?: number;
  description?: string;
  amenities?: string[];
  images?: string[];
  opening_hours?: Record<string, { open: string; close: string }>;
  capacity?: number;
  current_occupancy?: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Membership {
  id: string;
  user_id: string;
  gym_id: string;
  plan_type: 'basic' | 'premium' | 'vip';
  status: 'active' | 'paused' | 'expired' | 'cancelled';
  start_date: string;
  end_date: string;
  qr_code: string;
  home_gym_id?: string;
  access_all_locations: boolean;
  auto_renew: boolean;
  created_at: string;
  updated_at: string;
  gym?: Gym;
}

export interface CheckIn {
  id: string;
  user_id: string;
  gym_id: string;
  membership_id: string;
  checked_in_at: string;
  checked_out_at?: string;
  duration_minutes?: number;
  gym?: Gym;
}

export interface Exercise {
  id: string;
  name: string;
  description?: string;
  exercise_type: string;
  muscle_groups: string[];
  equipment?: string[];
  difficulty?: string;
  instructions?: string[];
  image_url?: string;
  video_url?: string;
  created_at: string;
}

export interface Workout {
  id: string;
  user_id: string;
  name: string;
  description?: string;
  category?: string;
  estimated_duration: number;
  difficulty: string;
  target_muscles?: string[];
  is_template: boolean;
  is_public: boolean;
  created_at: string;
  updated_at: string;
}

export interface WorkoutExercise {
  id: string;
  workout_id: string;
  exercise_id: string;
  order_index: number;
  sets: number;
  reps?: number;
  duration?: number;
  weight?: number;
  rest_seconds?: number;
  notes?: string;
  exercise?: Exercise;
}

export interface WorkoutSession {
  id: string;
  user_id: string;
  workout_id?: string;
  started_at: string;
  completed_at?: string;
  duration_minutes?: number;
  total_sets?: number;
  total_reps?: number;
  total_weight?: number;
  status: 'in_progress' | 'completed' | 'cancelled';
  notes?: string;
  workout?: Workout;
}

export interface WorkoutLog {
  id: string;
  session_id: string;
  exercise_id: string;
  set_number: number;
  reps?: number;
  weight?: number;
  duration?: number;
  notes?: string;
  completed_at: string;
}

export interface GymClass {
  id: string;
  gym_id: string;
  name: string;
  description?: string;
  category: string;
  duration_minutes: number;
  max_capacity: number;
  difficulty?: string;
  instructor_name?: string;
  is_active: boolean;
  created_at: string;
}

export interface ClassSchedule {
  id: string;
  gym_id: string;
  class_id: string;
  scheduled_at: string;
  spots_remaining: number;
  is_cancelled: boolean;
  gym_class?: GymClass;
}

export interface Booking {
  id: string;
  user_id: string;
  class_schedule_id: string;
  status: 'confirmed' | 'waitlist' | 'cancelled' | 'attended';
  booked_at: string;
  cancelled_at?: string;
  schedule?: ClassSchedule;
}
