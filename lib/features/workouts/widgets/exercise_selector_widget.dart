import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_colors.dart';
import '../models/exercise_model.dart';

/// Widget for selecting exercises from the exercise library.
class ExerciseSelectorWidget extends StatefulWidget {
  final List<ExerciseModel> exercises;
  final Set<String> selectedExerciseIds;
  final Function(ExerciseModel) onExerciseSelected;
  final bool isLoading;

  const ExerciseSelectorWidget({
    super.key,
    required this.exercises,
    required this.selectedExerciseIds,
    required this.onExerciseSelected,
    this.isLoading = false,
  });

  @override
  State<ExerciseSelectorWidget> createState() => _ExerciseSelectorWidgetState();
}

class _ExerciseSelectorWidgetState extends State<ExerciseSelectorWidget> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedMuscleGroup;
  List<ExerciseModel> _filteredExercises = [];

  // Common muscle groups for filtering
  static const List<String> muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Legs',
    'Core',
    'Glutes',
    'Cardio',
  ];

  @override
  void initState() {
    super.initState();
    _filteredExercises = widget.exercises;
    _searchController.addListener(_filterExercises);
  }

  @override
  void didUpdateWidget(ExerciseSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercises != widget.exercises) {
      _filterExercises();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterExercises() {
    setState(() {
      _filteredExercises = widget.exercises.where((exercise) {
        // Filter by search query
        final query = _searchController.text.toLowerCase();
        final matchesSearch = query.isEmpty ||
            exercise.name.toLowerCase().contains(query) ||
            exercise.description?.toLowerCase().contains(query) == true;

        // Filter by muscle group
        final matchesMuscleGroup = _selectedMuscleGroup == null ||
            exercise.muscleGroups.any((muscle) =>
                muscle.toLowerCase().contains(_selectedMuscleGroup!.toLowerCase()));

        return matchesSearch && matchesMuscleGroup;
      }).toList();
    });
  }

  void _selectMuscleGroup(String? muscleGroup) {
    setState(() {
      _selectedMuscleGroup =
          _selectedMuscleGroup == muscleGroup ? null : muscleGroup;
      _filterExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: AppSpacing.screenPadding,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search exercises...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // Muscle group filter chips
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.screenPadding,
            itemCount: muscleGroups.length,
            separatorBuilder: (context, index) => AppSpacing.hGapSm,
            itemBuilder: (context, index) {
              final muscleGroup = muscleGroups[index];
              final isSelected = _selectedMuscleGroup == muscleGroup;
              return FilterChip(
                label: Text(muscleGroup),
                selected: isSelected,
                onSelected: (_) => _selectMuscleGroup(muscleGroup),
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
              );
            },
          ),
        ),

        AppSpacing.vGapMd,

        // Exercise list
        Expanded(
          child: widget.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredExercises.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3),
                          ),
                          AppSpacing.vGapMd,
                          Text(
                            'No exercises found',
                            style: AppTypography.bodyLarge.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty ||
                              _selectedMuscleGroup != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _selectMuscleGroup(null);
                                },
                                child: const Text('Clear filters'),
                              ),
                            ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: AppSpacing.screenPadding,
                      itemCount: _filteredExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _filteredExercises[index];
                        final isSelected =
                            widget.selectedExerciseIds.contains(exercise.id);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  exercise.typeEmoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            title: Text(
                              exercise.name,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppSpacing.vGapXs,
                                Text(
                                  exercise.muscleGroups.join(', '),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                if (exercise.equipment != null &&
                                    exercise.equipment!.isNotEmpty)
                                  Text(
                                    'Equipment: ${exercise.equipment!.join(', ')}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.5),
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () =>
                                        widget.onExerciseSelected(exercise),
                                  ),
                            onTap: isSelected
                                ? null
                                : () => widget.onExerciseSelected(exercise),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
