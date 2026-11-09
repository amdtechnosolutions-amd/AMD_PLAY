import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../data/services/password_service.dart';
import '../controllers/auth_controller.dart';

/// Full-page dedicated Forgot / Reset Password Screen
/// Supports both:
/// 1. Coach & Admin (POST /api/v1/auth/reset-password) by email
/// 2. Student Portal (POST /api/v1/auth/student/reset-password) by regNo or phone
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color darkText = Color(0xFF0F172A);
  static const Color slateText = Color(0xFF64748B);

  final PasswordService _passwordService = PasswordService();
  final _formKey = GlobalKey<FormState>();

  String _selectedRole = 'Student'; // 'Student' or 'Coach'
  bool _isStudentPhoneMode = false;

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      if (args['role'] != null) {
        _selectedRole = args['role'].toString();
      }
      if (args['identifier'] != null && args['identifier'].toString().isNotEmpty) {
        _identifierController.text = args['identifier'].toString();
        if (_selectedRole == 'Student' && RegExp(r'^[0-9]{10}$').hasMatch(_identifierController.text)) {
          _isStudentPhoneMode = true;
        }
      }
    } else if (Get.isRegistered<AuthController>()) {
      final authCtrl = Get.find<AuthController>();
      _selectedRole = authCtrl.selectedRole.value;
      if (authCtrl.identifierController.text.isNotEmpty) {
        _identifierController.text = authCtrl.identifierController.text.trim();
        if (_selectedRole == 'Student' && RegExp(r'^[0-9]{10}$').hasMatch(_identifierController.text)) {
          _isStudentPhoneMode = true;
        }
      }
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    final id = _identifierController.text.trim();
    final newPass = _passwordController.text.trim();

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      if (_selectedRole == 'Student') {
        if (_isStudentPhoneMode) {
          await _passwordService.resetStudentPasswordByPhone(
            phone: id,
            newPassword: newPass,
          );
        } else {
          await _passwordService.resetStudentPasswordByRegNo(
            regNo: id,
            newPassword: newPass,
            tenantSlug: 'gba',
          );
        }
      } else {
        await _passwordService.resetCoachOrAdminPassword(
          email: id,
          newPassword: newPass,
          tenantSlug: 'gba',
        );
      }

      if (mounted) {
        // Prefill into AuthController so user can immediately sign in
        if (Get.isRegistered<AuthController>()) {
          final authCtrl = Get.find<AuthController>();
          authCtrl.selectRole(_selectedRole);
          authCtrl.identifierController.text = id;
          authCtrl.pinController.text = newPass;
        }

        Get.snackbar(
          'Password Reset Successfully',
          'Your new password has been set. Sign in to access your portal.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: darkText,
          borderColor: const Color(0xFF10B981),
          borderWidth: 1.5,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
          icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
          duration: const Duration(seconds: 4),
        );

        // Navigate back to Login
        if (Navigator.of(context).canPop()) {
          Get.back();
        } else {
          Get.offNamed(AppRoutes.login);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final isStudent = _selectedRole == 'Student';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Reset Password',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkText),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Get.back();
            } else {
              Get.offNamed(AppRoutes.login);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 36.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand Logo / Icon Header
              Center(
                child: Container(
                  width: 80.h,
                  height: 80.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0x35D4AF37),
                        Color(0x10D4AF37),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.6, 1.0],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 54.h,
                      height: 54.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: goldAccent, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x20D4AF37),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lock_reset_rounded,
                        size: 28.sp,
                        color: const Color(0xFF9E7B1A),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Title & Subtitle
              Center(
                child: Text(
                  'Forgot Your Password?',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: darkText,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Center(
                child: Text(
                  'Select your account role and verify your registered credentials to set a new password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12.5.sp,
                    color: slateText,
                    height: 1.35,
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Role Selector Tabs (Student vs Coach / Admin)
              Row(
                children: [
                  Expanded(
                    child: _buildRoleTab(
                      title: 'Student Portal',
                      subtitle: 'Trainees & Siblings',
                      icon: Icons.school_outlined,
                      isSelected: isStudent,
                      onTap: () {
                        setState(() {
                          _selectedRole = 'Student';
                          _errorMessage = '';
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildRoleTab(
                      title: 'Coach & Staff',
                      subtitle: 'Trainers & Admin',
                      icon: Icons.sports_rounded,
                      isSelected: !isStudent,
                      onTap: () {
                        setState(() {
                          _selectedRole = 'Coach';
                          _errorMessage = '';
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Student Identifier Mode (Reg No vs Phone)
              if (isStudent) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildPillModeTab(
                        title: 'Admission Reg. No',
                        isSelected: !_isStudentPhoneMode,
                        onTap: () => setState(() => _isStudentPhoneMode = false),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildPillModeTab(
                        title: 'Mobile Phone',
                        isSelected: _isStudentPhoneMode,
                        onTap: () => setState(() => _isStudentPhoneMode = true),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],

              // Identifier Input Field
              Text(
                isStudent
                    ? (_isStudentPhoneMode ? 'Registered Mobile Number' : 'Admission / Reg. Number (regNo)')
                    : 'Account Email Address',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _identifierController,
                keyboardType: isStudent
                    ? (_isStudentPhoneMode ? TextInputType.phone : TextInputType.text)
                    : TextInputType.emailAddress,
                style: TextStyle(fontFamily: 'Nunito', fontSize: 14.sp, color: darkText),
                decoration: InputDecoration(
                  hintText: isStudent
                      ? (_isStudentPhoneMode ? 'e.g. 9876543210' : 'e.g. 1001')
                      : 'e.g. coach@example.com',
                  hintStyle: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  prefixIcon: Icon(
                    isStudent
                        ? (_isStudentPhoneMode ? Icons.phone_android_rounded : Icons.badge_outlined)
                        : Icons.email_outlined,
                    color: const Color(0xFF9E7B1A),
                    size: 20.sp,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: goldAccent, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'This field is required';
                  if (!isStudent && !val.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  if (isStudent && _isStudentPhoneMode && val.trim().length < 10) {
                    return 'Please enter a valid 10-digit mobile number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // New Password Field
              Text(
                'New Password',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                style: TextStyle(fontFamily: 'Nunito', fontSize: 14.sp, color: darkText),
                decoration: InputDecoration(
                  hintText: 'Enter new secure password',
                  hintStyle: TextStyle(fontFamily: 'Nunito', fontSize: 13.sp, color: const Color(0xFF94A3B8)),
                  prefixIcon: Icon(Icons.lock_outline_rounded, color: const Color(0xFF9E7B1A), size: 20.sp),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: slateText,
                      size: 20.sp,
                    ),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: goldAccent, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter a new password';
                  if (val.trim().length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Confirm New Password Field
              Text(
                'Confirm New Password',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                style: TextStyle(fontFamily: 'Nunito', fontSize: 14.sp, color: darkText),
                decoration: InputDecoration(
                  hintText: 'Re-enter your new password',
                  hintStyle: TextStyle(fontFamily: 'Nunito', fontSize: 13.sp, color: const Color(0xFF94A3B8)),
                  prefixIcon: Icon(Icons.lock_outline_rounded, color: const Color(0xFF9E7B1A), size: 20.sp),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: slateText,
                      size: 20.sp,
                    ),
                    onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: goldAccent, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please confirm your new password';
                  if (val.trim() != _passwordController.text.trim()) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              // Error Display Box
              if (_errorMessage.isNotEmpty) ...[
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, size: 20.sp, color: const Color(0xFFDC2626)),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12.5.sp,
                            color: const Color(0xFFDC2626),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 28.h),

              // Submit Action Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _handleReset,
                  child: _isSubmitting
                      ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.6,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'RESET PASSWORD',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 18.h),

              // Back to Login Link
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Get.back();
                    } else {
                      Get.offNamed(AppRoutes.login);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_rounded, size: 14.sp, color: const Color(0xFF9E7B1A)),
                      SizedBox(width: 4.w),
                      Text(
                        'Back to Sign In',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF9E7B1A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFDF5) : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? goldAccent : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x20D4AF37),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0x20D4AF37) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16.sp, color: isSelected ? const Color(0xFF9E7B1A) : slateText),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10.sp,
                      color: slateText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillModeTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFDF5) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? goldAccent : const Color(0xFFE2E8F0),
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? const Color(0xFF9E7B1A) : slateText,
            ),
          ),
        ),
      ),
    );
  }
}

