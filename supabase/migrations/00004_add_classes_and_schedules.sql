-- ============================================
-- LifeAndGym Database Schema
-- Migration 00004: Add Classes and Schedules for Midtown and 24/7 Gyms
-- ============================================

-- ============================================
-- ADD CLASSES FOR MIDTOWN GYM
-- ============================================
INSERT INTO classes (gym_id, name, description, type, difficulty, duration_minutes, capacity, equipment_needed)
SELECT
  g.id,
  'Morning Yoga Flow',
  'Start your day with a rejuvenating yoga session focusing on flexibility and mindfulness.',
  'yoga',
  'all_levels',
  60,
  20,
  ARRAY['yoga_mat']
FROM gyms g WHERE g.slug = 'midtown';

INSERT INTO classes (gym_id, name, description, type, difficulty, duration_minutes, capacity, equipment_needed)
SELECT
  g.id,
  'HIIT Blast',
  'High-intensity interval training to burn calories and build endurance.',
  'hiit',
  'intermediate',
  45,
  15,
  ARRAY[]::TEXT[]
FROM gyms g WHERE g.slug = 'midtown';

INSERT INTO classes (gym_id, name, description, type, difficulty, duration_minutes, capacity, equipment_needed)
SELECT
  g.id,
  'Spin Class',
  'Indoor cycling class with high-energy music and motivated instructors.',
  'spin',
  'all_levels',
  45,
  25,
  ARRAY['spin_bike']
FROM gyms g WHERE g.slug = 'midtown';

INSERT INTO classes (gym_id, name, description, type, difficulty, duration_minutes, capacity, equipment_needed)
SELECT
  g.id,
  'Strength & Conditioning',
  'Build strength and improve conditioning with this comprehensive class.',
  'strength',
  'intermediate',
  60,
  12,
  ARRAY['barbell', 'dumbbells', 'kettlebell']
FROM gyms g WHERE g.slug = 'midtown';

INSERT INTO classes (gym_id, name, description, type, difficulty, duration_minutes, capacity, equipment_needed)
SELECT
  g.id,
  'Boxing Basics',
  'Learn boxing fundamentals while getting an intense cardio workout.',
  'boxing',
  'beginner',
  60,
  10,
  ARRAY['boxing_gloves', 'punching_bag']
FROM gyms g WHERE g.slug = 'midtown';

-- ============================================
-- ADD CLASSES FOR 24/7 GYM
-- ============================================
INSERT INTO classes (gym_id, name, description, type, difficulty, duration_minutes, capacity, equipment_needed)
SELECT
  g.id,
  'Morning Yoga Flow',
  'Start your day with a rejuvenating yoga session focusing on flexibility and mindfulness.',
  'yoga',
  'all_levels',
  60,
  20,
  ARRAY['yoga_mat']
FROM gyms g WHERE g.slug = '24-7';

INSERT INTO classes (gym_id, name, description, type, difficulty, duration_minutes, capacity, equipment_needed)
SELECT
  g.id,
  'HIIT Blast',
  'High-intensity interval training to burn calories and build endurance.',
  'hiit',
  'intermediate',
  45,
  15,
  ARRAY[]::TEXT[]
FROM gyms g WHERE g.slug = '24-7';

INSERT INTO classes (gym_id, name, description, type, difficulty, duration_minutes, capacity, equipment_needed)
SELECT
  g.id,
  'Spin Class',
  'Indoor cycling class with high-energy music and motivated instructors.',
  'spin',
  'all_levels',
  45,
  25,
  ARRAY['spin_bike']
FROM gyms g WHERE g.slug = '24-7';

INSERT INTO classes (gym_id, name, description, type, difficulty, duration_minutes, capacity, equipment_needed)
SELECT
  g.id,
  'Strength & Conditioning',
  'Build strength and improve conditioning with this comprehensive class.',
  'strength',
  'intermediate',
  60,
  12,
  ARRAY['barbell', 'dumbbells', 'kettlebell']
FROM gyms g WHERE g.slug = '24-7';

INSERT INTO classes (gym_id, name, description, type, difficulty, duration_minutes, capacity, equipment_needed)
SELECT
  g.id,
  'Boxing Basics',
  'Learn boxing fundamentals while getting an intense cardio workout.',
  'boxing',
  'beginner',
  60,
  10,
  ARRAY['boxing_gloves', 'punching_bag']
