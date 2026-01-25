-- ============================================
-- LifeAndGym Database Schema
-- Migration 00001: Initial Schema
-- ============================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  avatar_url TEXT,
  phone TEXT,
  date_of_birth DATE,
  gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
  height_cm DECIMAL(5,2),
  fitness_level TEXT CHECK (fitness_level IN ('beginner', 'intermediate', 'advanced')),
  fitness_goals TEXT[], -- Array: ['weight_loss', 'muscle_gain', 'endurance', 'flexibility']
  preferred_units TEXT DEFAULT 'imperial' CHECK (preferred_units IN ('imperial', 'metric')),
  notification_preferences JSONB DEFAULT '{"push": true, "email": true, "class_reminders": true, "workout_reminders": true}',
  onboarding_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- GYMS TABLE
-- ============================================
CREATE TABLE gyms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT,
  address TEXT NOT NULL,
  city TEXT NOT NULL,
  state TEXT,
  country TEXT NOT NULL DEFAULT 'US',
  postal_code TEXT,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  phone TEXT,
  email TEXT,
  website TEXT,
  logo_url TEXT,
  images TEXT[], -- Array of image URLs
  amenities TEXT[], -- ['parking', 'showers', 'lockers', 'sauna', 'pool', 'wifi', 'towels', 'water_fountain']
  equipment TEXT[], -- ['treadmill', 'weights', 'machines', 'yoga_studio', 'pool', 'basketball']
  operating_hours JSONB, -- {"monday": {"open": "06:00", "close": "22:00"}, ...}
  capacity INTEGER DEFAULT 100,
  current_occupancy INTEGER DEFAULT 0,
  is_24_hours BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER update_gyms_updated_at
  BEFORE UPDATE ON gyms
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Index for location-based queries
CREATE INDEX idx_gyms_location ON gyms(latitude, longitude);
CREATE INDEX idx_gyms_city ON gyms(city);
CREATE INDEX idx_gyms_active ON gyms(is_active) WHERE is_active = TRUE;

-- ============================================
-- MEMBERSHIPS TABLE
-- ============================================
CREATE TABLE memberships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  plan_type TEXT NOT NULL CHECK (plan_type IN ('basic', 'premium', 'vip', 'day_pass')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'cancelled', 'expired')),
  start_date DATE NOT NULL DEFAULT CURRENT_DATE,
  end_date DATE,
  auto_renew BOOLEAN DEFAULT TRUE,
  qr_code TEXT UNIQUE NOT NULL,
  home_gym_id UUID REFERENCES gyms(id),
  access_all_locations BOOLEAN DEFAULT FALSE,
  monthly_fee DECIMAL(10, 2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, gym_id)
);

CREATE TRIGGER update_memberships_updated_at
  BEFORE UPDATE ON memberships
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX idx_memberships_user ON memberships(user_id);
CREATE INDEX idx_memberships_status ON memberships(status) WHERE status = 'active';

-- ============================================
-- CHECK-INS TABLE
-- ============================================
CREATE TABLE check_ins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  membership_id UUID NOT NULL REFERENCES memberships(id) ON DELETE CASCADE,
  checked_in_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  checked_out_at TIMESTAMPTZ,
  duration_minutes INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_check_ins_user_date ON check_ins(user_id, checked_in_at DESC);
CREATE INDEX idx_check_ins_gym_date ON check_ins(gym_id, checked_in_at DESC);

-- ============================================
-- TRAINERS TABLE
-- ============================================
CREATE TABLE trainers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  gym_id UUID REFERENCES gyms(id) ON DELETE SET NULL,
  bio TEXT,
  specialties TEXT[], -- ['weight_training', 'cardio', 'yoga', 'nutrition', 'hiit']
  certifications TEXT[],
  experience_years INTEGER,
  hourly_rate DECIMAL(10, 2),
  rating DECIMAL(3, 2) DEFAULT 0.00,
  total_reviews INTEGER DEFAULT 0,
  availability JSONB, -- {"monday": ["09:00-12:00", "14:00-18:00"], ...}
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER update_trainers_updated_at
  BEFORE UPDATE ON trainers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- CLASSES TABLE
