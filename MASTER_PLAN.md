# LifeAndGym - Master Plan Document

> **Purpose:** This document serves as the single source of truth for the LifeAndGym app development. Reference this document before implementing any feature to ensure consistency and alignment.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture](#2-architecture)
3. [Tech Stack](#3-tech-stack)
4. [Database Schema](#4-database-schema)
5. [API Endpoints](#5-api-endpoints)
6. [Feature Specifications](#6-feature-specifications)
7. [UI/UX Guidelines](#7-uiux-guidelines)
8. [Screen Specifications](#8-screen-specifications)
9. [Code Patterns](#9-code-patterns)
10. [Development Phases](#10-development-phases)
11. [File Structure](#11-file-structure)
12. [Mistakes to Avoid](#12-mistakes-to-avoid)
13. [Testing Strategy](#13-testing-strategy)
14. [Deployment](#14-deployment)

---

## 1. Project Overview

### 1.1 App Description
LifeAndGym is a comprehensive gym membership and fitness tracking mobile application inspired by GoodLife Fitness, Planet Fitness, Anytime Fitness, and Fitness First. It provides members with digital check-in, class booking, workout tracking, and progress monitoring.

### 1.2 Target Users
- **Primary:** Gym members aged 18-45
- **Secondary:** Personal trainers, gym staff

### 1.3 Core Value Propositions
1. Seamless digital gym access (QR check-in)
2. Easy class booking with real-time availability
3. Comprehensive workout tracking
4. Progress visualization and goal tracking
5. Personalized training plans

### 1.4 Key Success Metrics
- User retention: >60% at 90 days (industry avg: 30%)
- Daily active users: >40% of members
- Class booking rate: >3 bookings/user/month
- Workout logging rate: >2 sessions/user/week

---

## 2. Architecture

### 2.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              Flutter App (iOS + Android)                 │    │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐        │    │
│  │  │   UI    │ │Providers│ │Services │ │ Models  │        │    │
│  │  │ Screens │ │ (State) │ │  (API)  │ │ (Data)  │        │    │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘        │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                       SUPABASE BACKEND                           │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────────────┐     │
│  │   Supabase   │ │   Supabase   │ │     Supabase         │     │
│  │     Auth     │ │   Database   │ │     Storage          │     │
│  │              │ │ (PostgreSQL) │ │   (Media/Images)     │     │
│  └──────────────┘ └──────────────┘ └──────────────────────┘     │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────────────┐     │
│  │   Supabase   │ │   Supabase   │ │     Edge             │     │
│  │   Realtime   │ │  Row Level   │ │   Functions          │     │
│  │              │ │   Security   │ │   (Complex Logic)    │     │
│  └──────────────┘ └──────────────┘ └──────────────────────┘     │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    EXTERNAL INTEGRATIONS                         │
├─────────────────────────────────────────────────────────────────┤
│  • Apple HealthKit        • Google Fit                           │
│  • Firebase Cloud Messaging (Push Notifications)                 │
│  • Stripe (Payments - Future)                                    │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Architecture Principles

1. **Feature-First Organization:** Code organized by feature, not by type
2. **Offline-First:** Core features work without internet, sync when online
3. **Single Source of Truth:** Supabase as the primary data source
4. **Modular Design:** Features are independent and loosely coupled
5. **Provider Pattern:** State management using Provider with SafeChangeNotifier
6. **Repository Pattern:** Abstract data sources from business logic

### 2.3 Data Flow

```
UI (Screen)
    ↓ user action
Provider (State Management)
    ↓ calls
Service (API/Business Logic)
    ↓ calls
Repository (Data Source Abstraction)
    ↓ calls
Supabase Client / Local Cache
    ↓ returns
Model (Data Class)
    ↑ updates
Provider → UI rebuilds
```

---

## 3. Tech Stack

### 3.1 Frontend

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| Framework | Flutter | 3.24+ | Cross-platform UI |
| Language | Dart | 3.5+ | Programming language |
| State Management | Provider | 6.1+ | Reactive state |
| Navigation | Go Router | 14+ | Declarative routing |
| Localization | intl | 0.19+ | i18n support |

### 3.2 Backend (Supabase)

| Component | Technology | Purpose |
|-----------|------------|---------|
| Database | PostgreSQL 15 | Primary data store |
| Auth | Supabase Auth | Authentication & sessions |
| Storage | Supabase Storage | Media files |
| Realtime | Supabase Realtime | Live updates |
| Functions | Edge Functions | Complex business logic |

### 3.3 Key Dependencies

```yaml
dependencies:
  # Core
  flutter:
    sdk: flutter
  provider: ^6.1.2
  go_router: ^14.2.0

  # Supabase
  supabase_flutter: ^2.5.0

  # UI/UX
  cached_network_image: ^3.3.1
  flutter_svg: ^2.0.10
  shimmer: ^3.0.0

  # Utilities
  shared_preferences: ^2.2.3
  connectivity_plus: ^6.0.3
  intl: ^0.19.0

  # Health & Fitness
  health: ^10.2.0  # HealthKit & Google Fit

  # Notifications
  firebase_messaging: ^15.0.0
  flutter_local_notifications: ^17.2.0

  # Media
  image_picker: ^1.1.0
  qr_flutter: ^4.1.0

  # Charts
  fl_chart: ^0.68.0
```

---

## 4. Database Schema

### 4.1 Entity Relationship Diagram

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│   users     │       │    gyms     │       │  trainers   │
├─────────────┤       ├─────────────┤       ├─────────────┤
│ id (PK)     │       │ id (PK)     │       │ id (PK)     │
│ email       │       │ name        │       │ user_id(FK) │
│ full_name   │       │ address     │       │ gym_id (FK) │
│ avatar_url  │       │ latitude    │       │ specialties │
│ phone       │       │ longitude   │       │ bio         │
│ created_at  │       │ capacity    │       │ hourly_rate │
└─────────────┘       │ amenities   │       │ rating      │
       │              │ hours       │       └─────────────┘
       │              └─────────────┘              │
       ▼                    │                      │
┌─────────────┐            │                      │
│ memberships │◄───────────┘                      │
├─────────────┤                                   │
│ id (PK)     │       ┌─────────────┐            │
│ user_id(FK) │       │   classes   │            │
│ gym_id (FK) │       ├─────────────┤            │
│ plan_type   │       │ id (PK)     │            │
│ status      │       │ gym_id (FK) │            │
│ start_date  │       │ trainer_id  │◄───────────┘
│ end_date    │       │ name        │
│ qr_code     │       │ description │
└─────────────┘       │ type        │
       │              │ capacity    │
       │              │ schedule    │
       ▼              └─────────────┘
┌─────────────┐              │
│  check_ins  │              │
├─────────────┤              ▼
│ id (PK)     │       ┌─────────────┐
│ user_id(FK) │       │  bookings   │
│ gym_id (FK) │       ├─────────────┤
│ checked_in  │       │ id (PK)     │
│ checked_out │       │ user_id(FK) │
└─────────────┘       │ class_id(FK)│
                      │ status      │
                      │ booked_at   │
                      └─────────────┘

┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│  workouts   │       │  exercises  │       │workout_logs │
├─────────────┤       ├─────────────┤       ├─────────────┤
│ id (PK)     │       │ id (PK)     │       │ id (PK)     │
│ user_id(FK) │       │ name        │       │ workout_id  │
│ name        │       │ description │       │ exercise_id │
│ description │       │ muscle_group│       │ sets        │
│ is_template │       │ equipment   │       │ reps        │
│ created_at  │       │ video_url   │       │ weight      │
└─────────────┘       │ image_url   │       │ duration    │
                      │ difficulty  │       │ notes       │
                      └─────────────┘       │ completed_at│
                                            └─────────────┘

┌─────────────┐       ┌─────────────┐
│   goals     │       │ body_metrics│
├─────────────┤       ├─────────────┤
│ id (PK)     │       │ id (PK)     │
│ user_id(FK) │       │ user_id(FK) │
│ type        │       │ weight      │
│ target      │       │ body_fat    │
│ current     │       │ muscle_mass │
│ deadline    │       │ recorded_at │
│ status      │       └─────────────┘
└─────────────┘

┌─────────────────┐
│ training_plans  │
├─────────────────┤
│ id (PK)         │
│ name            │
│ description     │
│ duration_weeks  │
│ difficulty      │
│ goal_type       │
│ workouts (JSON) │
│ is_premium      │
└─────────────────┘
```

### 4.2 Table Definitions

#### 4.2.1 users
```sql
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
  notification_preferences JSONB DEFAULT '{"push": true, "email": true, "class_reminders": true}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 4.2.2 gyms
```sql
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
  amenities TEXT[], -- ['parking', 'showers', 'lockers', 'sauna', 'pool', 'wifi']
  equipment TEXT[], -- ['treadmill', 'weights', 'machines', 'yoga_studio']
  operating_hours JSONB, -- {"monday": {"open": "06:00", "close": "22:00"}, ...}
  capacity INTEGER DEFAULT 100,
  current_occupancy INTEGER DEFAULT 0, -- Updated by check-ins
  is_24_hours BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 4.2.3 memberships
```sql
CREATE TABLE memberships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  plan_type TEXT NOT NULL CHECK (plan_type IN ('basic', 'premium', 'vip', 'day_pass')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'cancelled', 'expired')),
  start_date DATE NOT NULL DEFAULT CURRENT_DATE,
  end_date DATE,
  auto_renew BOOLEAN DEFAULT TRUE,
  qr_code TEXT UNIQUE NOT NULL, -- Unique QR code for check-in
  home_gym_id UUID REFERENCES gyms(id), -- Primary gym
  access_all_locations BOOLEAN DEFAULT FALSE,
  monthly_fee DECIMAL(10, 2),
  payment_method_id TEXT, -- Stripe payment method
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, gym_id)
);
```

#### 4.2.4 check_ins
```sql
CREATE TABLE check_ins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  membership_id UUID NOT NULL REFERENCES memberships(id) ON DELETE CASCADE,
  checked_in_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  checked_out_at TIMESTAMPTZ,
  duration_minutes INTEGER, -- Calculated on checkout
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for fast lookups
CREATE INDEX idx_check_ins_user_date ON check_ins(user_id, checked_in_at DESC);
CREATE INDEX idx_check_ins_gym_date ON check_ins(gym_id, checked_in_at DESC);
```

#### 4.2.5 trainers
```sql
CREATE TABLE trainers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  gym_id UUID REFERENCES gyms(id) ON DELETE SET NULL, -- Can be freelance
  bio TEXT,
  specialties TEXT[], -- ['weight_training', 'cardio', 'yoga', 'nutrition']
  certifications TEXT[],
  experience_years INTEGER,
  hourly_rate DECIMAL(10, 2),
  rating DECIMAL(3, 2) DEFAULT 0.00, -- 0.00 to 5.00
  total_reviews INTEGER DEFAULT 0,
  availability JSONB, -- {"monday": ["09:00-12:00", "14:00-18:00"], ...}
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 4.2.6 classes
```sql
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
```

#### 4.2.7 class_schedules
```sql
CREATE TABLE class_schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  trainer_id UUID REFERENCES trainers(id) ON DELETE SET NULL,
  scheduled_at TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER NOT NULL,
  room TEXT, -- 'Studio A', 'Pool', etc.
  capacity INTEGER NOT NULL,
  spots_remaining INTEGER NOT NULL,
  status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'cancelled', 'completed')),
  cancellation_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for fast schedule lookups
CREATE INDEX idx_class_schedules_gym_date ON class_schedules(gym_id, scheduled_at);
```

#### 4.2.8 bookings
```sql
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  class_schedule_id UUID NOT NULL REFERENCES class_schedules(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'cancelled', 'attended', 'no_show', 'waitlist')),
  waitlist_position INTEGER, -- If on waitlist
  booked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  cancelled_at TIMESTAMPTZ,
  cancellation_reason TEXT,
  attended_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, class_schedule_id)
);
```

#### 4.2.9 exercises
```sql
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
  is_compound BOOLEAN DEFAULT FALSE, -- Multi-joint exercise
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Full-text search index
CREATE INDEX idx_exercises_search ON exercises USING GIN(to_tsvector('english', name || ' ' || COALESCE(description, '')));
```

#### 4.2.10 workouts
```sql
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
```

#### 4.2.11 workout_sessions
```sql
CREATE TABLE workout_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  workout_id UUID REFERENCES workouts(id) ON DELETE SET NULL,
  gym_id UUID REFERENCES gyms(id) ON DELETE SET NULL,
  name TEXT NOT NULL, -- Can be custom even if from template
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  duration_minutes INTEGER,
  total_volume DECIMAL(10, 2), -- Total weight lifted (sets * reps * weight)
  calories_burned INTEGER,
  notes TEXT,
  rating INTEGER CHECK (rating BETWEEN 1 AND 5), -- User's rating of workout
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 4.2.12 workout_logs (Exercise Sets)
```sql
CREATE TABLE workout_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  set_number INTEGER NOT NULL,
  reps INTEGER,
  weight DECIMAL(7, 2), -- In user's preferred unit
  weight_unit TEXT DEFAULT 'lbs' CHECK (weight_unit IN ('lbs', 'kg')),
  duration_seconds INTEGER, -- For timed exercises
  distance DECIMAL(10, 2), -- For cardio (meters)
  rest_seconds INTEGER,
  rpe INTEGER CHECK (rpe BETWEEN 1 AND 10), -- Rate of Perceived Exertion
  is_warmup BOOLEAN DEFAULT FALSE,
  is_dropset BOOLEAN DEFAULT FALSE,
  notes TEXT,
  completed_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for personal records lookup
CREATE INDEX idx_workout_logs_exercise_user ON workout_logs(exercise_id, (SELECT user_id FROM workout_sessions WHERE id = session_id));
```

#### 4.2.13 goals
```sql
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
```

#### 4.2.14 body_metrics
```sql
CREATE TABLE body_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  weight DECIMAL(5, 2), -- In user's preferred unit
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

-- Index for trend queries
CREATE INDEX idx_body_metrics_user_date ON body_metrics(user_id, recorded_at DESC);
```

#### 4.2.15 training_plans
```sql
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
```

#### 4.2.16 user_training_plans
```sql
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
```

#### 4.2.17 notifications
```sql
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

-- Index for unread notifications
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;
```

### 4.3 Row Level Security (RLS) Policies

```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE check_ins ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE body_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users can only access their own data
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Memberships: Users see their own, gyms see their members
CREATE POLICY "Users can view own memberships" ON memberships
  FOR SELECT USING (auth.uid() = user_id);

-- Check-ins: Users see their own
CREATE POLICY "Users can view own check-ins" ON check_ins
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own check-ins" ON check_ins
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Bookings: Users manage their own
CREATE POLICY "Users can manage own bookings" ON bookings
  FOR ALL USING (auth.uid() = user_id);

-- Workout data: Private to user
CREATE POLICY "Users can manage own workout sessions" ON workout_sessions
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own workout logs" ON workout_logs
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM workout_sessions
      WHERE workout_sessions.id = workout_logs.session_id
      AND workout_sessions.user_id = auth.uid()
    )
  );

-- Public read access for shared data
CREATE POLICY "Anyone can view gyms" ON gyms
  FOR SELECT USING (is_active = TRUE);

CREATE POLICY "Anyone can view classes" ON classes
  FOR SELECT USING (is_active = TRUE);

CREATE POLICY "Anyone can view exercises" ON exercises
  FOR SELECT USING (is_active = TRUE);

CREATE POLICY "Anyone can view training plans" ON training_plans
  FOR SELECT USING (is_active = TRUE);
```

---

## 5. API Endpoints

### 5.1 Supabase Direct Access (Primary)

Most data access will use Supabase client directly with RLS policies. The Flutter app will use:

```dart
// Example: Get user's memberships
final memberships = await supabase
    .from('memberships')
    .select('*, gyms(*)')
    .eq('user_id', userId);

// Example: Book a class
await supabase.from('bookings').insert({
  'user_id': userId,
  'class_schedule_id': classId,
  'status': 'confirmed',
});
```

### 5.2 Edge Functions (Complex Logic)

For operations requiring complex logic or transactions:

| Function | Method | Purpose |
|----------|--------|---------|
| `/check-in` | POST | Validate membership, update gym occupancy |
| `/check-out` | POST | Calculate duration, update occupancy |
| `/book-class` | POST | Check capacity, handle waitlist |
| `/cancel-booking` | POST | Handle cancellation policy, waitlist promotion |
| `/complete-workout` | POST | Calculate stats, check PRs, update goals |
| `/generate-qr` | POST | Generate unique QR code for membership |

### 5.3 Edge Function Examples

#### check-in
```typescript
// supabase/functions/check-in/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { qr_code, gym_id } = await req.json()

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // 1. Validate membership
  const { data: membership } = await supabase
    .from('memberships')
    .select('*')
    .eq('qr_code', qr_code)
    .eq('status', 'active')
    .single()

  if (!membership) {
    return new Response(JSON.stringify({ error: 'Invalid or inactive membership' }), { status: 400 })
  }

  // 2. Check if already checked in
  const { data: existingCheckIn } = await supabase
    .from('check_ins')
    .select('*')
    .eq('user_id', membership.user_id)
    .is('checked_out_at', null)
    .single()

  if (existingCheckIn) {
    return new Response(JSON.stringify({ error: 'Already checked in' }), { status: 400 })
  }

  // 3. Create check-in and update occupancy (transaction)
  const { data: checkIn } = await supabase
    .from('check_ins')
    .insert({
      user_id: membership.user_id,
      gym_id: gym_id,
      membership_id: membership.id,
    })
    .select()
    .single()

  await supabase.rpc('increment_gym_occupancy', { gym_id })

  return new Response(JSON.stringify({ success: true, check_in: checkIn }))
})
```

---

## 6. Feature Specifications

### 6.1 Phase 1: MVP Features

#### 6.1.1 Authentication
- **Email/Password Sign Up & Login**
- **Social Auth:** Google, Apple
- **Password Reset** via email
- **Session Management:** Auto-refresh tokens
- **Biometric Login:** Face ID / Fingerprint (stored credentials)

#### 6.1.2 Onboarding Flow
1. **Welcome Screen:** App benefits, Get Started button
2. **Account Creation:** Email/password or social
3. **Profile Setup:** Name, avatar (optional)
4. **Fitness Profile:**
   - Fitness level: Beginner / Intermediate / Advanced
   - Goals: Weight loss, Muscle gain, Endurance, Flexibility (multi-select)
   - Workout frequency preference
5. **Gym Selection:** Search or select home gym
6. **Permissions:** Notifications, HealthKit (optional)
7. **Complete:** Navigate to home

**Target:** Complete in <60 seconds (critical for retention)

#### 6.1.3 Digital Membership
- **QR Code Display:** Full-screen QR for gym entry
- **Membership Details:** Plan type, status, renewal date
- **Home Gym:** View and change home gym
- **Multi-location Access:** If plan allows

#### 6.1.4 Gym Finder
- **Map View:** Google Maps with gym markers
- **List View:** Sorted by distance
- **Gym Details:**
  - Address, phone, hours
  - Amenities icons
  - Current occupancy (real-time)
  - Equipment list
  - Photos gallery
- **Directions:** Open in Maps app
- **Set as Home Gym**

#### 6.1.5 Class Booking
- **Schedule View:** Day/week view
- **Filter By:** Type, trainer, time
- **Class Details:**
  - Description, difficulty, duration
  - Trainer info
  - Spots remaining
  - Equipment needed
- **Book/Cancel:** With confirmation
- **Waitlist:** Auto-promote when spot opens
- **Reminders:** Push notification before class

#### 6.1.6 Basic Workout Tracking
- **Quick Log:** Simple set/rep/weight entry
- **Exercise Search:** By name, muscle group
- **Timer:** Rest timer between sets
- **Session Summary:** Duration, volume, exercises

### 6.2 Phase 2: Enhanced Features

#### 6.2.1 Training Plans
- **Browse Plans:** Filter by goal, duration, difficulty
- **Plan Details:** Weekly structure, required equipment
- **Start Plan:** Guided weekly workouts
- **Progress Tracking:** Completed workouts, current week

#### 6.2.2 Custom Workouts
- **Create Workout:** Add exercises, sets, reps
- **Save Templates:** Reuse favorite workouts
- **Edit/Delete:** Manage saved workouts

#### 6.2.3 On-Demand Content
- **Exercise Videos:** Form demonstrations
- **Workout Videos:** Follow-along sessions
- **Categories:** By type, duration, equipment

#### 6.2.4 Progress Dashboard
- **Workout Stats:** Weekly/monthly summaries
- **Charts:** Volume, frequency, calories
- **Personal Records:** PRs by exercise
- **Streaks:** Consecutive workout days
- **Body Metrics:** Weight, measurements over time

#### 6.2.5 Wearable Integration
- **Apple HealthKit:** Steps, heart rate, sleep
- **Google Fit:** Android equivalent
- **Sync:** Background data import
- **Display:** Health data in app

#### 6.2.6 Push Notifications
- **Class Reminders:** 1 hour before
- **Workout Reminders:** Based on schedule
- **Streak Alerts:** Don't break the streak!
- **Goal Progress:** Milestone celebrations

### 6.3 Phase 3: Advanced Features

#### 6.3.1 AI Coach (Future)
- **Personalized Recommendations**
- **Adaptive Plans:** Based on progress
- **Form Feedback:** (requires video analysis)
- **Recovery Suggestions**

#### 6.3.2 Nutrition (Future)
- **Meal Logging**
- **Macro Tracking**
- **Water Intake**
- **Integration:** MyFitnessPal API

#### 6.3.3 PT Booking (Future)
- **Browse Trainers:** At selected gym
- **Availability Calendar**
- **Book Session:** With payment
- **Session History**

#### 6.3.4 Social Features (Future)
- **Friends:** Add, view activity
- **Challenges:** Group competitions
- **Leaderboards:** By gym, friends
- **Share:** Achievements to social media

---

## 7. UI/UX Guidelines

### 7.1 Design Principles

1. **Speed First:** Onboarding <60 seconds, workout start <3 taps
2. **Distraction-Free Workouts:** No pop-ups, minimal chrome during exercise
3. **One-Hand Operation:** Critical actions within thumb reach
4. **Dark Mode Default:** Gym lighting consideration
5. **Progressive Disclosure:** Show basics first, details on demand
6. **Contextual Data:** Always show progress relative to goals

### 7.2 Color Palette

```
Primary Colors:
- Primary:        #6366F1 (Indigo 500) - Main actions, active states
- Primary Dark:   #4F46E5 (Indigo 600) - Pressed states
- Primary Light:  #A5B4FC (Indigo 300) - Backgrounds, highlights

Secondary Colors:
- Success:        #22C55E (Green 500) - Completed, positive
- Warning:        #F59E0B (Amber 500) - Caution, almost full
- Error:          #EF4444 (Red 500) - Errors, cancelled
- Info:           #3B82F6 (Blue 500) - Information

Neutral Colors (Dark Mode Default):
- Background:     #0F172A (Slate 900)
- Surface:        #1E293B (Slate 800)
- Surface Variant:#334155 (Slate 700)
- On Surface:     #F8FAFC (Slate 50)
- On Surface Dim: #94A3B8 (Slate 400)

Light Mode:
- Background:     #F8FAFC (Slate 50)
- Surface:        #FFFFFF (White)
- Surface Variant:#F1F5F9 (Slate 100)
- On Surface:     #0F172A (Slate 900)
- On Surface Dim: #64748B (Slate 500)
```

### 7.3 Typography

```
Font Family: Inter (Google Fonts) or SF Pro (iOS native)

Heading 1:  32sp / Bold / -0.5 letter spacing
Heading 2:  24sp / SemiBold / -0.25 letter spacing
Heading 3:  20sp / SemiBold / 0 letter spacing
Heading 4:  18sp / Medium / 0 letter spacing
Body:       16sp / Regular / 0.15 letter spacing
Body Small: 14sp / Regular / 0.1 letter spacing
Caption:    12sp / Regular / 0.4 letter spacing
Button:     14sp / SemiBold / 1.25 letter spacing / UPPERCASE (optional)
```

### 7.4 Spacing System

```
Base unit: 4dp

Spacing scale:
- xs:   4dp  (0.25rem)
- sm:   8dp  (0.5rem)
- md:   16dp (1rem)
- lg:   24dp (1.5rem)
- xl:   32dp (2rem)
- 2xl:  48dp (3rem)
- 3xl:  64dp (4rem)

Component spacing:
- Card padding:        16dp
- List item padding:   16dp horizontal, 12dp vertical
- Section spacing:     24dp
- Screen padding:      16dp (safe area + 16dp)
```

### 7.5 Component Specifications

#### Buttons
```
Primary Button:
- Height: 48dp
- Border radius: 12dp
- Background: Primary color
- Text: White, 14sp SemiBold
- Padding: 16dp horizontal

Secondary Button:
- Same dimensions
- Background: Transparent
- Border: 1dp Primary color
- Text: Primary color

Icon Button:
- Size: 40dp x 40dp
- Icon: 24dp
```

#### Cards
```
Standard Card:
- Background: Surface color
- Border radius: 16dp
- Padding: 16dp
- Shadow: elevation 2 (subtle)
- Margin between cards: 12dp
```

#### Input Fields
```
Text Field:
- Height: 56dp
- Border radius: 12dp
- Background: Surface variant
- Border: 1dp on focus (Primary)
- Padding: 16dp
- Label: 12sp above field
```

### 7.6 Navigation

```
Bottom Navigation Bar:
- Height: 64dp (+ safe area)
- 5 items maximum
- Icons: 24dp
- Labels: 12sp
- Active: Primary color
- Inactive: On Surface Dim

Items:
1. Home (house icon)
2. Workouts (dumbbell icon)
3. Book (calendar icon)
4. Progress (chart icon)
5. Profile (person icon)
```

### 7.7 Iconography

Use consistent icon set: **Lucide Icons** or **Material Symbols**

```
Navigation icons: 24dp, outlined style
Action icons: 20dp
Inline icons: 16dp
Feature icons: 48dp (illustrations)
```

---

## 8. Screen Specifications

### 8.1 Screen List

#### Authentication
1. `SplashScreen` - App launch, auth check
2. `WelcomeScreen` - First launch, benefits showcase
3. `LoginScreen` - Email/password, social buttons
4. `RegisterScreen` - Create account form
5. `ForgotPasswordScreen` - Password reset
6. `OnboardingFlow` - Multi-step profile setup

#### Main Tabs
7. `HomeScreen` - Dashboard with QR, stats, quick actions
8. `WorkoutsScreen` - Workout list, start workout
9. `BookScreen` - Class schedule, bookings
10. `ProgressScreen` - Stats, charts, PRs
11. `ProfileScreen` - Settings, account, preferences

#### Gym
12. `GymFinderScreen` - Map + list view
13. `GymDetailScreen` - Gym info, classes, hours

#### Classes
14. `ClassDetailScreen` - Class info, book button
15. `MyBookingsScreen` - Upcoming and past bookings

#### Workouts
16. `WorkoutDetailScreen` - Workout preview
17. `ActiveWorkoutScreen` - During workout (distraction-free)
18. `WorkoutSummaryScreen` - Post-workout stats
19. `ExerciseLibraryScreen` - Browse exercises
20. `ExerciseDetailScreen` - Exercise info, video
21. `CreateWorkoutScreen` - Custom workout builder
22. `TrainingPlansScreen` - Browse plans
23. `TrainingPlanDetailScreen` - Plan info, start

#### Progress
24. `BodyMetricsScreen` - Log measurements
25. `PersonalRecordsScreen` - PRs by exercise
26. `GoalsScreen` - View/create goals

#### Profile
27. `EditProfileScreen` - Update user info
28. `SettingsScreen` - App preferences
29. `NotificationsScreen` - Notification center
30. `MembershipScreen` - Membership details

### 8.2 Key Screen Wireframes

#### 8.2.1 Home Screen
```
┌─────────────────────────────────────────┐
│ [Safe Area]                             │
├─────────────────────────────────────────┤
│                                         │
│  Good Morning, Alex!          [Avatar]  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 🎫 TAP TO CHECK IN              │    │
│  │                                 │    │
│  │     ┌───────────────┐          │    │
│  │     │   QR CODE     │          │    │
│  │     │   [Image]     │          │    │
│  │     └───────────────┘          │    │
│  │                                 │    │
│  │  Downtown Gym • Premium Member  │    │
│  └─────────────────────────────────┘    │
│                                         │
│  📍 Your Gym                            │
│  ┌─────────────────────────────────┐    │
│  │ Downtown Fitness    [2.1 mi →]  │    │
│  │ 🟢 Not Busy • 23/100 people     │    │
│  │ Open until 10:00 PM             │    │
│  └─────────────────────────────────┘    │
│                                         │
│  💪 Today's Workout                     │
│  ┌─────────────────────────────────┐    │
│  │ Upper Body Strength             │    │
│  │ 8 exercises • ~45 min           │    │
│  │ [Start Workout →]               │    │
│  └─────────────────────────────────┘    │
│                                         │
│  📅 Upcoming Classes                    │
│  ┌────────┐ ┌────────┐ ┌────────┐      │
│  │ Yoga   │ │ HIIT   │ │ Spin   │      │
│  │ 10 AM  │ │ 2 PM   │ │ 6 PM   │      │
│  │ 3 spots│ │ BOOKED │ │ 8 spots│      │
│  └────────┘ └────────┘ └────────┘      │
│                                         │
│  📊 This Week                           │
│  ┌─────────────────────────────────┐    │
│  │ M  T  W  T  F  S  S             │    │
│  │ ●  ●  ○  ●  ○  ○  ○  3/5 days  │    │
│  │                                 │    │
│  │ 🔥 12 day streak               │    │
│  └─────────────────────────────────┘    │
│                                         │
├─────────────────────────────────────────┤
│  🏠      💪       📅       📊      👤  │
│ Home  Workouts   Book   Progress Profile│
└─────────────────────────────────────────┘
```

#### 8.2.2 Active Workout Screen (Distraction-Free)
```
┌─────────────────────────────────────────┐
│ [Safe Area - Minimal]                   │
├─────────────────────────────────────────┤
│                                         │
│  ✕ Close                    ⏸️ 🔊 ⋯    │
│                                         │
│            BENCH PRESS                  │
│         Chest, Triceps, Shoulders       │
│                                         │
│         ┌─────────────────┐            │
│         │                 │            │
│         │   [Exercise     │            │
│         │    Animation]   │            │
│         │                 │            │
│         └─────────────────┘            │
│                                         │
│            SET 2 of 4                   │
│                                         │
│  ┌──────────┐┌──────────┐┌──────────┐  │
│  │    10    ││   135    ││   90s    │  │
│  │   REPS   ││   LBS    ││   REST   │  │
│  │  [-] [+] ││  [-] [+] ││  [-] [+] │  │
│  └──────────┘└──────────┘└──────────┘  │
│                                         │
│       Last set: 10 reps @ 130 lbs      │
│       PR: 12 reps @ 155 lbs            │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │                                 │    │
│  │        ✓ COMPLETE SET           │    │
│  │                                 │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌──────────┐          ┌──────────┐    │
│  │ ← PREV   │          │ NEXT →   │    │
│  │ Warm-up  │          │ Incline  │    │
│  └──────────┘          └──────────┘    │
│                                         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│  2/8 Exercises • 12:45 elapsed          │
│                                         │
└─────────────────────────────────────────┘
```

#### 8.2.3 Class Booking Screen
```
┌─────────────────────────────────────────┐
│ [Safe Area]                             │
├─────────────────────────────────────────┤
│                                         │
│  ← Classes             📍 Downtown      │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ Today  Tue  Wed  Thu  Fri  Sat  │    │
│  │  [24]  25   26   27   28   29   │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 🔍 Search classes...            │    │
│  └─────────────────────────────────┘    │
│                                         │
│  [All] [Yoga] [HIIT] [Spin] [Strength]  │
│                                         │
│  ─── Morning ───────────────────────    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 🧘 Yoga Flow                    │    │
│  │ 7:00 AM • 60 min • Studio A     │    │
│  │ with Sarah M.                   │    │
│  │ All Levels                      │    │
│  │                                 │    │
│  │ 🟢 12/20 spots         [BOOK]   │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 🏃 HIIT Blast                   │    │
│  │ 9:00 AM • 45 min • Studio B     │    │
│  │ with Mike T.                    │    │
│  │ Intermediate                    │    │
│  │                                 │    │
│  │ 🟡 18/20 spots         [BOOK]   │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ─── Afternoon ─────────────────────    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 🚴 Spin Class                   │    │
│  │ 12:00 PM • 45 min • Cycle Room  │    │
│  │ with Lisa K.                    │    │
│  │ All Levels                      │    │
│  │                                 │    │
│  │ 🔴 FULL          [JOIN WAITLIST]│    │
│  └─────────────────────────────────┘    │
│                                         │
├─────────────────────────────────────────┤
│  🏠      💪       📅       📊      👤  │
│ Home  Workouts   Book   Progress Profile│
└─────────────────────────────────────────┘
```

---

## 9. Code Patterns

### 9.1 Patterns to Reuse from Cuckoo

#### 9.1.1 Base Service (Adapt)
```dart
// lib/core/services/base_service.dart

abstract class BaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ConnectivityService _connectivity = ConnectivityService();

  /// Get current auth token with auto-refresh
  Future<String?> getAuthToken() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;

    // Check if token expires within 5 minutes
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      session.expiresAt! * 1000
    );
    final timeUntilExpiry = expiresAt.difference(DateTime.now()).inSeconds;

    if (timeUntilExpiry < 300) {
      await _supabase.auth.refreshSession();
      return _supabase.auth.currentSession?.accessToken;
    }

    return session.accessToken;
  }

  /// Execute request with connectivity check and retry
  Future<T> executeWithRetry<T>({
    required Future<T> Function() request,
    int maxRetries = 2,
  }) async {
    // Check connectivity first
    if (!await _connectivity.hasConnection) {
      throw NetworkException('No internet connection');
    }

    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await request();
      } on PostgrestException catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          throw ApiException(e.message, statusCode: e.code.hashCode);
        }
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      }
    }

    throw ApiException('Request failed after $maxRetries attempts');
  }
}
```

#### 9.1.2 Safe Change Notifier (Copy As-Is)
```dart
// lib/core/providers/safe_change_notifier.dart

