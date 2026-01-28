# Apply Class Schedules Migration

## Option 1: Using Supabase SQL Editor (Recommended)

1. Go to your Supabase Dashboard: https://app.supabase.com
2. Select your LifeAndGym project
3. Click on "SQL Editor" in the left sidebar
4. Click "New Query"
5. Copy and paste the contents of `supabase/migrations/00005_update_class_schedules.sql`
6. Click "Run" button

This will:
- Delete all old class schedules
- Generate fresh schedules for the next 30 days
- Create multiple time slots per day for each class type

## Option 2: Using Supabase CLI (If you have it installed)

```bash
# From project root
supabase db push
```

## What This Migration Does

**Deletes:** All existing old class schedules

**Creates:** Fresh schedules for next 30 days with the following schedule:
- **Morning Yoga Flow**: 7:00 AM (every day except Sunday)
- **HIIT Blast**: 12:00 PM and 6:00 PM (every day except Sunday)
- **Spin Class**: 5:00 PM (every day except Sunday)
- **Strength & Conditioning**: 9:00 AM and 7:00 PM (every day except Sunday)
- **Boxing Basics**: 7:00 PM (every day except Sunday)

**For:** All gyms in the database (Downtown, Midtown, 24/7)

## Expected Result

After running this migration, your Classes screen should show:
- **Today** (Jan 27): ~25-30 classes across all gyms
- **Tomorrow** (Jan 28): ~25-30 classes
- **Next 30 days**: ~750-900 total class schedules

## Verification

After applying the migration:

1. **Check the database:**
   ```sql
   SELECT COUNT(*) FROM class_schedules WHERE status = 'scheduled';
   -- Should return ~750-900 schedules

   SELECT COUNT(*) FROM class_schedules
   WHERE DATE(scheduled_at) = CURRENT_DATE AND status = 'scheduled';
   -- Should return ~25-30 for today
   ```

2. **Check the app:**
   - Open the Classes screen
   - You should see classes for today
   - Switch between days to see upcoming schedules
   - Try filtering by class type (Yoga, HIIT, etc.)

## Troubleshooting

If classes still don't show:

1. **Check if migration ran successfully**
   ```sql
   SELECT COUNT(*) FROM class_schedules;
   ```
   Should return a large number (700+)

2. **Check API logs** in your Flutter app console:
   ```
   flutter: [INFO] Loaded X schedules
   ```
   X should be > 0

3. **Verify gym IDs match:**
   ```sql
   SELECT g.name, COUNT(cs.id) as schedule_count
   FROM gyms g
   LEFT JOIN class_schedules cs ON g.id = cs.gym_id
   GROUP BY g.name;
   ```
   Each gym should have ~250-300 schedules

## Maintenance

This migration creates 30 days of schedules. You'll need to:
- Run it again in ~25-30 days to keep schedules fresh
- Or set up a cron job/scheduled function to auto-generate schedules weekly

## Automating Schedule Generation (Optional)

Create a Supabase Edge Function that runs weekly:
```sql
-- Create a function to auto-generate schedules
CREATE OR REPLACE FUNCTION generate_future_schedules()
RETURNS void AS $$
-- Copy the DO block from the migration here
$$ LANGUAGE plpgsql;

-- Schedule it to run weekly (requires pg_cron extension)
SELECT cron.schedule('generate-schedules', '0 0 * * 0', 'SELECT generate_future_schedules()');
```
