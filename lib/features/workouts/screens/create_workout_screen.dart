import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/card_container.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/exercise_model.dart';
import '../providers/workout_provider.dart';
import '../widgets/exercise_selector_widget.dart';

/// Screen for creating a new workout with a multi-step wizard.
class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int _currentStep = 0;
  final int _totalSteps = 4;

  // Step 1: Basic Info
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _category = 'Strength';
  double _estimatedDuration = 45;
  String _difficulty = 'Intermediate';

  // Step 2: Exercise Selection
  final Set<String> _selectedExerciseIds = {};
  final List<ExerciseModel> _selectedExercises = [];

  // Step 3: Exercise Configuration
  final Map<String, Map<String, dynamic>> _exerciseConfigs = {};

  static const List<String> categories = [
    'Strength',
    'Cardio',
    'Flexibility',
    'Mixed',
    'HIIT',
    'Yoga',
    'Pilates',
  ];

  static const List<String> difficulties = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  static const Map<String, int> restTimes = {
    '30s': 30,
    '60s': 60,
    '90s': 90,
    '2min': 120,
    '3min': 180,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workoutProvider = context.read<WorkoutProvider>();
      if (workoutProvider.exercises.isEmpty) {
        workoutProvider.loadExercises();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      // Validate current step before proceeding
      if (_validateStep(_currentStep)) {
        setState(() {
          _currentStep++;
        });
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToStep(int step) {
    if (step >= 0 && step < _totalSteps) {
      setState(() {
        _currentStep = step;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0: // Basic Info
        if (_formKey.currentState?.validate() ?? false) {
          _formKey.currentState?.save();
          return true;
        }
        return false;

      case 1: // Exercise Selection
        if (_selectedExercises.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select at least one exercise'),
            ),
          );
          return false;
        }
        // Initialize exercise configs with defaults
        for (var exercise in _selectedExercises) {
          if (!_exerciseConfigs.containsKey(exercise.id)) {
            _exerciseConfigs[exercise.id] = {
              'sets': 3,
              'reps': 10,
              'weight': 0.0,
              'restSeconds': 60,
              'notes': '',
            };
          }
        }
        return true;

      case 2: // Exercise Configuration
        // Validate all exercises have valid sets and reps
        for (var config in _exerciseConfigs.values) {
          if ((config['sets'] as int) <= 0 || (config['reps'] as int) <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sets and reps must be greater than 0'),
              ),
            );
            return false;
          }
        }
        return true;

      default:
        return true;
    }
  }

  Future<void> _saveWorkout() async {
    final authProvider = context.read<AuthProvider>();
    final workoutProvider = context.read<WorkoutProvider>();

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to create a workout'),
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Create workout
      final workout = await workoutProvider.createWorkout(
        userId: authProvider.user!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _category,
        estimatedDuration: _estimatedDuration.toInt(),
        difficulty: _difficulty,
        targetMuscles: _selectedExercises
            .expand((e) => e.muscleGroups)
            .toSet()
            .toList(),
      );

      if (workout == null) {
        throw Exception('Failed to create workout');
      }

      // Add exercises to workout
      int orderIndex = 0;
      for (var exercise in _selectedExercises) {
        final config = _exerciseConfigs[exercise.id]!;
        final success = await workoutProvider.addExerciseToWorkout(
          workoutId: workout.id,
          exerciseId: exercise.id,
          orderIndex: orderIndex++,
          sets: config['sets'] as int,
          reps: config['reps'] as int,
          weight: (config['weight'] as double) > 0
              ? config['weight'] as double
              : null,
          restSeconds: config['restSeconds'] as int,
          notes: (config['notes'] as String).isEmpty
              ? null
              : config['notes'] as String,
        );

        if (!success) {
          throw Exception('Failed to add exercise to workout');
        }
      }

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate back to workouts screen
      context.pop();
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create workout: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workout'),
        actions: [
          if (_currentStep < _totalSteps - 1)
            TextButton(
              onPressed: _nextStep,
              child: const Text('Next'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBasicInfoStep(),
                _buildExerciseSelectionStep(),
                _buildExerciseConfigurationStep(),
                _buildReviewStep(),
              ],
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              final isActive = index == _currentStep;
              final isCompleted = index < _currentStep;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          AppSpacing.vGapSm,
          Text(
            'Step ${_currentStep + 1} of $_totalSteps',
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: AppSpacing.screenPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) AppSpacing.hGapMd,
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentStep == _totalSteps - 1
                  ? _saveWorkout
                  : _nextStep,
              child: Text(
                _currentStep == _totalSteps - 1 ? 'Save Workout' : 'Next',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step 1: Basic Info
  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: AppTypography.heading3,
            ),
            AppSpacing.vGapMd,

            // Workout name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Workout Name',
                hintText: 'e.g. Upper Body Strength',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a workout name';
                }
                return null;
              },
            ),
            AppSpacing.vGapMd,

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Describe your workout...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            AppSpacing.vGapMd,

            // Category
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                  });
                }
              },
            ),
            AppSpacing.vGapMd,

            // Estimated duration
            Text(
              'Estimated Duration: ${_estimatedDuration.toInt()} minutes',
              style: AppTypography.bodyLarge,
            ),
            Slider(
              value: _estimatedDuration,
              min: 15,
              max: 180,
              divisions: 33,
              label: '${_estimatedDuration.toInt()} min',
              onChanged: (value) {
                setState(() {
                  _estimatedDuration = value;
                });
              },
            ),
            AppSpacing.vGapMd,

            // Difficulty
            Text(
              'Difficulty',
              style: AppTypography.bodyLarge,
            ),
            AppSpacing.vGapSm,
            Row(
              children: difficulties.map((difficulty) {
                return Expanded(
                  child: RadioListTile<String>(
                    value: difficulty,
                    groupValue: _difficulty,
                    title: Text(
                      difficulty,
                      style: const TextStyle(fontSize: 12),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _difficulty = value;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Step 2: Exercise Selection
  Widget _buildExerciseSelectionStep() {
    final workoutProvider = context.watch<WorkoutProvider>();

    return Column(
      children: [
        // Selected exercises header
        if (_selectedExercises.isNotEmpty)
          Container(
            padding: AppSpacing.screenPadding,
            color: AppColors.primary.withValues(alpha: 0.05),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success),
                AppSpacing.hGapSm,
                Text(
                  '${_selectedExercises.length} exercise(s) selected',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedExercises.clear();
                      _selectedExerciseIds.clear();
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),

        // Exercise selector
        Expanded(
          child: ExerciseSelectorWidget(
            exercises: workoutProvider.exercises,
            selectedExerciseIds: _selectedExerciseIds,
            isLoading: workoutProvider.isLoading,
            onExerciseSelected: (exercise) {
              setState(() {
                if (!_selectedExerciseIds.contains(exercise.id)) {
                  _selectedExercises.add(exercise);
                  _selectedExerciseIds.add(exercise.id);
                }
              });
            },
          ),
        ),

        // Selected exercises list
        if (_selectedExercises.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ListView.builder(
              padding: AppSpacing.screenPadding,
              itemCount: _selectedExercises.length,
              itemBuilder: (context, index) {
                final exercise = _selectedExercises[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Text(
                    exercise.typeEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  title: Text(
                    exercise.name,
                    style: AppTypography.body,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedExercises.removeAt(index);
                        _selectedExerciseIds.remove(exercise.id);
                        _exerciseConfigs.remove(exercise.id);
                      });
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // Step 3: Exercise Configuration
  Widget _buildExerciseConfigurationStep() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configure Exercises',
            style: AppTypography.heading3,
          ),
          AppSpacing.vGapMd,

          // Exercise configuration cards
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedExercises.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final exercise = _selectedExercises.removeAt(oldIndex);
                _selectedExercises.insert(newIndex, exercise);
              });
            },
            itemBuilder: (context, index) {
              final exercise = _selectedExercises[index];
              final config = _exerciseConfigs[exercise.id]!;

              return CardContainer(
                key: ValueKey(exercise.id),
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise header
                    Row(
                      children: [
                        Icon(
                          Icons.drag_handle,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                        ),
                        AppSpacing.hGapSm,
                        Text(
                          exercise.typeEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        AppSpacing.hGapSm,
                        Expanded(
                          child: Text(
                            exercise.name,
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGapMd,

                    // Sets and Reps
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: config['sets'].toString(),
                            decoration: const InputDecoration(
                              labelText: 'Sets',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              config['sets'] = int.tryParse(value) ?? 3;
                            },
                          ),
                        ),
                        AppSpacing.hGapMd,
                        Expanded(
                          child: TextFormField(
                            initialValue: config['reps'].toString(),
                            decoration: const InputDecoration(
                              labelText: 'Reps',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              config['reps'] = int.tryParse(value) ?? 10;
                            },
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGapSm,

                    // Weight and Rest
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: config['weight'].toString(),
                            decoration: const InputDecoration(
                              labelText: 'Weight (kg)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            onChanged: (value) {
                              config['weight'] = double.tryParse(value) ?? 0.0;
                            },
                          ),
                        ),
                        AppSpacing.hGapMd,
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: config['restSeconds'],
                            decoration: const InputDecoration(
                              labelText: 'Rest',
                              border: OutlineInputBorder(),
                            ),
                            items: restTimes.entries.map((entry) {
                              return DropdownMenuItem(
                                value: entry.value,
                                child: Text(entry.key),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                config['restSeconds'] = value;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGapSm,

                    // Notes
                    TextFormField(
                      initialValue: config['notes'],
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        config['notes'] = value;
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Step 4: Review
  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Save',
            style: AppTypography.heading3,
          ),
          AppSpacing.vGapMd,

          // Basic info card
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Workout Details',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _goToStep(0),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                AppSpacing.vGapSm,
                _buildInfoRow('Name', _nameController.text),
                if (_descriptionController.text.isNotEmpty)
                  _buildInfoRow('Description', _descriptionController.text),
                _buildInfoRow('Category', _category),
                _buildInfoRow('Duration', '${_estimatedDuration.toInt()} min'),
                _buildInfoRow('Difficulty', _difficulty),
              ],
            ),
          ),
          AppSpacing.vGapMd,

          // Exercises card
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Exercises (${_selectedExercises.length})',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _goToStep(2),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                AppSpacing.vGapSm,
                ...List.generate(_selectedExercises.length, (index) {
                  final exercise = _selectedExercises[index];
                  final config = _exerciseConfigs[exercise.id]!;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}.',
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        AppSpacing.hGapSm,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${config['sets']} sets × ${config['reps']} reps${config['weight'] > 0 ? ' @ ${config['weight']}kg' : ''} • ${restTimes.entries.firstWhere((e) => e.value == config['restSeconds']).key} rest',
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
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          AppSpacing.vGapMd,

          // Total time estimate
          CardContainer(
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.primary),
                AppSpacing.hGapMd,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Estimated Time',
                      style: AppTypography.bodySmall.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      '${_estimatedDuration.toInt()} minutes',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTypography.body.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
