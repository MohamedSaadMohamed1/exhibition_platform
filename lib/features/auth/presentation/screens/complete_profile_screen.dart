import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../router/routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_background.dart';
import '../widgets/glassmorphic_card.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _completeProfile() {
    if (_formKey.currentState!.validate()) {
      ref.read(authNotifierProvider.notifier).completeProfile(
            name: _nameController.text.trim(),
            email: _emailController.text.trim().isNotEmpty
                ? _emailController.text.trim()
                : null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final textTheme = Theme.of(context).textTheme;

    ref.listen(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go(next.user?.role?.homeRoute ?? AppRoutes.home);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        );
      }
    });

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: ResponsiveConstrainedBox(
              maxWidth: AppDimensions.maxWidthMobile,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                    GlassmorphicCard(
                      child: Padding(
                        padding: EdgeInsets.all(28.r),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Icon
                              Container(
                                width: 90.r,
                                height: 90.r,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withOpacity(0.3),
                                      AppColors.primaryLight.withOpacity(0.2),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(Icons.person_outline, size: 40.r, color: Colors.white),
                              ),
                              SizedBox(height: AppDimensions.spacingXxl.h),
                              // Title
                              Text(
                                'Complete Your Profile',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: AppDimensions.spacingSm.h),
                              Text(
                                'Please provide your details to continue',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppDimensions.spacing3xl.h),
                              // Name Input
                              _buildInputField(
                                label: 'Full Name *',
                                hint: 'Enter your full name',
                                controller: _nameController,
                                icon: Icons.person_outline,
                                validator: Validators.validateName,
                                textCapitalization: TextCapitalization.words,
                                textTheme: textTheme,
                              ),
                              SizedBox(height: AppDimensions.spacingXl.h),
                              // Email Input (Optional)
                              _buildInputField(
                                label: 'Email (Optional)',
                                hint: 'Enter your email',
                                controller: _emailController,
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    return Validators.validateEmail(value);
                                  }
                                  return null;
                                },
                                textTheme: textTheme,
                              ),
                              SizedBox(height: AppDimensions.spacingXxl.h),
                              // Role Info
                              Container(
                                padding: EdgeInsets.all(AppDimensions.spacingLg.r),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: AppColors.info, size: 20.r),
                                    SizedBox(width: AppDimensions.spacingMd.w),
                                    Expanded(
                                      child: Text(
                                        'You are registering as a Visitor. Contact admin if you need a different role.',
                                        style: textTheme.labelMedium?.copyWith(
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 28.h),
                              _buildContinueButton(authState.isLoading, textTheme),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required TextTheme textTheme,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(color: Colors.white.withOpacity(0.9)),
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            style: textTheme.bodyLarge?.copyWith(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(0.4)),
              prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.6), size: 22.r),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              errorStyle: TextStyle(color: AppColors.error, fontSize: 12.sp),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(bool isLoading, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      height: AppDimensions.buttonHeightLg.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _completeProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        ),
        child: isLoading
            ? SizedBox(
                width: 24.r,
                height: 24.r,
                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacingSm.w),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20.r),
                ],
              ),
      ),
    );
  }
}
