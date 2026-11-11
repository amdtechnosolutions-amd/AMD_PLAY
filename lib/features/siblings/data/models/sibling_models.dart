/// Models for Sibling Family Groups, Student Sibling Records,
/// and Mobile App Profile Switcher matching /api/v1/students/.../siblings.
class SiblingBatchScheduleFormatter {
  SiblingBatchScheduleFormatter._();

  static const Map<int, String> _dayNames = {
    0: 'Sun',
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun',
  };

  /// Formats either a String or a backend Map schedule:
  /// `{ "daysOfWeek": [1, 3, 5], "startTime": "17:00", "endTime": "18:30" }`
  static String format(dynamic rawSchedule, {String fallback = 'Active Coaching'}) {
    if (rawSchedule == null) return fallback;
    if (rawSchedule is String) {
      final trimmed = rawSchedule.trim();
      return trimmed.isNotEmpty ? trimmed : fallback;
    }
    if (rawSchedule is Map) {
      final daysRaw = rawSchedule['daysOfWeek'];
      final start = (rawSchedule['startTime'] ?? '').toString().trim();
      final end = (rawSchedule['endTime'] ?? '').toString().trim();

      String daysText = '';
      if (daysRaw is List && daysRaw.isNotEmpty) {
        final labels = daysRaw
            .map((d) => _dayNames[int.tryParse(d.toString()) ?? -1] ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
        if (labels.isNotEmpty) {
          daysText = labels.join(', ');
        }
      }

      String timeText = '';
      if (start.isNotEmpty && end.isNotEmpty) {
        timeText = '$start - $end';
      } else if (start.isNotEmpty) {
        timeText = start;
      }

      if (daysText.isNotEmpty && timeText.isNotEmpty) {
        return '$daysText • $timeText';
      }
      if (daysText.isNotEmpty) return daysText;
      if (timeText.isNotEmpty) return timeText;
    }
    return fallback;
  }
}

class SiblingEnrollmentModel {
  final String id;
  final String batchId;
  final String batchName;
  final String sportName;
  final String scheduleText;
  final String status;

  const SiblingEnrollmentModel({
    required this.id,
    required this.batchId,
    required this.batchName,
    required this.sportName,
    required this.scheduleText,
    required this.status,
  });

  factory SiblingEnrollmentModel.fromJson(Map<String, dynamic> json) {
    final batch = json['batchId'] is Map ? json['batchId'] as Map : null;
    final sport = batch?['sportId'] is Map
        ? (batch!['sportId'] as Map)['name']?.toString()
        : (batch?['sport'] ?? json['sportName'] ?? json['sport'])?.toString();

    return SiblingEnrollmentModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      batchId: batch != null
          ? (batch['_id'] ?? batch['id'] ?? '').toString()
          : (json['batchId']?.toString() ?? ''),
      batchName: (batch?['name'] ?? json['batchName'] ?? 'Coaching Batch').toString(),
      sportName: (sport != null && sport.trim().isNotEmpty) ? sport.trim() : 'Academy Sport',
      scheduleText: SiblingBatchScheduleFormatter.format(batch?['schedule'] ?? json['schedule']),
      status: (json['status'] ?? 'active').toString(),
    );
  }
}

class SiblingStudentModel {
  final String studentId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String regNo;
  final String cardNo;
  final String phone;
  final String email;
  final String parentPhone;
  final String parentName;
  final String siblingGroupId;
  final String batchId;
  final String batchName;
  final String status;
  final List<SiblingEnrollmentModel> enrollments;

  const SiblingStudentModel({
    required this.studentId,
    this.firstName = '',
    this.lastName = '',
    required this.fullName,
    this.regNo = '',
    this.cardNo = '',
    this.phone = '',
    this.email = '',
    this.parentPhone = '',
    this.parentName = '',
    this.siblingGroupId = '',
    this.batchId = '',
    this.batchName = '',
    this.status = 'active',
    this.enrollments = const [],
  });

