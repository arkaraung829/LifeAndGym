import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/card_container.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/booking_model.dart';
import '../providers/classes_provider.dart';

/// My Bookings screen showing user's class bookings.
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  Future<void> _loadBookings() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      await context.read<ClassesProvider>().loadBookings(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final classesProvider = context.watch<ClassesProvider>();
    final bookings = classesProvider.bookings;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myBookings),
      ),
      body: classesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? EmptyStates.noBookings(context)
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.separated(
                    padding: AppSpacing.screenPadding,
                    itemCount: bookings.length,
                    separatorBuilder: (context, index) => AppSpacing.vGapMd,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      final schedule = booking.schedule;
                      final isConfirmed = booking.status == BookingStatus.confirmed;
                      final isCancelled = booking.status == BookingStatus.cancelled;

                      // Enable swipe-to-cancel only for confirmed bookings
                      if (isConfirmed) {
                        return Dismissible(
                          key: Key(booking.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            HapticFeedback.mediumImpact();
                            return await _confirmCancelBooking(context);
                          },
                          onDismissed: (direction) async {
                            HapticFeedback.heavyImpact();
                            await _performCancelBooking(context, booking.id);
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete_outline, color: Colors.white, size: 32),
                                SizedBox(height: 4),
                                Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          child: _buildBookingCard(context, booking, schedule, isConfirmed, isCancelled),
                        );
                      }

                      return _buildBookingCard(context, booking, schedule, isConfirmed, isCancelled);
                    },
                  ),
                ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking, schedule, bool isConfirmed, bool isCancelled) {
    final statusColor = isConfirmed
        ? AppColors.success
        : isCancelled
            ? AppColors.error
            : AppColors.warning;

    final statusIcon = isConfirmed
        ? Icons.check_circle
        : isCancelled
            ? Icons.cancel
            : Icons.access_time;

    return CardContainer(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 28,
                ),
              ),
              AppSpacing.hGapMd,

              // Class info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule?.classInfo?.name ?? 'Class',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.vGapXs,
                    if (schedule?.scheduledAt != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatDate(schedule!.scheduledAt)} at ${_formatTime(schedule.scheduledAt)}',
                            style: AppTypography.bodySmall.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    AppSpacing.vGapXs,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        booking.status.displayName.toUpperCase(),
                        style: AppTypography.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Cancel button for confirmed bookings
              if (isConfirmed)
                IconButton(
                  icon: const Icon(Icons.close),
                  color: AppColors.error,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _cancelBooking(context, booking.id);
                  },
                  tooltip: 'Cancel booking',
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  Future<bool> _confirmCancelBooking(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.cancelBooking),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.no),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(context.l10n.yes),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _performCancelBooking(BuildContext context, String bookingId) async {
    final classesProvider = context.read<ClassesProvider>();
    final authProvider = context.read<AuthProvider>();

    final success = await classesProvider.cancelBooking(bookingId);

    if (!context.mounted) return;

    if (success) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Booking cancelled successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Reload bookings
      if (authProvider.user != null) {
        await classesProvider.loadBookings(authProvider.user!.id);
      }
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(classesProvider.error ?? 'Failed to cancel booking'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      classesProvider.clearError();
      // Reload bookings to restore the dismissed card
      if (authProvider.user != null) {
        await classesProvider.loadBookings(authProvider.user!.id);
      }
    }
  }

  Future<void> _cancelBooking(BuildContext context, String bookingId) async {
    final confirmed = await _confirmCancelBooking(context);
    if (!confirmed || !context.mounted) return;

    await _performCancelBooking(context, bookingId);
  }
}
