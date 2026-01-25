-- ============================================
-- LifeAndGym Database Schema
-- Migration 00003: Seed Data
-- ============================================

-- ============================================
-- SEED EXERCISES
-- ============================================
INSERT INTO exercises (name, description, instructions, muscle_groups, equipment, difficulty, exercise_type, is_compound, calories_per_minute) VALUES
-- Chest
('Barbell Bench Press', 'The classic chest exercise for building strength and mass.',
  ARRAY['Lie flat on the bench with eyes under the bar', 'Grip the bar slightly wider than shoulder width', 'Unrack and lower to mid-chest', 'Press up until arms are fully extended'],
  ARRAY['chest', 'triceps', 'shoulders'], ARRAY['barbell', 'bench'], 'intermediate', 'strength', TRUE, 8.0),

('Dumbbell Bench Press', 'A versatile pressing movement allowing greater range of motion.',
  ARRAY['Lie flat with a dumbbell in each hand', 'Start with arms extended above chest', 'Lower dumbbells to sides of chest', 'Press back up to starting position'],
  ARRAY['chest', 'triceps', 'shoulders'], ARRAY['dumbbells', 'bench'], 'beginner', 'strength', TRUE, 7.5),

('Push-Ups', 'Bodyweight exercise for chest, shoulders, and triceps.',
  ARRAY['Start in plank position with hands shoulder-width apart', 'Lower body until chest nearly touches floor', 'Push back up to starting position', 'Keep core tight throughout'],
  ARRAY['chest', 'triceps', 'shoulders', 'core'], ARRAY[]::TEXT[], 'beginner', 'strength', TRUE, 7.0),

('Incline Dumbbell Press', 'Targets the upper chest muscles.',
  ARRAY['Set bench to 30-45 degree incline', 'Press dumbbells up from shoulders', 'Lower with control to chest level', 'Keep feet flat on floor'],
  ARRAY['chest', 'shoulders', 'triceps'], ARRAY['dumbbells', 'bench'], 'intermediate', 'strength', TRUE, 7.5),

('Cable Flyes', 'Isolation exercise for chest with constant tension.',
  ARRAY['Set pulleys to shoulder height', 'Grip handles and step forward', 'Bring hands together in front of chest', 'Control the return movement'],
  ARRAY['chest'], ARRAY['cable_machine'], 'intermediate', 'strength', FALSE, 5.0),

-- Back
('Barbell Rows', 'Compound back exercise for thickness and strength.',
  ARRAY['Bend at hips with slight knee bend', 'Grip bar shoulder-width apart', 'Pull bar to lower chest', 'Lower with control'],
  ARRAY['back', 'biceps', 'shoulders'], ARRAY['barbell'], 'intermediate', 'strength', TRUE, 8.0),

('Pull-Ups', 'Classic bodyweight back exercise.',
  ARRAY['Hang from bar with overhand grip', 'Pull up until chin clears bar', 'Lower with control', 'Avoid swinging'],
  ARRAY['back', 'biceps', 'shoulders'], ARRAY['pull_up_bar'], 'intermediate', 'strength', TRUE, 9.0),

('Lat Pulldown', 'Machine-based lat exercise for beginners to advanced.',
  ARRAY['Sit with thighs secured under pads', 'Grip bar wider than shoulder width', 'Pull bar to upper chest', 'Control the return'],
  ARRAY['back', 'biceps'], ARRAY['cable_machine'], 'beginner', 'strength', TRUE, 6.0),

('Seated Cable Row', 'Excellent for mid-back development.',
  ARRAY['Sit with feet on platform', 'Grip handle with arms extended', 'Pull to abdomen squeezing shoulder blades', 'Extend arms with control'],
  ARRAY['back', 'biceps'], ARRAY['cable_machine'], 'beginner', 'strength', TRUE, 6.0),

('Deadlift', 'The king of compound exercises.',
  ARRAY['Stand with feet hip-width apart', 'Grip bar just outside legs', 'Drive through heels and extend hips', 'Lower bar with control following same path'],
  ARRAY['back', 'glutes', 'hamstrings', 'core'], ARRAY['barbell'], 'advanced', 'strength', TRUE, 10.0),

