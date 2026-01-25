import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/guest_mode_banner.dart';

/// Goals screen for tracking fitness goals.
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Add goal
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flag_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
              AppSpacing.vGapLg,
              Text(
                'No Goals Yet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              AppSpacing.vGapMd,
              Text(
                'Set your fitness goals and track your progress',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGapLg,
              FilledButton.icon(
                onPressed: () {
                  // TODO: Add goal
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Goal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
