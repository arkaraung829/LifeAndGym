import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../../../shared/widgets/card_container.dart';
import '../../../shared/widgets/guest_mode_banner.dart';
import '../../auth/providers/auth_provider.dart';
import '../../membership/providers/membership_provider.dart';

/// Profile screen placeholder.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!authProvider.isGuest)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: Navigate to settings
              },
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
              child: Text(
                user?.initials ?? 'U',
                style: AppTypography.heading1.copyWith(
                  color: Colors.white,
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
                  onPressed: () {
                    // TODO: Change avatar
                  },
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
          label: const Text('Edit Profile'),
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
        // Navigate to membership details
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
    final menuItems = [
      {
        'icon': Icons.notifications_outlined,
        'title': 'Notifications',
        'onTap': () {},
      },
      {
        'icon': Icons.flag_outlined,
        'title': 'Goals',
        'onTap': () {},
      },
      {
        'icon': Icons.monitor_weight_outlined,
        'title': 'Body Metrics',
        'onTap': () {},
      },
      {
        'icon': Icons.history,
        'title': 'Workout History',
        'onTap': () {},
      },
      {
        'icon': Icons.calendar_today_outlined,
        'title': 'My Bookings',
        'onTap': () {},
      },
      {
        'icon': Icons.help_outline,
        'title': 'Help & Support',
        'onTap': () {},
      },
      {
        'icon': Icons.info_outline,
        'title': 'About',
        'onTap': () {},
      },
    ];

    return Column(
      children: menuItems.map((item) {
        return ListTileCard(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item['icon'] as IconData,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          title: item['title'] as String,
          onTap: item['onTap'] as VoidCallback,
        );
      }).toList(),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Sign Out'),
              content: const Text('Are you sure you want to sign out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Sign Out'),
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
          'Sign Out',
          style: TextStyle(color: AppColors.error),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
