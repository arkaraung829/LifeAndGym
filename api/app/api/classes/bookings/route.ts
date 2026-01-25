import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseBody } from '@/lib/utils/validation';
import { ConflictError, DatabaseError, NotFoundError } from '@/lib/utils/errors';
import type { ClassSchedule } from '@/lib/supabase/types';

const bookClassSchema = z.object({
  classScheduleId: z.string().uuid(),
});

export async function GET(request: NextRequest) {
  try {
    const { user } = await verifyAuth(request);

    const { data: bookings, error } = await supabaseAdmin
      .from(Tables.bookings)
      .select('*, class_schedules(*, classes(*))')
      .eq('user_id', user.id)
      .order('created_at', { ascending: false });

    if (error) {
      throw new DatabaseError('Failed to fetch bookings');
    }

    return successResponse({ bookings }, request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to fetch bookings'), request);
  }
}

export async function POST(request: NextRequest) {
  try {
    const { user } = await verifyAuth(request);
    const body = await parseBody(request, bookClassSchema);

    // Check if already booked
    const { data: existing } = await supabaseAdmin
      .from(Tables.bookings)
      .select('*')
      .eq('user_id', user.id)
      .eq('class_schedule_id', body.classScheduleId)
      .neq('status', 'cancelled')
      .maybeSingle();

    if (existing) {
      throw new ConflictError('Already booked this class');
    }

    // Get schedule to check availability
    const { data: schedule, error: scheduleError } = await supabaseAdmin
      .from(Tables.classSchedules)
      .select('*')
      .eq('id', body.classScheduleId)
      .single();

    if (scheduleError || !schedule) {
      throw new NotFoundError('Class schedule');
    }

    const typedSchedule = schedule as ClassSchedule;

    // Determine booking status (confirmed or waitlist)
    const isFull = typedSchedule.spots_remaining <= 0;
    const status = isFull ? 'waitlist' : 'confirmed';

    const { data: booking, error } = await supabaseAdmin
      .from(Tables.bookings)
      .insert({
        user_id: user.id,
        class_schedule_id: body.classScheduleId,
        status,
        booked_at: new Date().toISOString(),
      })
      .select('*, class_schedules(*, classes(*))')
      .single();

    if (error) {
      throw new DatabaseError('Failed to book class');
    }

    // Update spots remaining if confirmed
    if (status === 'confirmed') {
      await supabaseAdmin
        .from(Tables.classSchedules)
        .update({ spots_remaining: typedSchedule.spots_remaining - 1 })
        .eq('id', body.classScheduleId);
    }

    return successResponse(
      {
        booking,
        message: isFull ? 'Added to waitlist' : 'Class booked successfully',
      },
      request,
      { status: 201 }
    );
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to book class'), request);
  }
}
