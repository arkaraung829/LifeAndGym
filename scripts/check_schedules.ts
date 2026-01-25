/**
 * Script to check class_schedules table
 * Run with: npx tsx scripts/check_schedules.ts
 */

import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.SUPABASE_URL || 'https://gngjfqofeokqzdvfehyh.supabase.co';
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseServiceKey) {
  console.error('Missing SUPABASE_SERVICE_ROLE_KEY environment variable');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function checkSchedules() {
  console.log('\n=== CHECKING CLASS_SCHEDULES TABLE ===\n');

  // 1. Count total schedules
  const { count, error: countError } = await supabase
    .from('class_schedules')
    .select('*', { count: 'exact', head: true });

  if (countError) {
    console.error('Error counting schedules:', countError);
    return;
  }

  console.log(`Total schedules in database: ${count}`);

  // 2. Get all schedules with details
  const { data: schedules, error: fetchError } = await supabase
    .from('class_schedules')
    .select('id, gym_id, scheduled_at, status')
    .order('scheduled_at');

  if (fetchError) {
    console.error('Error fetching schedules:', fetchError);
    return;
  }

  console.log(`\nSchedules retrieved: ${schedules?.length || 0}\n`);

  if (schedules && schedules.length > 0) {
    // Group by gym_id
    const byGym = schedules.reduce((acc, s) => {
      const gymId = s.gym_id;
      if (!acc[gymId]) acc[gymId] = [];
      acc[gymId].push(s);
      return acc;
    }, {} as Record<string, typeof schedules>);

    console.log('=== SCHEDULES BY GYM ===');
    for (const [gymId, gymSchedules] of Object.entries(byGym)) {
      console.log(`\nGym ID: ${gymId}`);
      console.log(`Count: ${gymSchedules.length}`);

      const dates = gymSchedules.map(s => new Date(s.scheduled_at));
      const minDate = new Date(Math.min(...dates.map(d => d.getTime())));
      const maxDate = new Date(Math.max(...dates.map(d => d.getTime())));

      console.log(`Date range: ${minDate.toISOString()} to ${maxDate.toISOString()}`);

      // Check if dates are in past or future
      const now = new Date('2026-01-25T00:00:00Z');
      const futureCount = gymSchedules.filter(s => new Date(s.scheduled_at) >= now).length;
      const pastCount = gymSchedules.length - futureCount;

      console.log(`Future schedules: ${futureCount}`);
      console.log(`Past schedules: ${pastCount}`);
    }

    // 3. Check the specific gym from your query
    const targetGymId = '1ac65486-92c8-428a-9d95-ab5f4bc696f8';
    const targetDate = '2026-01-25';

    console.log(`\n=== CHECKING SPECIFIC QUERY ===`);
    console.log(`Gym ID: ${targetGymId}`);
    console.log(`Date: ${targetDate}\n`);

    const schedulesForGym = schedules.filter(s => s.gym_id === targetGymId);
    console.log(`Total schedules for this gym: ${schedulesForGym.length}`);

    if (schedulesForGym.length > 0) {
      console.log('\nFirst 5 schedules:');
      schedulesForGym.slice(0, 5).forEach(s => {
        console.log(`  - ${s.scheduled_at} (Status: ${s.status})`);
      });
    }

    // 4. Run the exact query from the API
    console.log('\n=== RUNNING API QUERY ===');

    const startOfDay = new Date(targetDate);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(targetDate);
    endOfDay.setHours(23, 59, 59, 999);

    console.log(`Query conditions:`);
    console.log(`  gym_id = ${targetGymId}`);
    console.log(`  status != 'cancelled'`);
    console.log(`  scheduled_at > ${new Date().toISOString()}`);
    console.log(`  scheduled_at >= ${startOfDay.toISOString()}`);
    console.log(`  scheduled_at <= ${endOfDay.toISOString()}`);

    const { data: apiResult, error: apiError } = await supabase
      .from('class_schedules')
      .select('*, gym_class:classes(*)')
      .neq('status', 'cancelled')
      .gt('scheduled_at', new Date().toISOString())
      .eq('gym_id', targetGymId)
      .gte('scheduled_at', startOfDay.toISOString())
      .lte('scheduled_at', endOfDay.toISOString())
      .order('scheduled_at');

    if (apiError) {
      console.error('\nAPI Query Error:', apiError);
    } else {
      console.log(`\nAPI Query Result: ${apiResult?.length || 0} schedules`);

      if (apiResult && apiResult.length > 0) {
        console.log('\nSchedules found:');
        apiResult.forEach(s => {
          console.log(`  - ${s.scheduled_at} (Status: ${s.status})`);
        });
      }
    }
  }

  console.log('\n=== DIAGNOSIS ===');
  console.log('Checking for potential issues...\n');

  // Check gyms
  const { data: gyms } = await supabase.from('gyms').select('id, name, slug');
  if (gyms) {
    console.log('Available gyms:');
    gyms.forEach(g => {
      console.log(`  - ${g.name} (${g.slug}): ${g.id}`);
    });
  }
}

checkSchedules()
  .then(() => {
    console.log('\n✓ Check complete');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n✗ Error:', error);
    process.exit(1);
  });
