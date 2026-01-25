import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../shared/widgets/card_container.dart';

/// Settings screen for app configuration.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language
            ListTileCard(
              leading: const Icon(Icons.language),
              title: l10n.language,
              trailing: Text(
                localeProvider.currentLocaleName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              onTap: () => _showLanguageDialog(context),
            ),

            AppSpacing.vGapSm,

            // Notifications
            ListTileCard(
              leading: const Icon(Icons.notifications_outlined),
              title: l10n.notifications,
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Toggle notifications
                },
                activeColor: AppColors.primary,
              ),
              onTap: () {},
            ),

            AppSpacing.vGapSm,

            // Dark Mode
            ListTileCard(
              leading: const Icon(Icons.dark_mode_outlined),
              title: l10n.darkMode,
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  // TODO: Toggle dark mode
                },
                activeColor: AppColors.primary,
              ),
              onTap: () {},
            ),

            AppSpacing.vGapLg,

            // Section: Data & Privacy
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Data & Privacy',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),

            ListTileCard(
              leading: const Icon(Icons.download_outlined),
              title: 'Download My Data',
              onTap: () {
                // TODO: Download data
              },
            ),

            AppSpacing.vGapSm,

            ListTileCard(
              leading: const Icon(Icons.delete_outline),
              title: 'Delete Account',
              trailing: const Icon(Icons.chevron_right, color: AppColors.error),
              onTap: () => _showDeleteAccountDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localeProvider = context.read<LocaleProvider>();
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LocaleProvider.supportedLocales.map((locale) {
            return RadioListTile<Locale>(
              title: Text(localeProvider.getDisplayName(locale)),
              value: locale,
              groupValue: localeProvider.locale,
              activeColor: AppColors.primary,
              onChanged: (value) {
                if (value != null) {
                  localeProvider.setLocale(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Delete account
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
