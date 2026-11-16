import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Screen presenting official Merchant, Business & Legal Information for
/// Payment Gateway (Cashfree / Razorpay) compliance & user transparency.
class MerchantLegalInfoScreen extends StatelessWidget {
  const MerchantLegalInfoScreen({super.key});

  static const String businessLegalName = 'TEAM INERTIA ENTERPRISES';
  static const String proprietorLegalName = 'KRISHNAN ROHITH KUMAR';
  static const String officialEmail = 'Teaminertia3499@gmail.com';
  static const String officialPhone = '9789006925';
  static const String officialPhoneFormatted = '+91 97890 06925';
  static const String brandName = 'Inertia Sports Academy';

  @override
  Widget build(BuildContext context) {
    const goldAccent = Color(0xFFD4AF37);
    const darkSlate = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Merchant & Legal Information',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: darkSlate,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkSlate, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Primary Verified Merchant Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0x60D4AF37), width: 1.3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x18D4AF37),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDF5),
                          shape: BoxShape.circle,
                          border: Border.all(color: goldAccent, width: 1.5),
                        ),
                        child: Icon(Icons.verified_rounded, color: goldAccent, size: 26.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(color: const Color(0xFF10B981)),
                              ),
                              child: Text(
                                'OFFICIAL REGISTERED ENTITY',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 9.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF059669),
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              businessLegalName,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                color: darkSlate,
                                letterSpacing: 0.2,
                              ),
                            ),
                            Text(
                              'Trade Name: $brandName',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  const Divider(color: Color(0x20D4AF37), height: 1),
                  SizedBox(height: 14.h),

                  // Detail Rows
                  _buildLegalInfoRow(
                    label: 'Proprietor / Legal Name',
                    value: proprietorLegalName,
                    icon: Icons.person_rounded,
                    canCopy: true,
                  ),
                  SizedBox(height: 12.h),
                  _buildLegalInfoRow(
                    label: 'Support & Billing Email',
                    value: officialEmail,
                    icon: Icons.alternate_email_rounded,
                    canCopy: true,
                  ),
                  SizedBox(height: 12.h),
                  _buildLegalInfoRow(
                    label: 'Customer Support Helpline',
                    value: officialPhoneFormatted,
                    copyValue: officialPhone,
                    icon: Icons.phone_android_rounded,
                    canCopy: true,
                  ),
                  SizedBox(height: 12.h),
                  _buildLegalInfoRow(
                    label: 'Payment Gateway Partner',
                    value: 'Cashfree Payments & Authorized Aggregators',
                    icon: Icons.security_rounded,
                    valueColor: const Color(0xFF059669),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // 2. Compliance Notice Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, color: const Color(0xFF2563EB), size: 20.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'All commercial transactions, fee settlements, and slot reservations on this application are legally operated and fulfilled by $businessLegalName ($proprietorLegalName).',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E40AF),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // 3. Policy & Governance Cards
            Text(
              'Merchant Policies & Governance',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: darkSlate,
              ),
            ),
            SizedBox(height: 12.h),

            _buildPolicyCard(
              title: 'Cancellation & Refund Policy',
              icon: Icons.replay_rounded,
              accentColor: const Color(0xFFD4AF37),
              content: [
                '• Court & Turf Slot Bookings: Cancellations requested at least 24 hours prior to the reserved slot start time are eligible for a 100% refund.',
                '• Late Cancellations: Cancellations requested within 24 hours of the reserved slot are non-refundable due to facility hold allocation.',
                '• Academy Coaching Fees: Monthly coaching batch fees are non-refundable once the batch cycle commences.',
                '• Refund Settlement Timeline: Approved refunds are processed back to the original source account (UPI / Card / NetBanking via Cashfree / Razorpay) within 5 to 7 business banking days.',
              ],
            ),
            SizedBox(height: 14.h),

            _buildPolicyCard(
              title: 'Terms of Service & Facility Rules',
              icon: Icons.gavel_rounded,
              accentColor: const Color(0xFF2563EB),
              content: [
                '• All players and trainees must carry non-marking badminton shoes on synthetic/wooden courts.',
                '• Admission to courts requires valid 6-digit PIN pass or QR code issued at booking checkout.',
                '• Trainees must adhere to coaching squad schedules and safety regulations enforced by academy staff.',
                '• Management reserves the right of admission to maintain safe and sportsmanlike environment.',
              ],
            ),
            SizedBox(height: 14.h),

            _buildPolicyCard(
              title: 'Privacy & Data Protection',
              icon: Icons.lock_outline_rounded,
              accentColor: const Color(0xFF10B981),
              content: [
                '• We collect player contact information (phone number, name) strictly to verify access passes and dispatch booking notifications.',
                '• We do not store sensitive payment card details or net banking credentials on our servers.',
                '• All online transactions are tokenized and processed through PCI-DSS compliant payment gateways (Cashfree / Razorpay).',
                '• Your private data is never sold or shared with unauthorized third-party advertisers.',
              ],
            ),
            SizedBox(height: 14.h),

            // 4. Contact Us & Grievance Redressal Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.headset_mic_rounded, color: goldAccent, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Customer Care & Grievance Officer',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w800,
                          color: darkSlate,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'For payment queries, booking rescheduling, or grievance redressal, please reach out directly to our designated representative:',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11.5.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Officer: $proprietorLegalName',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: darkSlate,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Email: $officialEmail',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12.sp,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Contact Phone: $officialPhoneFormatted',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12.sp,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Operating Hours: 06:00 AM - 10:00 PM IST (All 7 Days)',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
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

  Widget _buildLegalInfoRow({
    required String label,
    required String value,
    String? copyValue,
    required IconData icon,
    bool canCopy = false,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: const Color(0xFF94A3B8)),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: valueColor ?? const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        if (canCopy)
          IconButton(
            icon: Icon(Icons.copy_rounded, size: 16.sp, color: const Color(0xFFD4AF37)),
            tooltip: 'Copy $label',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: copyValue ?? value));
              Get.snackbar(
                'Copied to Clipboard',
                '$label copied to clipboard',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF0F172A),
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(16),
                borderRadius: 10,
              );
            },
          ),
      ],
    );
  }

  Widget _buildPolicyCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<String> content,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: accentColor, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...content.map(
            (point) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Text(
                point,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11.5.sp,
                  color: const Color(0xFF475569),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
