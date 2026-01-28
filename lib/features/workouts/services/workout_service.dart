import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/api_config.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/exceptions/exceptions.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/logger_service.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';
import '../models/workout_session_model.dart';

/// Service for managing exercises, workouts, and workout sessions.
/// Uses API for most operations, Supabase directly for operations without API endpoints.
class WorkoutService {
  final ApiClient _apiClient;
  final SupabaseClient _supabase;

  WorkoutService({ApiClient? apiClient, SupabaseClient? supabase})
      : _apiClient = apiClient ?? ApiClient(),
        _supabase = supabase ?? SupabaseConfig.client;

  // ==================== EXERCISES (API) ====================

  /// Get all exercises with optional filters.
  Future<List<ExerciseModel>> getAllExercises({
    String? query,
    String? muscleGroup,
    String? exerciseType,
    String? difficulty,
  }) async {
    try {
      AppLogger.info('Fetching exercises');

      final queryParams = <String, dynamic>{};
      if (query != null) queryParams['q'] = query;
      if (muscleGroup != null) queryParams['muscleGroup'] = muscleGroup;
      if (exerciseType != null) queryParams['exerciseType'] = exerciseType;
      if (difficulty != null) queryParams['difficulty'] = difficulty;

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.exercises,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      final exercisesList = response.data['exercises'] as List;
      final exercises =
          exercisesList.map((json) => ExerciseModel.fromJson(json)).toList();

      AppLogger.info('Fetched ${exercises.length} exercises');
      return exercises;
    } catch (e) {
      AppLogger.error('Failed to fetch exercises', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to fetch exercises', originalError: e);
    }
  }

  /// Get exercises by muscle group.
  Future<List<ExerciseModel>> getExercisesByMuscleGroup(String muscleGroup) async {
    return getAllExercises(muscleGroup: muscleGroup);
  }

  /// Get exercises by type.
  Future<List<ExerciseModel>> getExercisesByType(String exerciseType) async {
    return getAllExercises(exerciseType: exerciseType);
  }

  /// Search exercises by name.
  Future<List<ExerciseModel>> searchExercises(String query) async {
    return getAllExercises(query: query);
  }

  // ==================== WORKOUTS (API + Supabase) ====================

  /// Get user's workouts.
  Future<List<WorkoutModel>> getUserWorkouts(String userId) async {
    try {
      AppLogger.info('Fetching user workouts');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.workouts,
      );

      final workoutsList = response.data['workouts'] as List;
      final workouts =
          workoutsList.map((json) => WorkoutModel.fromJson(json)).toList();

      AppLogger.info('Fetched ${workouts.length} workouts');
      return workouts;
    } catch (e) {
      AppLogger.error('Failed to fetch user workouts', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to fetch user workouts', originalError: e);
    }
  }

  /// Get public workout templates.
  Future<List<WorkoutModel>> getPublicWorkouts() async {
    try {
      AppLogger.info('Fetching public workouts');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.publicWorkouts,
      );

      final workoutsList = response.data['workouts'] as List;
      final workouts =
          workoutsList.map((json) => WorkoutModel.fromJson(json)).toList();

      AppLogger.info('Fetched ${workouts.length} public workouts');
      return workouts;
    } catch (e) {
      AppLogger.error('Failed to fetch public workouts', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to fetch public workouts', originalError: e);
    }
  }

  /// Get workout by ID (Supabase direct).
  Future<WorkoutModel?> getWorkoutById(String workoutId) async {
    try {
      AppLogger.info('Fetching workout: $workoutId');

      final response = await _supabase
          .from(Tables.workouts)
          .select()
          .eq('id', workoutId)
          .maybeSingle();

      if (response == null) return null;

      return WorkoutModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Failed to fetch workout', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to fetch workout', originalError: e);
    }
  }

