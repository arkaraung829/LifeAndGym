import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
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
              ? Center(
                  child: Padding(
                    padding: AppSpacing.screenPadding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        AppSpacing.vGapLg,
                        Text(
                          'No Bookings',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        AppSpacing.vGapMd,
                        Text(
                          'Book a class to get started',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.separated(
                    padding: AppSpacing.screenPadding,
                    itemCount: bookings.length,
                    separatorBuilder: (context, index) => AppSpacing.vGapSm,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      final schedule = booking.schedule;

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            child: Icon(
                              booking.status == BookingStatus.confirmed
                                  ? Icons.check_circle
                                  : booking.status == BookingStatus.cancelled
                                      ? Icons.cancel
                                      : Icons.access_time,
                            ),
                          ),
                          title: Text(schedule?.classInfo?.name ?? 'Class'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppSpacing.vGapXs,
                              if (schedule?.scheduledAt != null)
                                Text(
                                  '${_formatDate(schedule!.scheduledAt)} at ${_formatTime(schedule.scheduledAt)}',
                                ),
                              AppSpacing.vGapXs,
                              Chip(
                                label: Text(
                                  booking.status.displayName.toUpperCase(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          trailing: booking.status == BookingStatus.confirmed
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    // TODO: Cancel booking
                                  },
                                )
                              : null,
                        ),
                      );
                    },
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
}
