import { NextRequest } from 'next/server';
import { supabaseAdmin, Tables } from '@/lib/supabase/client';
import { verifyAuth } from '@/lib/middleware/auth';
import { successResponse, errorResponse } from '@/lib/utils/response';
import { NotFoundError, DatabaseError, ForbiddenError } from '@/lib/utils/errors';
import type { Booking, ClassSchedule } from '@/lib/supabase/types';

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { user } = await verifyAuth(request);
    const { id: bookingId } = await params;

    // Get booking
    const { data: booking, error: bookingError } = await supabaseAdmin
      .from(Tables.bookings)
      .select('*, class_schedules(*)')
      .eq('id', bookingId)
      .single();

    if (bookingError || !booking) {
      throw new NotFoundError('Booking');
    }

    const typedBooking = booking as Booking & { class_schedules: ClassSchedule };

    if (typedBooking.user_id !== user.id) {
      throw new ForbiddenError('You do not own this booking');
    }

    if (typedBooking.status === 'cancelled') {
      throw new ForbiddenError('Booking is already cancelled');
    }

    // Update booking status
    const { error } = await supabaseAdmin
      .from(Tables.bookings)
      .update({
        status: 'cancelled',
        cancelled_at: new Date().toISOString(),
      })
      .eq('id', bookingId);

    if (error) {
      throw new DatabaseError('Failed to cancel booking');
    }

    // Update spots remaining if it was confirmed
    if (typedBooking.status === 'confirmed' && typedBooking.class_schedules) {
      await supabaseAdmin
        .from(Tables.classSchedules)
        .update({
          spots_remaining: typedBooking.class_schedules.spots_remaining + 1,
        })
        .eq('id', typedBooking.class_schedule_id);
    }

    return successResponse(
      { message: 'Booking cancelled successfully' },
      request
    );
  } catch (error) {
    return errorResponse(error instanceof Error ? error : new Error('Failed to cancel booking'), request);
  }
}
