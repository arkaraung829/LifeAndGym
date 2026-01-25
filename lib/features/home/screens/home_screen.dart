import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
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

    // Load data in parallel
    await Future.wait([
      context.read<MembershipProvider>().initializeMembershipData(userId),
      context.read<GymProvider>().loadGyms(),
      context.read<WorkoutProvider>().loadWorkoutStats(userId),
      context.read<WorkoutProvider>().loadWorkoutHistory(userId: userId, limit: 7),
      _loadClassSchedules(),
    ]);

    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  Future<void> _loadClassSchedules() async {
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
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isGuest = authProvider.isGuest;
    final greeting = _getGreeting();

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
                          isGuest ? 'Guest' : (user?.fullName ?? 'Member'),
                          style: AppTypography.heading2,
                        ),
                      ],
                    ),
                    if (isGuest)
                      const GuestModeIndicator()
                    else
                      CircleAvatar(
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildQRCheckInCard(BuildContext context) {
    final membershipProvider = context.watch<MembershipProvider>();
    final membership = membershipProvider.activeMembership;
    final isCheckedIn = membershipProvider.isCheckedIn;

    return GradientCard(
      gradient: isCheckedIn ? AppColors.successGradient : AppColors.primaryGradient,
      padding: AppSpacing.cardPaddingLarge,
      onTap: () {
        _showQRDialog(context);
      },
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isCheckedIn ? Icons.check_circle : Icons.qr_code_2,
                color: Colors.white,
                size: 24,
              ),
              AppSpacing.hGapSm,
              Text(
                isCheckedIn ? 'CHECKED IN' : 'TAP TO CHECK IN',
                style: AppTypography.labelLarge.copyWith(
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: QrImageView(
              data: membership != null
                  ? 'MEMBER-${membership.id}'
                  : 'MEMBER-${DateTime.now().millisecondsSinceEpoch}',
              version: QrVersions.auto,
              size: 120,
            ),
          ),
          AppSpacing.vGapMd,
          Text(
            membership != null
                ? '${membership.planType.name} Member'
                : 'No active membership',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  void _showQRDialog(BuildContext context) {
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
                'Scan to Check In',
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
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGymStatusCard(BuildContext context) {
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
            const Expanded(
              child: Text('No gym available'),
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
        ? 'Not Busy'
        : gym.currentOccupancy < 70
            ? 'Moderate'
            : 'Busy';

    return CardContainer(
      onTap: () {
        gymProvider.selectGym(gym);
        // Navigate to gym detail when implemented
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
                      '$occupancyText • ${gym.currentOccupancy}/${gym.capacity} people',
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
    final workoutProvider = context.watch<WorkoutProvider>();
    final hasActiveSession = workoutProvider.hasActiveSession;
    final userWorkouts = workoutProvider.userWorkouts;

    return CardContainer(
      onTap: () {
        if (hasActiveSession) {
          context.push(RoutePaths.activeWorkout);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasActiveSession ? Icons.play_circle : Icons.fitness_center,
                color: hasActiveSession ? AppColors.success : AppColors.primary,
              ),
              AppSpacing.hGapSm,
              Text(
                hasActiveSession ? 'Workout in Progress' : "Today's Workout",
                style: AppTypography.labelLarge,
              ),
            ],
          ),
          AppSpacing.vGapMd,
          Text(
            hasActiveSession
                ? 'Continue your session'
                : userWorkouts.isNotEmpty
                    ? userWorkouts.first.name
                    : 'Start a Quick Workout',
            style: AppTypography.heading3,
          ),
          AppSpacing.vGapXs,
          Text(
            hasActiveSession
                ? 'Tap to resume'
                : userWorkouts.isNotEmpty
                    ? '~${userWorkouts.first.estimatedDuration} min'
                    : 'No planned workouts',
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          AppSpacing.vGapMd,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (hasActiveSession) {
                  context.push(RoutePaths.activeWorkout);
                } else {
                  _startQuickWorkout(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: hasActiveSession ? AppColors.success : null,
              ),
              child: Text(hasActiveSession ? 'Resume Workout' : 'Start Workout'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startQuickWorkout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final workoutProvider = context.read<WorkoutProvider>();

    if (authProvider.user == null) return;

    final success = await workoutProvider.startWorkoutSession(
      userId: authProvider.user!.id,
    );

    if (!mounted) return;

    if (success) {
      context.push(RoutePaths.activeWorkout);
    }
  }

  Widget _buildUpcomingClassesSection(BuildContext context) {
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
              'Upcoming Classes',
              style: AppTypography.heading4,
            ),
            TextButton(
              onPressed: () {
                // Navigate to classes tab
              },
              child: const Text('See All'),
            ),
          ],
        ),
        AppSpacing.vGapSm,
        if (classesProvider.isLoading)
          const Center(child: LoadingIndicator())
        else if (schedules.isEmpty)
          CardContainer(
            padding: AppSpacing.cardPaddingSmall,
            child: const Center(
              child: Text('No classes scheduled today'),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: schedules.map((schedule) {
                final isBooked = bookings.any(
                    (b) => b.classScheduleId == schedule.id && b.isConfirmed);
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  child: CardContainer(
                    padding: AppSpacing.cardPaddingSmall,
                    onTap: () {
                      // Navigate to class detail
                    },
                    child: Column(
                      children: [
                        Text(
                          schedule.classInfo?.name ?? 'Class',
                          style: AppTypography.labelLarge,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.vGapXs,
                        Text(
                          _formatTime(schedule.scheduledAt),
                          style: AppTypography.bodySmall.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        AppSpacing.vGapSm,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isBooked
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: AppSpacing.borderRadiusFull,
                          ),
                          child: Text(
                            isBooked
                                ? 'BOOKED'
                                : '${schedule.spotsRemaining} spots',
                            style: AppTypography.labelSmall.copyWith(
                              color:
                                  isBooked ? AppColors.success : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
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

  Widget _buildWeeklyProgressCard(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final stats = workoutProvider.workoutStats;
    final history = workoutProvider.workoutHistory;

    // Calculate which days had workouts this week
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final completedDays = <int>{};

    for (final session in history) {
      if (session.status == SessionStatus.completed &&
          session.startedAt.isAfter(startOfWeek)) {
        completedDays.add(session.startedAt.weekday);
      }
    }

    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final weeklyGoal = 5; // Default weekly goal
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
                'This Week',
                style: AppTypography.heading4,
              ),
              if (streak > 0)
                Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: AppColors.warning, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '$streak day streak',
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
            '$completedCount/$weeklyGoal workouts completed',
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
