import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/card_container.dart';

/// About screen showing app information.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.about),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppSpacing.vGapLg,

            // App Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 50,
                color: Colors.white,
              ),
            ),

            AppSpacing.vGapMd,

            // App Name
            Text(
              l10n.appName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            AppSpacing.vGapSm,

            // Version
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),

            AppSpacing.vGapLg,

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Your complete fitness companion for tracking workouts, booking classes, and achieving your health goals.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),

            AppSpacing.vGapXl,

            // Links
            ListTileCard(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: l10n.privacyPolicy,
              onTap: () {
                // TODO: Open privacy policy
              },
            ),

            AppSpacing.vGapSm,

            ListTileCard(
              leading: const Icon(Icons.description_outlined),
              title: l10n.termsOfService,
              onTap: () {
                // TODO: Open terms
              },
            ),

            AppSpacing.vGapSm,

            ListTileCard(
              leading: const Icon(Icons.open_in_new),
              title: 'Visit Our Website',
              onTap: () {
                // TODO: Open website
              },
            ),

            AppSpacing.vGapXl,

            // Copyright
            Text(
              '© 2026 Life & Gym. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),

            AppSpacing.vGapMd,
          ],
        ),
      ),
    );
  }
}
