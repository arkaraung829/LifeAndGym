-- ============================================
-- LifeAndGym Database Schema
-- Migration 00002: Workouts and Exercises
-- ============================================

-- ============================================
-- EXERCISES TABLE
-- ============================================
CREATE TABLE exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  instructions TEXT[], -- Step-by-step instructions
  muscle_groups TEXT[] NOT NULL, -- ['chest', 'triceps', 'shoulders']
  equipment TEXT[], -- ['barbell', 'bench', 'dumbbells']
  difficulty TEXT CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  exercise_type TEXT CHECK (exercise_type IN ('strength', 'cardio', 'flexibility', 'balance')),
  video_url TEXT,
  image_url TEXT,
  thumbnail_url TEXT,
  calories_per_minute DECIMAL(5, 2),
  is_compound BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Full-text search index
CREATE INDEX idx_exercises_search ON exercises
  USING GIN(to_tsvector('english', name || ' ' || COALESCE(description, '')));
CREATE INDEX idx_exercises_muscle ON exercises USING GIN(muscle_groups);
CREATE INDEX idx_exercises_type ON exercises(exercise_type);

-- ============================================
-- WORKOUTS TABLE (Templates)
-- ============================================
CREATE TABLE workouts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE, -- NULL for system templates
  name TEXT NOT NULL,
  description TEXT,
  workout_type TEXT CHECK (workout_type IN ('strength', 'cardio', 'hiit', 'flexibility', 'mixed')),
  difficulty TEXT CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  estimated_duration_minutes INTEGER,
  is_template BOOLEAN DEFAULT FALSE, -- System-provided template
  is_public BOOLEAN DEFAULT FALSE, -- User shared publicly
  exercises JSONB NOT NULL, -- Array of {exercise_id, sets, reps, weight, rest_seconds, order}
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER update_workouts_updated_at
  BEFORE UPDATE ON workouts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX idx_workouts_user ON workouts(user_id);
CREATE INDEX idx_workouts_type ON workouts(workout_type);
CREATE INDEX idx_workouts_templates ON workouts(is_template) WHERE is_template = TRUE;

-- ============================================
-- WORKOUT SESSIONS TABLE
-- ============================================
CREATE TABLE workout_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  workout_id UUID REFERENCES workouts(id) ON DELETE SET NULL,
  gym_id UUID REFERENCES gyms(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  duration_minutes INTEGER,
  total_volume DECIMAL(10, 2), -- Total weight lifted (sets * reps * weight)
  total_reps INTEGER,
  total_sets INTEGER,
  calories_burned INTEGER,
  notes TEXT,
  rating INTEGER CHECK (rating BETWEEN 1 AND 5),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_workout_sessions_user ON workout_sessions(user_id);
CREATE INDEX idx_workout_sessions_date ON workout_sessions(user_id, started_at DESC);

-- ============================================
-- WORKOUT LOGS TABLE (Individual Sets)
-- ============================================
CREATE TABLE workout_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  set_number INTEGER NOT NULL,
  reps INTEGER,
  weight DECIMAL(7, 2),
  weight_unit TEXT DEFAULT 'lbs' CHECK (weight_unit IN ('lbs', 'kg')),
  duration_seconds INTEGER, -- For timed exercises
  distance DECIMAL(10, 2), -- For cardio (meters)
  rest_seconds INTEGER,
  rpe INTEGER CHECK (rpe BETWEEN 1 AND 10), -- Rate of Perceived Exertion
  is_warmup BOOLEAN DEFAULT FALSE,
  is_dropset BOOLEAN DEFAULT FALSE,
  is_failure BOOLEAN DEFAULT FALSE,
  notes TEXT,
  completed_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_workout_logs_session ON workout_logs(session_id);
CREATE INDEX idx_workout_logs_exercise ON workout_logs(exercise_id);

-- ============================================
-- TRAINING PLANS TABLE
-- ============================================
CREATE TABLE training_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  duration_weeks INTEGER NOT NULL,
  difficulty TEXT CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  goal_type TEXT CHECK (goal_type IN ('weight_loss', 'muscle_gain', 'strength', 'endurance', 'general_fitness')),
  workouts_per_week INTEGER NOT NULL,
  plan_structure JSONB NOT NULL, -- Weekly workout templates
  equipment_needed TEXT[],
  image_url TEXT,
  is_premium BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_by UUID REFERENCES users(id), -- NULL for system plans
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER update_training_plans_updated_at
  BEFORE UPDATE ON training_plans
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX idx_training_plans_goal ON training_plans(goal_type);
CREATE INDEX idx_training_plans_difficulty ON training_plans(difficulty);

-- ============================================
-- USER TRAINING PLANS TABLE
-- ============================================
CREATE TABLE user_training_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  plan_id UUID NOT NULL REFERENCES training_plans(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'paused', 'completed', 'abandoned')),
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  current_week INTEGER DEFAULT 1,
  completed_workouts INTEGER DEFAULT 0,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, plan_id)
);

CREATE INDEX idx_user_training_plans_user ON user_training_plans(user_id);