mixin SafeChangeNotifierMixin on ChangeNotifier {
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}
```

#### 9.1.3 Exception Hierarchy (Adapt)
```dart
// lib/core/exceptions/exceptions.dart

abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  final int? statusCode;
  final bool isTimeout;

  const NetworkException(
    super.message, {
    this.statusCode,
    this.isTimeout = false,
    super.code,
    super.originalError,
  });
}

class AuthException extends AppException {
  final AuthErrorType type;

  const AuthException(
    super.message, {
    required this.type,
    super.code,
    super.originalError,
  });
}

enum AuthErrorType {
  invalidCredentials,
  sessionExpired,
  emailNotVerified,
  userNotFound,
  weakPassword,
  emailAlreadyInUse,
  unknown,
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors,
    super.code,
  });
}

class ApiException extends AppException {
  final int? statusCode;
  final String? endpoint;

  const ApiException(
    super.message, {
    this.statusCode,
    this.endpoint,
    super.code,
    super.originalError,
  });
}

class CacheException extends AppException {
  final String? key;

  const CacheException(
    super.message, {
    this.key,
    super.code,
  });
}
```

#### 9.1.4 Error Handler Service (Adapt)
```dart
// lib/core/services/error_handler_service.dart

class ErrorHandlerService {
  static final ErrorHandlerService _instance = ErrorHandlerService._();
  factory ErrorHandlerService() => _instance;
  ErrorHandlerService._();

