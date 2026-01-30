import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/router/route_names.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Banner shown to guest users prompting them to sign up.
class GuestModeBanner extends StatelessWidget {
  final String? message;
  final bool showDismiss;

  const GuestModeBanner({
    super.key,
    this.message,
    this.showDismiss = true,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Only show for guest users
    if (!authProvider.isGuest) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: AppSpacing.paddingMd,
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primaryLight.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 24,
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guest Mode',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                AppSpacing.vGapXs,
                Text(
                  message ??
                      'Sign up to unlock check-ins, class bookings, and progress tracking',
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hGapMd,
          TextButton(
            onPressed: () async {
              await authProvider.exitGuestMode();
              if (context.mounted) {
                context.go(RoutePaths.register);
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(context.l10n.signUp),
          ),
        ],
      ),
    );
  }
}

/// Compact guest mode indicator for app bar.
class GuestModeIndicator extends StatelessWidget {
  const GuestModeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isGuest) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_outlined,
            size: 14,
            color: AppColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            'Guest',
            style: AppTypography.caption.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen guest prompt for restricted features.
class GuestModePrompt extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const GuestModePrompt({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.lock_outline,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.vGapLg,
            Text(
              title,
              style: AppTypography.heading3,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapSm,
            Text(
              message,
              style: AppTypography.body.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapXl,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await authProvider.exitGuestMode();
                  if (context.mounted) {
                    context.go(RoutePaths.register);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Create Account'),
              ),
            ),
            AppSpacing.vGapMd,
            TextButton(
              onPressed: () async {
                await authProvider.exitGuestMode();
                if (context.mounted) {
                  context.go(RoutePaths.login);
                }
              },
              child: Text(
                'I already have an account',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
