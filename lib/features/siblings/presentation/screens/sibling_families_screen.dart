import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../data/models/sibling_models.dart';
import '../controllers/sibling_controller.dart';

/// Screen for Coaches & Academy Admins to view all Sibling Family Groups,
/// link existing students into a sibling group, update personal sibling phone
/// numbers, and unlink students cleanly.
class SiblingFamiliesScreen extends StatelessWidget {
  const SiblingFamiliesScreen({super.key});

  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color darkText = Color(0xFF0F172A);
  static const Color slateText = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<SiblingController>()
        ? Get.find<SiblingController>()
        : Get.put(SiblingController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Sibling Families',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkText),
                onPressed: () => Get.back(),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: goldAccent),
            tooltip: 'Refresh Sibling Families',
            onPressed: () => controller.fetchFamilies(page: 1),
          ),
          IconButton(
            icon: const Icon(Icons.group_add_outlined, color: goldAccent),
            tooltip: 'Link Siblings',
            onPressed: () => _openLinkSiblingsSheet(context, controller),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openLinkSiblingsSheet(context, controller),
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: goldAccent, width: 1.5),
        ),
        icon: const Icon(Icons.link_rounded, color: Color(0xFF9E7B1A)),
        label: Text(
          'LINK SIBLINGS',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w900,
            color: darkText,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: goldAccent,
        backgroundColor: Colors.white,
        onRefresh: () => controller.fetchFamilies(page: 1),
        child: Column(
          children: [
            _buildSearchHeader(controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.families.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: goldAccent, strokeWidth: 2.5),
                        SizedBox(height: 14.h),
                        Text(
                          'Loading sibling family groups...',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: slateText,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.hasError.value && controller.families.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 60.h),
                    child: EmptyState(
                      title: 'Sibling Data Unavailable',
                      message: controller.errorMessage.value.isNotEmpty
                          ? controller.errorMessage.value
                          : 'Unable to retrieve sibling families right now.',
                      icon: Icons.family_restroom_rounded,
                      buttonText: 'RETRY',
                      onButtonPressed: () => controller.fetchFamilies(page: 1),
                    ),
                  );
                }

                if (controller.families.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 60.h),
                    child: EmptyState(
                      title: 'No Sibling Families Found',
                      message: controller.searchQuery.value.isNotEmpty
                          ? 'No family groups match "${controller.searchQuery.value}".'
                          : 'No linked sibling families yet. Tap "Link Siblings" to connect enrolled students.',
                      icon: Icons.family_restroom_rounded,
                      buttonText: 'LINK EXISTING SIBLINGS',
                      onButtonPressed: () => _openLinkSiblingsSheet(context, controller),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 96.h),
                  itemCount: controller.families.length,
                  itemBuilder: (context, index) {
                    return _buildFamilyCard(context, controller.families[index], controller);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(SiblingController controller) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0x60D4AF37), width: 1.1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10D4AF37),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          onSubmitted: controller.updateSearch,
          onChanged: (val) {
            if (val.isEmpty) controller.updateSearch('');
          },
          textInputAction: TextInputAction.search,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w600,
            color: darkText,
          ),
          decoration: InputDecoration(
            hintText: 'Search parent, phone, student name or Reg No...',
            hintStyle: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12.5.sp,
              color: const Color(0xFF94A3B8),
            ),
            prefixIcon: Icon(Icons.search_rounded, size: 18.sp, color: goldAccent),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyCard(
    BuildContext context,
    SiblingFamilyGroupModel family,
    SiblingController controller,
  ) {
    final parentTitle = family.parentName.isNotEmpty ? family.parentName : 'Family Group';

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0x60D4AF37), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F172A),
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
                width: 42.h,
                height: 42.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF5),
                  shape: BoxShape.circle,
                  border: Border.all(color: goldAccent, width: 1.2),
                ),
                child: Icon(Icons.family_restroom_rounded, color: const Color(0xFF9E7B1A), size: 21.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parentTitle,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                    if (family.familyPhone.isNotEmpty)
                      Text(
                        'Family Phone: ${family.familyPhone}',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12.sp,
                          color: slateText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF5),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: goldAccent, width: 1.0),
                ),
                child: Text(
                  '${family.studentCount} SIBLINGS',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF9E7B1A),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          SizedBox(height: 10.h),
          ...family.students.map((st) => _buildStudentRow(context, st, family, controller)),
        ],
      ),
    );
  }

  Widget _buildStudentRow(
    BuildContext context,
    SiblingStudentModel student,
    SiblingFamilyGroupModel family,
    SiblingController controller,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17.r,
            backgroundColor: const Color(0x20D4AF37),
            child: Text(
              student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : 'S',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF9E7B1A),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
                Text(
                  [
                    if (student.regNo.isNotEmpty) student.regNo,
                    if (student.batchName.isNotEmpty) student.batchName,
                  ].join(' • '),
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11.5.sp,
                    color: slateText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (student.phone.isNotEmpty)
                  Text(
                    'Mobile: ${student.phone}',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11.sp,
                      color: const Color(0xFF475569),
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: slateText, size: 20),
            onSelected: (action) {
              if (action == 'phone') {
                _openUpdatePhoneDialog(context, student, family, controller);
              } else if (action == 'unlink') {
                _confirmUnlinkDialog(context, student, controller);
              } else if (action == 'details') {
                _showStudentSiblingsModal(context, student, controller);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'details',
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: darkText),
                    SizedBox(width: 8),
                    Text('View Sibling Roster'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'phone',
                child: Row(
                  children: [
                    Icon(Icons.phone_android_rounded, size: 18, color: Color(0xFF9E7B1A)),
                    SizedBox(width: 8),
                    Text('Update Mobile Number'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'unlink',
                child: Row(
                  children: [
                    Icon(Icons.link_off_rounded, size: 18, color: Color(0xFFEF4444)),
                    SizedBox(width: 8),
                    Text('Unlink from Group', style: TextStyle(color: Color(0xFFEF4444))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openLinkSiblingsSheet(BuildContext context, SiblingController controller) {
    controller.loadStudentDropdown();
    String? masterStudentId;
    String? newStudentId;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Link Existing Siblings',
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
                  Text(
                    'Select the Master Student and Sibling Student. Parent contact and family group ID are inherited automatically.',
                    style: TextStyle(fontFamily: 'Nunito', fontSize: 12.sp, color: slateText),
                  ),
                  SizedBox(height: 16.h),
                  Obx(() {
                    if (controller.isLoadingStudents.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: goldAccent),
                        ),
                      );
                    }

                    final options = controller.studentOptions;
                    if (options.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Text(
                          'No enrolled students available to link.',
                          style: TextStyle(fontFamily: 'Nunito', fontSize: 13.sp, color: slateText),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Master / Primary Student',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: masterStudentId,
                          decoration: _dropdownDecoration('Select Master Student'),
                          items: options.map((s) {
                            final id = (s['id'] ?? s['value'] ?? s['_id'] ?? '').toString();
                            final label = (s['label'] ?? s['name'] ?? id).toString();
                            return DropdownMenuItem(value: id, child: Text(label, overflow: TextOverflow.ellipsis));
                          }).toList(),
                          onChanged: (val) => setModalState(() => masterStudentId = val),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          'New / Sibling Student',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: newStudentId,
                          decoration: _dropdownDecoration('Select Sibling Student'),
                          items: options.map((s) {
                            final id = (s['id'] ?? s['value'] ?? s['_id'] ?? '').toString();
                            final label = (s['label'] ?? s['name'] ?? id).toString();
                            return DropdownMenuItem(value: id, child: Text(label, overflow: TextOverflow.ellipsis));
                          }).toList(),
                          onChanged: (val) => setModalState(() => newStudentId = val),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: 22.h),
                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: goldAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          ),
                          onPressed: controller.isSubmitting.value
                              ? null
                              : () async {
                                  final ok = await controller.linkStudents(
                                    masterStudentId: masterStudentId ?? '',
                                    newStudentId: newStudentId ?? '',
                                  );
                                  if (ok) Get.back();
                                },
                          child: controller.isSubmitting.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'LINK AS SIBLINGS',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      )),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontFamily: 'Nunito', fontSize: 13.sp, color: const Color(0xFF94A3B8)),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0x60D4AF37)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: goldAccent, width: 1.5),
      ),
    );
  }

  void _openUpdatePhoneDialog(
    BuildContext context,
    SiblingStudentModel student,
    SiblingFamilyGroupModel family,
    SiblingController controller,
  ) {
    final phoneCtrl = TextEditingController(text: student.phone);
    final parentPhoneCtrl = TextEditingController(
      text: student.parentPhone.isNotEmpty ? student.parentPhone : family.familyPhone,
    );
    final parentNameCtrl = TextEditingController(
      text: student.parentName.isNotEmpty ? student.parentName : family.parentName,
    );

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Text(
          'Update Sibling Mobile',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: darkText),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${student.fullName} (${student.regNo}) stays in the family group.',
                style: TextStyle(fontFamily: 'Nunito', fontSize: 12.sp, color: slateText),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: _dropdownDecoration('Student Personal Mobile *'),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: parentPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: _dropdownDecoration('Parent Phone (Optional)'),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: parentNameCtrl,
                decoration: _dropdownDecoration('Parent Name (Optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: slateText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: goldAccent, foregroundColor: Colors.white),
            onPressed: () async {
              final phone = phoneCtrl.text.trim();
              if (phone.isEmpty) return;
              Get.back();
              await controller.updateStudentPhone(
                studentId: student.studentId,
                phone: phone,
                parentPhone: parentPhoneCtrl.text.trim(),
                parentName: parentNameCtrl.text.trim(),
              );
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _confirmUnlinkDialog(
    BuildContext context,
    SiblingStudentModel student,
    SiblingController controller,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Text(
          'Unlink Student?',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: darkText),
        ),
        content: Text(
          'Remove ${student.fullName} from this sibling family group? If only 1 student remains, that student will reset to single status.',
          style: TextStyle(fontFamily: 'Nunito', fontSize: 13.sp, color: slateText),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: slateText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            onPressed: () async {
              Get.back();
              await controller.unlinkStudent(student.studentId);
            },
            child: const Text('UNLINK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showStudentSiblingsModal(
    BuildContext context,
    SiblingStudentModel student,
    SiblingController controller,
  ) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: goldAccent)),
      barrierDismissible: false,
    );
    final details = await controller.fetchStudentSiblings(student.studentId);
    Get.back();
    if (details == null) return;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sibling Roster: ${details.student?.fullName ?? student.fullName}',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 17.sp, fontWeight: FontWeight.w800, color: darkText),
            ),
            SizedBox(height: 4.h),
            Text(
              'Parent: ${details.parentName.isNotEmpty ? details.parentName : 'N/A'} • Family Phone: ${details.familyPhone.isNotEmpty ? details.familyPhone : 'N/A'}',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 12.sp, color: slateText),
            ),
            SizedBox(height: 14.h),
            if (details.siblings.isEmpty)
              Text(
                'No other siblings linked to this student.',
                style: TextStyle(fontFamily: 'Nunito', fontSize: 13.sp, color: slateText),
              )
            else
              ...details.siblings.map((sib) => Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF5),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0x60D4AF37)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, color: Color(0xFF9E7B1A)),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${sib.fullName} ${sib.regNo.isNotEmpty ? "(${sib.regNo})" : ""}',
                                style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: darkText),
                              ),
                              Text(
                                '${sib.batchName.isNotEmpty ? sib.batchName : "Active Batch"} • ${sib.phone}',
                                style: TextStyle(fontFamily: 'Nunito', fontSize: 11.5.sp, color: slateText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