  String handleError(dynamic error, {BuildContext? context}) {
    final message = _getUserFriendlyMessage(error);

    // Log error
    if (kDebugMode) {
      debugPrint('Error: $error');
    }

    return message;
  }

  String _getUserFriendlyMessage(dynamic error) {
    if (error is NetworkException) {
      if (error.isTimeout) return 'Request timed out. Please try again.';
      if (error.statusCode == 401) return 'Please log in again.';
      if (error.statusCode == 403) return 'You don\'t have permission for this action.';
      if (error.statusCode == 404) return 'The requested item was not found.';
      if (error.statusCode != null && error.statusCode! >= 500) {
        return 'Server error. Please try again later.';
      }
      return 'No internet connection. Please check your network.';
    }

    if (error is AuthException) {
      switch (error.type) {
        case AuthErrorType.invalidCredentials:
          return 'Invalid email or password.';
        case AuthErrorType.sessionExpired:
          return 'Your session has expired. Please log in again.';
        case AuthErrorType.emailNotVerified:
          return 'Please verify your email address.';
        case AuthErrorType.userNotFound:
          return 'No account found with this email.';
        case AuthErrorType.weakPassword:
          return 'Password is too weak. Use at least 8 characters.';
        case AuthErrorType.emailAlreadyInUse:
          return 'An account with this email already exists.';
        default:
          return 'Authentication error. Please try again.';
      }
    }

    if (error is ValidationException) {
      return error.message;
    }

    if (error is ApiException) {
      return error.message;
    }

    return 'Something went wrong. Please try again.';
  }

