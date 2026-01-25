import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../../../core/services/error_handler_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/providers/auth_provider.dart';

/// Onboarding screen for new users.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Onboarding data
  String? _selectedFitnessLevel;
  final List<String> _selectedGoals = [];

  final _fitnessLevels = [
    {'id': 'beginner', 'title': 'Beginner', 'icon': Icons.emoji_people, 'description': 'New to working out'},
    {'id': 'intermediate', 'title': 'Intermediate', 'icon': Icons.directions_run, 'description': 'Work out regularly'},
    {'id': 'advanced', 'title': 'Advanced', 'icon': Icons.fitness_center, 'description': 'Experienced athlete'},
  ];

  final _fitnessGoals = [
    {'id': 'weight_loss', 'title': 'Lose Weight', 'icon': Icons.monitor_weight},
    {'id': 'muscle_gain', 'title': 'Build Muscle', 'icon': Icons.fitness_center},
    {'id': 'endurance', 'title': 'Improve Endurance', 'icon': Icons.directions_run},
    {'id': 'flexibility', 'title': 'Increase Flexibility', 'icon': Icons.self_improvement},
    {'id': 'strength', 'title': 'Get Stronger', 'icon': Icons.sports_gymnastics},
    {'id': 'general_fitness', 'title': 'General Fitness', 'icon': Icons.favorite},
  ];

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    if (_selectedFitnessLevel == null || _selectedGoals.isEmpty) {
      ErrorHandlerService().showErrorSnackBar(
        context,
        'Please complete all selections',
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.completeOnboarding(
      fitnessLevel: _selectedFitnessLevel!,
      fitnessGoals: _selectedGoals,
    );

    if (!mounted) return;

    if (success) {
      context.go(RoutePaths.home);
    } else {
      ErrorHandlerService().showErrorSnackBar(
        context,
        authProvider.error ?? 'Failed to complete onboarding',
      );
      authProvider.clearError();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: AppSpacing.screenPadding,
              child: Row(
                children: List.generate(2, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 1 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppColors.primary
                            : AppColors.surfaceVariantDark,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildFitnessLevelPage(),
                  _buildGoalsPage(),
                ],
              ),
            ),

            // Bottom buttons
            Padding(
              padding: AppSpacing.screenPadding,
              child: PrimaryButton(
                text: _currentPage < 1 ? 'Continue' : 'Get Started',
                onPressed: _canProceed() ? _nextPage : null,
                isEnabled: _canProceed(),
              ),
            ),
            AppSpacing.vGapMd,
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    if (_currentPage == 0) {
      return _selectedFitnessLevel != null;
    }
    return _selectedGoals.isNotEmpty;
  }

  Widget _buildFitnessLevelPage() {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.vGapLg,
          Text(
            "What's your fitness level?",
            style: AppTypography.heading1,
          ),
          AppSpacing.vGapSm,
          Text(
            "We'll personalize your experience based on this",
            style: AppTypography.body.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          AppSpacing.vGapXxl,
          ...(_fitnessLevels.map((level) => _buildLevelOption(level))),
        ],
      ),
    );
  }

  Widget _buildLevelOption(Map<String, dynamic> level) {
    final isSelected = _selectedFitnessLevel == level['id'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFitnessLevel = level['id'] as String;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Theme.of(context).colorScheme.surface,
          borderRadius: AppSpacing.borderRadiusLg,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                level['icon'] as IconData,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 28,
              ),
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level['title'] as String,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    level['description'] as String,
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
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsPage() {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.vGapLg,
          Text(
            'What are your goals?',
            style: AppTypography.heading1,
          ),
          AppSpacing.vGapSm,
          Text(
            'Select all that apply',
            style: AppTypography.body.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          AppSpacing.vGapXxl,
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _fitnessGoals.map((goal) => _buildGoalChip(goal)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalChip(Map<String, dynamic> goal) {
    final isSelected = _selectedGoals.contains(goal['id']);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedGoals.remove(goal['id']);
          } else {
            _selectedGoals.add(goal['id'] as String);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Theme.of(context).colorScheme.surface,
          borderRadius: AppSpacing.borderRadiusFull,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              goal['icon'] as IconData,
              size: 20,
              color: isSelected
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              goal['title'] as String,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
