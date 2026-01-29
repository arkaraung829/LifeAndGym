import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../../../shared/widgets/card_container.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../../workouts/providers/workout_provider.dart';

/// Progress screen with real workout data.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (_isInitialized) return;

    final authProvider = context.read<AuthProvider>();
    if (authProvider.isGuest || authProvider.user == null) {
      setState(() => _isInitialized = true);
      return;
    }

    final userId = authProvider.user!.id;
    final workoutProvider = context.read<WorkoutProvider>();

    // Load workout stats and history
    await Future.wait([
      workoutProvider.loadWorkoutStats(userId),
      workoutProvider.loadWorkoutHistory(userId: userId, limit: 30),
    ]);

    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _showDateRangePicker(context),
          ),
        ],
      ),
      body: authProvider.isGuest
          ? _buildGuestState(context)
          : RefreshIndicator(
              onRefresh: () async {
                _isInitialized = false;
                await _loadData();
              },
              child: workoutProvider.isLoading && !_isInitialized
                  ? const Center(child: LoadingIndicator())
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSpacing.screenPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary Cards
                          _buildSummaryCards(context, workoutProvider),

                          AppSpacing.vGapLg,

                          // Streak
                          _buildStreakCard(context, workoutProvider),

                          AppSpacing.vGapLg,

                          // Recent Workouts
                          _buildSection(
                            context,
                            title: 'Recent Workouts',
                            child: _buildRecentWorkouts(context, workoutProvider),
                          ),

                          AppSpacing.vGapLg,

                          // Body Metrics
                          _buildSection(
                            context,
                            title: 'Body Metrics',
                            action: TextButton(
                              onPressed: () => context.push(RoutePaths.bodyMetrics),
                              child: const Text('Log'),
                            ),
                            child: _buildMetricsPlaceholder(context),
                          ),

                          AppSpacing.vGapXxl,
                        ],
                      ),
                    ),
            ),
    );
  }

  Widget _buildGuestState(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            AppSpacing.vGapLg,
            Text(
              'Track Your Progress',
              style: AppTypography.heading3,
            ),
            AppSpacing.vGapSm,
            Text(
              'Sign in to track your workouts and see your progress over time.',
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, WorkoutProvider workoutProvider) {
    final history = workoutProvider.workoutHistory;

    // Calculate stats from history
    final completedWorkouts = history.where((s) => s.isCompleted).length;
    final totalMinutes = history.fold<int>(
      0,
      (sum, session) => sum + (session.durationMinutes ?? 0),
    );
    final totalHours = (totalMinutes / 60).toStringAsFixed(1);
    final totalCalories = history.fold<int>(
      0,
      (sum, session) => sum + (session.caloriesBurned ?? 0),
    );

    String formatCalories(int calories) {
      if (calories >= 1000) {
        return '${(calories / 1000).toStringAsFixed(1)}K';
      }
      return calories.toString();
    }

    final summaryStats = [
      {'label': 'Workouts', 'value': completedWorkouts.toString(), 'icon': Icons.fitness_center},
      {'label': 'Hours', 'value': totalHours, 'icon': Icons.timer},
      {'label': 'Calories', 'value': formatCalories(totalCalories), 'icon': Icons.local_fire_department},
    ];

    return Row(
      children: summaryStats.map((stat) {
        return Expanded(
          child: CardContainer(
            margin: EdgeInsets.only(
              right: stat == summaryStats.last ? 0 : 8,
            ),
            child: Column(
              children: [
                Icon(
                  stat['icon'] as IconData,
                  color: AppColors.primary,
                  size: 28,
                ),
                AppSpacing.vGapSm,
                Text(
                  stat['value'] as String,
                  style: AppTypography.heading2,
                ),
                Text(
                  stat['label'] as String,
                  style: AppTypography.caption.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStreakCard(BuildContext context, WorkoutProvider workoutProvider) {
    final stats = workoutProvider.workoutStats;
    final currentStreak = stats?['currentStreak'] as int? ?? 0;
    final longestStreak = stats?['longestStreak'] as int? ?? 0;

    if (currentStreak == 0) {
      return GradientCard(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Colors.white,
                size: 32,
              ),
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Your Streak!',
                    style: AppTypography.heading3.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Complete a workout today to begin.',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GradientCard(
      gradient: const LinearGradient(
        colors: [Color(0xFFFF6B35), Color(0xFFFF8C00)],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 32,
            ),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currentStreak Day Streak!',
                  style: AppTypography.heading3.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  longestStreak > currentStreak
                      ? 'Keep it up! Your longest streak was $longestStreak days.'
                      : "You're on fire! This is your best streak!",
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    Widget? action,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.heading4,
            ),
            if (action != null) action,
          ],
        ),
        AppSpacing.vGapMd,
        child,
      ],
    );
  }

  Widget _buildRecentWorkouts(BuildContext context, WorkoutProvider workoutProvider) {
    final history = workoutProvider.workoutHistory.take(5).toList();

    if (history.isEmpty) {
      return CardContainer(
        child: Column(
          children: [
            Icon(
              Icons.fitness_center,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            AppSpacing.vGapMd,
            Text(
              'No workouts yet',
              style: AppTypography.bodyLarge,
            ),
            AppSpacing.vGapXs,
            Text(
              'Start your first workout to see it here',
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: history.map((session) {
        return CardContainer(
          margin: const EdgeInsets.only(bottom: 8),
          padding: AppSpacing.listItemPadding,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: AppColors.primary,
                  size: 20,
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatDate(session.startedAt),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    session.formattedDuration,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (session.totalSets != null)
                    Text(
                      '${session.totalSets} sets',
                      style: AppTypography.caption.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
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
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}';
    }
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final now = DateTime.now();
    final initialDateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );

    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Select date range',
      cancelText: 'Cancel',
      confirmText: 'Apply',
      saveText: 'Apply',
    );

    if (pickedRange != null && mounted) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        final workoutProvider = context.read<WorkoutProvider>();
        await workoutProvider.loadWorkoutHistory(
          userId: authProvider.user!.id,
          startDate: pickedRange.start,
          endDate: pickedRange.end,
        );
      }
    }
  }

  Widget _buildMetricsPlaceholder(BuildContext context) {
    return CardContainer(
      child: Column(
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          AppSpacing.vGapMd,
          Text(
            'Track your body metrics',
            style: AppTypography.bodyLarge,
          ),
          AppSpacing.vGapXs,
          Text(
            'Log weight, measurements, and more',
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          AppSpacing.vGapMd,
          ElevatedButton(
            onPressed: () => context.push(RoutePaths.bodyMetrics),
            child: const Text('Add First Entry'),
          ),
        ],
      ),
    );
  }
}