  /// Get exercises for a workout (Supabase direct).
  Future<List<WorkoutExerciseModel>> getWorkoutExercises(String workoutId) async {
    try {
      AppLogger.info('Fetching exercises for workout: $workoutId');

      final response = await _supabase
          .from('workout_exercises')
          .select('*, exercise:exercises(*)')
          .eq('workout_id', workoutId)
          .order('order_index');

      final exercises = (response as List)
          .map((json) => WorkoutExerciseModel.fromJson(json))
          .toList();

      AppLogger.info('Fetched ${exercises.length} workout exercises');
      return exercises;
    } catch (e) {
      AppLogger.error('Failed to fetch workout exercises', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to fetch workout exercises', originalError: e);
    }
  }

  /// Create a new workout.
  Future<WorkoutModel> createWorkout({
    required String userId,
    required String name,
    String? description,
    String? category,
    required int estimatedDuration,
    required String difficulty,
    List<String>? targetMuscles,
    bool isTemplate = false,
    bool isPublic = false,
    List<Map<String, dynamic>>? exercises,
  }) async {
    try {
      AppLogger.info('Creating workout: $name');

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.workouts,
        body: {
          'name': name,
          'description': description,
          'category': category,
          'estimatedDuration': estimatedDuration,
          'difficulty': difficulty,
          'targetMuscles': targetMuscles,
          'isTemplate': isTemplate,
          'isPublic': isPublic,
          'exercises': exercises,
        },
      );

      final workout = WorkoutModel.fromJson(response.data['workout']);
      AppLogger.info('Created workout: ${workout.id}');
      return workout;
    } catch (e) {
      AppLogger.error('Failed to create workout', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to create workout', originalError: e);
    }
  }

  /// Add exercise to workout (Supabase direct).
  Future<WorkoutExerciseModel> addExerciseToWorkout({
    required String workoutId,
    required String exerciseId,
    required int orderIndex,
    int sets = 3,
    int? reps,
    int? duration,
    double? weight,
    int? restSeconds,
    String? notes,
  }) async {
    try {
      AppLogger.info('Adding exercise to workout: $workoutId');

      final response = await _supabase.from('workout_exercises').insert({
        'workout_id': workoutId,
        'exercise_id': exerciseId,
        'order_index': orderIndex,
        'sets': sets,
        'reps': reps,
        'duration_seconds': duration,
        'weight_kg': weight,
        'rest_seconds': restSeconds,
        'notes': notes,
      }).select('*, exercise:exercises(*)').single();

      AppLogger.info('Added exercise to workout');
      return WorkoutExerciseModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Failed to add exercise to workout', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to add exercise to workout', originalError: e);
    }
  }