-- ============================================
CREATE TABLE classes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  trainer_id UUID REFERENCES trainers(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  description TEXT,
  type TEXT NOT NULL CHECK (type IN ('yoga', 'hiit', 'spin', 'pilates', 'strength', 'cardio', 'dance', 'boxing', 'swimming', 'other')),
  difficulty TEXT CHECK (difficulty IN ('beginner', 'intermediate', 'advanced', 'all_levels')),
  duration_minutes INTEGER NOT NULL DEFAULT 60,
  capacity INTEGER NOT NULL DEFAULT 20,
  equipment_needed TEXT[],
  image_url TEXT,
  is_recurring BOOLEAN DEFAULT TRUE,
  recurrence_rule TEXT, -- iCal RRULE format
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER update_classes_updated_at
  BEFORE UPDATE ON classes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX idx_classes_gym ON classes(gym_id);
CREATE INDEX idx_classes_type ON classes(type);

-- ============================================
-- CLASS SCHEDULES TABLE
-- ============================================
CREATE TABLE class_schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  trainer_id UUID REFERENCES trainers(id) ON DELETE SET NULL,
  scheduled_at TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER NOT NULL,
  room TEXT,
  capacity INTEGER NOT NULL,
  spots_remaining INTEGER NOT NULL,
  status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'cancelled', 'completed')),
  cancellation_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER update_class_schedules_updated_at
  BEFORE UPDATE ON class_schedules
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX idx_class_schedules_gym_date ON class_schedules(gym_id, scheduled_at);
CREATE INDEX idx_class_schedules_class ON class_schedules(class_id);

-- ============================================
-- BOOKINGS TABLE
-- ============================================
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  class_schedule_id UUID NOT NULL REFERENCES class_schedules(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'cancelled', 'attended', 'no_show', 'waitlist')),
  waitlist_position INTEGER,
  booked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  cancelled_at TIMESTAMPTZ,
  cancellation_reason TEXT,
  attended_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, class_schedule_id)
);

CREATE INDEX idx_bookings_user ON bookings(user_id);
CREATE INDEX idx_bookings_schedule ON bookings(class_schedule_id);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE check_ins ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Memberships policies
CREATE POLICY "Users can view own memberships" ON memberships
  FOR SELECT USING (auth.uid() = user_id);

-- Check-ins policies
CREATE POLICY "Users can view own check-ins" ON check_ins
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own check-ins" ON check_ins
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own check-ins" ON check_ins
  FOR UPDATE USING (auth.uid() = user_id);

-- Bookings policies
CREATE POLICY "Users can manage own bookings" ON bookings
  FOR ALL USING (auth.uid() = user_id);

-- Public read access for gyms, classes, trainers
CREATE POLICY "Anyone can view active gyms" ON gyms
  FOR SELECT USING (is_active = TRUE);

CREATE POLICY "Anyone can view active classes" ON classes
  FOR SELECT USING (is_active = TRUE);

CREATE POLICY "Anyone can view class schedules" ON class_schedules
  FOR SELECT USING (TRUE);

CREATE POLICY "Anyone can view active trainers" ON trainers
  FOR SELECT USING (is_active = TRUE);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to increment gym occupancy
CREATE OR REPLACE FUNCTION increment_gym_occupancy(p_gym_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE gyms
  SET current_occupancy = current_occupancy + 1
  WHERE id = p_gym_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to decrement gym occupancy
CREATE OR REPLACE FUNCTION decrement_gym_occupancy(p_gym_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE gyms
  SET current_occupancy = GREATEST(0, current_occupancy - 1)
  WHERE id = p_gym_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update spots remaining when booking
CREATE OR REPLACE FUNCTION update_spots_on_booking()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.status = 'confirmed' THEN
    UPDATE class_schedules
    SET spots_remaining = spots_remaining - 1
    WHERE id = NEW.class_schedule_id AND spots_remaining > 0;
  ELSIF TG_OP = 'UPDATE' AND OLD.status = 'confirmed' AND NEW.status = 'cancelled' THEN
    UPDATE class_schedules
    SET spots_remaining = spots_remaining + 1
    WHERE id = NEW.class_schedule_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_spots_on_booking
  AFTER INSERT OR UPDATE ON bookings
  FOR EACH ROW
  EXECUTE FUNCTION update_spots_on_booking();