  void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = handleError(error, context: context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Future<T?> wrapAsync<T>(
    BuildContext context,
    Future<T> Function() operation,
  ) async {
    try {
      return await operation();
    } catch (e) {
      showErrorSnackBar(context, e);
      return null;
    }
  }
}
```

#### 9.1.5 Validation Utils (Adapt)
```dart
// lib/core/utils/validation.dart

class ValidationUtils {
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';

    // Optional: Add complexity requirements
    // if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Password needs an uppercase letter';
    // if (!RegExp(r'[0-9]').hasMatch(value)) return 'Password needs a number';

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return null; // Optional field

    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validatePositiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return '${fieldName ?? 'Value'} must be a positive number';
    }
    return null;
  }

  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) return null;

    final weight = double.tryParse(value);
    if (weight == null || weight <= 0 || weight > 1500) {
      return 'Please enter a valid weight';
    }
    return null;
  }

  static String? validateReps(String? value) {
    if (value == null || value.isEmpty) return 'Reps is required';

    final reps = int.tryParse(value);
    if (reps == null || reps <= 0 || reps > 1000) {
      return 'Please enter valid reps (1-1000)';
    }
    return null;
  }

  /// Chain multiple validators
  static String? validateMultiple(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}
```

#### 9.1.6 Logger Service (Improve)
```dart
// lib/core/services/logger_service.dart

