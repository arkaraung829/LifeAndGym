import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/error_handler_service.dart';
import '../../../shared/widgets/card_container.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/membership_model.dart';
import '../services/membership_service.dart';
import 'membership_plans_screen.dart';

/// Upgrade confirmation screen for changing membership plans.
class UpgradeConfirmationScreen extends StatefulWidget {
  final PlanDetails selectedPlan;
  final MembershipModel? currentMembership;

  const UpgradeConfirmationScreen({
    super.key,
    required this.selectedPlan,
    required this.currentMembership,
  });

  @override
  State<UpgradeConfirmationScreen> createState() => _UpgradeConfirmationScreenState();
}

class _UpgradeConfirmationScreenState extends State<UpgradeConfirmationScreen> {
  bool _acceptedTerms = false;
  bool _isProcessing = false;
  final _membershipService = MembershipService();

  @override
  Widget build(BuildContext context) {
    final isUpgrade = _isUpgrade();
    final priceDifference = _calculatePriceDifference();
    final proratedAmount = _calculateProratedAmount();
    final nextBillingDate = _calculateNextBillingDate();

    return Scaffold(
      appBar: AppBar(
        title: Text(isUpgrade ? 'Confirm Upgrade' : 'Confirm Downgrade'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan comparison
            _buildPlanComparison(context, isUpgrade),

            AppSpacing.vGapLg,

            // Pricing breakdown
            _buildPricingBreakdown(
              context,
              priceDifference: priceDifference,
              proratedAmount: proratedAmount,
              nextBillingDate: nextBillingDate,
            ),

            AppSpacing.vGapLg,

            // Payment method
            _buildPaymentMethod(context),

            AppSpacing.vGapLg,

            // Terms and conditions
            _buildTermsCheckbox(context),

            AppSpacing.vGapLg,

            // Action buttons
            _buildActionButtons(context, isUpgrade),

            AppSpacing.vGapXxl,
          ],
        ),
      ),
    );
  }

  Widget _buildPlanComparison(BuildContext context, bool isUpgrade) {
    return CardContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan Comparison',
              style: AppTypography.heading3,
            ),
            AppSpacing.vGapMd,

            // Current plan
            if (widget.currentMembership != null) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From',
                          style: AppTypography.bodySmall.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.currentMembership!.planType.displayName,
                          style: AppTypography.heading4,
                        ),
                        Text(
                          '\$${widget.currentMembership!.monthlyFee?.toStringAsFixed(0) ?? "0"}/month',
                          style: AppTypography.bodySmall.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              AppSpacing.vGapMd,

              Divider(color: Theme.of(context).colorScheme.surface),

              AppSpacing.vGapMd,
            ],

            // New plan
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isUpgrade ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isUpgrade ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 20,
                    color: isUpgrade ? AppColors.success : AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To',
                        style: AppTypography.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.selectedPlan.name,
                        style: AppTypography.heading4.copyWith(
                          color: isUpgrade ? AppColors.success : AppColors.warning,
                        ),
                      ),
                      Text(
                        '\$${widget.selectedPlan.price.toStringAsFixed(0)}/month',
                        style: AppTypography.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AppSpacing.vGapMd,

            // Feature changes
            if (widget.currentMembership != null) ...[
              Divider(color: Theme.of(context).colorScheme.surface),
              AppSpacing.vGapMd,
              Text(
                isUpgrade ? 'New Features' : 'Features Removed',
                style: AppTypography.heading4,
              ),
              AppSpacing.vGapSm,
              ..._getFeatureChanges(isUpgrade).map((feature) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        isUpgrade ? Icons.add_circle : Icons.remove_circle,
                        color: isUpgrade ? AppColors.success : AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPricingBreakdown(
    BuildContext context, {
    required double priceDifference,
    required double proratedAmount,
    required DateTime nextBillingDate,
  }) {
    return CardContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pricing Breakdown',
              style: AppTypography.heading3,
            ),
            AppSpacing.vGapMd,

            _buildPriceRow(
              context,
              label: 'New plan price',
              value: '\$${widget.selectedPlan.price.toStringAsFixed(2)}/month',
            ),

            if (widget.currentMembership != null) ...[
              _buildPriceRow(
                context,
                label: 'Prorated adjustment',
                value: proratedAmount >= 0
                    ? '+\$${proratedAmount.toStringAsFixed(2)}'
                    : '-\$${proratedAmount.abs().toStringAsFixed(2)}',
                valueColor: proratedAmount >= 0 ? AppColors.error : AppColors.success,
              ),
            ],

            Divider(color: Theme.of(context).colorScheme.surface),

            _buildPriceRow(
              context,
              label: 'Total due today',
              value: '\$${proratedAmount.abs().toStringAsFixed(2)}',
              isTotal: true,
            ),

            AppSpacing.vGapSm,

            _buildPriceRow(
              context,
              label: 'Next billing date',
              value: _formatDate(nextBillingDate),
              valueColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal ? AppTypography.heading4 : AppTypography.body,
          ),
          Text(
            value,
            style: isTotal
                ? AppTypography.heading4.copyWith(color: AppColors.primary)
                : AppTypography.body.copyWith(
                    color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(BuildContext context) {
    return CardContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: AppTypography.heading3,
            ),
            AppSpacing.vGapMd,

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.credit_card,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visa ending in 1234',
                        style: AppTypography.body,
                      ),
                      Text(
                        'Expires 12/25',
                        style: AppTypography.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to payment method change
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment method change not yet implemented'),
                      ),
                    );
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptedTerms,
          onChanged: (value) {
            setState(() {
              _acceptedTerms = value ?? false;
            });
          },
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _acceptedTerms = !_acceptedTerms;
                });
              },
              child: Text(
                'I agree to the terms and conditions of the membership plan change',
                style: AppTypography.body,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isUpgrade) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _acceptedTerms && !_isProcessing ? _handleConfirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isUpgrade ? AppColors.success : AppColors.warning,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Confirm ${isUpgrade ? "Upgrade" : "Downgrade"}',
                    style: AppTypography.button,
                  ),
          ),
        ),
        AppSpacing.vGapSm,
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isProcessing ? null : () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  bool _isUpgrade() {
    if (widget.currentMembership == null) return true;

    final currentIndex = _getPlanIndex(widget.currentMembership!.planType);
    final newIndex = _getPlanIndex(widget.selectedPlan.type);

    return newIndex > currentIndex;
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

  double _calculatePriceDifference() {
    if (widget.currentMembership == null) return widget.selectedPlan.price;

    final currentPrice = widget.currentMembership!.monthlyFee ?? 0;
    return widget.selectedPlan.price - currentPrice;
  }

  double _calculateProratedAmount() {
    if (widget.currentMembership == null) return widget.selectedPlan.price;

    // Calculate days remaining in current cycle
    final endDate = widget.currentMembership!.endDate;
    if (endDate == null) return 0;

    final now = DateTime.now();
    final daysRemaining = endDate.difference(now).inDays;
    final totalDaysInCycle = 30; // Assuming 30-day cycle

    if (daysRemaining <= 0) return widget.selectedPlan.price;

    // Calculate refund/credit for current plan
    final currentPrice = widget.currentMembership!.monthlyFee ?? 0;
    final currentPlanCredit = (currentPrice * daysRemaining) / totalDaysInCycle;

    // Calculate charge for new plan
    final newPlanCharge = (widget.selectedPlan.price * daysRemaining) / totalDaysInCycle;

    // Net amount (positive means charge, negative means credit)
    return newPlanCharge - currentPlanCredit;
  }

  DateTime _calculateNextBillingDate() {
    if (widget.currentMembership?.endDate != null) {
      return widget.currentMembership!.endDate!;
    }

    // Default to 30 days from now
    return DateTime.now().add(const Duration(days: 30));
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  List<String> _getFeatureChanges(bool isUpgrade) {
    // Simplified feature changes based on plan transitions
    if (widget.currentMembership == null) {
      return widget.selectedPlan.features.where((f) => f.included).map((f) => f.name).toList();
    }

    final currentPlan = widget.currentMembership!.planType;
    final newPlan = widget.selectedPlan.type;

    if (currentPlan == MembershipPlanType.basic && newPlan == MembershipPlanType.premium) {
      return ['Priority booking', '2 guest passes/month', '2 trainer sessions/month', '24/7 access'];
    } else if (currentPlan == MembershipPlanType.basic && newPlan == MembershipPlanType.vip) {
      return [
        'Priority booking',
        'Unlimited guest passes',
        '8 trainer sessions/month',
        'Nutrition consultation',
        'Premium classes',
        '24/7 access',
        'Locker rental included'
      ];
    } else if (currentPlan == MembershipPlanType.premium && newPlan == MembershipPlanType.vip) {
      return [
        'Unlimited guest passes (vs 2/month)',
        '8 trainer sessions/month (vs 2/month)',
        'Nutrition consultation',
        'Premium classes',
        'Locker rental included'
      ];
    } else if (currentPlan == MembershipPlanType.premium && newPlan == MembershipPlanType.basic) {
      return ['Priority booking', 'Guest passes', 'Trainer sessions', '24/7 access'];
    } else if (currentPlan == MembershipPlanType.vip && newPlan == MembershipPlanType.premium) {
      return [
        'Unlimited guest passes',
        'Nutrition consultation',
        'Premium classes',
        'Locker rental',
        '6 trainer sessions/month'
      ];
    } else if (currentPlan == MembershipPlanType.vip && newPlan == MembershipPlanType.basic) {
      return [
        'Priority booking',
        'Guest passes',
        'Trainer sessions',
        'Nutrition consultation',
        'Premium classes',
        '24/7 access',
        'Locker rental'
      ];
    }

    return [];
  }

  Future<void> _handleConfirm() async {
    if (!_acceptedTerms) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.id;

      if (userId == null) {
        throw Exception('User not found');
      }

      if (widget.currentMembership == null) {
        throw Exception('No active membership found');
      }

      // Call upgrade API
      await _membershipService.upgradeMembership(
        membershipId: widget.currentMembership!.id,
        newPlanType: widget.selectedPlan.type,
      );

      if (!mounted) return;

      // Show success message
      ErrorHandlerService().showSuccessSnackBar(
        context,
        'Membership ${_isUpgrade() ? "upgraded" : "downgraded"} successfully!',
      );

      // Navigate back to profile
      context.go('/profile');
    } catch (e) {
      if (!mounted) return;

      ErrorHandlerService().showErrorSnackBar(
        context,
        e,
        fallback: 'Failed to update membership. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
