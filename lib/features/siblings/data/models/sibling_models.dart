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
  final String sportName;
  final String status;
  final bool isCurrent;
  final bool isSelected;
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
    this.sportName = '',
    this.status = 'active',
    this.isCurrent = false,
    this.isSelected = false,
    this.enrollments = const [],
  });

  SiblingStudentModel copyWith({
    String? studentId,
    String? firstName,
    String? lastName,
    String? fullName,
    String? regNo,
    String? cardNo,
    String? phone,
    String? email,
    String? parentPhone,
    String? parentName,
    String? siblingGroupId,
    String? batchId,
    String? batchName,
    String? sportName,
    String? status,
    bool? isCurrent,
    bool? isSelected,
    List<SiblingEnrollmentModel>? enrollments,
  }) {
    return SiblingStudentModel(
      studentId: studentId ?? this.studentId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      regNo: regNo ?? this.regNo,
      cardNo: cardNo ?? this.cardNo,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      parentPhone: parentPhone ?? this.parentPhone,
      parentName: parentName ?? this.parentName,
      siblingGroupId: siblingGroupId ?? this.siblingGroupId,
      batchId: batchId ?? this.batchId,
      batchName: batchName ?? this.batchName,
      sportName: sportName ?? this.sportName,
      status: status ?? this.status,
      isCurrent: isCurrent ?? this.isCurrent,
      isSelected: isSelected ?? this.isSelected,
      enrollments: enrollments ?? this.enrollments,
    );
  }

  factory SiblingStudentModel.fromJson(Map<String, dynamic> json) {
    final rawStudentId = json['studentId'] is Map
        ? (json['studentId']['_id'] ?? json['studentId']['id'] ?? '')
        : (json['studentId'] ?? json['id'] ?? json['_id'] ?? '');
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

    String resolvedSportName = (json['sportName'] ?? json['sport'] ?? '').toString().trim();
    if (resolvedSportName.isEmpty && parsedEnrollments.isNotEmpty) {
      resolvedSportName = parsedEnrollments.first.sportName;
    }

    final isCur = json['isCurrent'] == true;
    final isSel = json['isSelected'] == true || isCur;

    return SiblingStudentModel(
      studentId: rawStudentId.toString(),
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
      sportName: resolvedSportName,
      status: (json['status'] ?? 'active').toString(),
      isCurrent: isCur,
      isSelected: isSel,
      enrollments: parsedEnrollments,
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
    List<SiblingStudentModel> parsedSiblings = rawSiblings
        .whereType<Map>()
        .map((s) => SiblingStudentModel.fromJson(Map<String, dynamic>.from(s)))
        .toList();

    // Fallback: If root siblings is empty, check student.siblings
    if (parsedSiblings.isEmpty && studentMap != null && studentMap['siblings'] is List) {
      final nestedList = studentMap['siblings'] as List;
      parsedSiblings = nestedList
          .whereType<Map>()
          .map((s) => SiblingStudentModel.fromJson(Map<String, dynamic>.from(s)))
          .toList();
    }

    final parentName = (json['parentName'] ?? studentMap?['parentName'] ?? '').toString().trim();
    final familyPhone = (json['familyPhone'] ?? studentMap?['parentPhone'] ?? json['parentPhone'] ?? '').toString().trim();
    final siblingGroupId = (json['siblingGroupId'] ?? studentMap?['siblingGroupId'] ?? '').toString().trim();

    return StudentSiblingDetailsModel(
      student: studentMap != null ? SiblingStudentModel.fromJson(studentMap) : null,
      hasSiblings: json['hasSiblings'] == true || parsedSiblings.length > 1,
      siblingCount: (json['siblingCount'] as num?)?.toInt() ?? parsedSiblings.length,
      siblingGroupId: siblingGroupId,
      familyPhone: familyPhone,
      parentName: parentName,
      siblings: parsedSiblings,
    );
  }
}

