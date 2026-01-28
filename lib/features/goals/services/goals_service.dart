import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/exceptions/exceptions.dart';
import '../../../core/services/logger_service.dart';
import '../models/goal_model.dart';

/// Service for managing goals.
/// Uses Supabase directly for all operations.
class GoalsService {
  final SupabaseClient _supabase;

  GoalsService({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseConfig.client;

  // ==================== GOALS ====================

  /// Get user's goals.
  Future<List<GoalModel>> getUserGoals(String userId) async {
    try {
      AppLogger.info('Fetching user goals for: $userId');

      final response = await _supabase
          .from(Tables.goals)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final goalsList = response as List;
      final goals = goalsList.map((json) => GoalModel.fromJson(json)).toList();

      AppLogger.info('Fetched ${goals.length} goals');
      return goals;
    } catch (e) {
      AppLogger.error('Failed to fetch user goals', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to fetch user goals', originalError: e);
    }
  }

  /// Create a new goal.
  Future<GoalModel> createGoal(GoalModel goal) async {
    try {
      AppLogger.info('Creating goal: ${goal.name}');

      final response = await _supabase
          .from(Tables.goals)
          .insert(goal.toJson())
          .select()
          .single();

      final createdGoal = GoalModel.fromJson(response);
      AppLogger.info('Created goal: ${createdGoal.id}');
      return createdGoal;
    } catch (e) {
      AppLogger.error('Failed to create goal', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to create goal', originalError: e);
    }
  }

  /// Update goal progress.
  Future<GoalModel> updateGoalProgress(String goalId, double currentValue) async {
    try {
      AppLogger.info('Updating goal progress: $goalId');

      final response = await _supabase
          .from(Tables.goals)
          .update({
            'current_value': currentValue,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goalId)
          .select()
          .single();

      final updatedGoal = GoalModel.fromJson(response);
      AppLogger.info('Updated goal progress');
      return updatedGoal;
    } catch (e) {
      AppLogger.error('Failed to update goal progress', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to update goal progress', originalError: e);
    }
  }

  /// Delete a goal.
  Future<void> deleteGoal(String goalId) async {
    try {
      AppLogger.info('Deleting goal: $goalId');

      await _supabase
          .from(Tables.goals)
          .delete()
          .eq('id', goalId);

      AppLogger.info('Deleted goal');
    } catch (e) {
      AppLogger.error('Failed to delete goal', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to delete goal', originalError: e);
    }
  }

  /// Update goal status.
  Future<GoalModel> updateGoalStatus(String goalId, GoalStatus status) async {
    try {
      AppLogger.info('Updating goal status: $goalId');

      final statusString = switch (status) {
        GoalStatus.active => 'active',
        GoalStatus.completed => 'completed',
        GoalStatus.abandoned => 'abandoned',
      };

      final response = await _supabase
          .from(Tables.goals)
          .update({
            'status': statusString,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goalId)
          .select()
          .single();

      final updatedGoal = GoalModel.fromJson(response);
      AppLogger.info('Updated goal status');
      return updatedGoal;
    } catch (e) {
      AppLogger.error('Failed to update goal status', error: e);
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to update goal status', originalError: e);
    }
  }
}
