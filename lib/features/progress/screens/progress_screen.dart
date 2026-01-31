import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
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
        title: Text(context.l10n.progress),
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
                            title: context.l10n.recentWorkouts,
                            child: _buildRecentWorkouts(context, workoutProvider),
                          ),

                          AppSpacing.vGapLg,

                          // Body Metrics
                          _buildSection(
                            context,
                            title: context.l10n.bodyMetrics,
                            action: TextButton(
                              onPressed: () {
                                // Navigate to add metrics
                              },
                              child: Text(context.l10n.log),
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
              context.l10n.trackYourProgress,
              style: AppTypography.heading3,
            ),
            AppSpacing.vGapSm,
            Text(
              context.l10n.signInToTrackProgress,
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

    return Row(
      children: [
        _buildSummaryCard(context, context.l10n.workouts, completedWorkouts.toString(), Icons.fitness_center, isFirst: true),
        _buildSummaryCard(context, context.l10n.hours, totalHours, Icons.timer),
        _buildSummaryCard(context, context.l10n.calories, formatCalories(totalCalories), Icons.local_fire_department, isLast: true),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String label, String value, IconData icon, {bool isFirst = false, bool isLast = false}) {
    return Expanded(
      child: CardContainer(
        margin: EdgeInsets.only(
          right: isLast ? 0 : 8,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
            AppSpacing.vGapSm,
            Text(
              value,
              style: AppTypography.heading2,
            ),
            Text(
              label,
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
                    context.l10n.startYourStreak,
                    style: AppTypography.heading3.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    context.l10n.completeWorkoutToBegin,
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
                  context.l10n.dayStreak(currentStreak),
                  style: AppTypography.heading3.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  longestStreak > currentStreak
                      ? context.l10n.keepItUpLongestStreak(longestStreak)
                      : context.l10n.youreBestStreak,
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
              context.l10n.noWorkoutsYet,
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            AppSpacing.vGapXs,
            Text(
              context.l10n.startFirstWorkoutToSeeHere,
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
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
                      session.workout?.name ?? context.l10n.quickWorkout,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatDate(context, session.startedAt),
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
                      '${session.totalSets} ${context.l10n.sets}',
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

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return context.l10n.today;
    } else if (difference.inDays == 1) {
      return context.l10n.yesterday;
    } else if (difference.inDays < 7) {
      return context.l10n.daysAgo(difference.inDays);
    } else {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}';
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
            context.l10n.trackYourBodyMetrics,
            style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          AppSpacing.vGapXs,
          Text(
            context.l10n.logWeightMeasurementsAndMore,
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vGapMd,
          ElevatedButton(
            onPressed: () {
              // Navigate to add metrics
            },
            child: Text(context.l10n.addFirstEntry),
          ),
        ],
      ),
    );
  }
}
