import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';

/// Body metrics screen for tracking measurements.
class BodyMetricsScreen extends StatelessWidget {
  const BodyMetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Metrics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Add metrics
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
                Icons.monitor_weight_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
              AppSpacing.vGapLg,
              Text(
                'No Metrics Logged',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              AppSpacing.vGapMd,
              Text(
                'Track your weight, body fat, and measurements',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGapLg,
              FilledButton.icon(
                onPressed: () {
                  // TODO: Add metrics
                },
                icon: const Icon(Icons.add),
                label: const Text('Log Your First Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
