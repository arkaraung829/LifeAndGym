import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/card_container.dart';
import '../../../shared/widgets/empty_state.dart';

/// Workouts screen placeholder.
class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Create workout
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              tabs: const [
                Tab(text: 'My Workouts'),
                Tab(text: 'Templates'),
                Tab(text: 'History'),
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
    return EmptyStates.noWorkouts(
      onAction: () {
        // TODO: Start workout
      },
    );
  }

  Widget _buildTemplatesTab(BuildContext context) {
    final templates = [
      {'name': 'Full Body Strength', 'exercises': 8, 'duration': '45 min'},
      {'name': 'Upper Body', 'exercises': 6, 'duration': '40 min'},
      {'name': 'Lower Body', 'exercises': 7, 'duration': '45 min'},
      {'name': 'Push Day', 'exercises': 5, 'duration': '35 min'},
      {'name': 'Pull Day', 'exercises': 5, 'duration': '35 min'},
    ];

    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return CardContainer(
          margin: const EdgeInsets.only(bottom: 12),
          onTap: () {
            // TODO: View template
          },
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template['name'] as String,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${template['exercises']} exercises • ${template['duration']}',
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
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    return const Center(
      child: Text('Workout history will appear here'),
    );
  }
}
