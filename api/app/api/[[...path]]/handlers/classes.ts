import { NextRequest } from 'next/server';
import { z } from 'zod';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { parseBody, parseQuery } from '@/lib/utils/validation';
import { NotFoundError, DatabaseError, ValidationError } from '@/lib/utils/errors';

const bookingSchema = z.object({
  scheduleId: z.string().uuid('Invalid schedule ID'),
});

const classesQuerySchema = z.object({
  gymId: z.string().uuid().optional(),
  category: z.string().optional(),
});

const schedulesQuerySchema = z.object({
  gymId: z.string().uuid().optional(),
  classId: z.string().uuid().optional(),
  date: z.string().optional(),
  startDate: z.string().optional(),
  endDate: z.string().optional(),
});

function getRoute(subpath: string[]): string {
  return subpath.join('/');
}

export async function handleGet(request: NextRequest, subpath: string[]) {
  try {
    const route = getRoute(subpath);

    if (route === '' || route === 'list') {
      return await handleListClasses(request);
    }
    if (route === 'schedules') {
      return await handleListSchedules(request);
    }
    if (route === 'bookings') {
      return await handleListBookings(request);
    }

    return errorResponse(new NotFoundError('Endpoint'), request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Handler failed'), request);
  }
}

export async function handlePost(request: NextRequest, subpath: string[]) {
  try {
    const route = getRoute(subpath);

    if (route === 'bookings') {
      return await handleCreateBooking(request);
    }
    if (subpath.length === 3 && subpath[0] === 'bookings' && subpath[2] === 'cancel') {
      return await handleCancelBooking(request, subpath[1]);
    }

    return errorResponse(new NotFoundError('Endpoint'), request);
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Handler failed'), request);
  }
}

async function handleListClasses(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const query = parseQuery(searchParams, classesQuerySchema);

  let dbQuery = supabaseAdmin
    .from(Tables.classes)
    .select('*')
    .eq('is_active', true);

  if (query.gymId) {
    dbQuery = dbQuery.eq('gym_id', query.gymId);
  }
  if (query.category) {
    dbQuery = dbQuery.eq('category', query.category);
  }

  const { data: classes, error } = await dbQuery.order('name');

  if (error) throw new DatabaseError('Failed to fetch classes');
  return successResponse({ classes }, request);
}

async function handleListSchedules(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const query = parseQuery(searchParams, schedulesQuerySchema);

  let dbQuery = supabaseAdmin
    .from(Tables.classSchedules)
    .select(`*, classes:${Tables.classes}(*)`)
    .neq('status', 'cancelled')
    .gt('scheduled_at', new Date().toISOString());

  if (query.gymId) {
    dbQuery = dbQuery.eq('gym_id', query.gymId);
  }
  if (query.classId) {
    dbQuery = dbQuery.eq('class_id', query.classId);
  }
  if (query.date) {
    const startOfDay = new Date(query.date);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(query.date);
    endOfDay.setHours(23, 59, 59, 999);
    dbQuery = dbQuery.gte('scheduled_at', startOfDay.toISOString()).lte('scheduled_at', endOfDay.toISOString());
  } else if (query.startDate || query.endDate) {
    if (query.startDate) {
      const start = new Date(query.startDate);
      start.setHours(0, 0, 0, 0);
      dbQuery = dbQuery.gte('scheduled_at', start.toISOString());
    }
    if (query.endDate) {
      const end = new Date(query.endDate);
      end.setHours(23, 59, 59, 999);
      dbQuery = dbQuery.lte('scheduled_at', end.toISOString());
    }
  }

  const { data: schedules, error } = await dbQuery.order('scheduled_at');

  if (error) throw new DatabaseError('Failed to fetch schedules');
  return successResponse({ schedules }, request);
}

async function handleListBookings(request: NextRequest) {
  const { user } = await verifyAuth(request);
  const searchParams = request.nextUrl.searchParams;
  const status = searchParams.get('status');
  const upcoming = searchParams.get('upcoming') === 'true';

  let dbQuery = supabaseAdmin
    .from(Tables.bookings)
    .select(`*, schedule:${Tables.classSchedules}(*, classes:${Tables.classes}(*))`)
    .eq('user_id', user.id);

  if (status) {
    dbQuery = dbQuery.eq('status', status);
  }
  if (upcoming) {
    dbQuery = dbQuery.in('status', ['confirmed', 'waitlist']);
  }

  const { data: bookings, error } = await dbQuery.order('booked_at', { ascending: false });

  if (error) throw new DatabaseError('Failed to fetch bookings');
  return successResponse({ bookings }, request);
}

async function handleCreateBooking(request: NextRequest) {
  const { user } = await verifyAuth(request);
  const body = await parseBody(request, bookingSchema);

  const { data: schedule, error: scheduleError } = await supabaseAdmin
    .from(Tables.classSchedules)
    .select(`*, classes:${Tables.classes}(*)`)
    .eq('id', body.scheduleId)
    .single();

  if (scheduleError || !schedule) {
    throw new NotFoundError('Class schedule');
  }

  if (schedule.is_cancelled) {
    throw new ValidationError('This class has been cancelled');
  }

  if (new Date(schedule.scheduled_at) < new Date()) {
    throw new ValidationError('This class has already started');
  }

  const { data: existingBooking } = await supabaseAdmin
    .from(Tables.bookings)
    .select('*')
    .eq('user_id', user.id)
    .eq('class_schedule_id', body.scheduleId)
    .in('status', ['confirmed', 'waitlist'])
    .single();

  if (existingBooking) {
    throw new ValidationError('You already have a booking for this class');
  }

  const status = schedule.spots_remaining > 0 ? 'confirmed' : 'waitlist';

  const { data: booking, error } = await supabaseAdmin
    .from(Tables.bookings)
    .insert({
      user_id: user.id,
      class_schedule_id: body.scheduleId,
      status,
      booked_at: new Date().toISOString(),
    })
    .select(`*, schedule:${Tables.classSchedules}(*, classes:${Tables.classes}(*))`)
    .single();

  if (error) throw new DatabaseError('Failed to create booking');

  if (status === 'confirmed') {
    await supabaseAdmin
      .from(Tables.classSchedules)
      .update({ spots_remaining: schedule.spots_remaining - 1 })
      .eq('id', body.scheduleId);
  }

  return successResponse({ booking }, request, { status: 201 });
}

async function handleCancelBooking(request: NextRequest, bookingId: string) {
  const { user } = await verifyAuth(request);

  const { data: booking, error: findError } = await supabaseAdmin
    .from(Tables.bookings)
    .select(`*, schedule:${Tables.classSchedules}(*)`)
    .eq('id', bookingId)
    .eq('user_id', user.id)
    .single();

  if (findError || !booking) {
    throw new NotFoundError('Booking');
  }

  if (booking.status === 'cancelled') {
    throw new ValidationError('Booking is already cancelled');
  }

  if (booking.status === 'attended') {
    throw new ValidationError('Cannot cancel a completed booking');
  }

  const wasConfirmed = booking.status === 'confirmed';

  // Delete the booking instead of updating to avoid unique constraint issues on re-booking
  const { error } = await supabaseAdmin
    .from(Tables.bookings)
    .delete()
    .eq('id', bookingId);

  if (error) throw new DatabaseError('Failed to cancel booking');

  if (wasConfirmed && booking.schedule) {
    await supabaseAdmin
      .from(Tables.classSchedules)
      .update({ spots_remaining: booking.schedule.spots_remaining + 1 })
      .eq('id', booking.class_schedule_id);

    const { data: waitlistBooking } = await supabaseAdmin
      .from(Tables.bookings)
      .select('*')
      .eq('class_schedule_id', booking.class_schedule_id)
      .eq('status', 'waitlist')
      .order('booked_at')
      .limit(1)
      .single();

    if (waitlistBooking) {
      await supabaseAdmin
        .from(Tables.bookings)
        .update({ status: 'confirmed' })
        .eq('id', waitlistBooking.id);
    }
  }

  return successResponse({ message: 'Booking cancelled successfully' }, request);
}
