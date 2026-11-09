import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../auth/data/services/password_service.dart';

/// Dialog allowing Coaches / Admins to directly assign a new password for a student
/// via POST /api/v1/students/:id/reset-password
class DirectStudentPasswordResetDialog extends StatefulWidget {
  final String studentId;
  final String studentName;

  const DirectStudentPasswordResetDialog({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  static Future<void> show({
    required BuildContext context,
    required String studentId,
    required String studentName,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => DirectStudentPasswordResetDialog(
        studentId: studentId,
        studentName: studentName,
      ),
    );
  }

  @override
  State<DirectStudentPasswordResetDialog> createState() =>
      _DirectStudentPasswordResetDialogState();
}

class _DirectStudentPasswordResetDialogState
    extends State<DirectStudentPasswordResetDialog> {
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color darkText = Color(0xFF0F172A);

  final PasswordService _passwordService = PasswordService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSubmitting = false;
  bool _showPassword = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    final newPass = _passwordController.text.trim();
    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      await _passwordService.directResetStudentPassword(
        studentId: widget.studentId,
        newPassword: newPass,
      );

      if (mounted) {
        Navigator.of(context).pop();
        Get.snackbar(
          'Password Assigned',
          'New password has been assigned for ${widget.studentName}.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: darkText,
          borderColor: const Color(0xFF10B981),
          borderWidth: 1.5,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
          icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38.h,
                    height: 38.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF5),
                      shape: BoxShape.circle,
                      border: Border.all(color: goldAccent, width: 1.2),
                    ),
                    child: Center(
                      child: Icon(Icons.vpn_key_rounded, size: 20.sp, color: const Color(0xFF9E7B1A)),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Direct Password Reset',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            color: darkText,
                          ),
                        ),
                        Text(
                          widget.studentName,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Color(0x20D4AF37), height: 20),
              Text(
                'Assign New Password',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                style: TextStyle(fontFamily: 'Nunito', fontSize: 13.5.sp, color: darkText),
                decoration: InputDecoration(
                  hintText: 'Enter new assigned password',
                  hintStyle: TextStyle(fontFamily: 'Nunito', fontSize: 12.5.sp, color: const Color(0xFF94A3B8)),
                  prefixIcon: Icon(Icons.lock_outline_rounded, color: const Color(0xFF9E7B1A), size: 18.sp),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: const Color(0xFF64748B),
                      size: 18.sp,
                    ),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: goldAccent, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Password required';
                  if (val.trim().length < 6) return 'At least 6 characters required';
                  return null;
                },
              ),
              if (_errorMessage.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Text(
                  _errorMessage,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11.5.sp,
                    color: const Color(0xFFDC2626),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              SizedBox(height: 18.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    ),
                    onPressed: _isSubmitting ? null : _handleReset,
                    child: _isSubmitting
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'ASSIGN PASSWORD',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