-- Shoulders
('Overhead Press', 'Primary shoulder strength builder.',
  ARRAY['Stand with bar at shoulder height', 'Press bar overhead', 'Lock out arms at top', 'Lower to shoulders with control'],
  ARRAY['shoulders', 'triceps'], ARRAY['barbell'], 'intermediate', 'strength', TRUE, 7.0),

('Lateral Raises', 'Isolation exercise for side delts.',
  ARRAY['Stand with dumbbells at sides', 'Raise arms out to sides until parallel', 'Control the lowering phase', 'Keep slight bend in elbows'],
  ARRAY['shoulders'], ARRAY['dumbbells'], 'beginner', 'strength', FALSE, 4.0),

('Face Pulls', 'Great for rear delts and shoulder health.',
  ARRAY['Set cable at face height', 'Pull rope to face with elbows high', 'Squeeze shoulder blades at end', 'Return with control'],
  ARRAY['shoulders', 'back'], ARRAY['cable_machine'], 'beginner', 'strength', FALSE, 4.0),

-- Arms
('Barbell Curl', 'Classic bicep builder.',
  ARRAY['Stand with bar at thigh level', 'Curl bar up to shoulders', 'Squeeze biceps at top', 'Lower with control'],
  ARRAY['biceps'], ARRAY['barbell'], 'beginner', 'strength', FALSE, 5.0),

('Tricep Pushdown', 'Effective tricep isolation.',
  ARRAY['Grip cable attachment at chest height', 'Push down until arms are straight', 'Keep elbows at sides', 'Control the return'],
  ARRAY['triceps'], ARRAY['cable_machine'], 'beginner', 'strength', FALSE, 4.0),

('Hammer Curls', 'Builds biceps and forearms.',
  ARRAY['Hold dumbbells with neutral grip', 'Curl up keeping palms facing each other', 'Squeeze at top', 'Lower with control'],
  ARRAY['biceps', 'forearms'], ARRAY['dumbbells'], 'beginner', 'strength', FALSE, 5.0),

-- Legs
('Barbell Squat', 'The king of leg exercises.',
  ARRAY['Position bar on upper back', 'Feet shoulder-width apart', 'Squat down until thighs parallel', 'Drive up through heels'],
  ARRAY['quadriceps', 'glutes', 'hamstrings', 'core'], ARRAY['barbell', 'squat_rack'], 'intermediate', 'strength', TRUE, 10.0),

('Leg Press', 'Machine-based leg builder.',
  ARRAY['Sit with back flat against pad', 'Place feet shoulder-width on platform', 'Lower platform with control', 'Push through heels to extend'],
  ARRAY['quadriceps', 'glutes', 'hamstrings'], ARRAY['leg_press'], 'beginner', 'strength', TRUE, 8.0),

('Romanian Deadlift', 'Targets hamstrings and glutes.',
  ARRAY['Hold bar at thigh level', 'Hinge at hips pushing them back', 'Lower bar along legs', 'Drive hips forward to stand'],
  ARRAY['hamstrings', 'glutes', 'back'], ARRAY['barbell'], 'intermediate', 'strength', TRUE, 7.0),

('Leg Curl', 'Isolation for hamstrings.',
  ARRAY['Lie face down on machine', 'Position pad above heels', 'Curl weight toward glutes', 'Lower with control'],
  ARRAY['hamstrings'], ARRAY['leg_curl_machine'], 'beginner', 'strength', FALSE, 5.0),

('Calf Raises', 'Build calf muscles.',
  ARRAY['Stand on platform with heels hanging off', 'Rise up on toes', 'Pause at top', 'Lower slowly below platform level'],
  ARRAY['calves'], ARRAY['calf_raise_machine'], 'beginner', 'strength', FALSE, 4.0),

-- Core
('Plank', 'Isometric core stabilization.',
  ARRAY['Start in push-up position on forearms', 'Keep body in straight line', 'Engage core and hold', 'Breathe steadily'],
  ARRAY['core', 'shoulders'], ARRAY[]::TEXT[], 'beginner', 'strength', FALSE, 4.0),