import 'package:flutter/foundation.dart';

class AppLogger {
  static void debug(String message, {String? tag}) {
    _log('DEBUG', message, tag: tag);
  }

  static void info(String message, {String? tag}) {
    _log('INFO', message, tag: tag);
  }

  static void warning(String message, {String? tag}) {
    _log('WARNING', message, tag: tag);
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('ERROR', message, tag: tag);
    if (error != null && kDebugMode) {
      debugPrint('  Error: $error');
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('  StackTrace: $stackTrace');
    }
  }

  // Tagged loggers for specific domains
  static void auth(String message) => _log('AUTH', message);
  static void api(String message) => _log('API', message);
  static void network(String message) => _log('NETWORK', message);
  static void storage(String message) => _log('STORAGE', message);
  static void navigation(String message) => _log('NAV', message);

  static void _log(String level, String message, {String? tag}) {
    if (!kDebugMode) return; // No logging in production

    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final tagStr = tag != null ? '[$tag] ' : '';
    debugPrint('[$timestamp] [$level] $tagStr$message');
  }
}
```

#### 9.1.7 Connectivity Service (New)
```dart
// lib/core/services/connectivity_service.dart

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;
  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  Future<bool> get hasConnection async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Stream<bool> get connectionStream {
    return _connectivity.onConnectivityChanged.map(
      (result) => !result.contains(ConnectivityResult.none),
    );
  }
}
```

#### 9.1.8 Cache Service (New)
```dart
// lib/core/services/cache_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static final CacheService _instance = CacheService._();
  factory CacheService() => _instance;
  CacheService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> set<T>(
    String key,
    T value, {
    Duration? ttl,
  }) async {
    final data = {
      'value': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'ttl': ttl?.inMilliseconds,
    };
    await _prefs?.setString(key, jsonEncode(data));
  }

  T? get<T>(String key) {
    final raw = _prefs?.getString(key);
    if (raw == null) return null;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final timestamp = data['timestamp'] as int;
      final ttl = data['ttl'] as int?;

      // Check if expired
      if (ttl != null) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(timestamp + ttl);
        if (DateTime.now().isAfter(expiry)) {
          remove(key);
          return null;
        }
      }

      return data['value'] as T;
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }
}
```

### 9.2 Provider Pattern Template
```dart
// lib/features/workouts/providers/workouts_provider.dart