  factory SiblingStudentModel.fromJson(Map<String, dynamic> json) {
    final fName = (json['firstName'] ?? '').toString().trim();
    final lName = (json['lastName'] ?? '').toString().trim();
    final combined = '$fName $lName'.trim();
    final rawFull = (json['fullName'] ?? json['name'] ?? '').toString().trim();
    final resolvedFull = rawFull.isNotEmpty ? rawFull : (combined.isNotEmpty ? combined : 'Trainee');

    final rawEnrollments = json['enrollments'];
    final List<SiblingEnrollmentModel> parsedEnrollments = [];
    if (rawEnrollments is List) {
      for (final e in rawEnrollments) {
        if (e is Map) {
          parsedEnrollments.add(SiblingEnrollmentModel.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    String resolvedBatchName = (json['batchName'] ?? '').toString().trim();
    if (resolvedBatchName.isEmpty && parsedEnrollments.isNotEmpty) {
      resolvedBatchName = parsedEnrollments.first.batchName;
    }

    return SiblingStudentModel(
      studentId: (json['studentId'] ?? json['id'] ?? json['_id'] ?? '').toString(),
      firstName: fName,
      lastName: lName,
      fullName: resolvedFull,
      regNo: (json['regNo'] ?? json['employeeNo'] ?? '').toString().trim(),
      cardNo: (json['cardNo'] ?? '').toString().trim(),
      phone: (json['phone'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      parentPhone: (json['parentPhone'] ?? '').toString().trim(),
      parentName: (json['parentName'] ?? '').toString().trim(),
      siblingGroupId: (json['siblingGroupId'] ?? '').toString().trim(),
      batchId: (json['batchId'] ?? (parsedEnrollments.isNotEmpty ? parsedEnrollments.first.batchId : '')).toString(),
      batchName: resolvedBatchName,
      status: (json['status'] ?? 'active').toString(),
      enrollments: parsedEnrollments,
    );
  }
}

class SiblingFamilyGroupModel {
  final String siblingGroupId;
  final String familyPhone;
  final String parentName;
  final int studentCount;
  final List<SiblingStudentModel> students;

  const SiblingFamilyGroupModel({
    required this.siblingGroupId,
    this.familyPhone = '',
    this.parentName = '',
    required this.studentCount,
    required this.students,
  });

  factory SiblingFamilyGroupModel.fromJson(Map<String, dynamic> json) {
    final rawStudents = json['students'] as List? ?? [];
    final parsed = rawStudents
        .whereType<Map>()
        .map((s) => SiblingStudentModel.fromJson(Map<String, dynamic>.from(s)))
        .toList();

    return SiblingFamilyGroupModel(
      siblingGroupId: (json['siblingGroupId'] ?? json['_id'] ?? json['id'] ?? '').toString(),
      familyPhone: (json['familyPhone'] ?? '').toString().trim(),
      parentName: (json['parentName'] ?? '').toString().trim(),
      studentCount: (json['studentCount'] as num?)?.toInt() ?? parsed.length,
      students: parsed,
    );
  }
}

class StudentSiblingDetailsModel {
  final SiblingStudentModel? student;
  final bool hasSiblings;
  final int siblingCount;
  final String siblingGroupId;
  final String familyPhone;
  final String parentName;
  final List<SiblingStudentModel> siblings;

  const StudentSiblingDetailsModel({
    this.student,
    required this.hasSiblings,
    required this.siblingCount,
    this.siblingGroupId = '',
    this.familyPhone = '',
    this.parentName = '',
    this.siblings = const [],
  });

  factory StudentSiblingDetailsModel.fromJson(Map<String, dynamic> json) {
    final studentMap = json['student'] is Map ? Map<String, dynamic>.from(json['student'] as Map) : null;
    final rawSiblings = json['siblings'] as List? ?? [];
    final parsedSiblings = rawSiblings
        .whereType<Map>()
        .map((s) => SiblingStudentModel.fromJson(Map<String, dynamic>.from(s)))
        .toList();

    return StudentSiblingDetailsModel(
      student: studentMap != null ? SiblingStudentModel.fromJson(studentMap) : null,
      hasSiblings: json['hasSiblings'] == true || parsedSiblings.isNotEmpty,
      siblingCount: (json['siblingCount'] as num?)?.toInt() ?? parsedSiblings.length,
      siblingGroupId: (json['siblingGroupId'] ?? '').toString().trim(),
      familyPhone: (json['familyPhone'] ?? '').toString().trim(),
      parentName: (json['parentName'] ?? '').toString().trim(),
      siblings: parsedSiblings,
    );
  }
}