FROM gyms g WHERE g.slug = '24-7';

-- ============================================
-- CREATE SCHEDULES FOR MIDTOWN GYM (7 days x 5 classes = 35 schedules)
-- ============================================

-- Day 1: 2026-01-25
INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-25 07:00:00'::timestamptz, c.duration_minutes, 20, 20, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Morning Yoga Flow';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-25 12:00:00'::timestamptz, c.duration_minutes, 15, 15, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'HIIT Blast';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-25 17:00:00'::timestamptz, c.duration_minutes, 12, 12, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Strength & Conditioning';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-25 18:00:00'::timestamptz, c.duration_minutes, 25, 25, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Spin Class';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-25 19:00:00'::timestamptz, c.duration_minutes, 10, 10, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Boxing Basics';

-- Day 2: 2026-01-26
INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-26 07:00:00'::timestamptz, c.duration_minutes, 20, 20, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Morning Yoga Flow';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-26 12:00:00'::timestamptz, c.duration_minutes, 15, 15, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'HIIT Blast';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-26 17:00:00'::timestamptz, c.duration_minutes, 12, 12, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Strength & Conditioning';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-26 18:00:00'::timestamptz, c.duration_minutes, 25, 25, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Spin Class';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-26 19:00:00'::timestamptz, c.duration_minutes, 10, 10, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Boxing Basics';

-- Day 3: 2026-01-27
INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-27 07:00:00'::timestamptz, c.duration_minutes, 20, 20, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Morning Yoga Flow';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-27 12:00:00'::timestamptz, c.duration_minutes, 15, 15, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'HIIT Blast';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-27 17:00:00'::timestamptz, c.duration_minutes, 12, 12, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Strength & Conditioning';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-27 18:00:00'::timestamptz, c.duration_minutes, 25, 25, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Spin Class';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-27 19:00:00'::timestamptz, c.duration_minutes, 10, 10, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Boxing Basics';

-- Day 4: 2026-01-28
INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-28 07:00:00'::timestamptz, c.duration_minutes, 20, 20, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Morning Yoga Flow';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-28 12:00:00'::timestamptz, c.duration_minutes, 15, 15, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'HIIT Blast';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-28 17:00:00'::timestamptz, c.duration_minutes, 12, 12, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Strength & Conditioning';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-28 18:00:00'::timestamptz, c.duration_minutes, 25, 25, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Spin Class';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-28 19:00:00'::timestamptz, c.duration_minutes, 10, 10, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Boxing Basics';

-- Day 5: 2026-01-29
INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-29 07:00:00'::timestamptz, c.duration_minutes, 20, 20, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Morning Yoga Flow';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-29 12:00:00'::timestamptz, c.duration_minutes, 15, 15, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'HIIT Blast';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-29 17:00:00'::timestamptz, c.duration_minutes, 12, 12, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Strength & Conditioning';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-29 18:00:00'::timestamptz, c.duration_minutes, 25, 25, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Spin Class';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-29 19:00:00'::timestamptz, c.duration_minutes, 10, 10, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Boxing Basics';

-- Day 6: 2026-01-30
INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-30 07:00:00'::timestamptz, c.duration_minutes, 20, 20, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Morning Yoga Flow';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-30 12:00:00'::timestamptz, c.duration_minutes, 15, 15, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'HIIT Blast';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-30 17:00:00'::timestamptz, c.duration_minutes, 12, 12, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Strength & Conditioning';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-30 18:00:00'::timestamptz, c.duration_minutes, 25, 25, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Spin Class';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-30 19:00:00'::timestamptz, c.duration_minutes, 10, 10, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Boxing Basics';

-- Day 7: 2026-01-31
INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-31 07:00:00'::timestamptz, c.duration_minutes, 20, 20, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Morning Yoga Flow';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-31 12:00:00'::timestamptz, c.duration_minutes, 15, 15, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'HIIT Blast';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-31 17:00:00'::timestamptz, c.duration_minutes, 12, 12, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Strength & Conditioning';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-31 18:00:00'::timestamptz, c.duration_minutes, 25, 25, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Spin Class';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-31 19:00:00'::timestamptz, c.duration_minutes, 10, 10, 'scheduled'
FROM classes c WHERE c.gym_id = 'f162e2c2-8127-4a64-82c3-4cce08b885c4' AND c.name = 'Boxing Basics';

