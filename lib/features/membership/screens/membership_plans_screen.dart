import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/card_container.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/membership_model.dart';
import '../providers/membership_provider.dart';
import 'upgrade_confirmation_screen.dart';

/// Plan details data structure
class PlanDetails {
  final MembershipPlanType type;
  final String name;
  final double price;
  final String period;
  final List<PlanFeature> features;
  final Color color;
  final Gradient gradient;

  const PlanDetails({
    required this.type,
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    required this.color,
    required this.gradient,
  });
}

/// Individual plan feature
class PlanFeature {
  final String name;
  final bool included;

  const PlanFeature({
    required this.name,
    required this.included,
  });
}

/// Membership plans screen showing all available plans.
class MembershipPlansScreen extends StatelessWidget {
  const MembershipPlansScreen({super.key});

  static final List<PlanDetails> _availablePlans = [
    PlanDetails(
      type: MembershipPlanType.basic,
      name: 'Basic',
      price: 29,
      period: 'month',
      color: const Color(0xFF6366F1),
      gradient: const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      features: [
        const PlanFeature(name: 'Access to all gyms', included: true),
        const PlanFeature(name: 'Standard booking', included: true),
        const PlanFeature(name: 'Guest passes', included: false),
        const PlanFeature(name: 'Trainer sessions', included: false),
        const PlanFeature(name: 'Nutrition consultation', included: false),
        const PlanFeature(name: 'Premium classes', included: false),
        const PlanFeature(name: '24/7 access', included: false),
        const PlanFeature(name: 'Locker rental', included: false),
      ],
    ),
    PlanDetails(
      type: MembershipPlanType.premium,
      name: 'Premium',
      price: 49,
      period: 'month',
      color: const Color(0xFF8B5CF6),
      gradient: const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      features: [
        const PlanFeature(name: 'Access to all gyms', included: true),
        const PlanFeature(name: 'Priority booking', included: true),
        const PlanFeature(name: '2 guest passes/month', included: true),
        const PlanFeature(name: '2 trainer sessions/month', included: true),
        const PlanFeature(name: 'Nutrition consultation', included: false),
        const PlanFeature(name: 'Premium classes', included: false),
        const PlanFeature(name: '24/7 access', included: true),
        const PlanFeature(name: 'Locker rental', included: false),
      ],
    ),
    PlanDetails(
      type: MembershipPlanType.vip,
      name: 'VIP',
      price: 99,
      period: 'month',
      color: const Color(0xFFF59E0B),
      gradient: const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      features: [
        const PlanFeature(name: 'Access to all gyms', included: true),
        const PlanFeature(name: 'Priority booking', included: true),
        const PlanFeature(name: 'Unlimited guest passes', included: true),
        const PlanFeature(name: '8 trainer sessions/month', included: true),
        const PlanFeature(name: 'Nutrition consultation', included: true),
        const PlanFeature(name: 'Premium classes', included: true),
        const PlanFeature(name: '24/7 access', included: true),
        const PlanFeature(name: 'Locker rental included', included: true),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final membershipProvider = context.watch<MembershipProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentMembership = membershipProvider.activeMembership;
    final userId = authProvider.user?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Plans'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Choose Your Plan',
              style: AppTypography.heading2,
            ),
            AppSpacing.vGapXs,
            Text(
              'Select the membership that best fits your fitness goals',
              style: AppTypography.body.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),

            AppSpacing.vGapLg,

            // Plan cards
            ..._availablePlans.map((plan) {
              final isCurrentPlan = currentMembership?.planType == plan.type;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPlanCard(
                  context,
                  plan: plan,
                  isCurrentPlan: isCurrentPlan,
                  currentMembership: currentMembership,
                  userId: userId,
                ),
              );
            }),

            AppSpacing.vGapXxl,
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required PlanDetails plan,
    required bool isCurrentPlan,
    required MembershipModel? currentMembership,
    required String? userId,
  }) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient background
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: plan.gradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.name,
                      style: AppTypography.heading2.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    if (isCurrentPlan)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'CURRENT',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                AppSpacing.vGapSm,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${plan.price.toStringAsFixed(0)}',
                      style: AppTypography.heading1.copyWith(
                        color: Colors.white,
                        fontSize: 36,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '/${plan.period}',
                        style: AppTypography.body.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Features list
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ...plan.features.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          feature.included ? Icons.check_circle : Icons.cancel,
                          color: feature.included
                              ? AppColors.success
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature.name,
                            style: AppTypography.body.copyWith(
                              color: feature.included
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                              decoration: feature.included
                                  ? TextDecoration.none
                                  : TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                AppSpacing.vGapMd,

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan
                        ? null
                        : () => _handlePlanSelection(
                              context,
                              plan: plan,
                              currentMembership: currentMembership,
                              userId: userId,
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: plan.color,
                      disabledBackgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      isCurrentPlan
                          ? 'Current Plan'
                          : _getButtonText(currentMembership?.planType, plan.type),
                      style: AppTypography.button,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText(MembershipPlanType? currentPlan, MembershipPlanType newPlan) {
    if (currentPlan == null) {
      return 'Select Plan';
    }

    final currentIndex = _getPlanIndex(currentPlan);
    final newIndex = _getPlanIndex(newPlan);

    if (newIndex > currentIndex) {
      return 'Upgrade to ${newPlan.displayName}';
    } else if (newIndex < currentIndex) {
      return 'Downgrade to ${newPlan.displayName}';
    } else {
      return 'Select Plan';
    }
  }

  int _getPlanIndex(MembershipPlanType plan) {
    switch (plan) {
      case MembershipPlanType.basic:
        return 0;
      case MembershipPlanType.premium:
        return 1;
      case MembershipPlanType.vip:
        return 2;
      default:
        return 0;
    }
  }

  void _handlePlanSelection(
    BuildContext context, {
    required PlanDetails plan,
    required MembershipModel? currentMembership,
    required String? userId,
  }) {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to continue'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Navigate to upgrade confirmation screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UpgradeConfirmationScreen(
          selectedPlan: plan,
          currentMembership: currentMembership,
        ),
      ),
    );
  }
}
