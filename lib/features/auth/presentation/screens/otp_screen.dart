import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../router/routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_background.dart';
import '../widgets/glassmorphic_card.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _resendTimer;
  int _resendSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var n in _focusNodes) n.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _canResend = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
    if (_otp.length == 6) _verifyOtp();
  }

  void _onKeyDown(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verifyOtp() {
    if (_otp.length == 6) ref.read(authNotifierProvider.notifier).verifyOtp(_otp);
  }

  void _clearOtp() {
    for (var c in _controllers) c.clear();
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final textTheme = Theme.of(context).textTheme;

    ref.listen(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.profileIncomplete) {
        context.go(AppRoutes.completeProfile);
      } else if (next.status == AuthStatus.authenticated) {
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
        _clearOtp();
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
                    SizedBox(height: AppDimensions.spacingLg.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildBackButton(),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                    GlassmorphicCard(
                      child: Padding(
                        padding: EdgeInsets.all(28.r),
                        child: Column(
                          children: [
                            // Icon
                            Container(
                              width: 80.r,
                              height: 80.r,
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
                              child: Icon(Icons.message_outlined, size: 36.r, color: Colors.white),
                            ),
                            SizedBox(height: AppDimensions.spacingXxl.h),
                            // Title
                            Text(
                              'Verify Your Number',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: AppDimensions.spacingSm.h),
                            Text(
                              'Enter the 6-digit code sent to your phone',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: AppDimensions.spacing3xl.h),
                            // OTP Input Fields
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                return Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: index < 5 ? 8.w : 0),
                                    child: _buildOtpField(index, textTheme),
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: AppDimensions.spacing3xl.h),
                            _buildVerifyButton(authState.isLoading, textTheme),
                            SizedBox(height: AppDimensions.spacingXxl.h),
                            _buildResendSection(authState.isLoading, textTheme),
                          ],
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

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(Icons.arrow_back, color: Colors.white, size: 20.r),
      ),
    );
  }

  Widget _buildOtpField(int index, TextTheme textTheme) {
    return SizedBox(
      height: 55.h,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) => _onKeyDown(event, index),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => _onOtpChanged(value, index),
        ),
      ),
    );
  }

  Widget _buildVerifyButton(bool isLoading, TextTheme textTheme) {
    final isComplete = _otp.length == 6;
    return Container(
      width: double.infinity,
      height: AppDimensions.buttonHeightLg.h,
      decoration: BoxDecoration(
        gradient: isComplete
            ? LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isComplete ? null : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: isComplete
            ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading || !isComplete ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
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
                    'Verify',
                    style: textTheme.bodyLarge?.copyWith(
                      color: isComplete ? Colors.white : Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacingSm.w),
                  Icon(
                    Icons.check,
                    color: isComplete ? Colors.white : Colors.white.withOpacity(0.5),
                    size: 20.r,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildResendSection(bool isLoading, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive code? ",
          style: textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.7)),
        ),
        if (_canResend)
          GestureDetector(
            onTap: isLoading ? null : () => context.pop(),
            child: Text(
              'Resend',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          Text(
            'Resend in ${_resendSeconds}s',
            style: textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.5)),
          ),
      ],
    );
  }
}
