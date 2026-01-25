import 'package:flutter/material.dart';

import '../../../core/exceptions/exceptions.dart';
import '../../../core/providers/safe_change_notifier.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';
import '../models/workout_session_model.dart';
import '../services/workout_service.dart';

/// State for workout operations.
enum WorkoutState {
  initial,
  loading,
  loaded,
  error,
}

/// Provider for managing workout-related state and operations.
class WorkoutProvider extends ChangeNotifier with SafeChangeNotifierMixin {
  final WorkoutService _workoutService = WorkoutService();

  // State
  WorkoutState _state = WorkoutState.initial;
  String? _errorMessage;

  // Exercises
  List<ExerciseModel> _exercises = [];
  List<ExerciseModel> _filteredExercises = [];
  String? _selectedMuscleGroup;
  String? _selectedExerciseType;

  // Workouts
  List<WorkoutModel> _userWorkouts = [];
  List<WorkoutModel> _publicWorkouts = [];
  WorkoutModel? _selectedWorkout;
  List<WorkoutExerciseModel> _workoutExercises = [];

  // Active workout session
  WorkoutSessionModel? _activeSession;
  List<WorkoutLogModel> _sessionLogs = [];
  bool _isSessionActive = false;

  // Stats
  Map<String, dynamic>? _workoutStats;
  List<WorkoutSessionModel> _workoutHistory = [];

  // Getters
  WorkoutState get state => _state;
  String? get errorMessage => _errorMessage;

  // Exercises
  List<ExerciseModel> get exercises => _exercises;
  List<ExerciseModel> get filteredExercises =>
      _filteredExercises.isNotEmpty ? _filteredExercises : _exercises;
  String? get selectedMuscleGroup => _selectedMuscleGroup;
  String? get selectedExerciseType => _selectedExerciseType;

  // Workouts
  List<WorkoutModel> get userWorkouts => _userWorkouts;
  List<WorkoutModel> get publicWorkouts => _publicWorkouts;
  WorkoutModel? get selectedWorkout => _selectedWorkout;
  List<WorkoutExerciseModel> get workoutExercises => _workoutExercises;

  // Active session
  WorkoutSessionModel? get activeSession => _activeSession;
  List<WorkoutLogModel> get sessionLogs => _sessionLogs;
  bool get isSessionActive => _isSessionActive;
  bool get hasActiveSession => _activeSession != null && _isSessionActive;

  // Stats
  Map<String, dynamic>? get workoutStats => _workoutStats;
  List<WorkoutSessionModel> get workoutHistory => _workoutHistory;

  // Computed properties
  bool get isLoading => _state == WorkoutState.loading;
  bool get hasError => _state == WorkoutState.error;

  // ==================== EXERCISES ====================

  /// Load all exercises.
  Future<void> loadExercises() async {
    try {
      _state = WorkoutState.loading;
      _errorMessage = null;
      safeNotifyListeners();

      _exercises = await _workoutService.getAllExercises();
      _filteredExercises = _exercises;

      _state = WorkoutState.loaded;
      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
      _state = WorkoutState.error;
      safeNotifyListeners();
    }
  }

  /// Filter exercises by muscle group.
  Future<void> filterByMuscleGroup(String? muscleGroup) async {
    try {
      _selectedMuscleGroup = muscleGroup;
      _selectedExerciseType = null;

      if (muscleGroup == null) {
        _filteredExercises = _exercises;
      } else {
        _state = WorkoutState.loading;
        safeNotifyListeners();

        _filteredExercises =
            await _workoutService.getExercisesByMuscleGroup(muscleGroup);

        _state = WorkoutState.loaded;
      }

      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
      _state = WorkoutState.error;
      safeNotifyListeners();
    }
  }

  /// Filter exercises by type.
  Future<void> filterByExerciseType(String? exerciseType) async {
    try {
      _selectedExerciseType = exerciseType;
      _selectedMuscleGroup = null;

      if (exerciseType == null) {
        _filteredExercises = _exercises;
      } else {
        _state = WorkoutState.loading;
        safeNotifyListeners();

        _filteredExercises =
            await _workoutService.getExercisesByType(exerciseType);

        _state = WorkoutState.loaded;
      }

      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
      _state = WorkoutState.error;
      safeNotifyListeners();
    }
  }

  /// Search exercises by name.
  Future<void> searchExercises(String query) async {
    try {
      if (query.isEmpty) {
        _filteredExercises = _exercises;
        safeNotifyListeners();
        return;
      }

      _state = WorkoutState.loading;
      safeNotifyListeners();

      _filteredExercises = await _workoutService.searchExercises(query);

      _state = WorkoutState.loaded;
      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
      _state = WorkoutState.error;
      safeNotifyListeners();
    }
  }

  /// Clear exercise filters.
  void clearExerciseFilters() {
    _selectedMuscleGroup = null;
    _selectedExerciseType = null;
    _filteredExercises = _exercises;
    safeNotifyListeners();
  }