  /// Update workout exercise (Supabase direct).
  Future<WorkoutExerciseModel> updateWorkoutExercise({
    required String workoutExerciseId,
    int? sets,
    int? reps,
    int? duration,
    double? weight,
    int? restSeconds,
    String? notes,
  }) async {
    try {
      AppLogger.info('Updating workout exercise: $workoutExerciseId');

      final updates = <String, dynamic>{};
      if (sets != null) updates['sets'] = sets;
      if (reps != null) updates['reps'] = reps;
      if (duration != null) updates['duration_seconds'] = duration;
      if (weight != null) updates['weight_kg'] = weight;
      if (restSeconds != null) updates['rest_seconds'] = restSeconds;
      if (notes != null) updates['notes'] = notes;

      final response = await _supabase
          .from('workout_exercises')
          .update(updates)
          .eq('id', workoutExerciseId)
          .select('*, exercise:exercises(*)')
          .single();

      AppLogger.info('Updated workout exercise');
      return WorkoutExerciseModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Failed to update workout exercise', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to update workout exercise', originalError: e);
    }
  }

  /// Remove exercise from workout (Supabase direct).
  Future<void> removeExerciseFromWorkout(String workoutExerciseId) async {
    try {
      AppLogger.info('Removing exercise from workout: $workoutExerciseId');

      await _supabase
          .from('workout_exercises')
          .delete()
          .eq('id', workoutExerciseId);

      AppLogger.info('Removed exercise from workout');
    } catch (e) {
      AppLogger.error('Failed to remove exercise from workout', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to remove exercise from workout', originalError: e);
    }
  }

  /// Delete workout (Supabase direct).
  Future<void> deleteWorkout(String workoutId) async {
    try {
      AppLogger.info('Deleting workout: $workoutId');

      await _supabase.from(Tables.workouts).delete().eq('id', workoutId);

      AppLogger.info('Deleted workout');
    } catch (e) {
      AppLogger.error('Failed to delete workout', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to delete workout', originalError: e);
    }
  }

  // ==================== WORKOUT SESSIONS (API + Supabase) ====================

  /// Start a new workout session.
  Future<WorkoutSessionModel> startWorkoutSession({
    required String userId,
    String? workoutId,
    String? notes,
  }) async {
    try {
      AppLogger.info('Starting workout session');

      final body = <String, dynamic>{};
      if (workoutId != null) body['workoutId'] = workoutId;
      if (notes != null) body['notes'] = notes;

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.workoutSessions,
        body: body.isNotEmpty ? body : {},
      );

      final session = WorkoutSessionModel.fromJson(response.data['session']);
      AppLogger.info('Started session: ${session.id}');
      return session;
    } on ApiException catch (e) {
      if (e.code == 'VALIDATION_ERROR') {
        throw ValidationException(e.message, code: e.code);
      }
      rethrow;
    } catch (e) {
      AppLogger.error('Failed to start workout session', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to start workout session', originalError: e);
    }
  }

  /// Get active workout session for user.
  Future<WorkoutSessionModel?> getActiveWorkoutSession(String userId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.activeWorkoutSession,
      );

      final sessionData = response.data['session'];
      if (sessionData == null) return null;

      return WorkoutSessionModel.fromJson(sessionData);
    } catch (e) {
      AppLogger.error('Failed to fetch active workout session', error: e);
      return null;
    }
  }

  /// Get logs for a session (Supabase direct).
  Future<List<WorkoutLogModel>> getSessionLogs(String sessionId) async {
    try {
      AppLogger.info('Fetching logs for session: $sessionId');

      final response = await _supabase
          .from(Tables.workoutLogs)
          .select('*, exercise:exercises(*)')
          .eq('session_id', sessionId)
          .order('created_at');

      final logs = (response as List)
          .map((json) => WorkoutLogModel.fromJson(json))
          .toList();

      AppLogger.info('Fetched ${logs.length} session logs');
      return logs;
    } catch (e) {
      AppLogger.error('Failed to fetch session logs', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to fetch session logs', originalError: e);
    }
  }

  /// Log a set during workout session.
  Future<WorkoutLogModel> logWorkoutSet({
    required String sessionId,
    required String exerciseId,
    required int setNumber,
    int? reps,
    double? weight,
    int? duration,
    String? notes,
  }) async {
    try {
      AppLogger.info('Logging set for session: $sessionId');

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.workoutSessionLog(sessionId),
        body: {
          'exerciseId': exerciseId,
          'setNumber': setNumber,
          'reps': reps,
          'weight': weight,
          'duration': duration,
          'notes': notes,
        },
      );

      final log = WorkoutLogModel.fromJson(response.data['log']);
      AppLogger.info('Logged set successfully');
      return log;
    } catch (e) {
      AppLogger.error('Failed to log workout set', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to log workout set', originalError: e);
    }
  }

  /// Complete workout session.
  Future<WorkoutSessionModel> completeWorkoutSession({
    required String sessionId,
    String? notes,
  }) async {
    try {
      AppLogger.info('Completing workout session: $sessionId');

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.workoutSessionComplete(sessionId),
      );

      final session = WorkoutSessionModel.fromJson(response.data['session']);
      AppLogger.info('Completed session successfully');
      return session;
    } catch (e) {
      AppLogger.error('Failed to complete workout session', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to complete workout session', originalError: e);
    }
  }

  /// Cancel workout session via API.
  Future<void> cancelWorkoutSession(String sessionId) async {
    try {
      AppLogger.info('Cancelling workout session: $sessionId');

      await _apiClient.post(
        'workouts/sessions/$sessionId/cancel',
      );

      AppLogger.info('Cancelled workout session');
    } catch (e) {
      AppLogger.error('Failed to cancel workout session', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to cancel workout session', originalError: e);
    }
  }

  /// Get workout session history for user.
  Future<List<WorkoutSessionModel>> getWorkoutHistory({
    required String userId,
    int? limit,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      AppLogger.info('Fetching workout history');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.workoutHistory,
        queryParams: {
          'limit': limit ?? 20,
          'offset': offset,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        },
      );

      final sessionsList = response.data['sessions'] as List;
      final sessions =
          sessionsList.map((json) => WorkoutSessionModel.fromJson(json)).toList();

      AppLogger.info('Fetched ${sessions.length} sessions');
      return sessions;
    } catch (e) {
      AppLogger.error('Failed to fetch workout history', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to fetch workout history', originalError: e);
    }
  }

  /// Get workout statistics for user.
  Future<Map<String, dynamic>> getWorkoutStats(String userId) async {
    try {
      AppLogger.info('Fetching workout stats');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.workoutStats,
      );

      final stats = response.data['stats'] as Map<String, dynamic>;
      AppLogger.info('Fetched workout stats');
      return stats;
    } catch (e) {
      AppLogger.error('Failed to fetch workout stats', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to calculate workout stats', originalError: e);
    }
  }

  /// Get exercise history for a user (Supabase direct).
  Future<List<WorkoutLogModel>> getExerciseHistory({
    required String userId,
    required String exerciseId,
    int? limit,
  }) async {
    try {
      AppLogger.info('Fetching exercise history for: $exerciseId');

      var query = _supabase
          .from(Tables.workoutLogs)
          .select('*, exercise:exercises(*), session:workout_sessions!inner(*)')
          .eq('exercise_id', exerciseId)
          .eq('session.user_id', userId)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      final logs = (response as List)
          .map((json) => WorkoutLogModel.fromJson(json))
          .toList();

      AppLogger.info('Fetched ${logs.length} exercise history records');
      return logs;
    } catch (e) {
      AppLogger.error('Failed to fetch exercise history', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to fetch exercise history', originalError: e);
    }
  }

  /// Get personal record for an exercise (Supabase direct).
  Future<WorkoutLogModel?> getExercisePersonalRecord({
    required String userId,
    required String exerciseId,
  }) async {
    try {
      AppLogger.info('Fetching PR for exercise: $exerciseId');

      final response = await _supabase
          .from(Tables.workoutLogs)
          .select('*, exercise:exercises(*), session:workout_sessions!inner(*)')
          .eq('exercise_id', exerciseId)
          .eq('session.user_id', userId)
          .not('weight_kg', 'is', null)
          .order('weight_kg', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      AppLogger.info('Fetched PR for exercise');
      return WorkoutLogModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Failed to fetch exercise PR', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to fetch exercise PR', originalError: e);
    }
  }
}
