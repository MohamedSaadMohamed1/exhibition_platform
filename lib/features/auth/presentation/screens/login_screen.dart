import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../router/routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_background.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/country_picker.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _selectedCountryCode = '+965';
  String _selectedCountryFlag = '🇰🇼';
  String _selectedCountry = 'Kuwait';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onCountrySelected(String code, String flag, String country) {
    setState(() {
      _selectedCountryCode = code;
      _selectedCountryFlag = flag;
      _selectedCountry = country;
    });
  }

  void _handleSignIn() {
    final phone = _phoneController.text.trim();
    final phoneError = Validators.validateLocalPhone(phone, _selectedCountryCode);
    if (phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(phoneError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    ref.read(authNotifierProvider.notifier).sendOtp(
      phoneNumber: phone,
      countryCode: _selectedCountryCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    ref.listen(authNotifierProvider, (previous, next) {
      AppLogger.info('📍 LoginScreen: status changed from ${previous?.status} to ${next.status}', tag: 'LoginScreen');

      if (next.status == AuthStatus.codeSent) {
        AppLogger.info('📍 LoginScreen: Navigating to OTP screen', tag: 'LoginScreen');
        context.push(AppRoutes.otp);
      }
      if (next.errorMessage != null) {
        AppLogger.error('📍 LoginScreen: Error - ${next.errorMessage}', tag: 'LoginScreen');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppDimensions.spacingLg.h),
                    // Location Selector
                    _buildLocationSelector(textTheme),
                    SizedBox(height: size.height * 0.06),
                    // Glassmorphic Login Card
                    GlassmorphicCard(
                      child: Padding(
                        padding: EdgeInsets.all(28.r),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // App Title
                              Text(
                                'CANDOO',
                                style: TextStyle(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 4,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.primary.withOpacity(0.5),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppDimensions.spacingSm.h),
                              Text(
                                'Welcome back. Sign in to continue',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              SizedBox(height: AppDimensions.spacing3xl.h),
                              // Phone Number Label
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Phone Number',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ),
                              SizedBox(height: AppDimensions.spacingMd.h),
                              // Phone Input Field
                              _buildPhoneInput(textTheme),
                              SizedBox(height: AppDimensions.spacingLg.h),
                              // Forgot Password Link
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Forgot Password?',
                                    style: textTheme.labelLarge?.copyWith(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: AppDimensions.spacingXxl.h),
                              // Sign In Button
                              _buildSignInButton(authState.isLoading, textTheme),
                              SizedBox(height: 28.h),
                              // Sign Up Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Are you a new member? ',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.go(AppRoutes.signup),
                                    child: Text(
                                      'Sign Up',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppDimensions.spacingLg.h),
                              TextButton(
                                onPressed: () => context.push(AppRoutes.requestAccount),
                                child: Text(
                                  'Want to host an exhibition or offer services?',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.secondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: AppDimensions.spacingLg.h),
                              // Terms and Privacy
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: textTheme.labelSmall?.copyWith(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  children: [
                                    const TextSpan(text: 'By continuing, you agree to our '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const TextSpan(text: ' & '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

  Widget _buildLocationSelector(TextTheme textTheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: () => _showCountryPicker(),
        borderRadius: BorderRadius.circular(20.r),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_outlined, color: Colors.white70, size: 18.r),
            SizedBox(width: 6.w),
            Text(_selectedCountryFlag, style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 6.w),
            Text(
              _selectedCountry,
              style: textTheme.labelLarge?.copyWith(color: Colors.white),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20.r),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput(TextTheme textTheme) {
    return Container(
      height: AppDimensions.inputHeightLg.h,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A4A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: const Color(0xFF4A4A6A).withOpacity(0.8),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 18.w),
            child: Icon(
              Icons.phone_outlined,
              color: Colors.white.withOpacity(0.5),
              size: 22.r,
            ),
          ),
          GestureDetector(
            onTap: () => _showCountryPicker(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                _selectedCountryCode,
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                cursorColor: Colors.white.withOpacity(0.6),
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
                decoration: InputDecoration(
                  hintText: '5XX XXX XXXX',
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.4),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.only(right: 18.w),
                  isDense: true,
                  isCollapsed: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton(bool isLoading, TextTheme textTheme) {
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
        onPressed: isLoading ? null : _handleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24.r,
                height: 24.r,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign In',
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

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CountryPickerSheet(
        onCountrySelected: _onCountrySelected,
      ),
    );
  }
}
