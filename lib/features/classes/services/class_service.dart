import '../../../core/config/supabase_config.dart';
import '../../../core/exceptions/exceptions.dart';
import '../../../core/services/base_service.dart';
import '../../../core/services/logger_service.dart';
import '../models/booking_model.dart';
import '../models/class_model.dart';
import '../models/class_schedule_model.dart';

/// Service for class and booking operations.
class ClassService extends BaseService {
  /// Get all classes for a gym.
  Future<List<ClassModel>> getClassesByGym(String gymId) async {
    try {
      AppLogger.info('Fetching classes for gym: $gymId');

      final response = await supabase
          .from(Tables.classes)
          .select()
          .eq('gym_id', gymId)
          .eq('is_active', true)
          .order('name');

      final classes = (response as List)
          .map((json) => ClassModel.fromJson(json))
          .toList();

      AppLogger.info('Fetched ${classes.length} classes');
      return classes;
    } catch (e) {
      AppLogger.error('Failed to fetch classes', error: e);
      throw DatabaseException(
        'Failed to load classes',
        
        originalError: e,
      );
    }
  }

  /// Get class schedules for a date range.
  Future<List<ClassScheduleModel>> getSchedules({
    required String gymId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      AppLogger.info('Fetching schedules from $startDate to $endDate');

      final response = await supabase
          .from(Tables.classSchedules)
          .select('*, classes(*)')
          .eq('gym_id', gymId)
          .gte('scheduled_at', startDate.toIso8601String())
          .lte('scheduled_at', endDate.toIso8601String())
          .order('scheduled_at');

      final schedules = (response as List)
          .map((json) => ClassScheduleModel.fromJson(json))
          .toList();

      AppLogger.info('Fetched ${schedules.length} schedules');
      return schedules;
    } catch (e) {
      AppLogger.error('Failed to fetch schedules', error: e);
      throw DatabaseException(
        'Failed to load class schedules',
        
        originalError: e,
      );
    }
  }

  /// Get user's bookings.
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      AppLogger.info('Fetching bookings for user: $userId');

      final response = await supabase
          .from(Tables.bookings)
          .select('*, class_schedules(*, classes(*))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final bookings = (response as List)
          .map((json) => BookingModel.fromJson(json))
          .toList();

      AppLogger.info('Fetched ${bookings.length} bookings');
      return bookings;
    } catch (e) {
      AppLogger.error('Failed to fetch bookings', error: e);
      throw DatabaseException(
        'Failed to load bookings',
        
        originalError: e,
      );
    }
  }

  /// Book a class.
  Future<BookingModel> bookClass({
    required String userId,
    required String classScheduleId,
  }) async {
    try {
      AppLogger.info('Booking class: $classScheduleId for user: $userId');

      // Check if already booked
      final existing = await supabase
          .from(Tables.bookings)
          .select()
          .eq('user_id', userId)
          .eq('class_schedule_id', classScheduleId)
          .maybeSingle();

      if (existing != null) {
        throw ValidationException(
          'Already booked this class',
          code: 'ALREADY_BOOKED',
        );
      }

      // Get schedule to check availability
      final scheduleData = await supabase
          .from(Tables.classSchedules)
          .select()
          .eq('id', classScheduleId)
          .single();

      final schedule = ClassScheduleModel.fromJson(scheduleData);

      // Determine booking status
      final status = schedule.isFull ? BookingStatus.waitlist : BookingStatus.confirmed;

      final data = {
        'user_id': userId,
        'class_schedule_id': classScheduleId,
        'status': status.value,
        'booked_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from(Tables.bookings)
          .insert(data)
          .select('*, class_schedules(*, classes(*))')
          .single();

      // Update spots remaining if confirmed
      if (status == BookingStatus.confirmed) {
        await supabase
            .from(Tables.classSchedules)
            .update({'spots_remaining': schedule.spotsRemaining - 1})
            .eq('id', classScheduleId);
      }

      final booking = BookingModel.fromJson(response);
      AppLogger.info('Booked class successfully');
      return booking;
    } catch (e) {
      if (e is AppException) rethrow;
      AppLogger.error('Failed to book class', error: e);
      throw DatabaseException(
        'Failed to book class',
        
        originalError: e,
      );
    }
  }

  /// Cancel a booking.
  Future<void> cancelBooking(String bookingId) async {
    try {
      AppLogger.info('Cancelling booking: $bookingId');

      final bookingData = await supabase
          .from(Tables.bookings)
          .select('*, class_schedules(*)')
          .eq('id', bookingId)
          .single();

      final booking = BookingModel.fromJson(bookingData);

      await supabase
          .from(Tables.bookings)
          .update({
            'status': BookingStatus.cancelled.value,
            'cancelled_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);

      // Update spots remaining if it was confirmed
      if (booking.status == BookingStatus.confirmed && booking.schedule != null) {
        await supabase
            .from(Tables.classSchedules)
            .update({
              'spots_remaining': booking.schedule!.spotsRemaining + 1,
            })
            .eq('id', booking.classScheduleId);
      }

      AppLogger.info('Cancelled booking successfully');
    } catch (e) {
      AppLogger.error('Failed to cancel booking', error: e);
      throw DatabaseException(
        'Failed to cancel booking',
        
        originalError: e,
      );
    }
  }
}
