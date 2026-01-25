import '../../../core/exceptions/exceptions.dart';
import '../../../core/services/base_service.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';
import '../models/workout_session_model.dart';

/// Service for managing exercises, workouts, and workout sessions.
class WorkoutService extends BaseService {
  // ==================== EXERCISES ====================

  /// Get all exercises.
  Future<List<ExerciseModel>> getAllExercises() async {
    try {
      final response = await supabase
          .from(Tables.exercises)
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) => ExerciseModel.fromJson(json))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch exercises: $e');
    }
  }

  /// Get exercises by muscle group.
  Future<List<ExerciseModel>> getExercisesByMuscleGroup(
      String muscleGroup) async {
    try {
      final response = await supabase
          .from(Tables.exercises)
          .select()
          .contains('muscle_groups', [muscleGroup])
          .order('name', ascending: true);

      return (response as List)
          .map((json) => ExerciseModel.fromJson(json))
          .toList();
    } catch (e) {
      throw DatabaseException(
          'Failed to fetch exercises by muscle group: $e');
    }
  }

  /// Get exercises by type (strength, cardio, etc.).
  Future<List<ExerciseModel>> getExercisesByType(String exerciseType) async {
    try {
      final response = await supabase
          .from(Tables.exercises)
          .select()
          .eq('exercise_type', exerciseType)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => ExerciseModel.fromJson(json))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch exercises by type: $e');
    }
  }

  /// Search exercises by name.
  Future<List<ExerciseModel>> searchExercises(String query) async {
    try {
      final response = await supabase
          .from(Tables.exercises)
          .select()
          .ilike('name', '%$query%')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => ExerciseModel.fromJson(json))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to search exercises: $e');
    }
  }

  /// Get exercise by ID.
  Future<ExerciseModel?> getExerciseById(String exerciseId) async {
    try {
      final response = await supabase
          .from(Tables.exercises)
          .select()
          .eq('id', exerciseId)
          .maybeSingle();

      if (response == null) return null;
      return ExerciseModel.fromJson(response);
    } catch (e) {
      throw DatabaseException('Failed to fetch exercise: $e');
    }
  }

  // ==================== WORKOUTS ====================

  /// Get user's workouts (templates and custom).
  Future<List<WorkoutModel>> getUserWorkouts(String userId) async {
    try {
      final response = await supabase
          .from(Tables.workouts)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => WorkoutModel.fromJson(json))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch user workouts: $e');
    }
  }

  /// Get public workout templates.
  Future<List<WorkoutModel>> getPublicWorkouts() async {
    try {
      final response = await supabase
          .from(Tables.workouts)
          .select()
          .eq('is_public', true)
          .eq('is_template', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => WorkoutModel.fromJson(json))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch public workouts: $e');
    }
  }

  /// Get workout by ID with exercises.
  Future<WorkoutModel?> getWorkoutById(String workoutId) async {
    try {
      final response = await supabase
          .from(Tables.workouts)
          .select()
          .eq('id', workoutId)
          .maybeSingle();

      if (response == null) return null;
      return WorkoutModel.fromJson(response);
    } catch (e) {
      throw DatabaseException('Failed to fetch workout: $e');
    }
  }

  /// Get workout exercises for a workout.
  Future<List<WorkoutExerciseModel>> getWorkoutExercises(
      String workoutId) async {
    try {
      final response = await supabase
          .from(Tables.workoutExercises)
          .select('*, exercises(*)')
          .eq('workout_id', workoutId)
          .order('order_index', ascending: true);

      return (response as List)
          .map((json) => WorkoutExerciseModel.fromJson(json))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch workout exercises: $e');
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
  }) async {
    try {
      final response = await supabase
          .from(Tables.workouts)
          .insert({
            'user_id': userId,
            'name': name,
            'description': description,
            'category': category,
            'estimated_duration': estimatedDuration,
            'difficulty': difficulty,
            'target_muscles': targetMuscles,
            'is_template': isTemplate,
            'is_public': isPublic,
          })
          .select()
          .single();

      return WorkoutModel.fromJson(response);
    } catch (e) {
      throw DatabaseException('Failed to create workout: $e');
    }
  }

  /// Add exercise to workout.
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
      final response = await supabase
          .from(Tables.workoutExercises)
          .insert({
            'workout_id': workoutId,
            'exercise_id': exerciseId,
            'order_index': orderIndex,
            'sets': sets,
            'reps': reps,
            'duration': duration,
            'weight': weight,
            'rest_seconds': restSeconds,
            'notes': notes,
          })
          .select('*, exercises(*)')
          .single();

      return WorkoutExerciseModel.fromJson(response);
    } catch (e) {
      throw DatabaseException('Failed to add exercise to workout: $e');
    }
  }

  /// Update workout exercise.
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
      final updateData = <String, dynamic>{};
      if (sets != null) updateData['sets'] = sets;
      if (reps != null) updateData['reps'] = reps;
      if (duration != null) updateData['duration'] = duration;
      if (weight != null) updateData['weight'] = weight;
      if (restSeconds != null) updateData['rest_seconds'] = restSeconds;
      if (notes != null) updateData['notes'] = notes;

      final response = await supabase
          .from(Tables.workoutExercises)
          .update(updateData)
          .eq('id', workoutExerciseId)
          .select('*, exercises(*)')
          .single();

      return WorkoutExerciseModel.fromJson(response);
    } catch (e) {
      throw DatabaseException('Failed to update workout exercise: $e');
    }
  }

  /// Remove exercise from workout.
  Future<void> removeExerciseFromWorkout(String workoutExerciseId) async {
    try {
      await supabase
          .from(Tables.workoutExercises)
          .delete()
          .eq('id', workoutExerciseId);
    } catch (e) {
      throw DatabaseException('Failed to remove exercise from workout: $e');
    }
  }

  /// Delete workout.
  Future<void> deleteWorkout(String workoutId) async {
    try {
      // First delete all workout exercises
      await supabase
          .from(Tables.workoutExercises)
          .delete()
          .eq('workout_id', workoutId);

      // Then delete the workout
      await supabase.from(Tables.workouts).delete().eq('id', workoutId);
    } catch (e) {
      throw DatabaseException('Failed to delete workout: $e');
    }
  }

  // ==================== WORKOUT SESSIONS ====================

  /// Start a new workout session.
  Future<WorkoutSessionModel> startWorkoutSession({
    required String userId,
    String? workoutId,
    String? notes,
  }) async {
    try {
      // Check if user has an active session
      final activeSession = await getActiveWorkoutSession(userId);
      if (activeSession != null) {
        throw ValidationException(
          'You already have an active workout session',
          code: 'ACTIVE_SESSION_EXISTS',
        );
      }

      final response = await supabase
          .from(Tables.workoutSessions)
          .insert({
            'user_id': userId,
            'workout_id': workoutId,
            'started_at': DateTime.now().toIso8601String(),
            'status': 'in_progress',
            'notes': notes,
          })
          .select('*, workouts(*)')
          .single();

      return WorkoutSessionModel.fromJson(response);
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException('Failed to start workout session: $e');
    }
  }

  /// Get active workout session for user.
  Future<WorkoutSessionModel?> getActiveWorkoutSession(String userId) async {
    try {
      final response = await supabase
          .from(Tables.workoutSessions)
          .select('*, workouts(*)')
          .eq('user_id', userId)
          .eq('status', 'in_progress')
          .maybeSingle();

      if (response == null) return null;
      return WorkoutSessionModel.fromJson(response);
    } catch (e) {
      throw DatabaseException('Failed to fetch active workout session: $e');
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
      final response = await supabase
          .from(Tables.workoutLogs)
          .insert({
            'session_id': sessionId,
            'exercise_id': exerciseId,
            'set_number': setNumber,
            'reps': reps,
            'weight': weight,
            'duration': duration,
            'notes': notes,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return WorkoutLogModel.fromJson(response);
    } catch (e) {
      throw DatabaseException('Failed to log workout set: $e');
    }
  }

  /// Get workout logs for a session.
  Future<List<WorkoutLogModel>> getSessionLogs(String sessionId) async {
    try {
      final response = await supabase
          .from(Tables.workoutLogs)
          .select()
          .eq('session_id', sessionId)
          .order('completed_at', ascending: true);

      return (response as List)
          .map((json) => WorkoutLogModel.fromJson(json))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch session logs: $e');
    }
  }

  /// Complete workout session.
  Future<WorkoutSessionModel> completeWorkoutSession({
    required String sessionId,
    String? notes,
  }) async {
    try {
      // Get all logs for this session to calculate stats
      final logs = await getSessionLogs(sessionId);

      // Calculate stats
      final totalSets = logs.length;
      final totalReps = logs
          .where((log) => log.reps != null)
          .fold(0, (sum, log) => sum + log.reps!);
      final totalWeight = logs
          .where((log) => log.weight != null && log.reps != null)
          .fold(0.0, (sum, log) => sum + (log.weight! * log.reps!));

      // Get session start time to calculate duration
      final session = await supabase
          .from(Tables.workoutSessions)
          .select()
          .eq('id', sessionId)
          .single();

      final startedAt = DateTime.parse(session['started_at']);
      final duration = DateTime.now().difference(startedAt).inMinutes;

      // Update session
      final response = await supabase
          .from(Tables.workoutSessions)
          .update({
            'completed_at': DateTime.now().toIso8601String(),
            'duration_minutes': duration,
            'total_sets': totalSets,
            'total_reps': totalReps,
            'total_weight': totalWeight,
            'status': 'completed',
            'notes': notes ?? session['notes'],
          })
          .eq('id', sessionId)
          .select('*, workouts(*)')
          .single();

      return WorkoutSessionModel.fromJson(response);
    } catch (e) {
      throw DatabaseException('Failed to complete workout session: $e');
    }
  }

  /// Cancel workout session.
  Future<void> cancelWorkoutSession(String sessionId) async {
    try {
      await supabase
          .from(Tables.workoutSessions)
          .update({'status': 'cancelled'})
          .eq('id', sessionId);
    } catch (e) {
      throw DatabaseException('Failed to cancel workout session: $e');
    }
  }

  /// Get workout session history for user.
  Future<List<WorkoutSessionModel>> getWorkoutHistory({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var filterQuery = supabase
          .from(Tables.workoutSessions)
          .select('*, workouts(*)')
          .eq('user_id', userId);

      if (startDate != null) {
        filterQuery = filterQuery.gte('started_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        filterQuery = filterQuery.lte('started_at', endDate.toIso8601String());
      }

      var transformQuery = filterQuery.order('started_at', ascending: false);

      if (limit != null) {
        transformQuery = transformQuery.limit(limit);
      }

      final response = await transformQuery;

      return (response as List)
          .map((json) => WorkoutSessionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch workout history: $e');
    }
  }

  /// Get workout statistics for user.
  Future<Map<String, dynamic>> getWorkoutStats(String userId) async {
    try {
      final allSessions = await getWorkoutHistory(userId: userId);

      final completedSessions =
          allSessions.where((s) => s.isCompleted).toList();

      // Calculate stats
      final totalWorkouts = completedSessions.length;
      final totalMinutes = completedSessions.fold(
          0, (sum, session) => sum + (session.durationMinutes ?? 0));
      final totalSets =
          completedSessions.fold(0, (sum, session) => sum + (session.totalSets ?? 0));
      final totalReps =
          completedSessions.fold(0, (sum, session) => sum + (session.totalReps ?? 0));
      final totalWeight = completedSessions.fold(
          0.0, (sum, session) => sum + (session.totalWeight ?? 0));

      // This week stats
      final thisWeekStart =
          DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
      final thisWeekSessions = completedSessions
          .where((s) => s.startedAt.isAfter(thisWeekStart))
          .toList();
      final thisWeekWorkouts = thisWeekSessions.length;
      final thisWeekMinutes = thisWeekSessions.fold(
          0, (sum, session) => sum + (session.durationMinutes ?? 0));

      // This month stats
      final thisMonthStart =
          DateTime(DateTime.now().year, DateTime.now().month, 1);
      final thisMonthSessions = completedSessions
          .where((s) => s.startedAt.isAfter(thisMonthStart))
          .toList();
      final thisMonthWorkouts = thisMonthSessions.length;

      return {
        'total_workouts': totalWorkouts,
        'total_minutes': totalMinutes,
        'total_sets': totalSets,
        'total_reps': totalReps,
        'total_weight': totalWeight,
        'this_week_workouts': thisWeekWorkouts,
        'this_week_minutes': thisWeekMinutes,
        'this_month_workouts': thisMonthWorkouts,
        'average_duration':
            totalWorkouts > 0 ? (totalMinutes / totalWorkouts).round() : 0,
      };
    } catch (e) {
      throw DatabaseException('Failed to calculate workout stats: $e');
    }
  }

  /// Get exercise history for a specific exercise.
  Future<List<WorkoutLogModel>> getExerciseHistory({
    required String userId,
    required String exerciseId,
    int? limit,
  }) async {
    try {
      // First get user's completed sessions
      final sessions = await supabase
          .from(Tables.workoutSessions)
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'completed');

      final sessionIds = (sessions as List).map((s) => s['id']).toList();

      if (sessionIds.isEmpty) return [];

      // Get logs for this exercise from those sessions
      var query = supabase
          .from(Tables.workoutLogs)
          .select()
          .eq('exercise_id', exerciseId)
          .inFilter('session_id', sessionIds)
          .order('completed_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) => WorkoutLogModel.fromJson(json))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch exercise history: $e');
    }
  }

  /// Get personal record for an exercise (max weight).
  Future<WorkoutLogModel?> getExercisePersonalRecord({
    required String userId,
    required String exerciseId,
  }) async {
    try {
      final history = await getExerciseHistory(
        userId: userId,
        exerciseId: exerciseId,
      );

      if (history.isEmpty) return null;

      // Find max weight * reps
      WorkoutLogModel? maxLog;
      double maxVolume = 0;

      for (final log in history) {
        if (log.weight != null && log.reps != null) {
          final volume = log.weight! * log.reps!;
          if (volume > maxVolume) {
            maxVolume = volume;
            maxLog = log;
          }
        }
      }

      return maxLog;
    } catch (e) {
      throw DatabaseException('Failed to fetch personal record: $e');
    }
  }
}

/// Table names for database queries.
class Tables {
  static const String exercises = 'exercises';
  static const String workouts = 'workouts';
  static const String workoutExercises = 'workout_exercises';
  static const String workoutSessions = 'workout_sessions';
  static const String workoutLogs = 'workout_logs';
}