  // ==================== WORKOUTS ====================

  /// Load user's workouts.
  Future<void> loadUserWorkouts(String userId) async {
    try {
      _state = WorkoutState.loading;
      _errorMessage = null;
      safeNotifyListeners();

      _userWorkouts = await _workoutService.getUserWorkouts(userId);

      _state = WorkoutState.loaded;
      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
      _state = WorkoutState.error;
      safeNotifyListeners();
    }
  }

  /// Load public workout templates.
  Future<void> loadPublicWorkouts() async {
    try {
      _state = WorkoutState.loading;
      _errorMessage = null;
      safeNotifyListeners();

      _publicWorkouts = await _workoutService.getPublicWorkouts();

      _state = WorkoutState.loaded;
      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
      _state = WorkoutState.error;
      safeNotifyListeners();
    }
  }

  /// Select a workout and load its exercises.
  Future<void> selectWorkout(String workoutId) async {
    try {
      _state = WorkoutState.loading;
      safeNotifyListeners();

      _selectedWorkout = await _workoutService.getWorkoutById(workoutId);
      if (_selectedWorkout != null) {
        _workoutExercises =
            await _workoutService.getWorkoutExercises(workoutId);
      }

      _state = WorkoutState.loaded;
      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
      _state = WorkoutState.error;
      safeNotifyListeners();
    }
  }

  /// Create a new workout.
  Future<WorkoutModel?> createWorkout({
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
      _state = WorkoutState.loading;
      safeNotifyListeners();

      final workout = await _workoutService.createWorkout(
        userId: userId,
        name: name,
        description: description,
        category: category,
        estimatedDuration: estimatedDuration,
        difficulty: difficulty,
        targetMuscles: targetMuscles,
        isTemplate: isTemplate,
        isPublic: isPublic,
      );

      // Reload user workouts
      await loadUserWorkouts(userId);

      _state = WorkoutState.loaded;
      safeNotifyListeners();

      return workout;
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
      _state = WorkoutState.error;
      safeNotifyListeners();
      return null;
    }
  }

  /// Add exercise to workout.
  Future<bool> addExerciseToWorkout({
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
      await _workoutService.addExerciseToWorkout(
        workoutId: workoutId,
        exerciseId: exerciseId,
        orderIndex: orderIndex,
        sets: sets,
        reps: reps,
        duration: duration,
        weight: weight,
        restSeconds: restSeconds,
        notes: notes,
      );

      // Reload workout exercises
      _workoutExercises = await _workoutService.getWorkoutExercises(workoutId);

      safeNotifyListeners();
      return true;
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      safeNotifyListeners();
      return false;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      safeNotifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      safeNotifyListeners();
      return false;
    }
  }

  /// Update workout exercise.
  Future<bool> updateWorkoutExercise({
    required String workoutExerciseId,
    int? sets,
    int? reps,
    int? duration,
    double? weight,
    int? restSeconds,
    String? notes,
  }) async {
    try {
      await _workoutService.updateWorkoutExercise(
        workoutExerciseId: workoutExerciseId,
        sets: sets,
        reps: reps,
        duration: duration,
        weight: weight,
        restSeconds: restSeconds,
        notes: notes,
      );

      // Reload workout exercises if we have a selected workout
      if (_selectedWorkout != null) {
        _workoutExercises =
            await _workoutService.getWorkoutExercises(_selectedWorkout!.id);
      }

      safeNotifyListeners();
      return true;
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      safeNotifyListeners();
      return false;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      safeNotifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      safeNotifyListeners();
      return false;
    }
  }

  /// Remove exercise from workout.
  Future<bool> removeExerciseFromWorkout(String workoutExerciseId) async {
    try {
      await _workoutService.removeExerciseFromWorkout(workoutExerciseId);

      // Reload workout exercises if we have a selected workout
      if (_selectedWorkout != null) {
        _workoutExercises =
            await _workoutService.getWorkoutExercises(_selectedWorkout!.id);
      }

      safeNotifyListeners();
      return true;
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      safeNotifyListeners();
      return false;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      safeNotifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      safeNotifyListeners();
      return false;
    }
  }

  /// Delete workout.
  Future<bool> deleteWorkout(String workoutId, String userId) async {
    try {
      await _workoutService.deleteWorkout(workoutId);

      // Reload user workouts
      await loadUserWorkouts(userId);

      safeNotifyListeners();
      return true;
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      safeNotifyListeners();
      return false;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      safeNotifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      safeNotifyListeners();
      return false;
    }
  }

  // ==================== WORKOUT SESSIONS ====================

