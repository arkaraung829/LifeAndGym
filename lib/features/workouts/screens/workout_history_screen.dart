import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../models/workout_session_model.dart';
import '../providers/workout_provider.dart';

/// Screen for viewing workout history.
class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated && authProvider.user != null) {
        context
            .read<WorkoutProvider>()
            .loadWorkoutHistory(userId: authProvider.user!.id);
        context.read<WorkoutProvider>().loadWorkoutStats(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    provider.errorMessage ?? 'Failed to load workout history',
                    style: AppTypography.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: () {
                      final authProvider = context.read<AuthProvider>();
                      if (authProvider.user != null) {
                        provider.loadWorkoutHistory(
                            userId: authProvider.user!.id);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Stats summary
              if (provider.workoutStats != null) _buildStatsCard(provider.workoutStats!),

              // Workout history list
              Expanded(
                child: _buildHistoryList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    return Card(
      margin: AppSpacing.paddingMd,
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Stats',
              style: AppTypography.heading3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Workouts',
                  '${stats['total_workouts'] ?? 0}',
                  Icons.fitness_center,
                ),
                _buildStatItem(
                  'This Week',
                  '${stats['this_week_workouts'] ?? 0}',
                  Icons.calendar_today,
                ),
                _buildStatItem(
                  'Avg Duration',
                  '${stats['average_duration'] ?? 0}m',
                  Icons.timer,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Sets',
                  '${stats['total_sets'] ?? 0}',
                  Icons.repeat,
                ),
                _buildStatItem(
                  'Total Reps',
                  '${stats['total_reps'] ?? 0}',
                  Icons.format_list_numbered,
                ),
                _buildStatItem(
                  'Total Volume',
                  '${(stats['total_weight'] ?? 0).toStringAsFixed(0)}kg',
                  Icons.scale,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.heading4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceDimDark,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHistoryList(WorkoutProvider provider) {
    final history = provider.workoutHistory;

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.onSurfaceDimDark,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No workout history yet',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.onSurfaceDimDark,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start a workout to see it here',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onSurfaceDimDark,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: AppSpacing.paddingMd,
      itemCount: history.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final session = history[index];
        return _WorkoutSessionCard(session: session);
      },
    );
  }
}

class _WorkoutSessionCard extends StatelessWidget {
  final WorkoutSessionModel session;

  const _WorkoutSessionCard({required this.session});

  Color _getStatusColor() {
    switch (session.status) {
      case SessionStatus.completed:
        return AppColors.success;
      case SessionStatus.cancelled:
        return AppColors.error;
      case SessionStatus.inProgress:
        return AppColors.warning;
    }
  }

  IconData _getStatusIcon() {
    switch (session.status) {
      case SessionStatus.completed:
        return Icons.check_circle;
      case SessionStatus.cancelled:
        return Icons.cancel;
      case SessionStatus.inProgress:
        return Icons.play_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _showSessionDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      session.workout?.name ?? 'Quick Workout',
                      style: AppTypography.heading4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(session.startedAt),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceDimDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Stats
              Row(
                children: [
                  _buildMetric(
                    Icons.timer,
                    session.formattedDuration,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  if (session.totalSets != null)
                    _buildMetric(
                      Icons.fitness_center,
                      '${session.totalSets} sets',
                    ),
                  const SizedBox(width: AppSpacing.lg),
                  if (session.totalReps != null)
                    _buildMetric(
                      Icons.repeat,
                      '${session.totalReps} reps',
                    ),
                ],
              ),

              if (session.totalWeight != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _buildMetric(
                  Icons.scale,
                  '${session.totalWeight!.toStringAsFixed(0)}kg total volume',
                ),
              ],

              if (session.notes != null && session.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: AppSpacing.paddingSm,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: AppColors.onSurfaceDimDark,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          session.notes!,
                          style: AppTypography.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: AppTypography.bodySmall,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showSessionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _SessionDetailsSheet(session: session),
    );
  }
}

class _SessionDetailsSheet extends StatelessWidget {
  final WorkoutSessionModel session;

  const _SessionDetailsSheet({required this.session});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: AppSpacing.paddingLg,
          child: ListView(
            controller: scrollController,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.workout?.name ?? 'Quick Workout',
                      style: AppTypography.heading3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Date and time
              Text(
                'Started: ${_formatDateTime(session.startedAt)}',
                style: AppTypography.body.copyWith(
                  color: AppColors.onSurfaceDimDark,
                ),
              ),
              if (session.completedAt != null)
                Text(
                  'Completed: ${_formatDateTime(session.completedAt!)}',
                  style: AppTypography.body.copyWith(
                    color: AppColors.onSurfaceDimDark,
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),

              // Stats grid
              _buildStatsGrid(),

              if (session.notes != null && session.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Notes',
                  style: AppTypography.heading4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  session.notes!,
                  style: AppTypography.body,
                ),
              ],

              const SizedBox(height: AppSpacing.lg),
              Text(
                'Exercise Logs',
                style: AppTypography.heading4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Exercise logs will appear here',
                style: AppTypography.body.copyWith(
                  color: AppColors.onSurfaceDimDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Duration', session.formattedDuration),
              if (session.totalSets != null)
                _buildStatItem('Sets', '${session.totalSets}'),
              if (session.totalReps != null)
                _buildStatItem('Reps', '${session.totalReps}'),
            ],
          ),
          if (session.totalWeight != null) ...[
            const SizedBox(height: AppSpacing.md),
            _buildStatItem(
              'Total Volume',
              '${session.totalWeight!.toStringAsFixed(0)}kg',
            ),
          ],
          if (session.caloriesBurned != null) ...[
            const SizedBox(height: AppSpacing.md),
            _buildStatItem(
              'Calories Burned',
              '${session.caloriesBurned}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.heading3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceDimDark,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
