import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../models/exercise_model.dart';
import '../providers/workout_provider.dart';

/// Screen for browsing the exercise library.
class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilter;

  final List<String> _muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Legs',
    'Core',
    'Glutes',
    'Cardio',
  ];

  final List<String> _exerciseTypes = [
    'Strength',
    'Cardio',
    'Flexibility',
    'Balance',
    'Plyometrics',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().loadExercises();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<WorkoutProvider>().searchExercises(query);
  }

  void _filterByMuscleGroup(String? muscleGroup) {
    setState(() {
      _selectedFilter = muscleGroup;
    });
    context.read<WorkoutProvider>().filterByMuscleGroup(muscleGroup);
  }

  void _clearFilters() {
    setState(() {
      _selectedFilter = null;
    });
    _searchController.clear();
    context.read<WorkoutProvider>().clearExerciseFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        actions: [
          if (_selectedFilter != null || _searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilters,
              tooltip: 'Clear filters',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: AppSpacing.paddingMd,
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
                          _onSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearch,
            ),
          ),

          // Muscle group filters
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.paddingHorizontalMd,
              itemCount: _muscleGroups.length,
              itemBuilder: (context, index) {
                final muscleGroup = _muscleGroups[index];
                final isSelected = _selectedFilter == muscleGroup;

                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(muscleGroup),
                    selected: isSelected,
                    onSelected: (selected) {
                      _filterByMuscleGroup(selected ? muscleGroup : null);
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(),

          // Exercise list
          Expanded(
            child: Consumer<WorkoutProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
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
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          provider.errorMessage ?? 'Failed to load exercises',
                          style: AppTypography.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        FilledButton(
                          onPressed: () => provider.loadExercises(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final exercises = provider.filteredExercises;

                if (exercises.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: AppColors.onSurfaceDimDark,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No exercises found',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.onSurfaceDimDark,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: AppSpacing.paddingMd,
                  itemCount: exercises.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return _ExerciseCard(exercise: exercise);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;

  const _ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _showExerciseDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            children: [
              // Exercise type emoji
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    exercise.typeEmoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Exercise info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: AppTypography.heading4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      exercise.primaryMuscle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        _buildBadge(exercise.difficulty),
                        const SizedBox(width: AppSpacing.sm),
                        _buildBadge(exercise.equipmentList),
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron
              Icon(
                Icons.chevron_right,
                color: AppColors.onSurfaceDimDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          fontSize: 10,
        ),
      ),
    );
  }

  void _showExerciseDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ExerciseDetailsSheet(exercise: exercise),
    );
  }
}

class _ExerciseDetailsSheet extends StatelessWidget {
  final ExerciseModel exercise;

  const _ExerciseDetailsSheet({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: AppSpacing.paddingLg,
          child: ListView(
            controller: scrollController,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    exercise.typeEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: AppTypography.heading3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Details
              if (exercise.description != null) ...[
                _buildSectionTitle('Description'),
                Text(
                  exercise.description!,
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              _buildSectionTitle('Muscle Groups'),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: exercise.muscleGroups
                    .map((muscle) => Chip(label: Text(muscle)))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildSectionTitle('Equipment'),
              Text(
                exercise.equipmentList,
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.lg),

              if (exercise.instructions != null &&
                  exercise.instructions!.isNotEmpty) ...[
                _buildSectionTitle('Instructions'),
                ...exercise.instructions!.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: AppTypography.body,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.heading4.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