  /// Start a new workout session.
  Future<bool> startWorkoutSession({
    required String userId,
    String? workoutId,
    String? notes,
  }) async {
    try {
      _state = WorkoutState.loading;
      safeNotifyListeners();

      _activeSession = await _workoutService.startWorkoutSession(
        userId: userId,
        workoutId: workoutId,
        notes: notes,
      );

      _isSessionActive = true;
      _sessionLogs = [];

      _state = WorkoutState.loaded;
      safeNotifyListeners();

      return true;
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      _state = WorkoutState.error;
      safeNotifyListeners();
      return false;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      _state = WorkoutState.error;
      safeNotifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _state = WorkoutState.error;
      safeNotifyListeners();
      return false;
    }
  }

  /// Load active workout session.
  Future<void> loadActiveSession(String userId) async {
    try {
      _activeSession = await _workoutService.getActiveWorkoutSession(userId);
      _isSessionActive = _activeSession != null;

      if (_activeSession != null) {
        _sessionLogs =
            await _workoutService.getSessionLogs(_activeSession!.id);
      }

      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
      safeNotifyListeners();
    }
  }

  /// Log a workout set.
  Future<bool> logSet({
    required String sessionId,
    required String exerciseId,
    required int setNumber,
    int? reps,
    double? weight,
    int? duration,
    String? notes,
  }) async {
    try {
      final log = await _workoutService.logWorkoutSet(
        sessionId: sessionId,
        exerciseId: exerciseId,
        setNumber: setNumber,
        reps: reps,
        weight: weight,
        duration: duration,
        notes: notes,
      );

      // Add to session logs
      _sessionLogs.add(log);

      safeNotifyListeners();
      return true;
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      safeNotifyListeners();
      return false;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      safeNotifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      safeNotifyListeners();
      return false;
    }
  }

  /// Complete the active workout session.
  Future<bool> completeWorkoutSession({String? notes}) async {
    try {
      if (_activeSession == null) {
        throw ValidationException('No active workout session', code: 'NO_ACTIVE_SESSION');
      }

      _state = WorkoutState.loading;
      safeNotifyListeners();

      _activeSession = await _workoutService.completeWorkoutSession(
        sessionId: _activeSession!.id,
        notes: notes,
      );

      _isSessionActive = false;

      _state = WorkoutState.loaded;
      safeNotifyListeners();

      return true;
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      _state = WorkoutState.error;
      safeNotifyListeners();
      return false;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      _state = WorkoutState.error;
      safeNotifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _state = WorkoutState.error;
      safeNotifyListeners();
      return false;
    }
  }

  /// Cancel the active workout session.
  Future<bool> cancelWorkoutSession() async {
    try {
      if (_activeSession == null) {
        throw ValidationException('No active workout session', code: 'NO_ACTIVE_SESSION');
      }

      await _workoutService.cancelWorkoutSession(_activeSession!.id);

      _activeSession = null;
      _isSessionActive = false;
      _sessionLogs = [];

      safeNotifyListeners();
      return true;
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      safeNotifyListeners();
      return false;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      safeNotifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      safeNotifyListeners();
      return false;
    }
  }

  /// Clear active session (after completion/cancellation).
  void clearActiveSession() {
    _activeSession = null;
    _isSessionActive = false;
    _sessionLogs = [];
    safeNotifyListeners();
  }

  // ==================== STATS & HISTORY ====================

  /// Load workout statistics.
  Future<void> loadWorkoutStats(String userId) async {
    try {
      _workoutStats = await _workoutService.getWorkoutStats(userId);
      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
      safeNotifyListeners();
    }
  }

  /// Load workout history.
  Future<void> loadWorkoutHistory({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _state = WorkoutState.loading;
      safeNotifyListeners();

      _workoutHistory = await _workoutService.getWorkoutHistory(
        userId: userId,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );

      _state = WorkoutState.loaded;
      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
      _state = WorkoutState.error;
      safeNotifyListeners();
    }
  }

  /// Get exercise history.
  Future<List<WorkoutLogModel>> getExerciseHistory({
    required String userId,
    required String exerciseId,
    int? limit,
  }) async {
    try {
      return await _workoutService.getExerciseHistory(
        userId: userId,
        exerciseId: exerciseId,
        limit: limit,
      );
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      return [];
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      return [];
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }

  /// Get personal record for exercise.
  Future<WorkoutLogModel?> getExercisePersonalRecord({
    required String userId,
    required String exerciseId,
  }) async {
    try {
      return await _workoutService.getExercisePersonalRecord(
        userId: userId,
        exerciseId: exerciseId,
      );
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

  /// Reset provider state.
  void reset() {
    _state = WorkoutState.initial;
    _errorMessage = null;
    _exercises = [];
    _filteredExercises = [];
    _selectedMuscleGroup = null;
    _selectedExerciseType = null;
    _userWorkouts = [];
    _publicWorkouts = [];
    _selectedWorkout = null;
    _workoutExercises = [];
    _activeSession = null;
    _sessionLogs = [];
    _isSessionActive = false;
    _workoutStats = null;
    _workoutHistory = [];
    safeNotifyListeners();
  }
}