('Hanging Leg Raise', 'Advanced core exercise.',
  ARRAY['Hang from pull-up bar', 'Raise legs until parallel to floor', 'Lower with control', 'Avoid swinging'],
  ARRAY['core', 'hip_flexors'], ARRAY['pull_up_bar'], 'advanced', 'strength', FALSE, 6.0),

('Cable Woodchop', 'Rotational core exercise.',
  ARRAY['Set cable at high position', 'Rotate torso pulling cable diagonally down', 'Control the return', 'Keep arms relatively straight'],
  ARRAY['core', 'obliques'], ARRAY['cable_machine'], 'intermediate', 'strength', FALSE, 5.0),

-- Cardio
('Treadmill Running', 'Cardiovascular endurance training.',
  ARRAY['Set speed and incline', 'Maintain steady pace', 'Keep good posture', 'Land midfoot'],
  ARRAY['cardio', 'legs'], ARRAY['treadmill'], 'beginner', 'cardio', FALSE, 12.0),

('Stationary Bike', 'Low-impact cardio option.',
  ARRAY['Adjust seat height', 'Set resistance level', 'Maintain steady cadence', 'Keep core engaged'],
  ARRAY['cardio', 'legs'], ARRAY['stationary_bike'], 'beginner', 'cardio', FALSE, 8.0),

('Rowing Machine', 'Full-body cardio workout.',
  ARRAY['Grip handle with arms extended', 'Drive with legs first', 'Pull handle to chest', 'Return in reverse order'],
  ARRAY['cardio', 'back', 'legs', 'arms'], ARRAY['rowing_machine'], 'intermediate', 'cardio', TRUE, 10.0);

-- ============================================
-- SEED TRAINING PLANS
-- ============================================
INSERT INTO training_plans (name, description, duration_weeks, difficulty, goal_type, workouts_per_week, plan_structure, equipment_needed, is_premium) VALUES
('Beginner Full Body', 'Perfect for those new to the gym. Build a foundation of strength with simple, effective exercises.',
  8, 'beginner', 'general_fitness', 3,
  '{"weeks": [{"days": [{"name": "Full Body A", "exercises": ["Barbell Squat", "Dumbbell Bench Press", "Barbell Rows", "Overhead Press", "Plank"]}, {"name": "Rest"}, {"name": "Full Body B", "exercises": ["Deadlift", "Push-Ups", "Lat Pulldown", "Lateral Raises", "Leg Press"]}, {"name": "Rest"}, {"name": "Full Body A"}, {"name": "Rest"}, {"name": "Rest"}]}]}',
  ARRAY['barbell', 'dumbbells', 'cable_machine'], FALSE),

('Muscle Building 12-Week', 'Comprehensive hypertrophy program for building lean muscle mass.',
  12, 'intermediate', 'muscle_gain', 5,
  '{"weeks": [{"days": [{"name": "Chest & Triceps"}, {"name": "Back & Biceps"}, {"name": "Rest"}, {"name": "Shoulders & Abs"}, {"name": "Legs"}, {"name": "Rest"}, {"name": "Rest"}]}]}',
  ARRAY['barbell', 'dumbbells', 'cable_machine', 'bench'], TRUE),

('Fat Loss HIIT', 'High-intensity program designed for maximum calorie burn and fat loss.',
  6, 'intermediate', 'weight_loss', 4,
  '{"weeks": [{"days": [{"name": "HIIT Cardio"}, {"name": "Upper Body Circuit"}, {"name": "Rest"}, {"name": "HIIT Cardio"}, {"name": "Lower Body Circuit"}, {"name": "Active Recovery"}, {"name": "Rest"}]}]}',
  ARRAY['treadmill', 'dumbbells', 'kettlebell'], FALSE),

('Strength Foundation', 'Build raw strength with progressive overload on compound lifts.',
  8, 'intermediate', 'strength', 4,
  '{"weeks": [{"days": [{"name": "Squat Focus"}, {"name": "Bench Focus"}, {"name": "Rest"}, {"name": "Deadlift Focus"}, {"name": "Overhead Press Focus"}, {"name": "Rest"}, {"name": "Rest"}]}]}',
  ARRAY['barbell', 'squat_rack', 'bench'], FALSE);

