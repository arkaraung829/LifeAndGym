import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

/// Welcome screen for new/unauthenticated users.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Hero section
              _buildHeroSection(context),

              const Spacer(flex: 3),

              // Features
              _buildFeatures(context),

              const Spacer(flex: 2),

              // Action buttons
              _buildActionButtons(context),

              AppSpacing.vGapLg,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.fitness_center,
            size: 50,
            color: Colors.white,
          ),
        ),
        AppSpacing.vGapLg,

        // Title
        Text(
          'Welcome to LifeAndGym',
          style: AppTypography.heading1.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.vGapSm,

        // Subtitle
        Text(
          'Your all-in-one fitness companion',
          style: AppTypography.body.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatures(BuildContext context) {
    final features = [
      _FeatureItem(
        icon: Icons.qr_code,
        title: 'Digital Check-in',
        description: 'Access your gym with a tap',
      ),
      _FeatureItem(
        icon: Icons.calendar_month,
        title: 'Book Classes',
        description: 'Reserve your spot in classes',
      ),
      _FeatureItem(
        icon: Icons.fitness_center,
        title: 'Track Workouts',
        description: 'Log exercises and see progress',
      ),
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  feature.icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      feature.description,
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
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          text: 'Get Started',
          onPressed: () => context.push(RoutePaths.register),
        ),
        AppSpacing.vGapMd,
        SecondaryButton(
          text: 'I already have an account',
          onPressed: () => context.push(RoutePaths.login),
        ),
        AppSpacing.vGapMd,
        TextButton(
          onPressed: () async {
            final authProvider = context.read<AuthProvider>();
            await authProvider.continueAsGuest();
            if (context.mounted) {
              context.go(RoutePaths.home);
            }
          },
          child: Text(
            'Continue as Guest',
            style: AppTypography.body.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
