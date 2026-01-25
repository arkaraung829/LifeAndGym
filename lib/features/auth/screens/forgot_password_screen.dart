import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/error_handler_service.dart';
import '../../../core/utils/validation.dart';
import '../../../shared/widgets/input_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

/// Forgot password screen.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendPasswordResetEmail(
      _emailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _emailSent = true;
      });
    } else {
      ErrorHandlerService().showErrorSnackBar(
        context,
        authProvider.error ?? 'Failed to send reset email',
      );
      authProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: _emailSent ? _buildSuccessContent() : _buildFormContent(),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.vGapLg,

          // Header
          Text(
            'Forgot password?',
            style: AppTypography.heading1,
          ),
          AppSpacing.vGapSm,
          Text(
            "No worries! Enter your email and we'll send you a reset link.",
            style: AppTypography.body.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),

          AppSpacing.vGapXxl,

          // Email field
          EmailField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            autofocus: true,
            textInputAction: TextInputAction.done,
            validator: ValidationUtils.validateEmail,
            onSubmitted: (_) => _handleSendResetEmail(),
          ),

          AppSpacing.vGapLg,

          // Send button
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return PrimaryButton(
                text: 'Send Reset Link',
                onPressed: _handleSendResetEmail,
                isLoading: auth.isLoading,
              );
            },
          ),

          const Spacer(),

          // Back to login
          Center(
            child: TextButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Back to Sign In'),
            ),
          ),

          AppSpacing.vGapLg,
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.email_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        AppSpacing.vGapLg,

        Text(
          'Check your email',
          style: AppTypography.heading2,
        ),

        AppSpacing.vGapSm,

        Padding(
          padding: AppSpacing.paddingHorizontalLg,
          child: Text(
            "We've sent a password reset link to ${_emailController.text}",
            style: AppTypography.body.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        AppSpacing.vGapXxl,

        PrimaryButton(
          text: 'Back to Sign In',
          onPressed: () => context.pop(),
          width: 200,
        ),

        AppSpacing.vGapMd,

        TextButton(
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          child: const Text("Didn't receive email? Try again"),
        ),
      ],
    );
  }
}