class WorkoutsProvider extends ChangeNotifier with SafeChangeNotifierMixin {
  final WorkoutsService _service;

  WorkoutsProvider({WorkoutsService? service})
      : _service = service ?? WorkoutsService();

  // State
  List<Workout> _workouts = [];
  bool _isLoading = false;
  String? _error;

  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;
  static const int _pageSize = 20;

  // Getters
  List<Workout> get workouts => _workouts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  /// Load workouts with optional refresh
  Future<void> loadWorkouts({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;
    safeNotifyListeners();

    try {
      final result = await _service.getWorkouts(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (refresh) {
        _workouts = result.items;
      } else {
        _workouts.addAll(result.items);
      }

      _hasMore = result.hasMore;
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      safeNotifyListeners();
    }
  }

  /// Load next page
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    await loadWorkouts();
  }

  /// Create new workout
  Future<Workout?> createWorkout(WorkoutData data) async {
    try {
      final workout = await _service.createWorkout(data);
      _workouts.insert(0, workout);
      safeNotifyListeners();
      return workout;
    } catch (e) {
      _error = e.toString();
      safeNotifyListeners();
      return null;
    }
  }

  /// Delete workout
  Future<bool> deleteWorkout(String id) async {
    try {
      await _service.deleteWorkout(id);
      _workouts.removeWhere((w) => w.id == id);
      safeNotifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      safeNotifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    safeNotifyListeners();
  }
}
```

---

## 10. Development Phases

### 10.1 Phase 1: MVP (8-12 weeks)

#### Week 1-2: Project Setup & Core Infrastructure
- [ ] Flutter project initialization
- [ ] Supabase project setup
- [ ] Database migrations (core tables)
- [ ] Core folder structure
- [ ] Theme configuration (colors, typography)
- [ ] Navigation setup (Go Router)
- [ ] Provider configuration
- [ ] Base services (auth, error handler, logger)
- [ ] Exception hierarchy

#### Week 3-4: Authentication
- [ ] User model & service
- [ ] Auth provider
- [ ] Login screen
- [ ] Register screen
- [ ] Forgot password screen
- [ ] Splash screen (auth check)
- [ ] Social auth (Google, Apple)
- [ ] Biometric authentication

#### Week 5-6: Onboarding & Profile
- [ ] Onboarding flow (multi-step)
- [ ] Profile setup screens
- [ ] User preferences storage
- [ ] Edit profile screen
- [ ] Avatar upload

#### Week 7-8: Membership & Gym
- [ ] Gym model & service
- [ ] Membership model & service
- [ ] QR code generation
- [ ] Home screen with QR display
- [ ] Gym finder (map + list)
- [ ] Gym detail screen
- [ ] Check-in/check-out flow
- [ ] Real-time occupancy

#### Week 9-10: Class Booking
- [ ] Class models & service
- [ ] Class schedule service
- [ ] Booking service
- [ ] Classes screen (schedule view)
- [ ] Class detail screen
- [ ] Book/cancel flow
- [ ] Waitlist functionality
- [ ] My bookings screen

#### Week 11-12: Basic Workouts & Testing
- [ ] Exercise model & service
- [ ] Workout models & service
- [ ] Exercise library screen
- [ ] Basic workout logging
- [ ] Active workout screen
- [ ] Workout summary
- [ ] Integration testing
- [ ] Bug fixes & polish

### 10.2 Phase 2: Enhanced (10-14 weeks)

#### Week 13-16: Training Plans & Custom Workouts
- [ ] Training plan models
- [ ] Training plans screen
- [ ] Plan detail & start
- [ ] Progress tracking
- [ ] Create workout screen
- [ ] Workout templates
- [ ] Edit/delete workouts

#### Week 17-20: Progress & Analytics
- [ ] Progress dashboard
- [ ] Workout stats (charts)
- [ ] Personal records tracking
- [ ] Body metrics logging
- [ ] Goals system
- [ ] Streak tracking
- [ ] Export data

#### Week 21-24: Wearables & Notifications
- [ ] HealthKit integration
- [ ] Google Fit integration
- [ ] Background sync
- [ ] Health data display
- [ ] Firebase Cloud Messaging
- [ ] Local notifications
- [ ] Notification preferences
- [ ] Class reminders

#### Week 25-26: Polish & Optimization
- [ ] Performance optimization
- [ ] Offline support
- [ ] Error handling improvements
- [ ] UI polish
- [ ] Accessibility
- [ ] App Store preparation

### 10.3 Phase 3: Advanced (12-20 weeks)
- AI coaching features
- Nutrition tracking
- PT booking & payments
- Social features
- Live classes
- Advanced analytics

---

## 11. File Structure

```
/life_and_gym/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── app.dart                           # MaterialApp configuration
│   │
│   ├── core/                              # Core/shared code
│   │   ├── config/
│   │   │   ├── app_config.dart            # App constants
│   │   │   ├── supabase_config.dart       # Supabase initialization
│   │   │   └── theme_config.dart          # Theme data
│   │   │
│   │   ├── constants/
│   │   │   ├── app_colors.dart            # Color palette
│   │   │   ├── app_typography.dart        # Text styles
│   │   │   ├── app_spacing.dart           # Spacing constants
│   │   │   └── app_strings.dart           # Static strings
│   │   │
│   │   ├── exceptions/
│   │   │   └── exceptions.dart            # Custom exceptions
│   │   │
│   │   ├── extensions/
│   │   │   ├── context_extensions.dart    # BuildContext extensions
│   │   │   ├── datetime_extensions.dart   # DateTime helpers
│   │   │   └── string_extensions.dart     # String helpers
│   │   │
│   │   ├── providers/
│   │   │   └── safe_change_notifier.dart  # Safe notifier mixin
│   │   │
│   │   ├── services/
│   │   │   ├── base_service.dart          # Base service class
│   │   │   ├── error_handler_service.dart # Error handling
│   │   │   ├── connectivity_service.dart  # Network checking
│   │   │   ├── cache_service.dart         # Local caching
│   │   │   └── logger_service.dart        # Logging
│   │   │
│   │   ├── utils/
│   │   │   ├── validation.dart            # Form validators
│   │   │   ├── formatters.dart            # Data formatters
│   │   │   └── helpers.dart               # General helpers
│   │   │
│   │   └── router/
│   │       ├── app_router.dart            # Route definitions
│   │       └── route_names.dart           # Route name constants
│   │
│   ├── features/                          # Feature modules
│   │   │
│   │   ├── auth/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   ├── services/
│   │   │   │   └── auth_service.dart
│   │   │   ├── screens/
│   │   │   │   ├── splash_screen.dart
│   │   │   │   ├── welcome_screen.dart
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── forgot_password_screen.dart
│   │   │   └── widgets/
│   │   │       ├── auth_form.dart
│   │   │       └── social_auth_buttons.dart
│   │   │
│   │   ├── onboarding/
│   │   │   ├── providers/
│   │   │   │   └── onboarding_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── onboarding_flow.dart
│   │   │   └── widgets/
│   │   │       └── onboarding_step.dart
│   │   │
│   │   ├── home/
│   │   │   ├── providers/
│   │   │   │   └── home_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── qr_check_in_card.dart
│   │   │       ├── gym_status_card.dart
│   │   │       ├── todays_workout_card.dart
│   │   │       ├── upcoming_classes_card.dart
│   │   │       └── weekly_progress_card.dart
│   │   │
│   │   ├── membership/
│   │   │   ├── models/
│   │   │   │   ├── membership_model.dart
│   │   │   │   └── check_in_model.dart
│   │   │   ├── providers/
│   │   │   │   └── membership_provider.dart
│   │   │   ├── services/
│   │   │   │   └── membership_service.dart
│   │   │   ├── screens/
│   │   │   │   └── membership_screen.dart
│   │   │   └── widgets/
│   │   │       └── qr_code_display.dart
│   │   │
│   │   ├── gyms/
│   │   │   ├── models/
│   │   │   │   └── gym_model.dart
│   │   │   ├── providers/
│   │   │   │   └── gyms_provider.dart
│   │   │   ├── services/
│   │   │   │   └── gyms_service.dart
│   │   │   ├── screens/
│   │   │   │   ├── gym_finder_screen.dart
│   │   │   │   └── gym_detail_screen.dart
│   │   │   └── widgets/
│   │   │       ├── gym_map.dart
│   │   │       ├── gym_list_item.dart
│   │   │       └── occupancy_indicator.dart
│   │   │
│   │   ├── classes/
│   │   │   ├── models/
│   │   │   │   ├── class_model.dart
│   │   │   │   ├── class_schedule_model.dart
│   │   │   │   └── booking_model.dart
│   │   │   ├── providers/
│   │   │   │   ├── classes_provider.dart
│   │   │   │   └── bookings_provider.dart
│   │   │   ├── services/
│   │   │   │   ├── classes_service.dart
│   │   │   │   └── bookings_service.dart
│   │   │   ├── screens/
│   │   │   │   ├── classes_screen.dart
│   │   │   │   ├── class_detail_screen.dart
│   │   │   │   └── my_bookings_screen.dart
│   │   │   └── widgets/
│   │   │       ├── class_card.dart
│   │   │       ├── schedule_calendar.dart
│   │   │       └── booking_button.dart
│   │   │
│   │   ├── workouts/
│   │   │   ├── models/
│   │   │   │   ├── exercise_model.dart
│   │   │   │   ├── workout_model.dart
│   │   │   │   ├── workout_session_model.dart
│   │   │   │   └── workout_log_model.dart
│   │   │   ├── providers/
│   │   │   │   ├── exercises_provider.dart
│   │   │   │   ├── workouts_provider.dart
│   │   │   │   └── active_workout_provider.dart
│   │   │   ├── services/
│   │   │   │   ├── exercises_service.dart
│   │   │   │   ├── workouts_service.dart
│   │   │   │   └── workout_session_service.dart
│   │   │   ├── screens/
│   │   │   │   ├── workouts_screen.dart
│   │   │   │   ├── workout_detail_screen.dart
│   │   │   │   ├── active_workout_screen.dart
│   │   │   │   ├── workout_summary_screen.dart
│   │   │   │   ├── exercise_library_screen.dart
│   │   │   │   ├── exercise_detail_screen.dart
│   │   │   │   └── create_workout_screen.dart
│   │   │   └── widgets/
│   │   │       ├── exercise_card.dart
│   │   │       ├── set_row.dart
│   │   │       ├── rest_timer.dart
│   │   │       └── exercise_animation.dart
│   │   │
│   │   ├── training_plans/
│   │   │   ├── models/
│   │   │   │   └── training_plan_model.dart
│   │   │   ├── providers/
│   │   │   │   └── training_plans_provider.dart
│   │   │   ├── services/
│   │   │   │   └── training_plans_service.dart
│   │   │   ├── screens/
│   │   │   │   ├── training_plans_screen.dart
│   │   │   │   └── training_plan_detail_screen.dart
│   │   │   └── widgets/
│   │   │       └── plan_card.dart
│   │   │
│   │   ├── progress/
│   │   │   ├── models/
│   │   │   │   ├── goal_model.dart
│   │   │   │   └── body_metrics_model.dart
│   │   │   ├── providers/
│   │   │   │   ├── progress_provider.dart
│   │   │   │   └── goals_provider.dart
│   │   │   ├── services/
│   │   │   │   ├── progress_service.dart
│   │   │   │   └── goals_service.dart
│   │   │   ├── screens/
│   │   │   │   ├── progress_screen.dart
│   │   │   │   ├── body_metrics_screen.dart
│   │   │   │   ├── personal_records_screen.dart
│   │   │   │   └── goals_screen.dart
│   │   │   └── widgets/
│   │   │       ├── progress_chart.dart
│   │   │       ├── streak_indicator.dart
│   │   │       └── pr_card.dart
│   │   │
│   │   └── profile/
│   │       ├── providers/
│   │       │   └── profile_provider.dart
│   │       ├── screens/
│   │       │   ├── profile_screen.dart
│   │       │   ├── edit_profile_screen.dart
│   │       │   ├── settings_screen.dart
│   │       │   └── notifications_screen.dart
│   │       └── widgets/
│   │           └── profile_header.dart
│   │
│   └── shared/                            # Shared UI components
│       ├── widgets/
│       │   ├── app_bar.dart
│       │   ├── bottom_nav_bar.dart
│       │   ├── loading_indicator.dart
│       │   ├── error_view.dart
│       │   ├── empty_state.dart
│       │   ├── primary_button.dart
│       │   ├── secondary_button.dart
│       │   ├── input_field.dart
│       │   ├── card_container.dart
│       │   ├── avatar.dart
│       │   └── shimmer_loading.dart
│       │
│       └── dialogs/
│           ├── confirm_dialog.dart
│           └── error_dialog.dart
│
├── assets/
│   ├── images/
│   ├── icons/
│   ├── animations/                        # Lottie files
│   └── fonts/
│
├── supabase/
│   ├── migrations/
│   │   ├── 00001_initial_schema.sql
│   │   ├── 00002_gyms_and_memberships.sql
│   │   ├── 00003_classes_and_bookings.sql
│   │   ├── 00004_workouts_and_exercises.sql
│   │   ├── 00005_progress_and_goals.sql
│   │   └── 00006_rls_policies.sql
│   │
│   └── functions/
│       ├── check-in/
│       ├── check-out/
│       ├── book-class/
│       └── complete-workout/
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── pubspec.yaml
├── analysis_options.yaml
├── MASTER_PLAN.md                         # This file
└── README.md
```

---

## 12. Mistakes to Avoid

### 12.1 Critical (From Cuckoo Analysis)

| Issue | Bad Example | Good Example |
|-------|-------------|--------------|
| Disabled security in production | `bool get canList => isActive` (skipping `&& isVerified`) | Always keep security checks enabled; use feature flags for testing |
| Generic exceptions | `throw Exception('Failed')` | `throw ApiException('Failed', statusCode: 500)` |
| Debug logs in production | `debugPrint('🔵 Fetching...')` | `if (kDebugMode) debugPrint(...)` |
| API inconsistency workarounds | Parsing `image_urls`, `images`, `image_url` | Standardize API schema upfront |
| No caching | Always fetch fresh data | Implement cache-then-network pattern |
| No connectivity check | Direct API call | Check connectivity before requests |
| Silent failures | `catch (e) { return null; }` | Update error state, notify listeners |
| God services | `SellerApiService` with 50+ methods | Split by domain |
| Magic strings | `status ?? 'active'` | Use enums: `Status.active` |

### 12.2 Performance Issues

| Issue | Problem | Solution |
|-------|---------|----------|
| No pagination | Loading all data at once | Implement cursor/offset pagination |
| Redundant API calls | Same data fetched multiple times | Deduplicate requests, use caching |
| No image optimization | Full-size images everywhere | Use thumbnails, lazy loading |
| Blocking UI | Heavy operations on main thread | Use `compute()` for parsing |
| Memory leaks | Not disposing listeners | Use `SafeChangeNotifierMixin` |

### 12.3 UX Anti-Patterns

| Issue | Problem | Solution |
|-------|---------|----------|
| Slow onboarding | >60 seconds to first workout | Minimize steps, progressive disclosure |
| Pop-ups during workout | Interrupts focus | Distraction-free workout mode |
| Too many notifications | User uninstalls app | Smart, configurable notifications |
| No offline support | App unusable without internet | Core features work offline |
| Complex class booking | GoodLife user complaints | Simple, intuitive booking flow |

### 12.4 Security Checklist

- [ ] Never store tokens in plain SharedPreferences (use flutter_secure_storage)
- [ ] Validate all API responses
- [ ] Enable RLS on all user data tables
- [ ] Use parameterized queries (Supabase handles this)
- [ ] Never expose API keys in client code
- [ ] Implement rate limiting (Supabase built-in)
- [ ] Validate file uploads (type, size)
- [ ] Sanitize user input

---

## 13. Testing Strategy

### 13.1 Unit Tests
- All services (mock Supabase)
- All providers (mock services)
- Validation utilities
- Formatters and helpers

### 13.2 Widget Tests
- Form validations
- Button interactions
- List rendering
- Loading states
- Error states

### 13.3 Integration Tests
- Auth flow (register → login → logout)
- Onboarding flow
- Class booking flow
- Workout logging flow
- Check-in/check-out flow

### 13.4 Test Coverage Goals
- Core services: >90%
- Providers: >80%
- Widgets: >70%
- Overall: >75%

---

## 14. Deployment

### 14.1 Environment Configuration

```dart
// lib/core/config/app_config.dart

enum Environment { development, staging, production }

class AppConfig {
  static late Environment environment;

  static String get supabaseUrl {
    switch (environment) {
      case Environment.development:
        return 'http://localhost:54321';
      case Environment.staging:
        return 'https://staging-xxx.supabase.co';
      case Environment.production:
        return 'https://prod-xxx.supabase.co';
    }
  }

  static String get supabaseAnonKey {
    // Load from environment or secure storage
    return const String.fromEnvironment('SUPABASE_ANON_KEY');
  }
}
```

### 14.2 Build Commands

```bash
# Development
flutter run --dart-define=ENV=development

# Staging
flutter build apk --dart-define=ENV=staging
flutter build ios --dart-define=ENV=staging

# Production
flutter build apk --release --dart-define=ENV=production
flutter build ios --release --dart-define=ENV=production
```

### 14.3 App Store Checklist

- [ ] App icons (all sizes)
- [ ] Splash screen
- [ ] Screenshots (all device sizes)
- [ ] App description
- [ ] Privacy policy URL
- [ ] Terms of service URL
- [ ] Age rating questionnaire
- [ ] App category selection
- [ ] Keywords/tags
- [ ] Release notes

---

## Appendix A: Quick Reference

### Common Supabase Queries

```dart
// Get current user's memberships with gym info
final memberships = await supabase
    .from('memberships')
    .select('*, gyms(*)')
    .eq('user_id', userId)
    .eq('status', 'active');

// Get today's classes for a gym
final classes = await supabase
    .from('class_schedules')
    .select('*, classes(*), trainers(user_id, users(full_name))')
    .eq('gym_id', gymId)
    .gte('scheduled_at', today)
    .lt('scheduled_at', tomorrow)
    .order('scheduled_at');

// Get user's workout history (paginated)
final workouts = await supabase
    .from('workout_sessions')
    .select('*, workouts(name)')
    .eq('user_id', userId)
    .order('started_at', ascending: false)
    .range(0, 19);

// Get personal records
final prs = await supabase
    .rpc('get_personal_records', params: {'user_id': userId});
```

### Color Usage Quick Reference

| Context | Light Mode | Dark Mode |
|---------|------------|-----------|
| Background | Slate 50 | Slate 900 |
| Cards | White | Slate 800 |
| Primary action | Indigo 500 | Indigo 500 |
| Text | Slate 900 | Slate 50 |
| Secondary text | Slate 500 | Slate 400 |
| Success | Green 500 | Green 500 |
| Warning | Amber 500 | Amber 500 |
| Error | Red 500 | Red 500 |

---

**Document Version:** 1.0
**Last Updated:** 2026-01-24
**Author:** AI Assistant (Claude)

---

*This document should be referenced before implementing any feature to ensure consistency across the codebase.*
