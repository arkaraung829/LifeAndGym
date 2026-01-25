import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import 'primary_button.dart';

/// Empty state widget for when there's no content to display.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            AppSpacing.vGapLg,
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              AppSpacing.vGapSm,
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              AppSpacing.vGapLg,
              PrimaryButton(
                text: actionText!,
                onPressed: onAction,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Common empty states.
class EmptyStates {
  EmptyStates._();

  static Widget noWorkouts({VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.fitness_center,
      title: 'No Workouts Yet',
      description: 'Start your fitness journey by logging your first workout.',
      actionText: 'Start Workout',
      onAction: onAction,
    );
  }

  static Widget noClasses({VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.event_busy,
      title: 'No Classes Available',
      description: 'Check back later for upcoming classes.',
      actionText: 'Refresh',
      onAction: onAction,
    );
  }

  static Widget noBookings({VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.calendar_today,
      title: 'No Bookings',
      description: 'You haven\'t booked any classes yet.',
      actionText: 'Browse Classes',
      onAction: onAction,
    );
  }

  static Widget noExercises({VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Exercises Found',
      description: 'Try adjusting your search or filters.',
      actionText: 'Clear Filters',
      onAction: onAction,
    );
  }

  static Widget noNotifications() {
    return const EmptyState(
      icon: Icons.notifications_off,
      title: 'No Notifications',
      description: 'You\'re all caught up!',
    );
  }

  static Widget noSearchResults({VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      description: 'Try different keywords or filters.',
      actionText: 'Clear Search',
      onAction: onAction,
    );
  }
}
