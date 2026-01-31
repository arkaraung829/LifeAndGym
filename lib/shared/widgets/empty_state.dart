import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
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

  static Widget noWorkouts(BuildContext context, {VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.fitness_center,
      title: context.l10n.noWorkoutsYetTitle,
      description: context.l10n.startFitnessJourney,
      actionText: context.l10n.startWorkout,
      onAction: onAction,
    );
  }

  static Widget noClasses(BuildContext context, {VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.event_busy,
      title: context.l10n.noClassesAvailable,
      description: context.l10n.checkBackLater,
      actionText: context.l10n.refresh,
      onAction: onAction,
    );
  }

  static Widget noBookings(BuildContext context, {VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.calendar_today,
      title: context.l10n.noBookings,
      description: context.l10n.noBookingsYet,
      actionText: context.l10n.browseClasses,
      onAction: onAction,
    );
  }

  static Widget noExercises(BuildContext context, {VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.search_off,
      title: context.l10n.noExercisesFound,
      description: context.l10n.tryAdjustingFilters,
      actionText: context.l10n.clearFilters,
      onAction: onAction,
    );
  }

  static Widget noNotifications(BuildContext context) {
    return EmptyState(
      icon: Icons.notifications_off,
      title: context.l10n.noNotifications,
      description: context.l10n.youreAllCaughtUp,
    );
  }

  static Widget noSearchResults(BuildContext context, {VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.search_off,
      title: context.l10n.noResultsFound,
      description: context.l10n.tryDifferentKeywords,
      actionText: context.l10n.clearSearch,
      onAction: onAction,
    );
  }
}
