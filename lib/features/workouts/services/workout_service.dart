import '../../../core/config/api_config.dart';
import '../../../core/exceptions/exceptions.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/logger_service.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';
import '../models/workout_session_model.dart';

/// Service for managing exercises, workouts, and workout sessions via API.
class WorkoutService {
  final ApiClient _apiClient;

  WorkoutService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // ==================== EXERCISES ====================

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

  // ==================== WORKOUTS ====================

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

  /// Create a new workout.
  Future<WorkoutModel> createWorkout({
    required String userId,
    required String name,
    String? description,
    String? category,
    required int estimatedDuration,
    required String difficulty,
    List<String>? targetMuscles,
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

  // ==================== WORKOUT SESSIONS ====================

  /// Start a new workout session.
  Future<WorkoutSessionModel> startWorkoutSession({
    required String userId,
    String? workoutId,
  }) async {
    try {
      AppLogger.info('Starting workout session');

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.workoutSessions,
        body: workoutId != null ? {'workoutId': workoutId} : {},
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

  /// Get workout session history for user.
  Future<List<WorkoutSessionModel>> getWorkoutHistory({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      AppLogger.info('Fetching workout history');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.workoutHistory,
        queryParams: {'limit': limit, 'offset': offset},
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
}
