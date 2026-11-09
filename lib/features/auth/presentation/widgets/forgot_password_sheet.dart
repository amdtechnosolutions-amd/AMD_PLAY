import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../data/services/password_service.dart';

/// Interactive luxury modal sheet allowing Students, Coaches & Members
/// to reset their forgotten passwords via live endpoints:
/// - POST /api/v1/auth/student/reset-password (by regNo or phone)
/// - POST /api/v1/auth/reset-password (by email)
class ForgotPasswordBottomSheet extends StatefulWidget {
  final String initialRole; // 'Student', 'Coach', or 'Member'
  final String? initialIdentifier;
  final Function(String identifier, String newPassword)? onSuccess;

  const ForgotPasswordBottomSheet({
    super.key,
    required this.initialRole,
    this.initialIdentifier,
    this.onSuccess,
  });

  static Future<void> show({
    required BuildContext context,
    required String initialRole,
    String? initialIdentifier,
    Function(String identifier, String newPassword)? onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ForgotPasswordBottomSheet(
          initialRole: initialRole,
          initialIdentifier: initialIdentifier,
          onSuccess: onSuccess,
        ),
      ),
    );
  }

  @override
  State<ForgotPasswordBottomSheet> createState() => _ForgotPasswordBottomSheetState();
}

class _ForgotPasswordBottomSheetState extends State<ForgotPasswordBottomSheet> {
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color darkText = Color(0xFF0F172A);
  static const Color slateText = Color(0xFF64748B);

  final PasswordService _passwordService = PasswordService();
  final _formKey = GlobalKey<FormState>();

  late String _role;
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
    _role = widget.initialRole;
    if (widget.initialIdentifier != null && widget.initialIdentifier!.trim().isNotEmpty) {
      _identifierController.text = widget.initialIdentifier!.trim();
      if (_role == 'Student' && RegExp(r'^[0-9]{10}$').hasMatch(widget.initialIdentifier!.trim())) {
        _isStudentPhoneMode = true;
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
      if (_role == 'Student') {
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
        Navigator.of(context).pop();
        Get.snackbar(
          'Password Reset Successfully',
          'Your new password has been set. You can now sign in.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: const Color(0xFF0F172A),
          borderColor: const Color(0xFF10B981),
          borderWidth: 1.5,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
          icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
          duration: const Duration(seconds: 4),
        );

        widget.onSuccess?.call(id, newPass);
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
    final isStudent = _role == 'Student';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              // Header: Icon + Title
              Row(
                children: [
                  Container(
                    width: 42.h,
                    height: 42.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF5),
                      shape: BoxShape.circle,
                      border: Border.all(color: goldAccent, width: 1.5),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock_reset_rounded,
                        color: const Color(0xFF9E7B1A),
                        size: 24.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isStudent ? 'Reset Student Password' : 'Reset Account Password',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: darkText,
                          ),
                        ),
                        Text(
                          isStudent
                              ? 'Enter your Reg. No or registered mobile to set a new password'
                              : 'Enter your registered email to set a new password',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11.5.sp,
                            color: slateText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Color(0x20D4AF37), height: 24),

              // Student Identifier Mode Switch (Reg No vs Phone)
              if (isStudent) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildModeTab(
                        title: 'Admission Reg. No',
                        isSelected: !_isStudentPhoneMode,
                        onTap: () => setState(() => _isStudentPhoneMode = false),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildModeTab(
                        title: 'Mobile Number',
                        isSelected: _isStudentPhoneMode,
                        onTap: () => setState(() => _isStudentPhoneMode = true),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
              ],

              // Identifier Field (Reg No / Phone / Email)
              Text(
                isStudent
                    ? (_isStudentPhoneMode ? 'Registered Mobile Number' : 'Admission / Reg. Number')
                    : 'Account Email Address',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.sp,
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
                  hintStyle: TextStyle(fontFamily: 'Nunito', fontSize: 13.sp, color: const Color(0xFF94A3B8)),
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
                  if (val == null || val.trim().isEmpty) {
                    return 'This field is required';
                  }
                  if (!isStudent && !val.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  if (isStudent && _isStudentPhoneMode && val.trim().length < 10) {
                    return 'Please enter a valid 10-digit mobile number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 14.h),

              // New Password Field
              Text(
                'New Password',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.sp,
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
              SizedBox(height: 14.h),

              // Confirm New Password Field
              Text(
                'Confirm New Password',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.sp,
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
                  hintText: 'Re-enter new password',
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

              // Error Message
              if (_errorMessage.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, size: 18.sp, color: const Color(0xFFDC2626)),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12.sp,
                            color: const Color(0xFFDC2626),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 22.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  onPressed: _isSubmitting ? null : _handleReset,
                  child: _isSubmitting
                      ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeTab({
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
