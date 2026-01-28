import 'package:flutter/material.dart';

import '../../../core/exceptions/exceptions.dart';
import '../../../core/providers/safe_change_notifier.dart';
import '../models/goal_model.dart';
import '../services/goals_service.dart';

/// State for goals operations.
enum GoalsState {
  initial,
  loading,
  loaded,
  error,
}

/// Provider for managing goals-related state and operations.
class GoalsProvider extends ChangeNotifier with SafeChangeNotifierMixin {
  final GoalsService _goalsService;

  GoalsProvider({GoalsService? goalsService})
      : _goalsService = goalsService ?? GoalsService();

  // State
  GoalsState _state = GoalsState.initial;
  String? _errorMessage;

  // Goals
  List<GoalModel> _goals = [];
  GoalModel? _selectedGoal;

  // Getters
  GoalsState get state => _state;
  String? get errorMessage => _errorMessage;

  // Goals
  List<GoalModel> get goals => _goals;
  GoalModel? get selectedGoal => _selectedGoal;

  // Computed properties
  bool get isLoading => _state == GoalsState.loading;
  bool get hasError => _state == GoalsState.error;

  /// Get active goals.
  List<GoalModel> get activeGoals =>
      _goals.where((goal) => goal.status == GoalStatus.active).toList();

  /// Get completed goals.
  List<GoalModel> get completedGoals =>
      _goals.where((goal) => goal.status == GoalStatus.completed).toList();

  /// Get overdue goals.
  List<GoalModel> get overdueGoals =>
      _goals.where((goal) => goal.isOverdue).toList();

  // ==================== GOALS ====================

  /// Load user's goals.
  Future<void> loadGoals(String userId) async {
    try {
      _state = GoalsState.loading;
      _errorMessage = null;
      safeNotifyListeners();

      _goals = await _goalsService.getUserGoals(userId);

      _state = GoalsState.loaded;
      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      _state = GoalsState.error;
      safeNotifyListeners();
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      _state = GoalsState.error;
      safeNotifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = GoalsState.error;
      safeNotifyListeners();
    }
  }

  /// Create a new goal.
  Future<void> createGoal(GoalModel goal) async {
    try {
      _state = GoalsState.loading;
      safeNotifyListeners();

      final createdGoal = await _goalsService.createGoal(goal);

      // Add to goals list
      _goals.insert(0, createdGoal);

      _state = GoalsState.loaded;
      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      _state = GoalsState.error;
      safeNotifyListeners();
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      _state = GoalsState.error;
      safeNotifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _state = GoalsState.error;
      safeNotifyListeners();
    }
  }

  /// Update goal progress.
  Future<void> updateProgress(String goalId, double currentValue) async {
    try {
      final updatedGoal = await _goalsService.updateGoalProgress(goalId, currentValue);

      // Update in goals list
      final index = _goals.indexWhere((goal) => goal.id == goalId);
      if (index != -1) {
        _goals[index] = updatedGoal;
      }

      // Update selected goal if it matches
      if (_selectedGoal?.id == goalId) {
        _selectedGoal = updatedGoal;
      }

      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      safeNotifyListeners();
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      safeNotifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      safeNotifyListeners();
    }
  }

  /// Delete a goal.
  Future<void> deleteGoal(String goalId) async {
    try {
      await _goalsService.deleteGoal(goalId);

      // Remove from goals list
      _goals.removeWhere((goal) => goal.id == goalId);

      // Clear selected goal if it matches
      if (_selectedGoal?.id == goalId) {
        _selectedGoal = null;
      }

      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      safeNotifyListeners();
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      safeNotifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      safeNotifyListeners();
    }
  }

  /// Update goal status.
  Future<void> updateStatus(String goalId, GoalStatus status) async {
    try {
      final updatedGoal = await _goalsService.updateGoalStatus(goalId, status);

      // Update in goals list
      final index = _goals.indexWhere((goal) => goal.id == goalId);
      if (index != -1) {
        _goals[index] = updatedGoal;
      }

      // Update selected goal if it matches
      if (_selectedGoal?.id == goalId) {
        _selectedGoal = updatedGoal;
      }

      safeNotifyListeners();
    } on DatabaseException catch (e) {
      _errorMessage = e.message;
      safeNotifyListeners();
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      safeNotifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      safeNotifyListeners();
    }
  }

  /// Select a goal.
  void selectGoal(GoalModel? goal) {
    _selectedGoal = goal;
    safeNotifyListeners();
  }

  /// Reset provider state.
  void reset() {
    _state = GoalsState.initial;
    _errorMessage = null;
    _goals = [];
    _selectedGoal = null;
    safeNotifyListeners();
  }
}