-- ============================================
-- GOALS TABLE
-- ============================================
CREATE TABLE goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('weight', 'body_fat', 'strength', 'cardio', 'workout_frequency', 'custom')),
  name TEXT NOT NULL,
  description TEXT,
  target_value DECIMAL(10, 2) NOT NULL,
  current_value DECIMAL(10, 2) DEFAULT 0,
  unit TEXT, -- 'lbs', 'kg', '%', 'sessions', 'minutes'
  start_date DATE NOT NULL DEFAULT CURRENT_DATE,
  target_date DATE,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'abandoned')),
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER update_goals_updated_at
  BEFORE UPDATE ON goals
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX idx_goals_user ON goals(user_id);
CREATE INDEX idx_goals_status ON goals(status) WHERE status = 'active';

-- ============================================
-- BODY METRICS TABLE
-- ============================================
CREATE TABLE body_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  weight DECIMAL(5, 2),
  weight_unit TEXT DEFAULT 'lbs' CHECK (weight_unit IN ('lbs', 'kg')),
  body_fat_percentage DECIMAL(4, 2),
  muscle_mass DECIMAL(5, 2),
  bmi DECIMAL(4, 2),
  waist_cm DECIMAL(5, 2),
  chest_cm DECIMAL(5, 2),
  arms_cm DECIMAL(5, 2),
  thighs_cm DECIMAL(5, 2),
  notes TEXT,
  source TEXT DEFAULT 'manual' CHECK (source IN ('manual', 'smart_scale', 'gym_scan')),
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_body_metrics_user_date ON body_metrics(user_id, recorded_at DESC);

-- ============================================
-- NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('class_reminder', 'booking_confirmed', 'booking_cancelled', 'goal_achieved', 'streak', 'promotion', 'system')),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB, -- Additional data for deep linking
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE body_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_training_plans ENABLE ROW LEVEL SECURITY;

-- Workout sessions policies
CREATE POLICY "Users can manage own workout sessions" ON workout_sessions
  FOR ALL USING (auth.uid() = user_id);

-- Workout logs policies
CREATE POLICY "Users can manage own workout logs" ON workout_logs
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM workout_sessions
      WHERE workout_sessions.id = workout_logs.session_id
      AND workout_sessions.user_id = auth.uid()
    )
  );

-- Goals policies
CREATE POLICY "Users can manage own goals" ON goals
  FOR ALL USING (auth.uid() = user_id);

-- Body metrics policies
CREATE POLICY "Users can manage own body metrics" ON body_metrics
  FOR ALL USING (auth.uid() = user_id);

-- Notifications policies
CREATE POLICY "Users can view own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- User training plans policies
CREATE POLICY "Users can manage own training plans" ON user_training_plans
  FOR ALL USING (auth.uid() = user_id);

-- Public read access
CREATE POLICY "Anyone can view exercises" ON exercises
  FOR SELECT USING (is_active = TRUE);

CREATE POLICY "Anyone can view workouts templates" ON workouts
  FOR SELECT USING (is_template = TRUE OR is_public = TRUE OR user_id = auth.uid());

CREATE POLICY "Users can manage own workouts" ON workouts
  FOR ALL USING (user_id = auth.uid() OR user_id IS NULL);

CREATE POLICY "Anyone can view active training plans" ON training_plans
  FOR SELECT USING (is_active = TRUE);

-- ============================================
-- FUNCTIONS FOR STATS
-- ============================================

-- Function to get personal records for a user
CREATE OR REPLACE FUNCTION get_personal_records(p_user_id UUID)
RETURNS TABLE (
  exercise_id UUID,
  exercise_name TEXT,
  max_weight DECIMAL,
  max_reps INTEGER,
  achieved_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT ON (wl.exercise_id)
    wl.exercise_id,
    e.name AS exercise_name,
    wl.weight AS max_weight,
    wl.reps AS max_reps,
    wl.completed_at AS achieved_at
  FROM workout_logs wl
  JOIN workout_sessions ws ON wl.session_id = ws.id
  JOIN exercises e ON wl.exercise_id = e.id
  WHERE ws.user_id = p_user_id
    AND wl.weight IS NOT NULL
    AND wl.is_warmup = FALSE
  ORDER BY wl.exercise_id, wl.weight DESC, wl.reps DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to calculate workout streak
CREATE OR REPLACE FUNCTION get_workout_streak(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
  streak INTEGER := 0;
  check_date DATE := CURRENT_DATE;
  has_workout BOOLEAN;
BEGIN
  LOOP
    SELECT EXISTS (
      SELECT 1 FROM workout_sessions
      WHERE user_id = p_user_id
        AND DATE(started_at) = check_date
        AND completed_at IS NOT NULL
    ) INTO has_workout;

    IF has_workout THEN
      streak := streak + 1;
      check_date := check_date - 1;
    ELSE
      -- Allow one rest day
      IF check_date = CURRENT_DATE THEN
        check_date := check_date - 1;
      ELSE
        EXIT;
      END IF;
    END IF;

    -- Safety limit
    IF streak > 365 THEN
      EXIT;
    END IF;
  END LOOP;

  RETURN streak;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
