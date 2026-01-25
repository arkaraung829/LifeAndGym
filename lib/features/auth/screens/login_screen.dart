import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/route_names.dart';
import '../../../core/services/error_handler_service.dart';
import '../../../core/utils/validation.dart';
import '../../../shared/widgets/input_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

/// Login screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      if (authProvider.needsOnboarding) {
        context.go(RoutePaths.onboarding);
      } else {
        context.go(RoutePaths.home);
      }
    } else {
      ErrorHandlerService().showErrorSnackBar(
        context,
        authProvider.error ?? context.l10n.loginFailed,
      );
      authProvider.clearError();
    }
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
          SnackBar(
            content: Text(context.l10n.redirectingToGoogle),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ErrorHandlerService().showErrorSnackBar(
          context,
          authProvider.error ?? context.l10n.googleSignInFailed,
        );
        authProvider.clearError();
      }
    } catch (e) {
      if (!mounted) return;
      ErrorHandlerService().showErrorSnackBar(
        context,
        '${context.l10n.error}: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
                  l10n.welcomeBack,
                  style: AppTypography.heading1,
                ),
                AppSpacing.vGapXs,
                Text(
                  l10n.signInToContinue,
                  style: AppTypography.body.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),

                AppSpacing.vGapXxl,

                // Email field
                EmailField(
                  controller: _emailController,
                  label: l10n.email,
                  hint: l10n.enterYourEmail,
                  focusNode: _emailFocusNode,
                  textInputAction: TextInputAction.next,
                  validator: ValidationUtils.validateEmail,
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                ),

                AppSpacing.vGapMd,

                // Password field
                PasswordField(
                  controller: _passwordController,
                  label: l10n.password,
                  hint: l10n.enterYourPassword,
                  focusNode: _passwordFocusNode,
                  textInputAction: TextInputAction.done,
                  validator: (value) => ValidationUtils.validateRequired(
                    value,
                    fieldName: l10n.password,
                  ),
                  onSubmitted: (_) => _handleLogin(),
                ),

                AppSpacing.vGapSm,

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(RoutePaths.forgotPassword),
                    child: Text(l10n.forgotPassword),
                  ),
                ),

                AppSpacing.vGapLg,

                // Login button
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return PrimaryButton(
                      text: l10n.signIn,
                      onPressed: _handleLogin,
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
                        l10n.or,
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

                // Social login buttons
                _buildSocialButtons(context),

                AppSpacing.vGapXxl,

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.dontHaveAccount,
                      style: AppTypography.body.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pushReplacement(RoutePaths.register),
                      child: Text(l10n.signUp),
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

  Widget _buildSocialButtons(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        SecondaryButton(
          text: l10n.continueWithGoogle,
          icon: Icons.g_mobiledata,
          isLoading: _isGoogleLoading,
          onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
        ),
        AppSpacing.vGapMd,
        SecondaryButton(
          text: l10n.continueWithApple,
          icon: Icons.apple,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.appleSignInComingSoon)),
            );
          },
        ),
      ],
    );
  }
}
