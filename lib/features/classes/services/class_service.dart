import '../../../core/config/api_config.dart';
import '../../../core/exceptions/exceptions.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/logger_service.dart';
import '../models/booking_model.dart';
import '../models/class_model.dart';
import '../models/class_schedule_model.dart';

/// Service for class and booking operations via API.
class ClassService {
  final ApiClient _apiClient;

  ClassService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get all classes, optionally filtered by gym.
  Future<List<ClassModel>> getClassesByGym(String? gymId) async {
    try {
      AppLogger.info('Fetching classes${gymId != null ? " for gym: $gymId" : ""}');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.classes,
        queryParams: gymId != null ? {'gymId': gymId} : null,
      );

      final classesList = response.data['classes'] as List;
      final classes =
          classesList.map((json) => ClassModel.fromJson(json)).toList();

      AppLogger.info('Fetched ${classes.length} classes');
      return classes;
    } catch (e) {
      AppLogger.error('Failed to fetch classes', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException(
        'Failed to load classes',
        originalError: e,
      );
    }
  }

  /// Get class schedules for a date range.
  Future<List<ClassScheduleModel>> getSchedules({
    String? gymId,
    String? classId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      AppLogger.info('Fetching schedules');

      final queryParams = <String, dynamic>{};
      if (gymId != null) queryParams['gymId'] = gymId;
      if (classId != null) queryParams['classId'] = classId;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String().split('T').first;
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String().split('T').first;

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.classSchedules,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      final schedulesList = response.data['schedules'] as List;
      final schedules =
          schedulesList.map((json) => ClassScheduleModel.fromJson(json)).toList();

      AppLogger.info('Fetched ${schedules.length} schedules');
      return schedules;
    } catch (e) {
      AppLogger.error('Failed to fetch schedules', error: e);
      if (e is AppException) rethrow;
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

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.bookings,
      );

      final bookingsList = response.data['bookings'] as List;
      final bookings =
          bookingsList.map((json) => BookingModel.fromJson(json)).toList();

      AppLogger.info('Fetched ${bookings.length} bookings');
      return bookings;
    } catch (e) {
      AppLogger.error('Failed to fetch bookings', error: e);
      if (e is AppException) rethrow;
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

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.bookings,
        body: {'scheduleId': classScheduleId},
      );

      final booking = BookingModel.fromJson(response.data['booking']);
      AppLogger.info('Booked class successfully');
      return booking;
    } on ApiException catch (e) {
      if (e.code == 'VALIDATION_ERROR') {
        throw ValidationException(e.message, code: e.code);
      }
      rethrow;
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

      await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.cancelBooking(bookingId),
      );

      AppLogger.info('Cancelled booking successfully');
    } catch (e) {
      AppLogger.error('Failed to cancel booking', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException(
        'Failed to cancel booking',
        originalError: e,
      );
    }
  }
}
