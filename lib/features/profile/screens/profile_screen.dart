import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/router/route_names.dart';
import '../../../core/services/error_handler_service.dart';
import '../../../core/services/image_upload_service.dart';
import '../../../shared/widgets/card_container.dart';
import '../../../shared/widgets/guest_mode_banner.dart';
import '../../auth/providers/auth_provider.dart';
import '../../membership/providers/membership_provider.dart';
import '../../membership/screens/membership_plans_screen.dart';

/// Profile screen placeholder.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _imageUploadService = ImageUploadService();
  bool _isUploadingImage = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profile),
        actions: [
          if (!authProvider.isGuest)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push(RoutePaths.settings),
            ),
        ],
      ),
      body: authProvider.isGuest
          ? const GuestModePrompt(
              title: 'Sign Up to Create Your Profile',
              message:
                  'Create an account to track your progress, book classes, and unlock all features.',
              icon: Icons.person_outline,
            )
          : SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                children: [
                  // Profile header
                  _buildProfileHeader(context, user),

                  AppSpacing.vGapLg,

                  // Membership card
                  _buildMembershipCard(context),

                  AppSpacing.vGapMd,

                  // Menu items
                  _buildMenuSection(context),

                  AppSpacing.vGapLg,

                  // Sign out button
                  _buildSignOutButton(context),

                  AppSpacing.vGapXxl,
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Column(
      children: [
        // Avatar
        Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary,
              backgroundImage: user?.avatarUrl != null
                  ? NetworkImage(user!.avatarUrl!)
                  : null,
              child: user?.avatarUrl == null
                  ? Text(
                      user?.initials ?? 'U',
                      style: AppTypography.heading1.copyWith(
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            if (_isUploadingImage)
              Positioned.fill(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.camera_alt, size: 16),
                  onPressed: _isUploadingImage ? null : _handleAvatarTap,
                ),
              ),
            ),
          ],
        ),

        AppSpacing.vGapMd,

        // Name
        Text(
          user?.fullName ?? 'User',
          style: AppTypography.heading2,
        ),

        AppSpacing.vGapXs,

        // Email
        Text(
          user?.email ?? '',
          style: AppTypography.body.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),

        AppSpacing.vGapMd,

        // Edit profile button
        OutlinedButton.icon(
          onPressed: () {
            context.push(RoutePaths.editProfile);
          },
          icon: const Icon(Icons.edit, size: 18),
          label: Text(context.l10n.editProfile),
        ),
      ],
    );
  }

  Widget _buildMembershipCard(BuildContext context) {
    final membershipProvider = context.watch<MembershipProvider>();
    final membership = membershipProvider.activeMembership;

    if (membership == null) {
      return GradientCard(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        ),
        onTap: () {
          // Navigate to membership options
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MembershipPlansScreen(),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.card_membership,
                color: Colors.white,
                size: 28,
              ),
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get a Membership',
                    style: AppTypography.heading4.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Unlock all features',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white,
            ),
          ],
        ),
      );
    }

    return GradientCard(
      gradient: AppColors.primaryGradient,
      onTap: () {
        // Navigate to membership plans
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MembershipPlansScreen(),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.card_membership,
              color: Colors.white,
              size: 28,
            ),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${membership.planType.displayName} Member',
                  style: AppTypography.heading4.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  membership.accessAllLocations
                      ? 'Access to all locations'
                      : 'Single gym access',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final l10n = context.l10n;
    final localeProvider = context.watch<LocaleProvider>();

    return Column(
      children: [
        ListTileCard(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          title: l10n.notifications,
          onTap: () => context.push(RoutePaths.notifications),
        ),
        ListTileCard(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.language,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          title: l10n.language,
          trailing: Text(
            localeProvider.currentLocaleName,
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          onTap: () => _showLanguageDialog(context),
        ),
        ListTileCard(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.flag_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          title: 'Goals',
          onTap: () => context.push(RoutePaths.goals),
        ),
        ListTileCard(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.monitor_weight_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          title: 'Body Metrics',
          onTap: () => context.push(RoutePaths.bodyMetrics),
        ),
        ListTileCard(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.history,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          title: l10n.workoutHistory,
          onTap: () => context.go(RoutePaths.workouts),
        ),
        ListTileCard(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          title: l10n.myBookings,
          onTap: () => context.push(RoutePaths.myBookings),
        ),
        ListTileCard(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.help_outline,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          title: 'Help & Support',
          onTap: () => context.push('/help-support'),
        ),
        ListTileCard(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.info_outline,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          title: l10n.about,
          onTap: () => context.push('/about'),
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localeProvider = context.read<LocaleProvider>();
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.language),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: LocaleProvider.supportedLocales.map((locale) {
            final isSelected = localeProvider.locale == locale;
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
              selected: isSelected,
            );
          }).toList(),
        ),
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

  Widget _buildSignOutButton(BuildContext context) {
    final l10n = context.l10n;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(context.l10n.logout),
              content: Text(context.l10n.logoutConfirmation),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(context.l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(context.l10n.logout),
                ),
              ],
            ),
          );

          if (confirmed == true && context.mounted) {
            await context.read<AuthProvider>().signOut();
            if (context.mounted) {
              context.go(RoutePaths.welcome);
            }
          }
        },
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: Text(
          l10n.logout,
          style: const TextStyle(color: AppColors.error),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  void _handleAvatarTap() {
    final authProvider = context.read<AuthProvider>();
    final hasAvatar = authProvider.user?.avatarUrl != null;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(context.l10n.takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  _handleCameraPhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(context.l10n.chooseFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  _handleGalleryPhoto();
                },
              ),
              if (hasAvatar)
                ListTile(
                  leading: const Icon(Icons.delete, color: AppColors.error),
                  title: Text(context.l10n.removePhoto, style: const TextStyle(color: AppColors.error)),
                  onTap: () {
                    Navigator.pop(context);
                    _handleRemovePhoto();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCameraPhoto() async {
    setState(() => _isUploadingImage = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.id;

      if (userId == null) {
        throw Exception('User not found');
      }

      // Pick image from camera
      final image = await _imageUploadService.pickImage(ImageSource.camera);
      if (image == null) {
        // User cancelled
        setState(() => _isUploadingImage = false);
        return;
      }

      // Upload to Supabase
      final imageUrl = await _imageUploadService.uploadToSupabase(image, userId);

      // Delete old avatar if exists
      if (authProvider.user?.avatarUrl != null) {
        await _imageUploadService.deleteFromSupabase(authProvider.user!.avatarUrl!);
      }

      // Update user profile with new avatar URL
      final success = await authProvider.updateProfile({'avatar_url': imageUrl});

      if (!mounted) return;

      if (success) {
        ErrorHandlerService().showSuccessSnackBar(
          context,
          'Profile photo updated successfully',
        );
      } else {
        ErrorHandlerService().showErrorSnackBar(
          context,
          authProvider.error ?? 'Failed to update profile photo',
        );
        authProvider.clearError();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandlerService().showErrorSnackBar(
          context,
          e,
          fallback: 'Failed to upload photo',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _handleGalleryPhoto() async {
    setState(() => _isUploadingImage = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.id;

      if (userId == null) {
        throw Exception('User not found');
      }

      // Pick image from gallery
      final image = await _imageUploadService.pickImage(ImageSource.gallery);
      if (image == null) {
        // User cancelled
        setState(() => _isUploadingImage = false);
        return;
      }

      // Upload to Supabase
      final imageUrl = await _imageUploadService.uploadToSupabase(image, userId);

      // Delete old avatar if exists
      if (authProvider.user?.avatarUrl != null) {
        await _imageUploadService.deleteFromSupabase(authProvider.user!.avatarUrl!);
      }

      // Update user profile with new avatar URL
      final success = await authProvider.updateProfile({'avatar_url': imageUrl});

      if (!mounted) return;

      if (success) {
        ErrorHandlerService().showSuccessSnackBar(
          context,
          'Profile photo updated successfully',
        );
      } else {
        ErrorHandlerService().showErrorSnackBar(
          context,
          authProvider.error ?? 'Failed to update profile photo',
        );
        authProvider.clearError();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandlerService().showErrorSnackBar(
          context,
          e,
          fallback: 'Failed to upload photo',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _handleRemovePhoto() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Photo'),
        content: Text(context.l10n.removePhotoConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isUploadingImage = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final avatarUrl = authProvider.user?.avatarUrl;

      if (avatarUrl == null) {
        setState(() => _isUploadingImage = false);
        return;
      }

      // Delete from storage
      await _imageUploadService.deleteFromSupabase(avatarUrl);

      // Update user profile to remove avatar URL
      final success = await authProvider.updateProfile({'avatar_url': null});

      if (!mounted) return;

      if (success) {
        ErrorHandlerService().showSuccessSnackBar(
          context,
          'Profile photo removed successfully',
        );
      } else {
        ErrorHandlerService().showErrorSnackBar(
          context,
          authProvider.error ?? 'Failed to remove profile photo',
        );
        authProvider.clearError();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandlerService().showErrorSnackBar(
          context,
          e,
          fallback: 'Failed to remove photo',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }
}
