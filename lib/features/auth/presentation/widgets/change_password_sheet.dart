import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../data/services/password_service.dart';

/// Modal sheet for logged-in Coach, Student, or Member to change password
/// via POST /api/v1/auth/change-password
class ChangePasswordBottomSheet extends StatefulWidget {
  final bool isStudent;

  const ChangePasswordBottomSheet({
    super.key,
    this.isStudent = false,
  });

  static Future<void> show({
    required BuildContext context,
    bool isStudent = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ChangePasswordBottomSheet(isStudent: isStudent),
      ),
    );
  }

  @override
  State<ChangePasswordBottomSheet> createState() => _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color darkText = Color(0xFF0F172A);
  static const Color slateText = Color(0xFF64748B);

  final PasswordService _passwordService = PasswordService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final curPass = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      await _passwordService.changePasswordLoggedIn(
        currentPassword: curPass,
        newPassword: newPass,
      );

      if (mounted) {
        Navigator.of(context).pop();
        Get.snackbar(
          'Password Updated',
          'Your account password has been changed successfully.',
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

              // Title Header
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
                        Icons.password_rounded,
                        color: const Color(0xFF9E7B1A),
                        size: 22.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change Password',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: darkText,
                          ),
                        ),
                        Text(
                          'Update your login credentials securely',
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

              // Student Initial Password Tip
              if (widget.isStudent) ...[
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF5),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0x60D4AF37), width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16.sp, color: const Color(0xFF9E7B1A)),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Tip: If you have not changed your initial password yet, your current password is typically Isa@123 or Student123!.',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11.sp,
                            color: const Color(0xFF9E7B1A),
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
              ],

              // Current Password Field
              Text(
                'Current Password',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: !_showCurrentPassword,
                style: TextStyle(fontFamily: 'Nunito', fontSize: 14.sp, color: darkText),
                decoration: InputDecoration(
                  hintText: 'Enter your existing password',
                  hintStyle: TextStyle(fontFamily: 'Nunito', fontSize: 13.sp, color: const Color(0xFF94A3B8)),
                  prefixIcon: Icon(Icons.lock_open_rounded, color: const Color(0xFF9E7B1A), size: 20.sp),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showCurrentPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: slateText,
                      size: 20.sp,
                    ),
                    onPressed: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
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
                  if (val == null || val.trim().isEmpty) return 'Please enter current password';
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
                controller: _newPasswordController,
                obscureText: !_showNewPassword,
                style: TextStyle(fontFamily: 'Nunito', fontSize: 14.sp, color: darkText),
                decoration: InputDecoration(
                  hintText: 'Enter new secure password',
                  hintStyle: TextStyle(fontFamily: 'Nunito', fontSize: 13.sp, color: const Color(0xFF94A3B8)),
                  prefixIcon: Icon(Icons.lock_outline_rounded, color: const Color(0xFF9E7B1A), size: 20.sp),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showNewPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: slateText,
                      size: 20.sp,
                    ),
                    onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
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
                  if (val.trim() != _newPasswordController.text.trim()) {
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

              // Update Button
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
                  onPressed: _isSubmitting ? null : _handleChangePassword,
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
                          'CHANGE PASSWORD',
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
}

