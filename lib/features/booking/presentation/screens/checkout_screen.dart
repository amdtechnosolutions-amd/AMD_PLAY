import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/court_booking_controller.dart';
import 'digital_pass_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final CourtBookingController controller;

  const CheckoutScreen({super.key, required this.controller});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.checkCustomerSession().then((_) {
      if (mounted) {
        if (_phoneController.text.isEmpty && widget.controller.customerPhone.value.isNotEmpty) {
          _phoneController.text = widget.controller.customerPhone.value;
        }
        if (_nameController.text.isEmpty && widget.controller.customerName.value.isNotEmpty) {
          _nameController.text = widget.controller.customerName.value;
        }
        if (_emailController.text.isEmpty && widget.controller.customerEmail.value.isNotEmpty) {
          _emailController.text = widget.controller.customerEmail.value;
        }
      }
    });
    if (widget.controller.customerPhone.value.isNotEmpty) {
      _phoneController.text = widget.controller.customerPhone.value;
    }
    if (widget.controller.customerName.value.isNotEmpty) {
      _nameController.text = widget.controller.customerName.value;
    }
    if (widget.controller.customerEmail.value.isNotEmpty) {
      _emailController.text = widget.controller.customerEmail.value;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedSlots = widget.controller.selectedSlots;
    final court = widget.controller.selectedCourt.value;
    final slot = widget.controller.selectedSlot.value;

    if (selectedSlots.isEmpty && (court == null || slot == null)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('No slots selected')),
      );
    }

    final dateStr = DateFormat('EEE, d MMM yyyy').format(widget.controller.selectedDate.value);
    final basePrice = widget.controller.grandBaseAmount;
    final tax = widget.controller.grandTaxAmount;
    final total = widget.controller.grandTotalAmount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirm & Pay', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hold Timer Banner
            Obx(
              () => Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3F2),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFFECDCA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: Color(0xFFD92D20), size: 20),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Slot held for ${widget.controller.holdTimeFormatted}. Complete payment to issue your 6-digit access PIN.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFFD92D20),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // 2. Booking Summary Card (Multi-Slot Support)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedSlots.length > 1
                            ? '${selectedSlots.length} Slots Reserved'
                            : (court?.name ?? selectedSlots.firstOrNull?.courtName ?? 'Court Booking'),
                        style: AppTypography.cardTitle,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          selectedSlots.length > 1
                              ? 'MULTI-SLOT'
                              : (court?.sport.toUpperCase() ?? selectedSlots.firstOrNull?.sportName.toUpperCase() ?? 'SPORTS'),
                          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  if (selectedSlots.isNotEmpty) ...[
                    ...selectedSlots.map((s) => Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${s.courtName} • ${s.timeText}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.5.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        s.date,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  '₹${s.price.toInt()}',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ] else if (court != null && slot != null) ...[
                    _summaryRow(Icons.calendar_today_outlined, dateStr),
                    SizedBox(height: 6.h),
                    _summaryRow(Icons.access_time_rounded, slot.timeText),
                  ],
                  SizedBox(height: 4.h),
                  _summaryRow(Icons.location_on_outlined, 'Inertia Sports Academy - Main Branch'),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // 2.5 Customer Profile / Smart Match
            Text('Player Details', style: AppTypography.sectionTitle),
            SizedBox(height: 10.h),
            Obx(() {
              if (widget.controller.isGuestRegistered.value || widget.controller.isStudentOrCoach) {
                final isStudent = widget.controller.isStudent;
                final isCoach = widget.controller.isCoach;
                final badgeLabel = isStudent
                    ? 'STUDENT'
                    : isCoach
                        ? 'COACH'
                        : (widget.controller.isExistingCustomer.value ? 'CUSTOMER' : 'GUEST');

                return Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isStudent ? const Color(0xFFD4AF37) : const Color(0xFF10B981),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: isStudent ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isStudent ? Icons.school_rounded : Icons.verified_user_rounded,
                          color: isStudent ? const Color(0xFFD4AF37) : const Color(0xFF10B981),
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.controller.customerName.value.isNotEmpty
                                        ? widget.controller.customerName.value
                                        : (isStudent ? 'Academy Student' : 'Guest Player'),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: isStudent ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    badgeLabel,
                                    style: TextStyle(
                                      fontSize: 9.5.sp,
                                      fontWeight: FontWeight.w800,
                                      color: isStudent ? const Color(0xFF92400E) : const Color(0xFF166534),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              widget.controller.customerPhone.value.isNotEmpty
                                  ? '+91 ${widget.controller.customerPhone.value}'
                                  : (isStudent ? 'Verified Student Account' : 'Account Authenticated'),
                              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      if (!widget.controller.isStudentOrCoach)
                        TextButton(
                          onPressed: () {
                            widget.controller.isGuestRegistered.value = false;
                          },
                          child: Text('Edit', style: TextStyle(fontSize: 12.sp, color: AppColors.primary)),
                        ),
                    ],
                  ),
                );
              }

              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 18, color: Color(0xFF64748B)),
                        SizedBox(width: 8.w),
                        Text(
                          'Quick Auto-Match (No Password Needed)',
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        counterText: '',
                        prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                        hintText: '10-digit Mobile Number *',
                        hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.badge_outlined, size: 18),
                        hintText: 'Full Name *',
                        hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined, size: 18),
                        hintText: 'Email (Optional)',
                        hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '✨ Returning player? We match your history instantly without asking for old passwords.',
                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: 24.h),

            // 3. Payment Gateway (Razorpay Exclusive)
            Text('Payment Gateway', style: AppTypography.sectionTitle),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C2340),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.flash_on_rounded, color: Color(0xFF528FF0), size: 16),
                            SizedBox(width: 4.w),
                            Text(
                              'RAZORPAY',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Razorpay Payment Gateway',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Official Payment Channel',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  SizedBox(height: 12.h),
                  Text(
                    'Accepted payment channels in gateway:',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _buildGatewayFeature(Icons.qr_code_2_rounded, 'UPI: GPay, PhonePe, Paytm, BHIM, CRED'),
                  SizedBox(height: 6.h),
                  _buildGatewayFeature(Icons.credit_card_rounded, 'Cards: Visa, MasterCard, RuPay, Maestro'),
                  SizedBox(height: 6.h),
                  _buildGatewayFeature(Icons.account_balance_rounded, 'NetBanking & Wallets (50+ banks)'),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 16),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            '100% Secure 256-Bit SSL Encrypted. Direct payments disabled.',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // 4. Itemized Price Breakdown
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price Breakdown', style: AppTypography.cardTitle),
                  SizedBox(height: 12.h),
                  _priceRow('Slot Base Rate', '₹${basePrice.toInt()}'),
                  SizedBox(height: 8.h),
                  _priceRow('GST (18% SGST/CGST)', '₹${tax.toInt()}'),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Amount', style: AppTypography.cardTitle),
                      Text(
                        '₹${total.toInt()}',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // 5. Submit Button (Razorpay Exclusive)
            Obx(
              () => AppButton(
                text: 'PAY ₹${total.toInt()} VIA RAZORPAY',
                isLoading: widget.controller.isSubmitting.value || widget.controller.isRegisteringGuest.value,
                onPressed: () async {
                  // Step 1: Only auto-register if completely unauthenticated guest
                  if (!widget.controller.isGuestRegistered.value &&
                      !widget.controller.isStudentOrCoach) {
                    final phone = _phoneController.text.trim();
                    final name = _nameController.text.trim();
                    final email = _emailController.text.trim();

                    if (phone.length < 10) {
                      Get.snackbar(
                        'Mobile Number Required',
                        'Please enter your 10-digit mobile number to generate access PIN pass',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFFFEF2F2),
                        colorText: const Color(0xFF991B1B),
                      );
                      return;
                    }
                    if (name.isEmpty) {
                      Get.snackbar(
                        'Full Name Required',
                        'Please enter player name for facility check-in',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFFFEF2F2),
                        colorText: const Color(0xFF991B1B),
                      );
                      return;
                    }

                    final registered = await widget.controller.registerGuestCustomer(
                      phone: phone,
                      name: name,
                      email: email.isNotEmpty ? email : null,
                    );
                    if (!registered) return;
                  }

                  // Step 2: Launch Razorpay Gateway & finalize booking pass
                  final pass = await widget.controller.payWithRazorpay();
                  if (pass != null) {
                    Get.off(() => DigitalPassScreen(pass: pass));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        SizedBox(width: 8.w),
        Text(text, style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _priceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildGatewayFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF2563EB)),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF334155),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
