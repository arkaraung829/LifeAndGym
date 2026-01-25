import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../../../core/services/error_handler_service.dart';
import '../../../core/utils/validation.dart';
import '../../../shared/widgets/input_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

/// Registration screen.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signInWithGoogle();

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Redirecting to Google sign in...'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ErrorHandlerService().showErrorSnackBar(
          context,
          authProvider.error ?? 'Google sign in failed',
        );
        authProvider.clearError();
      }
    } catch (e) {
      if (!mounted) return;
      ErrorHandlerService().showErrorSnackBar(
        context,
        'Error: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.go(RoutePaths.onboarding);
    } else {
      ErrorHandlerService().showErrorSnackBar(
        context,
        authProvider.error ?? 'Registration failed',
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
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.vGapLg,

                // Header
                Text(
                  'Create account',
                  style: AppTypography.heading1,
                ),
                AppSpacing.vGapXs,
                Text(
                  'Start your fitness journey today',
                  style: AppTypography.body.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),

                AppSpacing.vGapXxl,

                // Name field
                InputField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) => ValidationUtils.validateName(
                    value,
                    fieldName: 'Name',
                  ),
                ),

                AppSpacing.vGapMd,

                // Email field
                EmailField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  textInputAction: TextInputAction.next,
                  validator: ValidationUtils.validateEmail,
                ),

                AppSpacing.vGapMd,

                // Password field
                PasswordField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Create a password',
                  textInputAction: TextInputAction.next,
                  validator: ValidationUtils.validatePassword,
                ),

                AppSpacing.vGapMd,

                // Confirm password field
                PasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  textInputAction: TextInputAction.done,
                  validator: (value) => ValidationUtils.validatePasswordConfirmation(
                    value,
                    _passwordController.text,
                  ),
                  onSubmitted: (_) => _handleRegister(),
                ),

                AppSpacing.vGapLg,

                // Terms and conditions
                Text(
                  'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                  style: AppTypography.caption.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),

                AppSpacing.vGapLg,

                // Register button
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return PrimaryButton(
                      text: 'Create Account',
                      onPressed: _handleRegister,
                      isLoading: auth.isLoading,
                    );
                  },
                ),

                AppSpacing.vGapLg,

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: AppSpacing.paddingHorizontalMd,
                      child: Text(
                        'or',
                        style: AppTypography.bodySmall.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                AppSpacing.vGapLg,

                // Google sign in button
                SecondaryButton(
                  text: 'Continue with Google',
                  icon: Icons.g_mobiledata,
                  isLoading: _isGoogleLoading,
                  onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                ),

                AppSpacing.vGapXxl,

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTypography.body.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pushReplacement(RoutePaths.login),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
