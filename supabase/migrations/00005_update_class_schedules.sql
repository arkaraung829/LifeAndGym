-- ============================================
-- LifeAndGym Database Schema
-- Migration 00005: Update Class Schedules with Fresh Dates
-- ============================================

-- Delete old schedules
DELETE FROM class_schedules;

-- ============================================
-- CREATE FRESH SCHEDULES FOR ALL GYMS (30 days forward)
-- ============================================

-- Helper function to generate schedules
DO $$
DECLARE
  gym_record RECORD;
  class_record RECORD;
  schedule_date DATE;
  day_counter INTEGER;
  time_slot TEXT;
  time_slots TEXT[] := ARRAY['07:00:00', '09:00:00', '12:00:00', '17:00:00', '18:00:00', '19:00:00'];
BEGIN
  -- Loop through each gym
  FOR gym_record IN SELECT id, name FROM gyms LOOP

    -- Loop through each class for this gym
    FOR class_record IN SELECT id, name, duration_minutes, capacity
                        FROM classes WHERE gym_id = gym_record.id LOOP

      -- Generate 30 days of schedules
      FOR day_counter IN 0..29 LOOP
        schedule_date := CURRENT_DATE + day_counter;

        -- Skip Sundays (optional, remove if you want 7-day schedules)
        IF EXTRACT(DOW FROM schedule_date) != 0 THEN

          -- Create 1-2 random time slots per day for each class
          -- For Morning Yoga: 7AM and 9AM
          IF class_record.name = 'Morning Yoga Flow' THEN
            INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
            VALUES (
              class_record.id,
              gym_record.id,
              (schedule_date || ' 07:00:00')::TIMESTAMP,
              class_record.duration_minutes,
              class_record.capacity,
              class_record.capacity,
              'scheduled'
            );

          -- For HIIT: 12PM and 6PM
          ELSIF class_record.name = 'HIIT Blast' THEN
            INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
            VALUES (
              class_record.id,
              gym_record.id,
              (schedule_date || ' 12:00:00')::TIMESTAMP,
              class_record.duration_minutes,
              class_record.capacity,
              class_record.capacity,
              'scheduled'
            );

            INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
            VALUES (
              class_record.id,
              gym_record.id,
              (schedule_date || ' 18:00:00')::TIMESTAMP,
              class_record.duration_minutes,
              class_record.capacity,
              class_record.capacity,
              'scheduled'
            );

          -- For Spin: 5PM and 6PM
          ELSIF class_record.name = 'Spin Class' THEN
            INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
            VALUES (
              class_record.id,
              gym_record.id,
              (schedule_date || ' 17:00:00')::TIMESTAMP,
              class_record.duration_minutes,
              class_record.capacity,
              class_record.capacity,
              'scheduled'
            );

          -- For Strength & Conditioning: 9AM and 7PM
          ELSIF class_record.name = 'Strength & Conditioning' THEN
            INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
            VALUES (
              class_record.id,
              gym_record.id,
              (schedule_date || ' 09:00:00')::TIMESTAMP,
              class_record.duration_minutes,
              class_record.capacity,
              class_record.capacity,
              'scheduled'
            );

            INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
            VALUES (
              class_record.id,
              gym_record.id,
              (schedule_date || ' 19:00:00')::TIMESTAMP,
              class_record.duration_minutes,
              class_record.capacity,
              class_record.capacity,
              'scheduled'
            );

          -- For Boxing: 7PM
          ELSIF class_record.name = 'Boxing Basics' THEN
            INSERT INTO class_schedules (class_id, gym_id, scheduled_at, duration_minutes, capacity, spots_remaining, status)
            VALUES (
              class_record.id,
              gym_record.id,
              (schedule_date || ' 19:00:00')::TIMESTAMP,
              class_record.duration_minutes,
              class_record.capacity,
              class_record.capacity,
              'scheduled'
            );
          END IF;

        END IF;
      END LOOP;
    END LOOP;
  END LOOP;
END $$;