-- ============================================
-- SEED SAMPLE GYM
-- ============================================
INSERT INTO gyms (name, slug, description, address, city, state, country, postal_code, latitude, longitude, phone, email, amenities, equipment, operating_hours, capacity, is_24_hours) VALUES
('LifeAndGym Downtown', 'downtown', 'Our flagship location with state-of-the-art equipment and expert trainers.',
  '123 Fitness Street', 'New York', 'NY', 'US', '10001',
  40.7128, -74.0060,
  '+1 (555) 123-4567', 'downtown@lifeandgym.com',
  ARRAY['parking', 'showers', 'lockers', 'sauna', 'wifi', 'towels', 'water_fountain'],
  ARRAY['treadmill', 'weights', 'machines', 'yoga_studio', 'spin_bikes'],
  '{"monday": {"open": "05:00", "close": "23:00"}, "tuesday": {"open": "05:00", "close": "23:00"}, "wednesday": {"open": "05:00", "close": "23:00"}, "thursday": {"open": "05:00", "close": "23:00"}, "friday": {"open": "05:00", "close": "22:00"}, "saturday": {"open": "07:00", "close": "20:00"}, "sunday": {"open": "08:00", "close": "18:00"}}',
  150, FALSE),

('LifeAndGym Midtown', 'midtown', 'Convenient midtown location perfect for before or after work.',
  '456 Central Ave', 'New York', 'NY', 'US', '10019',
  40.7580, -73.9855,
  '+1 (555) 234-5678', 'midtown@lifeandgym.com',
  ARRAY['showers', 'lockers', 'wifi', 'towels'],
  ARRAY['treadmill', 'weights', 'machines'],
  '{"monday": {"open": "06:00", "close": "22:00"}, "tuesday": {"open": "06:00", "close": "22:00"}, "wednesday": {"open": "06:00", "close": "22:00"}, "thursday": {"open": "06:00", "close": "22:00"}, "friday": {"open": "06:00", "close": "21:00"}, "saturday": {"open": "08:00", "close": "18:00"}, "sunday": {"open": "08:00", "close": "16:00"}}',
  100, FALSE),

('LifeAndGym 24/7', '24-7', 'Our 24-hour location for those who work out on their own schedule.',
  '789 Night Owl Blvd', 'New York', 'NY', 'US', '10003',
  40.7295, -73.9965,
  '+1 (555) 345-6789', '247@lifeandgym.com',
  ARRAY['showers', 'lockers', 'wifi', 'security'],
  ARRAY['treadmill', 'weights', 'machines', 'cardio_equipment'],
  '{}',
  80, TRUE);

-- ============================================
-- SEED SAMPLE CLASSES
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
FROM gyms g WHERE g.slug = 'downtown';

INSERT INTO classes (gym_id, name, description, type, difficulty, duration_minutes, capacity, equipment_needed)
SELECT
  g.id,
  'HIIT Blast',
  'High-intensity interval training to burn calories and build endurance.',
  'hiit',
  'intermediate',
  45,
  25,
  ARRAY[]::TEXT[]
FROM gyms g WHERE g.slug = 'downtown';

INSERT INTO classes (gym_id, name, description, type, difficulty, duration_minutes, capacity, equipment_needed)
SELECT
  g.id,
  'Spin Class',
  'Indoor cycling class with high-energy music and motivated instructors.',
  'spin',
  'all_levels',
  45,
  30,
  ARRAY['spin_bike']
FROM gyms g WHERE g.slug = 'downtown';

INSERT INTO classes (gym_id, name, description, type, difficulty, duration_minutes, capacity, equipment_needed)
SELECT
  g.id,
  'Strength & Conditioning',
  'Build strength and improve conditioning with this comprehensive class.',
  'strength',
  'intermediate',
  60,
  15,
  ARRAY['barbell', 'dumbbells', 'kettlebell']
FROM gyms g WHERE g.slug = 'downtown';

INSERT INTO classes (gym_id, name, description, type, difficulty, duration_minutes, capacity, equipment_needed)
SELECT
  g.id,
  'Boxing Basics',
  'Learn boxing fundamentals while getting an intense cardio workout.',
  'boxing',
  'beginner',
  60,
  20,
  ARRAY['boxing_gloves', 'punching_bag']
FROM gyms g WHERE g.slug = 'downtown';