-- ============================================
-- CREATE SCHEDULES FOR 24/7 GYM (7 days x 5 classes = 35 schedules)
-- ============================================

-- Day 1: 2026-01-25
INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-25 07:00:00'::timestamptz, c.duration_minutes, 20, 20, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Morning Yoga Flow';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-25 12:00:00'::timestamptz, c.duration_minutes, 15, 15, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'HIIT Blast';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-25 17:00:00'::timestamptz, c.duration_minutes, 12, 12, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Strength & Conditioning';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-25 18:00:00'::timestamptz, c.duration_minutes, 25, 25, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Spin Class';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-25 19:00:00'::timestamptz, c.duration_minutes, 10, 10, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Boxing Basics';

-- Day 2: 2026-01-26
INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-26 07:00:00'::timestamptz, c.duration_minutes, 20, 20, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Morning Yoga Flow';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-26 12:00:00'::timestamptz, c.duration_minutes, 15, 15, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'HIIT Blast';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-26 17:00:00'::timestamptz, c.duration_minutes, 12, 12, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Strength & Conditioning';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-26 18:00:00'::timestamptz, c.duration_minutes, 25, 25, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Spin Class';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-26 19:00:00'::timestamptz, c.duration_minutes, 10, 10, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Boxing Basics';

-- Day 3: 2026-01-27
INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-27 07:00:00'::timestamptz, c.duration_minutes, 20, 20, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Morning Yoga Flow';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-27 12:00:00'::timestamptz, c.duration_minutes, 15, 15, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'HIIT Blast';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-27 17:00:00'::timestamptz, c.duration_minutes, 12, 12, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Strength & Conditioning';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-27 18:00:00'::timestamptz, c.duration_minutes, 25, 25, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Spin Class';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-27 19:00:00'::timestamptz, c.duration_minutes, 10, 10, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Boxing Basics';

-- Day 4: 2026-01-28
INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-28 07:00:00'::timestamptz, c.duration_minutes, 20, 20, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Morning Yoga Flow';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-28 12:00:00'::timestamptz, c.duration_minutes, 15, 15, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'HIIT Blast';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-28 17:00:00'::timestamptz, c.duration_minutes, 12, 12, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Strength & Conditioning';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-28 18:00:00'::timestamptz, c.duration_minutes, 25, 25, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Spin Class';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-28 19:00:00'::timestamptz, c.duration_minutes, 10, 10, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Boxing Basics';

-- Day 5: 2026-01-29
INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-29 07:00:00'::timestamptz, c.duration_minutes, 20, 20, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Morning Yoga Flow';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-29 12:00:00'::timestamptz, c.duration_minutes, 15, 15, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'HIIT Blast';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-29 17:00:00'::timestamptz, c.duration_minutes, 12, 12, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Strength & Conditioning';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-29 18:00:00'::timestamptz, c.duration_minutes, 25, 25, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Spin Class';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-29 19:00:00'::timestamptz, c.duration_minutes, 10, 10, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Boxing Basics';

-- Day 6: 2026-01-30
INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-30 07:00:00'::timestamptz, c.duration_minutes, 20, 20, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Morning Yoga Flow';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-30 12:00:00'::timestamptz, c.duration_minutes, 15, 15, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'HIIT Blast';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-30 17:00:00'::timestamptz, c.duration_minutes, 12, 12, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Strength & Conditioning';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-30 18:00:00'::timestamptz, c.duration_minutes, 25, 25, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Spin Class';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-30 19:00:00'::timestamptz, c.duration_minutes, 10, 10, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Boxing Basics';

-- Day 7: 2026-01-31
INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-31 07:00:00'::timestamptz, c.duration_minutes, 20, 20, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Morning Yoga Flow';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-31 12:00:00'::timestamptz, c.duration_minutes, 15, 15, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'HIIT Blast';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-31 17:00:00'::timestamptz, c.duration_minutes, 12, 12, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Strength & Conditioning';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-31 18:00:00'::timestamptz, c.duration_minutes, 25, 25, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Spin Class';

INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
SELECT c.id, c.gym_id, '2026-01-31 19:00:00'::timestamptz, c.duration_minutes, 10, 10, 'scheduled'
FROM classes c WHERE c.gym_id = '1ac65486-92c8-428a-9d95-ab5f4bc696f8' AND c.name = 'Boxing Basics';
