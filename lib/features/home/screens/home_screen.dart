import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/route_names.dart';
import '../../../shared/widgets/card_container.dart';
import '../../../shared/widgets/guest_mode_banner.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../../classes/providers/classes_provider.dart';
import '../../gyms/providers/gym_provider.dart';
import '../../membership/providers/membership_provider.dart';
import '../../workouts/models/workout_session_model.dart';
import '../../workouts/providers/workout_provider.dart';

/// Home screen with QR check-in and overview.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

    // Load data in parallel - each method handles its own errors
    try {
      await Future.wait([
        context.read<MembershipProvider>().initializeMembershipData(userId),
        context.read<GymProvider>().loadGyms(),
        context.read<WorkoutProvider>().loadWorkoutStats(userId),
        context.read<WorkoutProvider>().loadWorkoutHistory(userId: userId, limit: 7),
        _loadClassSchedules(),
      ]);
    } catch (e) {
      // Log any uncaught errors but continue - UI should still render
      debugPrint('Error loading home data: $e');
    }

    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  Future<void> _loadClassSchedules() async {
    try {
      final gymProvider = context.read<GymProvider>();
      final classesProvider = context.read<ClassesProvider>();
      final authProvider = context.read<AuthProvider>();

      // Load gyms first if not loaded
      if (gymProvider.gyms.isEmpty) {
        await gymProvider.loadGyms();
      }

      // Load schedules for first gym (user's home gym or first available)
      if (gymProvider.gyms.isNotEmpty) {
        final gymId = gymProvider.gyms.first.id;
        final now = DateTime.now();
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

        await classesProvider.loadSchedules(
          gymId: gymId,
          startDate: now,
          endDate: endOfDay,
        );

        if (authProvider.user != null) {
          await classesProvider.loadBookings(authProvider.user!.id);
        }
      }
    } catch (e) {
      // Silently catch errors - classes are non-critical for home screen
      debugPrint('Error loading class schedules: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isGuest = authProvider.isGuest;
    final greeting = _getGreeting(context);
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _isInitialized = false;
            await _loadData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.vGapMd,

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: AppTypography.bodySmall.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          isGuest ? l10n.guest : (user?.fullName ?? l10n.member),
                          style: AppTypography.heading2,
                        ),
                      ],
                    ),
                    if (isGuest)
                      const GuestModeIndicator()
                    else
                      GestureDetector(
                        onTap: () => _showProfileMenu(context),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            user?.initials ?? 'U',
                            style: AppTypography.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                AppSpacing.vGapLg,

                // Guest mode banner
                if (isGuest) const GuestModeBanner(),

                // QR Check-in Card (only for authenticated users)
                if (!isGuest) _buildQRCheckInCard(context),

                AppSpacing.vGapMd,

                // Gym Status Card
                _buildGymStatusCard(context),

                AppSpacing.vGapMd,

                // Today's Workout Card
                _buildTodaysWorkoutCard(context),

                AppSpacing.vGapMd,

                // Upcoming Classes
                _buildUpcomingClassesSection(context),

                AppSpacing.vGapMd,

                // Weekly Progress
                _buildWeeklyProgressCard(context),

                AppSpacing.vGapXxl,
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting(BuildContext context) {
    final l10n = context.l10n;
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  Widget _buildQRCheckInCard(BuildContext context) {
    final l10n = context.l10n;
    final membershipProvider = context.watch<MembershipProvider>();
    final isCheckedIn = membershipProvider.isCheckedIn;

    return GradientCard(
      gradient: isCheckedIn ? AppColors.successGradient : AppColors.primaryGradient,
      padding: const EdgeInsets.all(16),
      onTap: () {
        _showQRDialog(context);
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCheckedIn ? Icons.check_circle : Icons.qr_code_2,
              color: Colors.white,
              size: 24,
            ),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCheckedIn ? l10n.checkedIn : l10n.tapToCheckIn,
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isCheckedIn ? 'Active session' : 'Show QR code',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  void _showQRDialog(BuildContext context) {
    final l10n = context.l10n;
    final membershipProvider = context.read<MembershipProvider>();
    final membership = membershipProvider.activeMembership;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: AppSpacing.cardPaddingLarge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.scanToCheckIn,
                style: AppTypography.heading3,
              ),
              AppSpacing.vGapLg,
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: QrImageView(
                  data: membership != null
                      ? 'MEMBER-${membership.id}'
                      : 'MEMBER-${DateTime.now().millisecondsSinceEpoch}',
                  version: QrVersions.auto,
                  size: 200,
                ),
              ),
              AppSpacing.vGapLg,
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGymStatusCard(BuildContext context) {
    final l10n = context.l10n;
    final gymProvider = context.watch<GymProvider>();
    final gym = gymProvider.selectedGym ??
        (gymProvider.gyms.isNotEmpty ? gymProvider.gyms.first : null);

    if (gymProvider.isLoading) {
      return const CardContainer(
        child: Center(child: LoadingIndicator()),
      );
    }

    if (gym == null) {
      return CardContainer(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariantDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.location_off),
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: Text(l10n.noGymAvailable),
            ),
          ],
        ),
      );
    }

    final occupancyColor = gym.currentOccupancy < 30
        ? AppColors.success
        : gym.currentOccupancy < 70
            ? AppColors.warning
            : AppColors.error;
    final occupancyText = gym.currentOccupancy < 30
        ? l10n.notBusy
        : gym.currentOccupancy < 70
            ? l10n.moderate
            : l10n.busy;

    return CardContainer(
      onTap: () {
        _showGymSelectorDialog(context);
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: occupancyColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.location_on,
              color: occupancyColor,
            ),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gym.name,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: occupancyColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.occupancyStatus(occupancyText, gym.currentOccupancy, gym.capacity),
                      style: AppTypography.bodySmall.copyWith(
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
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _buildTodaysWorkoutCard(BuildContext context) {
    final l10n = context.l10n;
    final workoutProvider = context.watch<WorkoutProvider>();
    final hasActiveSession = workoutProvider.hasActiveSession;
    final userWorkouts = workoutProvider.userWorkouts;

    return CardContainer(
      padding: AppSpacing.cardPaddingSmall,
      onTap: () {
        if (hasActiveSession) {
          context.push(RoutePaths.activeWorkout);
        } else {
          _showWorkoutOptionsDialog(context);
        }
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: hasActiveSession
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hasActiveSession ? Icons.play_circle : Icons.fitness_center,
              color: hasActiveSession ? AppColors.success : AppColors.primary,
              size: 24,
            ),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasActiveSession
                      ? l10n.continueYourSession
                      : l10n.startWorkout,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  hasActiveSession
                      ? l10n.tapToResume
                      : userWorkouts.isNotEmpty
                          ? '${userWorkouts.length} workout plans available'
                          : l10n.noPlannedWorkouts,
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  void _showWorkoutOptionsDialog(BuildContext context) {
    final workoutProvider = context.read<WorkoutProvider>();
    final userWorkouts = workoutProvider.userWorkouts;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start Workout',
              style: AppTypography.heading3,
            ),
            AppSpacing.vGapMd,

            // Quick Workout option
            CardContainer(
              padding: const EdgeInsets.all(12),
              onTap: () {
                Navigator.pop(context);
                _startWorkout(context, workoutId: null);
              },
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
                      Icons.flash_on,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  AppSpacing.hGapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Workout',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Start a free-form workout',
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
            ),

            // User's workout plans
            if (userWorkouts.isNotEmpty) ...[
              AppSpacing.vGapMd,
              Text(
                'Your Workout Plans',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.vGapSm,
              ...userWorkouts.take(3).map((workout) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CardContainer(
                    padding: const EdgeInsets.all(12),
                    onTap: () {
                      Navigator.pop(context);
                      _startWorkout(context, workoutId: workout.id);
                    },
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
                            Icons.fitness_center,
                            color: AppColors.success,
                            size: 24,
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                );
              }).toList(),

              // View all workouts link
              if (userWorkouts.length > 3)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push(RoutePaths.workouts);
                  },
                  child: const Text('View All Workouts'),
                ),
            ],

            AppSpacing.vGapMd,
          ],
        ),
      ),
    );
  }

  Future<void> _startWorkout(BuildContext context, {String? workoutId}) async {
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

  Widget _buildUpcomingClassesSection(BuildContext context) {
    final l10n = context.l10n;
    final classesProvider = context.watch<ClassesProvider>();
    final schedules = classesProvider.upcomingSchedules.take(3).toList();
    final bookings = classesProvider.bookings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.upcomingClasses,
              style: AppTypography.heading4,
            ),
            TextButton(
              onPressed: () => context.go(RoutePaths.book),
              child: Text(l10n.seeAll),
            ),
          ],
        ),
        AppSpacing.vGapSm,
        if (classesProvider.isLoading)
          const Center(child: LoadingIndicator())
        else if (schedules.isEmpty)
          CardContainer(
            padding: AppSpacing.cardPaddingSmall,
            child: Center(
              child: Text(l10n.noClassesScheduledToday),
            ),
          )
        else
          Column(
            children: schedules.map((schedule) {
              final isBooked = bookings.any(
                  (b) => b.classScheduleId == schedule.id && b.isConfirmed);
              final className = schedule.classInfo?.name ?? l10n.classes;
              final classType = schedule.classInfo?.type.value ?? 'fitness';
              final classIcon = _getClassIcon(classType);
              final classColor = _getClassColor(classType);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CardContainer(
                  padding: const EdgeInsets.all(12),
                  onTap: () => context.go(RoutePaths.book),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: classColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          classIcon,
                          color: classColor,
                          size: 24,
                        ),
                      ),
                      AppSpacing.hGapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              className,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTime(schedule.scheduledAt),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.people_outline,
                                  size: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${schedule.spotsRemaining}/${schedule.capacity}',
                                  style: AppTypography.bodySmall.copyWith(
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
                      ),
                      if (isBooked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: AppSpacing.borderRadiusFull,
                          ),
                          child: Text(
                            l10n.booked,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  IconData _getClassIcon(String classType) {
    switch (classType.toLowerCase()) {
      case 'yoga':
        return Icons.self_improvement;
      case 'hiit':
        return Icons.flash_on;
      case 'spin':
        return Icons.directions_bike;
      case 'strength':
        return Icons.fitness_center;
      case 'boxing':
        return Icons.sports_mma;
      case 'cardio':
        return Icons.favorite;
      case 'pilates':
        return Icons.accessibility_new;
      case 'crossfit':
        return Icons.sports_gymnastics;
      default:
        return Icons.sports_gymnastics;
    }
  }

  Color _getClassColor(String classType) {
    switch (classType.toLowerCase()) {
      case 'yoga':
        return const Color(0xFF9C27B0); // Purple
      case 'hiit':
        return const Color(0xFFFF5722); // Deep Orange
      case 'spin':
        return const Color(0xFF2196F3); // Blue
      case 'strength':
        return const Color(0xFF4CAF50); // Green
      case 'boxing':
        return const Color(0xFFF44336); // Red
      case 'cardio':
        return const Color(0xFFE91E63); // Pink
      case 'pilates':
        return const Color(0xFF00BCD4); // Cyan
      case 'crossfit':
        return const Color(0xFFFF9800); // Orange
      default:
        return AppColors.primary;
    }
  }

  Widget _buildWeeklyProgressCard(BuildContext context) {
    final l10n = context.l10n;
    final workoutProvider = context.watch<WorkoutProvider>();
    final stats = workoutProvider.workoutStats;
    final history = workoutProvider.workoutHistory;

    // Calculate which days had workouts this week
    final now = DateTime.now();
    // Get start of week (Monday at 00:00:00)
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final completedDays = <int>{};

    for (final session in history) {
      if (session.status == SessionStatus.completed &&
          session.startedAt.isAfter(startOfWeek) &&
          session.startedAt.isBefore(now.add(const Duration(days: 1)))) {
        completedDays.add(session.startedAt.weekday);
      }
    }

    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final weeklyGoal = stats?['weeklyGoal'] as int? ?? 5; // Get from stats or default to 5
    final completedCount = completedDays.length;
    final streak = stats?['currentStreak'] as int? ?? 0;

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.thisWeek,
                style: AppTypography.heading4,
              ),
              if (streak > 0)
                Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: AppColors.warning, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      l10n.dayStreak(streak),
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          AppSpacing.vGapMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayNumber = index + 1;
              final isCompleted = completedDays.contains(dayNumber);
              final isToday = dayNumber == now.weekday;

              return Column(
                children: [
                  Text(
                    days[index],
                    style: AppTypography.labelSmall.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.primary
                            : isToday
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.2),
                        width: isToday && !isCompleted ? 2 : 1,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ],
              );
            }),
          ),
          AppSpacing.vGapMd,
          LinearProgressIndicator(
            value: completedCount / weeklyGoal,
            backgroundColor: AppColors.surfaceVariantDark,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(4),
          ),
          AppSpacing.vGapSm,
          Text(
            l10n.workoutsCompleted(completedCount, weeklyGoal),
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showGymSelectorDialog(BuildContext context) {
    final gymProvider = context.read<GymProvider>();
    final gyms = gymProvider.gyms;
    final selectedGym = gymProvider.selectedGym ?? (gyms.isNotEmpty ? gyms.first : null);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Gym',
              style: AppTypography.heading3,
            ),
            AppSpacing.vGapMd,
            ...gyms.map((gym) {
              final isSelected = selectedGym?.id == gym.id;
              final occupancyColor = gym.currentOccupancy < 30
                  ? AppColors.success
                  : gym.currentOccupancy < 70
                      ? AppColors.warning
                      : AppColors.error;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CardContainer(
                  onTap: () {
                    gymProvider.selectGym(gym);
                    Navigator.pop(context);

                    // Reload schedules for the new gym
                    final now = DateTime.now();
                    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
                    context.read<ClassesProvider>().loadSchedules(
                      gymId: gym.id,
                      startDate: now,
                      endDate: endOfDay,
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: occupancyColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: occupancyColor,
                        ),
                      ),
                      AppSpacing.hGapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gym.name,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${gym.currentOccupancy}% occupancy',
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
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
            AppSpacing.vGapMd,
            // View All Gyms button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push(RoutePaths.gymFinder);
                },
                icon: const Icon(Icons.location_city),
                label: const Text('View All Gyms'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Row(
                children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user?.initials ?? 'U',
                    style: AppTypography.heading3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'User',
                        style: AppTypography.heading4,
                      ),
                      Text(
                        user?.email ?? '',
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
              ],
            ),
            AppSpacing.vGapLg,
            const Divider(),
            AppSpacing.vGapMd,

            // Menu options
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                context.push(RoutePaths.profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_membership_outlined),
              title: const Text('Membership'),
              onTap: () {
                Navigator.pop(context);
                context.push(RoutePaths.membership);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings screen coming soon')),
                );
              },
            ),
            AppSpacing.vGapMd,
            const Divider(),
            AppSpacing.vGapMd,
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  await authProvider.signOut();
                }
              },
            ),
            AppSpacing.vGapMd,
          ],
        ),
      ),
    ),
  );
}
}
