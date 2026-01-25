import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/card_container.dart';
import '../../../shared/widgets/primary_button.dart';
import '../models/exercise_model.dart';
import '../models/workout_session_model.dart';
import '../providers/workout_provider.dart';

/// Screen for tracking an active workout session.
class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isResting = false;
  int _restSecondsRemaining = 0;
  Timer? _restTimer;

  // Track sets for each exercise
  final Map<String, List<SetData>> _exerciseSets = {};
  final List<ExerciseModel> _selectedExercises = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWorkout();
    });
  }

  Future<void> _initializeWorkout() async {
    if (_isInitialized) return;

    final provider = context.read<WorkoutProvider>();
    final session = provider.activeSession;

    // Load exercises if not loaded
    if (provider.exercises.isEmpty) {
      await provider.loadExercises();
    }

    // If workout has predefined exercises, load them
    if (session?.workoutId != null) {
      await provider.selectWorkout(session!.workoutId!);
      for (final we in provider.workoutExercises) {
        if (we.exercise != null) {
          _selectedExercises.add(we.exercise!);
          _exerciseSets[we.exerciseId] = List.generate(
            we.sets,
            (i) => SetData(
              setNumber: i + 1,
              targetReps: we.reps,
              targetWeight: we.weight,
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsed += const Duration(seconds: 1);
        });
      }
    });
  }

  void _startRestTimer(int seconds) {
    setState(() {
      _isResting = true;
      _restSecondsRemaining = seconds;
    });

    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _restSecondsRemaining--;
          if (_restSecondsRemaining <= 0) {
            _isResting = false;
            timer.cancel();
          }
        });
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _restSecondsRemaining = 0;
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _logSet(String exerciseId, int setNumber, int reps, double? weight) async {
    final provider = context.read<WorkoutProvider>();
    final session = provider.activeSession;
    if (session == null) return;

    final success = await provider.logSet(
      sessionId: session.id,
      exerciseId: exerciseId,
      setNumber: setNumber,
      reps: reps,
      weight: weight,
    );

    if (success) {
      setState(() {
        final sets = _exerciseSets[exerciseId];
        if (sets != null && setNumber <= sets.length) {
          sets[setNumber - 1].isCompleted = true;
          sets[setNumber - 1].actualReps = reps;
          sets[setNumber - 1].actualWeight = weight;
        }
      });
      // Start rest timer
      _startRestTimer(90);
    }
  }

  Future<void> _addExercise() async {
    final provider = context.read<WorkoutProvider>();

    final exercise = await showModalBottomSheet<ExerciseModel>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ExerciseSelector(exercises: provider.exercises),
    );

    if (exercise != null) {
      setState(() {
        _selectedExercises.add(exercise);
        _exerciseSets[exercise.id] = List.generate(
          3,
          (i) => SetData(setNumber: i + 1),
        );
      });
    }
  }

  Future<void> _completeWorkout() async {
    final provider = context.read<WorkoutProvider>();
    final logs = provider.sessionLogs;

    if (logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log at least one set before finishing')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Workout'),
        content: Text('You logged ${logs.length} sets. Complete this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await provider.completeWorkoutSession();
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _cancelWorkout() async {
    final provider = context.read<WorkoutProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Workout'),
        content: const Text('Are you sure you want to cancel? All progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Going'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Cancel Workout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await provider.cancelWorkoutSession();
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        final session = provider.activeSession;
        final logs = provider.sessionLogs;

        if (session == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Workout')),
            body: const Center(child: Text('No active workout session')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(session.workout?.name ?? 'Quick Workout'),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _cancelWorkout,
              ),
            ],
          ),
          body: Column(
            children: [
              // Workout header with timer
              _buildWorkoutHeader(session, logs),

              // Rest timer overlay
              if (_isResting) _buildRestTimerOverlay(),

              // Exercise list
              Expanded(
                child: _selectedExercises.isEmpty
                    ? _buildEmptyState()
                    : _buildExerciseList(provider),
              ),

              // Bottom action bar
              _buildBottomBar(logs),
            ],
          ),
          floatingActionButton: !_isResting
              ? FloatingActionButton.extended(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildWorkoutHeader(WorkoutSessionModel session, List<WorkoutLogModel> logs) {
    final completedSets = logs.length;
    final totalSets = _exerciseSets.values.fold<int>(0, (sum, sets) => sum + sets.length);

    return Container(
      padding: AppSpacing.paddingMd,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.timer_outlined,
            label: 'Duration',
            value: _formatDuration(_elapsed),
          ),
          _buildStatItem(
            icon: Icons.fitness_center,
            label: 'Exercises',
            value: '${_selectedExercises.length}',
          ),
          _buildStatItem(
            icon: Icons.check_circle_outline,
            label: 'Sets',
            value: totalSets > 0 ? '$completedSets/$totalSets' : '$completedSets',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        AppSpacing.vGapSm,
        Text(
          value,
          style: AppTypography.heading3.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceDimDark,
          ),
        ),
      ],
    );
  }

  Widget _buildRestTimerOverlay() {
    return Container(
      padding: AppSpacing.paddingLg,
      color: AppColors.primary.withValues(alpha: 0.95),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Rest Time',
            style: AppTypography.heading3.copyWith(color: Colors.white),
          ),
          AppSpacing.vGapMd,
          Text(
            '$_restSecondsRemaining',
            style: AppTypography.displayLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vGapMd,
          TextButton(
            onPressed: _skipRest,
            child: Text(
              'Skip Rest',
              style: AppTypography.bodyLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            AppSpacing.vGapLg,
            Text(
              'No exercises yet',
              style: AppTypography.heading3,
            ),
            AppSpacing.vGapSm,
            Text(
              'Tap "Add Exercise" to start logging your workout',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onSurfaceDimDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseList(WorkoutProvider provider) {
    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: _selectedExercises.length,
      itemBuilder: (context, index) {
        final exercise = _selectedExercises[index];
        final sets = _exerciseSets[exercise.id] ?? [];
        return _ExerciseCard(
          exercise: exercise,
          sets: sets,
          onLogSet: (setNumber, reps, weight) {
            _logSet(exercise.id, setNumber, reps, weight);
          },
          onAddSet: () {
            setState(() {
              sets.add(SetData(setNumber: sets.length + 1));
            });
          },
          onRemoveExercise: () {
            setState(() {
              _selectedExercises.removeAt(index);
              _exerciseSets.remove(exercise.id);
            });
          },
        );
      },
    );
  }

  Widget _buildBottomBar(List<WorkoutLogModel> logs) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _cancelWorkout,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancel'),
              ),
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: PrimaryButton(
                text: 'Finish Workout',
                onPressed: logs.isNotEmpty ? _completeWorkout : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data class for tracking set information.
class SetData {
  final int setNumber;
  final int? targetReps;
  final double? targetWeight;
  int? actualReps;
  double? actualWeight;
  bool isCompleted;

  SetData({
    required this.setNumber,
    this.targetReps,
    this.targetWeight,
    this.actualReps,
    this.actualWeight,
    this.isCompleted = false,
  });
}

/// Card widget for displaying an exercise with its sets.
class _ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final List<SetData> sets;
  final Function(int setNumber, int reps, double? weight) onLogSet;
  final VoidCallback onAddSet;
  final VoidCallback onRemoveExercise;

  const _ExerciseCard({
    required this.exercise,
    required this.sets,
    required this.onLogSet,
    required this.onAddSet,
    required this.onRemoveExercise,
  });

  @override
  Widget build(BuildContext context) {
    final muscleColor = AppColors.getMuscleGroupColor(
      exercise.primaryMuscle,
    );

    return CardContainer(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: muscleColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: muscleColor,
                  size: 20,
                ),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      exercise.primaryMuscle,
                      style: AppTypography.caption.copyWith(
                        color: muscleColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onRemoveExercise,
                color: AppColors.error,
              ),
            ],
          ),

          AppSpacing.vGapMd,

          // Sets header
          Row(
            children: [
              const SizedBox(width: 40),
              Expanded(
                child: Text(
                  'SET',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceDimDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'REPS',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceDimDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'WEIGHT',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceDimDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),

          AppSpacing.vGapSm,

          // Sets list
          ...sets.map((set) => _SetRow(
                set: set,
                onLog: (reps, weight) => onLogSet(set.setNumber, reps, weight),
              )),

          // Add set button
          TextButton.icon(
            onPressed: onAddSet,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Set'),
          ),
        ],
      ),
    );
  }
}

/// Row widget for a single set.
class _SetRow extends StatefulWidget {
  final SetData set;
  final Function(int reps, double? weight) onLog;

  const _SetRow({
    required this.set,
    required this.onLog,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController _repsController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController(
      text: widget.set.actualReps?.toString() ??
          widget.set.targetReps?.toString() ??
          '10',
    );
    _weightController = TextEditingController(
      text: widget.set.actualWeight?.toString() ??
          widget.set.targetWeight?.toString() ??
          '',
    );
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Completion indicator
          Container(
            width: 40,
            alignment: Alignment.center,
            child: widget.set.isCompleted
                ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                : Icon(Icons.circle_outlined,
                    color: AppColors.onSurfaceDimDark.withValues(alpha: 0.3), size: 20),
          ),

          // Set number
          Expanded(
            child: Text(
              '${widget.set.setNumber}',
              style: AppTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),

          // Reps input
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _repsController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                enabled: !widget.set.isCompleted,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: widget.set.isCompleted,
                  fillColor: AppColors.surfaceVariantDark,
                ),
              ),
            ),
          ),

          AppSpacing.hGapSm,

          // Weight input
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                enabled: !widget.set.isCompleted,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'kg',
                  filled: widget.set.isCompleted,
                  fillColor: AppColors.surfaceVariantDark,
                ),
              ),
            ),
          ),

          // Log button
          SizedBox(
            width: 48,
            child: widget.set.isCompleted
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: () {
                      final reps = int.tryParse(_repsController.text) ?? 0;
                      final weight = double.tryParse(_weightController.text);
                      if (reps > 0) {
                        widget.onLog(reps, weight);
                      }
                    },
                    icon: const Icon(Icons.check, color: AppColors.success),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for selecting exercises.
class _ExerciseSelector extends StatefulWidget {
  final List<ExerciseModel> exercises;

  const _ExerciseSelector({required this.exercises});

  @override
  State<_ExerciseSelector> createState() => _ExerciseSelectorState();
}

class _ExerciseSelectorState extends State<_ExerciseSelector> {
  String _searchQuery = '';
  String? _selectedMuscle;

  final _muscles = ['All', 'Chest', 'Back', 'Shoulders', 'Biceps', 'Triceps', 'Legs', 'Core'];

  List<ExerciseModel> get _filteredExercises {
    var exercises = widget.exercises;

    if (_selectedMuscle != null && _selectedMuscle != 'All') {
      exercises = exercises.where((e) {
        return e.primaryMuscle.toLowerCase() == _selectedMuscle!.toLowerCase();
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      exercises = exercises.where((e) {
        return e.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return exercises;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceDimDark.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: AppSpacing.paddingHorizontalMd,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select Exercise', style: AppTypography.heading3),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Search
              Padding(
                padding: AppSpacing.paddingHorizontalMd,
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              AppSpacing.vGapMd,

              // Muscle filter
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: AppSpacing.paddingHorizontalMd,
                  itemCount: _muscles.length,
                  itemBuilder: (context, index) {
                    final muscle = _muscles[index];
                    final isSelected = _selectedMuscle == muscle ||
                        (muscle == 'All' && _selectedMuscle == null);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(muscle),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedMuscle = selected && muscle != 'All' ? muscle : null;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              AppSpacing.vGapMd,

              // Exercise list
              Expanded(
                child: _filteredExercises.isEmpty
                    ? Center(
                        child: Text(
                          'No exercises found',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.onSurfaceDimDark,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: AppSpacing.paddingHorizontalMd,
                        itemCount: _filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = _filteredExercises[index];
                          final muscleColor = AppColors.getMuscleGroupColor(
                            exercise.primaryMuscle,
                          );

                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: muscleColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.fitness_center,
                                color: muscleColor,
                                size: 20,
                              ),
                            ),
                            title: Text(exercise.name),
                            subtitle: Text(exercise.primaryMuscle),
                            onTap: () => Navigator.pop(context, exercise),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
