import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/error_handler_service.dart';
import '../../../shared/widgets/input_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/providers/auth_provider.dart';

/// Edit profile screen for updating user information.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _ageController;

  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _heightController = TextEditingController(
      text: user?.heightCm?.toStringAsFixed(0) ?? '',
    );
    _ageController = TextEditingController(
      text: user?.age?.toString() ?? '',
    );

    _nameController.addListener(_onFieldChanged);
    _heightController.addListener(_onFieldChanged);
    _ageController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      // Parse values
      final heightCm = double.tryParse(_heightController.text);
      final age = int.tryParse(_ageController.text);

      DateTime? dateOfBirth;
      if (age != null) {
        final now = DateTime.now();
        dateOfBirth = DateTime(now.year - age, now.month, now.day);
      }

      // Build updates map
      final updates = <String, dynamic>{
        'full_name': _nameController.text.trim(),
      };
      if (heightCm != null) {
        updates['height_cm'] = heightCm;
      }
      if (dateOfBirth != null) {
        updates['date_of_birth'] = dateOfBirth.toIso8601String().split('T').first;
      }

      final success = await authProvider.updateProfile(updates);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ErrorHandlerService().showErrorSnackBar(
          context,
          authProvider.error ?? 'Failed to update profile',
        );
        authProvider.clearError();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar section
              Center(child: _buildAvatarSection()),

              AppSpacing.vGapXl,

              // Personal Information section
              Text(
                'Personal Information',
                style: AppTypography.heading4,
              ),
              AppSpacing.vGapMd,

              InputField(
                label: 'Full Name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              AppSpacing.vGapLg,

              // Body Metrics section
              Text(
                'Body Metrics',
                style: AppTypography.heading4,
              ),
              AppSpacing.vGapSm,
              Text(
                'Optional - helps personalize your experience',
                style: AppTypography.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              AppSpacing.vGapMd,

              Row(
                children: [
                  Expanded(
                    child: InputField(
                      label: 'Height (cm)',
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final height = double.tryParse(value);
                          if (height == null || height < 50 || height > 300) {
                            return 'Invalid height';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  AppSpacing.hGapMd,
                  Expanded(
                    child: InputField(
                      label: 'Age',
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final age = int.tryParse(value);
                          if (age == null || age < 13 || age > 120) {
                            return 'Invalid age';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              AppSpacing.vGapXxl,

              // Save button
              PrimaryButton(
                text: 'Save Changes',
                onPressed: _hasChanges ? _saveProfile : null,
                isLoading: _isLoading,
              ),

              AppSpacing.vGapLg,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final user = context.watch<AuthProvider>().user;

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 56,
              backgroundColor: AppColors.primary,
              backgroundImage: user?.avatarUrl != null
                  ? NetworkImage(user!.avatarUrl!)
                  : null,
              child: user?.avatarUrl == null
                  ? Text(
                      user?.initials ?? 'U',
                      style: AppTypography.displayLarge.copyWith(
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 3,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  onPressed: _showImagePicker,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.vGapMd,
        TextButton(
          onPressed: _showImagePicker,
          child: const Text('Change Photo'),
        ),
      ],
    );
  }

  void _showImagePicker() {
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
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement camera capture
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera feature coming soon')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement gallery picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gallery feature coming soon')),
                  );
                },
              ),
              if (context.read<AuthProvider>().user?.avatarUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: AppColors.error),
                  title: const Text('Remove Photo', style: TextStyle(color: AppColors.error)),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement remove avatar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Remove photo feature coming soon')),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
