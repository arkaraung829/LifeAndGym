import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/error_handler_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/widgets/card_container.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../../gyms/providers/gym_provider.dart';
import '../models/class_schedule_model.dart';
import '../providers/classes_provider.dart';

/// Classes/Book screen with real data from provider.
class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  int _selectedDayIndex = 0;
  String _selectedFilter = 'All';
  bool _isInitialized = false;
  bool _showMyBookings = false;

  final _filters = ['All', 'Yoga', 'HIIT', 'Spin', 'Strength', 'Pilates', 'Cardio'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  List<DateTime> get _weekDays {
    final now = DateTime.now();
    return List.generate(7, (index) => now.add(Duration(days: index)));
  }

  Future<void> _loadData() async {
    if (_isInitialized) return;

    final gymProvider = context.read<GymProvider>();
    final classesProvider = context.read<ClassesProvider>();
    final authProvider = context.read<AuthProvider>();

    // Load gyms if not loaded
    if (gymProvider.gyms.isEmpty) {
      await gymProvider.loadGyms();
    }

    // Load schedules for first gym
    if (gymProvider.gyms.isNotEmpty) {
      await _loadSchedulesForDay(_selectedDayIndex);

      // Load user bookings
      if (authProvider.user != null) {
        await classesProvider.loadBookings(authProvider.user!.id);
      }
    }

    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  Future<void> _loadSchedulesForDay(int dayIndex) async {
    final gymProvider = context.read<GymProvider>();
    final classesProvider = context.read<ClassesProvider>();

    if (gymProvider.gyms.isEmpty) return;

    final gymId = gymProvider.gyms.first.id;
    final selectedDate = _weekDays[dayIndex];
    final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

    await classesProvider.loadSchedules(
      gymId: gymId,
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  List<ClassScheduleModel> get _filteredSchedules {
    final classesProvider = context.read<ClassesProvider>();
    var schedules = classesProvider.schedules;

    if (_selectedFilter != 'All') {
      schedules = schedules.where((s) {
        final classType = s.classInfo?.type.value ?? '';
        return classType == _selectedFilter.toLowerCase();
      }).toList();
    }

    // Sort by time
    schedules.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    return schedules;
  }

  @override
  Widget build(BuildContext context) {
    final classesProvider = context.watch<ClassesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_showMyBookings ? 'My Bookings' : 'Book Classes'),
        actions: [
          IconButton(
            icon: Icon(_showMyBookings ? Icons.calendar_today : Icons.event),
            onPressed: () {
              setState(() {
                _showMyBookings = !_showMyBookings;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_showMyBookings) ...[
            // Day selector
            _buildDaySelector(),

            // Filter chips
            _buildFilterChips(),
          ],

          // Classes list
          Expanded(
            child: _showMyBookings
                ? _buildMyBookingsList(classesProvider)
                : _buildSchedulesList(classesProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 72,
      padding: AppSpacing.paddingHorizontalMd,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _weekDays.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDayIndex;
          final date = _weekDays[index];
          final dayName = _getDayName(date, index);

          return GestureDetector(
            onTap: () async {
              setState(() {
                _selectedDayIndex = index;
              });
              await _loadSchedulesForDay(index);
            },
            child: Container(
              width: 56,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: AppSpacing.borderRadiusMd,
                border: isSelected
                    ? null
                    : Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.1),
                      ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    '${date.day}',
                    style: AppTypography.bodyLarge.copyWith(
                      color: isSelected ? Colors.white : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getDayName(DateTime date, int index) {
    if (index == 0) return 'Today';
    if (index == 1) return 'Tmrw';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  Widget _buildFilterChips() {
    return Container(
      height: 48,
      padding: AppSpacing.paddingHorizontalMd,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSchedulesList(ClassesProvider classesProvider) {
    if (classesProvider.isLoading) {
      return const Center(child: LoadingIndicator());
    }

    final schedules = _filteredSchedules;

    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            AppSpacing.vGapMd,
            Text(
              'No classes scheduled',
              style: AppTypography.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            AppSpacing.vGapSm,
            Text(
              _selectedFilter == 'All'
                  ? 'Try selecting a different day'
                  : 'Try removing the filter',
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadSchedulesForDay(_selectedDayIndex),
      child: ListView.builder(
        padding: AppSpacing.screenPadding,
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          return _buildClassCard(schedules[index]);
        },
      ),
    );
  }

  Widget _buildMyBookingsList(ClassesProvider classesProvider) {
    final bookings = classesProvider.upcomingBookings;

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            AppSpacing.vGapMd,
            Text(
              'No upcoming bookings',
              style: AppTypography.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            AppSpacing.vGapLg,
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showMyBookings = false;
                });
              },
              child: const Text('Book a Class'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final schedule = booking.schedule;
        if (schedule == null) return const SizedBox.shrink();

        return _buildBookingCard(booking, schedule);
      },
    );
  }

  Widget _buildClassCard(ClassScheduleModel schedule) {
    final classesProvider = context.read<ClassesProvider>();
    final authProvider = context.read<AuthProvider>();

    final classInfo = schedule.classInfo;
    final isFull = schedule.isFull;
    final typeColor = AppColors.getClassTypeColor(classInfo?.type.value ?? 'other');

    // Check if user has booked this class
    final userBooking = classesProvider.bookings
        .where((b) => b.classScheduleId == schedule.id && b.isConfirmed)
        .firstOrNull;
    final isBooked = userBooking != null;

    return CardContainer(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {
        // Show class details
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  (classInfo?.type.displayName ?? 'CLASS').toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: typeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatTime(schedule.scheduledAt),
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          AppSpacing.vGapSm,
          Text(
            classInfo?.name ?? 'Class',
            style: AppTypography.heading4,
          ),
          AppSpacing.vGapXs,
          Text(
            '${schedule.durationMinutes} min${schedule.room != null ? ' • ${schedule.room}' : ''}',
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          AppSpacing.vGapMd,
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isBooked
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : isFull
                          ? AppColors.error.withValues(alpha: 0.15)
                          : AppColors.success.withValues(alpha: 0.15),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isBooked
                          ? Icons.check_circle
                          : isFull
                              ? Icons.close
                              : Icons.check_circle,
                      size: 14,
                      color: isBooked
                          ? AppColors.primary
                          : isFull
                              ? AppColors.error
                              : AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isBooked
                          ? 'BOOKED'
                          : isFull
                              ? 'FULL'
                              : '${schedule.spotsRemaining}/${schedule.capacity}',
                      style: AppTypography.labelSmall.copyWith(
                        color: isBooked
                            ? AppColors.primary
                            : isFull
                                ? AppColors.error
                                : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isBooked && userBooking != null)
                OutlinedButton(
                  onPressed: () => _cancelBooking(userBooking.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    minimumSize: const Size(100, 36),
                  ),
                  child: const Text('Cancel'),
                )
              else
                ElevatedButton(
                  onPressed: authProvider.user != null && schedule.canBeBooked
                      ? () => _bookClass(schedule.id)
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 36),
                  ),
                  child: Text(isFull ? 'Join Waitlist' : 'Book'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(dynamic booking, ClassScheduleModel schedule) {
    final classInfo = schedule.classInfo;
    final typeColor = AppColors.getClassTypeColor(classInfo?.type.value ?? 'other');

    return CardContainer(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  (classInfo?.type.displayName ?? 'CLASS').toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: typeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  'CONFIRMED',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vGapSm,
          Text(
            classInfo?.name ?? 'Class',
            style: AppTypography.heading4,
          ),
          AppSpacing.vGapXs,
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14),
              const SizedBox(width: 4),
              Text(
                _formatDate(schedule.scheduledAt),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time, size: 14),
              const SizedBox(width: 4),
              Text(
                _formatTime(schedule.scheduledAt),
                style: AppTypography.bodySmall,
              ),
            ],
          ),
          AppSpacing.vGapMd,
          OutlinedButton(
            onPressed: () => _cancelBooking(booking.id),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _formatDate(DateTime dateTime) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }

  Future<void> _bookClass(String scheduleId) async {
    final authProvider = context.read<AuthProvider>();
    final classesProvider = context.read<ClassesProvider>();

    if (authProvider.user == null) return;

    // Find the schedule to get class details
    final schedule = classesProvider.schedules.firstWhere(
      (s) => s.id == scheduleId,
      orElse: () => throw Exception('Schedule not found'),
    );

    // Show booking dialog with reminder option
    final shouldSetReminder = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Class'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              'Book ${schedule.classInfo?.name ?? 'this class'}?',
              style: AppTypography.bodyLarge,
            ),
            AppSpacing.vGapMd,
            Row(
              children: [
                const Icon(Icons.notifications_active, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You\'ll receive a reminder 30 minutes before class',
                    style: AppTypography.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Book'),
        ),
      ],
    ),
  );

    if (shouldSetReminder != true) return;

    final success = await classesProvider.bookClass(
      userId: authProvider.user!.id,
      classScheduleId: scheduleId,
    );

    if (!mounted) return;

    if (success) {
      // Schedule reminder notification
      await NotificationService.instance.scheduleClassReminder(
        scheduleId,
        schedule.classInfo?.name ?? 'Your class',
        schedule.scheduledAt,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Class booked! You\'ll receive a reminder 30 minutes before.'),
          backgroundColor: AppColors.success,
        ),
      );
      // Reload schedules to update spots
      await _loadSchedulesForDay(_selectedDayIndex);
    } else {
      ErrorHandlerService().showErrorSnackBar(
        context,
        classesProvider.error ?? 'Failed to book class',
      );
      classesProvider.clearError();
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    final classesProvider = context.read<ClassesProvider>();

    // Find the booking to get schedule ID
    final booking = classesProvider.bookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => throw Exception('Booking not found'),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await classesProvider.cancelBooking(bookingId);

    if (!mounted) return;

    if (success) {
      // Cancel the reminder notification
      await NotificationService.instance.cancelClassReminder(booking.classScheduleId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled'),
        ),
      );
      // Reload schedules to update spots
      await _loadSchedulesForDay(_selectedDayIndex);
    } else {
      ErrorHandlerService().showErrorSnackBar(
        context,
        classesProvider.error ?? 'Failed to cancel booking',
      );
      classesProvider.clearError();
    }
  }
}
