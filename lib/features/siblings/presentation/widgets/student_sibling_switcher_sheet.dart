import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../data/models/sibling_models.dart';
import '../../data/services/sibling_service.dart';

/// Bottom Sheet showing all Sibling Profiles enrolled in the student's family
/// via GET /api/v1/students/my/siblings & GET /api/v1/students/:id/siblings
/// with 1-tap switching via POST /api/v1/auth/student/switch-profile.
class StudentSiblingSwitcherSheet {
  StudentSiblingSwitcherSheet._();

  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color darkText = Color(0xFF0F172A);
  static const Color slateText = Color(0xFF64748B);

  static Future<void> show(HomeController homeCtrl) async {
    final service = SiblingService();
    final activeId = homeCtrl.currentStudentId.value;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: FutureBuilder<StudentSiblingDetailsModel>(
          future: service.getMyProfile(),
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            final details = snapshot.data;

            // Combine current student + sibling profiles cleanly
            final List<SiblingStudentModel> allProfiles = [];
            if (details?.student != null) {
              allProfiles.add(details!.student!);
            }
            final seen = allProfiles.map((e) => e.studentId).toSet();
            for (final sib in (details?.siblings ?? const <SiblingStudentModel>[])) {
              if (sib.studentId.isNotEmpty && !seen.contains(sib.studentId)) {
                seen.add(sib.studentId);
                allProfiles.add(sib);
              }
            }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Family & Sibling Profiles',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: darkText,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: slateText),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                    if (details != null &&
                        (details.parentName.isNotEmpty || details.familyPhone.isNotEmpty)) ...[
                      Text(
                        [
                          if (details.parentName.isNotEmpty) 'Parent: ${details.parentName}',
                          if (details.familyPhone.isNotEmpty) 'Family: ${details.familyPhone}',
                        ].join(' • '),
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12.sp,
                          color: slateText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ] else ...[
                      Text(
                        'Tap any sibling profile below to switch active student view.',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12.sp,
                          color: slateText,
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(child: CircularProgressIndicator(color: goldAccent)),
                      )
                    else if (allProfiles.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Text(
                          'No other sibling profiles linked to this account yet.',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13.5.sp,
                            color: slateText,
                          ),
                        ),
                      )
                    else
                      ...allProfiles.map((profile) {
                        final isCurrent = profile.studentId == activeId;
                        final subtitleParts = <String>[
                          if (profile.regNo.isNotEmpty) profile.regNo,
                          if (profile.batchName.isNotEmpty) profile.batchName,
                          if (profile.enrollments.isNotEmpty) profile.enrollments.first.scheduleText,
                        ];

                        return GestureDetector(
                          onTap: () {
                            if (!isCurrent && profile.studentId.isNotEmpty) {
                              Get.back();
                              if (Get.isRegistered<ProfileController>()) {
                                Get.find<ProfileController>().switchStudentProfile(profile.studentId, homeCtrl);
                              } else {
                                homeCtrl.switchProfile(profile.studentId);
                              }
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10.h),
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: isCurrent ? const Color(0xFFFFFDF5) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: isCurrent ? goldAccent : const Color(0xFFE2E8F0),
                                width: isCurrent ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20.r,
                                  backgroundColor: isCurrent ? goldAccent : const Color(0xFFE2E8F0),
                                  child: Text(
                                    profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'S',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w900,
                                      color: isCurrent ? Colors.white : darkText,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.fullName,
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 14.5.sp,
                                          fontWeight: FontWeight.w800,
                                          color: darkText,
                                        ),
                                      ),
                                      if (subtitleParts.isNotEmpty)
                                        Text(
                                          subtitleParts.join(' • '),
                                          style: TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 11.5.sp,
                                            color: slateText,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (isCurrent)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0x2010B981),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      'ACTIVE',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF059669),
                                      ),
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.swap_horiz_rounded,
                                    color: const Color(0xFF9E7B1A),
                                    size: 20.sp,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                );
              },
            ),
          ),
          isScrollControlled: true,
        );
      }
    }

