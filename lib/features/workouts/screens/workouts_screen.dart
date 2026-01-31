import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/route_names.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/widgets/card_container.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout_session_model.dart';
import '../models/workout_model.dart';

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
        title: Text(context.l10n.workouts),
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
              tabs: [
                Tab(text: context.l10n.myWorkouts),
                Tab(text: context.l10n.templates),
                Tab(text: context.l10n.history),
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
        context,
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
                  icon: const Icon(Icons.notifications_outlined),
                  tooltip: context.l10n.setReminder,
                  onPressed: () => _showSetReminderDialog(context, workout),
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
      return Center(
        child: Text(context.l10n.noWorkoutTemplatesAvailable),
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
      return Center(
        child: Text(context.l10n.workoutHistoryWillAppearHere),
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
                        session.workout?.name ?? context.l10n.quickWorkout,
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
                      '${session.durationMinutes} ${context.l10n.min}',
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
    final timeStr = DateFormat('h:mm a').format(date);

    if (difference.inDays == 0) {
      return context.l10n.todayAt(timeStr);
    } else if (difference.inDays == 1) {
      return context.l10n.yesterdayAt(timeStr);
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
          content: Text(workoutProvider.errorMessage ?? context.l10n.failedToStartWorkout),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showCreateWorkoutDialog(BuildContext context) {
    context.push(RoutePaths.createWorkout);
  }

  Future<void> _showSetReminderDialog(BuildContext context, WorkoutModel workout) async {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(dialogContext.l10n.setWorkoutReminder),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dialogContext.l10n.getRemindedToDo(workout.name),
                style: AppTypography.bodyLarge,
              ),
              AppSpacing.vGapLg,
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(dialogContext.l10n.date),
                subtitle: Text(
                  DateFormat('MMM d, yyyy').format(selectedDate),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(dialogContext.l10n.time),
                subtitle: Text(
                  selectedTime.format(context),
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setState(() => selectedTime = time);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(dialogContext.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'date': selectedDate,
                'time': selectedTime,
              }),
              child: Text(dialogContext.l10n.setReminder),
            ),
          ],
        ),
      ),
    );

    if (result == null || !mounted) return;

    final date = result['date'] as DateTime;
    final time = result['time'] as TimeOfDay;

    // Combine date and time
    final reminderDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // Schedule the reminder
    await NotificationService.instance.scheduleWorkoutReminder(
      workout.id,
      workout.name,
      reminderDateTime,
    );

    if (!mounted) return;

    final dateStr = DateFormat('MMM d, yyyy').format(date);
    final timeStr = time.format(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.reminderSetFor(dateStr, timeStr),
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
