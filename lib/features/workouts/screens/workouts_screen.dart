import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../../shared/widgets/card_container.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout_session_model.dart';

/// Workouts screen with tabs for user workouts, templates, and history.
class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) return;

    final workoutProvider = context.read<WorkoutProvider>();
    await Future.wait([
      workoutProvider.loadUserWorkouts(authProvider.user!.id),
      workoutProvider.loadPublicWorkouts(),
      workoutProvider.loadWorkoutHistory(
        userId: authProvider.user!.id,
        limit: 50,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateWorkoutDialog(context),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              tabs: const [
                Tab(text: 'My Workouts'),
                Tab(text: 'Templates'),
                Tab(text: 'History'),
              ],
              labelStyle: AppTypography.labelLarge,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildMyWorkoutsTab(context),
                  _buildTemplatesTab(context),
                  _buildHistoryTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyWorkoutsTab(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final userWorkouts = workoutProvider.userWorkouts;

    if (workoutProvider.isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (userWorkouts.isEmpty) {
      return EmptyStates.noWorkouts(
        onAction: () => _showCreateWorkoutDialog(context),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: AppSpacing.screenPadding,
        itemCount: userWorkouts.length,
        itemBuilder: (context, index) {
          final workout = userWorkouts[index];
          return CardContainer(
            margin: const EdgeInsets.only(bottom: 12),
            onTap: () => _startWorkout(context, workout.id),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: AppColors.primary,
                  ),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.name,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${workout.estimatedDuration} min • ${workout.difficulty}',
                        style: AppTypography.bodySmall.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  onPressed: () => _startWorkout(context, workout.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplatesTab(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final publicWorkouts = workoutProvider.publicWorkouts;

    if (workoutProvider.isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (publicWorkouts.isEmpty) {
      return const Center(
        child: Text('No workout templates available'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: AppSpacing.screenPadding,
        itemCount: publicWorkouts.length,
        itemBuilder: (context, index) {
          final template = publicWorkouts[index];
          return CardContainer(
            margin: const EdgeInsets.only(bottom: 12),
            onTap: () => _startWorkout(context, template.id),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.library_books,
                    color: AppColors.success,
                  ),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${template.estimatedDuration} min • ${template.difficulty}',
                        style: AppTypography.bodySmall.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final history = workoutProvider.workoutHistory;

    if (workoutProvider.isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (history.isEmpty) {
      return const Center(
        child: Text('Your workout history will appear here'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: AppSpacing.screenPadding,
        itemCount: history.length,
        itemBuilder: (context, index) {
          final session = history[index];
          return CardContainer(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getSessionColor(session.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSessionIcon(session.status),
                    color: _getSessionColor(session.status),
                  ),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.workout?.name ?? 'Quick Workout',
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatSessionDate(session.startedAt),
                        style: AppTypography.bodySmall.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (session.durationMinutes != null)
                  Chip(
                    label: Text(
                      '${session.durationMinutes} min',
                      style: const TextStyle(fontSize: 12),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getSessionColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.completed:
        return AppColors.success;
      case SessionStatus.cancelled:
        return AppColors.error;
      case SessionStatus.inProgress:
        return AppColors.warning;
    }
  }

  IconData _getSessionIcon(SessionStatus status) {
    switch (status) {
      case SessionStatus.completed:
        return Icons.check_circle;
      case SessionStatus.cancelled:
        return Icons.cancel;
      case SessionStatus.inProgress:
        return Icons.play_circle;
    }
  }

  String _formatSessionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  Future<void> _startWorkout(BuildContext context, String workoutId) async {
    final authProvider = context.read<AuthProvider>();
    final workoutProvider = context.read<WorkoutProvider>();

    if (authProvider.user == null) return;

    final success = await workoutProvider.startWorkoutSession(
      userId: authProvider.user!.id,
      workoutId: workoutId,
    );

    if (!mounted) return;

    if (success) {
      context.push(RoutePaths.activeWorkout);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(workoutProvider.errorMessage ?? 'Failed to start workout'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showCreateWorkoutDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Workout creation coming soon'),
      ),
    );
  }
}
