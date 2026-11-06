import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class MembershipPassesScreen extends StatelessWidget {
  const MembershipPassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Academy Memberships', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Current Active Pass Card
            _buildActivePassCard(),
            SizedBox(height: 24.h),

            // 2. Available Membership Plans
            Text('Explore Subscription Passes', style: AppTypography.sectionTitle),
            SizedBox(height: 12.h),

            _buildPlanCard(
              title: 'Gold All-Access Pro',
              price: '₹5,999/mo',
              sportTag: 'All Sports (Badminton, Tennis, Turf)',
              isCurrent: true,
              features: [
                '25 Hours / Month court quota included',
                'Unlimited off-peak court reservations',
                '30% Off peak & weekend slot bookings',
                'Priority IoT turnstile entry PIN',
                '2 Free guest passes / month',
              ],
            ),
            SizedBox(height: 16.h),

            _buildPlanCard(
              title: 'Silver Racquet Pass',
              price: '₹2,499/mo',
              sportTag: 'Single Sport (Badminton or Tennis)',
              isCurrent: false,
              features: [
                '10 Hours / Month court quota',
                '20% Off off-peak court hours',
                '1-Week advance booking window',
                'Member locker room access',
              ],
            ),
            SizedBox(height: 16.h),

            _buildPlanCard(
              title: 'Platinum Annual Franchise',
              price: '₹49,999/yr',
              sportTag: 'Franchise Multi-Branch Access',
              isCurrent: false,
              features: [
                'Unlimited multi-branch bookings',
                'VIP court reservation lock guarantees',
                'Complimentary tournament entries',
                'Personal fitness coach consultation',
              ],
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePassCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: const Text(
                  'ACTIVE SUBSCRIBER',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF34D399)),
                ),
              ),
              const Icon(Icons.verified_rounded, color: Color(0xFF34D399), size: 22),
            ],
          ),
          SizedBox(height: 14.h),
          Text('Gold All-Access Pro Pass',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
          Text('Member ID: #APX-4910 • Valid until Dec 31, 2026',
              style: TextStyle(fontSize: 12.sp, color: Colors.white70)),
          SizedBox(height: 18.h),

          // Quota Usage Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly Court Hours', style: TextStyle(fontSize: 12.sp, color: Colors.white70)),
              Text('18 / 25 Hours Used',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: 18 / 25,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String sportTag,
    required bool isCurrent,
    required List<String> features,
  }) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isCurrent ? AppColors.primary : Colors.grey.shade200,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.cardTitle),
              Text(price, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ],
          ),
          SizedBox(height: 2.h),
          Text(sportTag, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
          const Divider(height: 20),
          ...features.map(
            (f) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(f, style: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary)),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Get.snackbar(
                  'Membership',
                  isCurrent ? 'You are currently active on this pass' : 'Upgrading to $title',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: isCurrent ? AppColors.primary : AppColors.textPrimary,
                side: BorderSide(color: isCurrent ? AppColors.primary : Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: Text(isCurrent ? 'CURRENT PASS' : 'UPGRADE TO PLAN'),
            ),
          ),
        ],
      ),
    );
  }
}
