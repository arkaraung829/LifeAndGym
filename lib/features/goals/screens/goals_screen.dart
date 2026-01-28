import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/card_container.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/goals_provider.dart';
import '../models/goal_model.dart';

/// Goals screen for tracking fitness goals.
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  int _selectedTabIndex = 0; // 0 = All, 1 = Active, 2 = Completed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGoals();
    });
  }

  Future<void> _loadGoals() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) return;

    final goalsProvider = context.read<GoalsProvider>();
    await goalsProvider.loadGoals(authProvider.user!.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGoalDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<GoalsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  AppSpacing.vGapMd,
                  Text(
                    provider.errorMessage ?? 'Failed to load goals',
                    style: AppTypography.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.vGapLg,
                  FilledButton.icon(
                    onPressed: _loadGoals,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredGoals = _getFilteredGoals(provider);

          if (provider.goals.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildFilterTabs(),
              Expanded(
                child: filteredGoals.isEmpty
                    ? _buildEmptyFilteredState()
                    : _buildGoalsList(filteredGoals),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
              'Set your first goal!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapLg,
            FilledButton.icon(
              onPressed: () => _showCreateGoalDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilteredState() {
    final message = _selectedTabIndex == 1
        ? 'No active goals'
        : _selectedTabIndex == 2
            ? 'No completed goals yet'
            : 'No goals';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          AppSpacing.vGapMd,
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment<int>(
            value: 0,
            label: Text('All'),
            icon: Icon(Icons.list),
          ),
          ButtonSegment<int>(
            value: 1,
            label: Text('Active'),
            icon: Icon(Icons.play_circle_outline),
          ),
          ButtonSegment<int>(
            value: 2,
            label: Text('Completed'),
            icon: Icon(Icons.check_circle_outline),
          ),
        ],
        selected: {_selectedTabIndex},
        onSelectionChanged: (Set<int> selection) {
          setState(() {
            _selectedTabIndex = selection.first;
          });
        },
      ),
    );
  }

  List<GoalModel> _getFilteredGoals(GoalsProvider provider) {
    switch (_selectedTabIndex) {
      case 1:
        return provider.activeGoals;
      case 2:
        return provider.completedGoals;
      default:
        return provider.goals;
    }
  }

  Widget _buildGoalsList(List<GoalModel> goals) {
    return RefreshIndicator(
      onRefresh: _loadGoals,
      child: ListView.builder(
        padding: AppSpacing.screenPadding,
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          return _buildGoalCard(goal);
        },
      ),
    );
  }

  Widget _buildGoalCard(GoalModel goal) {
    final isOverdue = goal.isOverdue;
    final daysRemaining = goal.daysRemaining;

    return CardContainer(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => _showGoalDetailDialog(goal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getGoalTypeColor(goal.type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getGoalTypeIcon(goal.type),
                  color: _getGoalTypeColor(goal.type),
                  size: 24,
                ),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatGoalType(goal.type),
                      style: AppTypography.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(goal.status),
            ],
          ),
          AppSpacing.vGapMd,

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${goal.currentValue.toStringAsFixed(1)} / ${goal.targetValue.toStringAsFixed(1)} ${goal.unit}',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${goal.progress.toStringAsFixed(0)}%',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getProgressColor(goal.progress),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: goal.progress / 100,
                  minHeight: 8,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(goal.progress),
                  ),
                ),
              ),
            ],
          ),

          AppSpacing.vGapMd,

          // Days remaining and actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isOverdue ? Icons.warning_amber_rounded : Icons.calendar_today,
                    size: 16,
                    color: isOverdue ? AppColors.error : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isOverdue
                        ? 'Overdue'
                        : daysRemaining == 0
                            ? 'Due today'
                            : daysRemaining == 1
                                ? '1 day left'
                                : '$daysRemaining days left',
                    style: AppTypography.bodySmall.copyWith(
                      color: isOverdue ? AppColors.error : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    iconSize: 20,
                    onPressed: () => _confirmDeleteGoal(goal),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(GoalStatus status) {
    Color color;
    String label;

    switch (status) {
      case GoalStatus.active:
        color = AppColors.success;
        label = 'Active';
        break;
      case GoalStatus.completed:
        color = AppColors.primary;
        label = 'Completed';
        break;
      case GoalStatus.abandoned:
        color = AppColors.error;
        label = 'Abandoned';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getGoalTypeColor(GoalType type) {
    switch (type) {
      case GoalType.weightLoss:
        return AppColors.error;
      case GoalType.muscleGain:
        return AppColors.success;
      case GoalType.strength:
        return AppColors.warning;
      case GoalType.endurance:
        return AppColors.info;
      case GoalType.flexibility:
        return AppColors.secondary;
      case GoalType.bodyFat:
        return AppColors.error;
      case GoalType.consistency:
        return AppColors.primary;
    }
  }

  IconData _getGoalTypeIcon(GoalType type) {
    switch (type) {
      case GoalType.weightLoss:
        return Icons.trending_down;
      case GoalType.muscleGain:
        return Icons.trending_up;
      case GoalType.strength:
        return Icons.fitness_center;
      case GoalType.endurance:
        return Icons.directions_run;
      case GoalType.flexibility:
        return Icons.self_improvement;
      case GoalType.bodyFat:
        return Icons.monitor_weight;
      case GoalType.consistency:
        return Icons.event_repeat;
    }
  }

  String _formatGoalType(GoalType type) {
    switch (type) {
      case GoalType.weightLoss:
        return 'Weight Loss';
      case GoalType.muscleGain:
        return 'Muscle Gain';
      case GoalType.strength:
        return 'Strength';
      case GoalType.endurance:
        return 'Endurance';
      case GoalType.flexibility:
        return 'Flexibility';
      case GoalType.bodyFat:
        return 'Body Fat';
      case GoalType.consistency:
        return 'Consistency';
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 100) return AppColors.success;
    if (progress >= 75) return AppColors.primary;
    if (progress >= 50) return AppColors.info;
    if (progress >= 25) return AppColors.warning;
    return AppColors.error;
  }

  Future<void> _showCreateGoalDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final targetValueController = TextEditingController();
    final currentValueController = TextEditingController(text: '0');
    final unitController = TextEditingController();

    GoalType selectedType = GoalType.weightLoss;
    DateTime? targetDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Goal'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Goal Name',
                      hintText: 'e.g., Lose 10kg',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a goal name';
                      }
                      return null;
                    },
                  ),
                  AppSpacing.vGapMd,

                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      hintText: 'Add details about your goal',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  AppSpacing.vGapMd,

                  DropdownButtonFormField<GoalType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Goal Type',
                      border: OutlineInputBorder(),
                    ),
                    items: GoalType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(_getGoalTypeIcon(type), size: 20),
                            const SizedBox(width: 8),
                            Text(_formatGoalType(type)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedType = value;
                        });
                      }
                    },
                  ),
                  AppSpacing.vGapMd,

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: targetValueController,
                          decoration: const InputDecoration(
                            labelText: 'Target Value',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            final number = double.tryParse(value);
                            if (number == null || number <= 0) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      AppSpacing.hGapSm,
                      Expanded(
                        child: TextFormField(
                          controller: currentValueController,
                          decoration: const InputDecoration(
                            labelText: 'Current Value',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            final number = double.tryParse(value);
                            if (number == null || number < 0) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vGapMd,

                  TextFormField(
                    controller: unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      hintText: 'e.g., kg, reps, minutes',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a unit';
                      }
                      return null;
                    },
                  ),
                  AppSpacing.vGapMd,

                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          targetDate = pickedDate;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Target Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        targetDate == null
                            ? 'Select target date'
                            : DateFormat('MMM dd, yyyy').format(targetDate!),
                        style: TextStyle(
                          color: targetDate == null
                              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (targetDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a target date')),
                  );
                  return;
                }

                final authProvider = context.read<AuthProvider>();
                if (authProvider.user == null) return;

                final goal = GoalModel(
                  id: '',
                  userId: authProvider.user!.id,
                  type: selectedType,
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  targetValue: double.parse(targetValueController.text),
                  currentValue: double.parse(currentValueController.text),
                  unit: unitController.text.trim(),
                  startDate: DateTime.now(),
                  targetDate: targetDate!,
                  status: GoalStatus.active,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                final goalsProvider = context.read<GoalsProvider>();
                await goalsProvider.createGoal(goal);

                if (!context.mounted) return;
                Navigator.of(context).pop();

                if (goalsProvider.hasError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(goalsProvider.errorMessage ?? 'Failed to create goal'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Goal created successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showGoalDetailDialog(GoalModel goal) async {
    final progressController = TextEditingController(
      text: goal.currentValue.toStringAsFixed(1),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getGoalTypeIcon(goal.type), color: _getGoalTypeColor(goal.type)),
            AppSpacing.hGapSm,
            Expanded(child: Text(goal.name)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              if (goal.description != null) ...[
                Text(
                  goal.description!,
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                AppSpacing.vGapMd,
              ],

              _buildDetailRow('Type', _formatGoalType(goal.type)),
              _buildDetailRow('Target', '${goal.targetValue} ${goal.unit}'),
              _buildDetailRow('Current', '${goal.currentValue} ${goal.unit}'),
              _buildDetailRow('Progress', '${goal.progress.toStringAsFixed(1)}%'),
              _buildDetailRow('Status', goal.status.name.toUpperCase()),
              _buildDetailRow('Start Date', DateFormat('MMM dd, yyyy').format(goal.startDate)),
              _buildDetailRow('Target Date', DateFormat('MMM dd, yyyy').format(goal.targetDate)),
              _buildDetailRow('Days Remaining', goal.isOverdue ? 'Overdue' : '${goal.daysRemaining} days'),

              AppSpacing.vGapLg,

              if (goal.status == GoalStatus.active) ...[
                const Divider(),
                AppSpacing.vGapMd,
                Text(
                  'Update Progress',
                  style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                AppSpacing.vGapSm,
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: progressController,
                        decoration: InputDecoration(
                          labelText: 'Current Value',
                          suffix: Text(goal.unit),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                      ),
                    ),
                    AppSpacing.hGapSm,
                    FilledButton(
                      onPressed: () async {
                        final value = double.tryParse(progressController.text);
                        if (value == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid value')),
                          );
                          return;
                        }

                        final goalsProvider = context.read<GoalsProvider>();
                        await goalsProvider.updateProgress(goal.id, value);

                        if (!context.mounted) return;
                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Progress updated!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (goal.status == GoalStatus.active)
          TextButton.icon(
            onPressed: () async {
              final goalsProvider = context.read<GoalsProvider>();
              await goalsProvider.updateStatus(goal.id, GoalStatus.completed);

              if (!context.mounted) return;
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Goal marked as completed!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Mark Complete'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteGoal(GoalModel goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final goalsProvider = context.read<GoalsProvider>();
      await goalsProvider.deleteGoal(goal.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal deleted'),
        ),
      );
    }
  }
}
