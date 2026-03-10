import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/providers/providers.dart';
import '../../../../shared/services/storage_service.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  File? _selectedImage;
  bool _imageRemoved = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser != null) {
      _nameController.text = currentUser.name;
      _emailController.text = currentUser.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSourceType source) async {
    final storageService = ref.read(storageServiceProvider);
    final file = await storageService.pickImage(source: source);
    if (file != null) {
      setState(() {
        _selectedImage = file;
        _imageRemoved = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageRemoved = true;
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Change Profile Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSourceType.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library, color: AppColors.secondary),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSourceType.gallery);
                },
              ),
              if (_hasExistingImage && !_imageRemoved)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete, color: AppColors.error),
                  ),
                  title: const Text('Remove Photo', style: TextStyle(color: AppColors.error)),
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasExistingImage {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    return currentUser?.profileImage != null && currentUser!.profileImage!.isNotEmpty;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    final profileNotifier = ref.read(profileNotifierProvider.notifier);
    bool success = true;

    // Upload new image if selected
    if (_selectedImage != null) {
      success = await profileNotifier.uploadProfileImage(
        userId: currentUser.id,
        imageFile: _selectedImage!,
      );
    } else if (_imageRemoved && _hasExistingImage) {
      success = await profileNotifier.deleteProfileImage(currentUser.id);
    }

    if (!success) return;

    // Update profile info
    success = await profileNotifier.updateProfile(
      userId: currentUser.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final profileState = ref.watch(profileNotifierProvider);

    // Listen for errors
    ref.listen(profileNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(profileNotifierProvider.notifier).clearError();
      }
    });

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: profileState.isLoading || profileState.isUploading
                ? null
                : _saveProfile,
            child: profileState.isLoading || profileState.isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.1),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 3,
                          ),
                          image: _getProfileImage(),
                        ),
                        child: _shouldShowPlaceholder()
                            ? Center(
                                child: Text(
                                  currentUser.name.isNotEmpty
                                      ? currentUser.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.scaffoldDark,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (profileState.isUploading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _showImageSourceDialog,
                child: const Text(
                  'Change Photo',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),
              // Name Field
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person_outline,
                validator: Validators.validateName,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              // Email Field
              _buildTextField(
                controller: _emailController,
                label: 'Email (Optional)',
                hint: 'Enter your email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    return Validators.validateEmail(value);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Phone (Read-only)
              _buildReadOnlyField(
                label: 'Phone Number',
                value: currentUser.phone,
                icon: Icons.phone_outlined,
                helperText: 'Phone number cannot be changed',
              ),
              const SizedBox(height: 16),
              // Role (Read-only)
              _buildReadOnlyField(
                label: 'Role',
                value: currentUser.role.value.toUpperCase(),
                icon: Icons.badge_outlined,
                helperText: 'Contact admin to change your role',
              ),
            ],
          ),
        ),
      ),
    );
  }

  DecorationImage? _getProfileImage() {
    if (_selectedImage != null) {
      return DecorationImage(
        image: FileImage(_selectedImage!),
        fit: BoxFit.cover,
      );
    }

    if (_imageRemoved) {
      return null;
    }

    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser?.profileImage != null && currentUser!.profileImage!.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(currentUser.profileImage!),
        fit: BoxFit.cover,
      );
    }

    return null;
  }

  bool _shouldShowPlaceholder() {
    if (_selectedImage != null) return false;
    if (_imageRemoved) return true;

    final currentUser = ref.read(currentUserProvider).valueOrNull;
    return currentUser?.profileImage == null || currentUser!.profileImage!.isEmpty;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surfaceDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey700),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey700),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey800),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.grey500),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(Icons.lock_outline, color: AppColors.grey600, size: 18),
            ],
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ],
    );
  }
}
