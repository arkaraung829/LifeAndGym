import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/notification_preferences_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../shared/widgets/card_container.dart';

/// Settings screen for app configuration.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final notificationProvider = context.watch<NotificationPreferencesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings),
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
                value: notificationProvider.notificationsEnabled,
                onChanged: (value) => _handleNotificationToggle(context, value),
                activeColor: AppColors.primary,
              ),
              onTap: () {},
            ),

            AppSpacing.vGapSm,

            // Daily Workout Reminder
            if (notificationProvider.notificationsEnabled) ...[
              ListTileCard(
                leading: const Icon(Icons.alarm),
                title: 'Daily Workout Reminder',
                trailing: Switch(
                  value: notificationProvider.dailyWorkoutReminderEnabled,
                  onChanged: (value) {
                    notificationProvider.setDailyWorkoutReminderEnabled(value);
                  },
                  activeColor: AppColors.primary,
                ),
                onTap: () {},
              ),
              if (notificationProvider.dailyWorkoutReminderEnabled) ...[
                AppSpacing.vGapSm,
                ListTileCard(
                  leading: const Icon(Icons.access_time),
                  title: 'Reminder Time',
                  trailing: Text(
                    notificationProvider.dailyWorkoutReminderTime.format(context),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  onTap: () => _showReminderTimePicker(context),
                ),
              ],
              AppSpacing.vGapSm,
            ],

            // Dark Mode
            ListTileCard(
              leading: const Icon(Icons.dark_mode_outlined),
              title: l10n.darkMode,
              trailing: Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
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

  Future<void> _handleNotificationToggle(BuildContext context, bool value) async {
    final notificationProvider = context.read<NotificationPreferencesProvider>();

    if (value) {
      // Enabling notifications - request permissions
      final success = await notificationProvider.setNotificationsEnabled(true);

      if (!success && context.mounted) {
        // Permission denied - show dialog to open settings
        _showPermissionDeniedDialog(context);
      }
    } else {
      // Disabling notifications - no permission needed
      await notificationProvider.setNotificationsEnabled(false);
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.notificationPermissionRequired),
        content: const Text(
          'Notifications are disabled in your device settings. To receive notifications, please enable them in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AppSettings.openAppSettings();
            },
            child: Text(context.l10n.openSettings),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localeProvider = context.read<LocaleProvider>();
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.language),
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
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showReminderTimePicker(BuildContext context) async {
    final notificationProvider = context.read<NotificationPreferencesProvider>();
    final currentTime = notificationProvider.dailyWorkoutReminderTime;

    final time = await showTimePicker(
      context: context,
      initialTime: currentTime,
      helpText: 'Select reminder time',
    );

    if (time != null) {
      await notificationProvider.setDailyWorkoutReminderTime(time);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.dailyReminderSet(time.format(context))),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteAccount),
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
