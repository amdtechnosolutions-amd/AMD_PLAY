/// Model representing an individual sibling's attendance summary returned by
/// GET /students/my/attendance?groupBy=sibling
class SiblingAttendanceItem {
  final String studentId;
  final String fullName;
  final String regNo;
  final String batchName;
  final String sportName;
  final int totalSessions;
  final int presentCount;
  final int absentCount;
  final int attendancePercentage;
  final bool isSelected;

  const SiblingAttendanceItem({
    required this.studentId,
    required this.fullName,
    this.regNo = '',
    this.batchName = '',
    this.sportName = '',
    this.totalSessions = 0,
    this.presentCount = 0,
    this.absentCount = 0,
    this.attendancePercentage = 0,
    this.isSelected = false,
  });

  factory SiblingAttendanceItem.fromJson(Map<String, dynamic> json) {
    return SiblingAttendanceItem(
      studentId: json['studentId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ??
          json['studentName']?.toString() ??
          '',
      regNo: json['regNo']?.toString() ?? '',
      batchName: json['batchName']?.toString() ?? '',
      sportName: json['sportName']?.toString() ?? '',
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      presentCount: (json['presentCount'] as num?)?.toInt() ?? 0,
      absentCount: (json['absentCount'] as num?)?.toInt() ?? 0,
      attendancePercentage:
          (json['attendancePercentage'] as num?)?.toInt() ?? 0,
      isSelected: json['isSelected'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'fullName': fullName,
      'regNo': regNo,
      'batchName': batchName,
      'sportName': sportName,
      'totalSessions': totalSessions,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'attendancePercentage': attendancePercentage,
      'isSelected': isSelected,
    };
  }
}

/// Model encapsulating the full sibling attendance response structure
class StudentAttendanceResponse {
  final String studentId;
  final String studentName;
  final String regNo;
  final String batchName;
  final String sportName;
  final int totalSessions;
  final int presentCount;
  final int absentCount;
  final int attendancePercentage;
  final bool hasSiblings;
  final int siblingCount;
  final String siblingGroupId;
  final String familyPhone;
  final List<SiblingAttendanceItem> siblings;
  final List<dynamic> punchLogs;
  final List<dynamic> sessionHistory;

  const StudentAttendanceResponse({
    required this.studentId,
    required this.studentName,
    this.regNo = '',
    this.batchName = '',
    this.sportName = '',
    this.totalSessions = 0,
    this.presentCount = 0,
    this.absentCount = 0,
    this.attendancePercentage = 0,
    this.hasSiblings = false,
    this.siblingCount = 0,
    this.siblingGroupId = '',
    this.familyPhone = '',
    this.siblings = const [],
    this.punchLogs = const [],
    this.sessionHistory = const [],
  });

  factory StudentAttendanceResponse.fromJson(Map<String, dynamic> json) {
    final rawSiblings = json['siblings'] as List? ?? [];
    final parsedSiblings = rawSiblings
        .whereType<Map>()
        .map((e) =>
            SiblingAttendanceItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return StudentAttendanceResponse(
      studentId: json['studentId']?.toString() ?? '',
      studentName: json['studentName']?.toString() ??
          json['selectedStudent']?['fullName']?.toString() ??
          '',
      regNo: json['regNo']?.toString() ?? '',
      batchName: json['batchName']?.toString() ??
          json['selectedStudent']?['batchName']?.toString() ??
          '',
      sportName: json['sportName']?.toString() ??
          json['selectedStudent']?['sportName']?.toString() ??
          '',
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      presentCount: (json['presentCount'] as num?)?.toInt() ?? 0,
      absentCount: (json['absentCount'] as num?)?.toInt() ?? 0,
      attendancePercentage:
          (json['attendancePercentage'] as num?)?.toInt() ?? 0,
      hasSiblings: json['hasSiblings'] == true,
      siblingCount: (json['siblingCount'] as num?)?.toInt() ??
          (parsedSiblings.length > 1 ? parsedSiblings.length - 1 : 0),
      siblingGroupId: json['siblingGroupId']?.toString() ?? '',
      familyPhone: json['familyPhone']?.toString() ?? '',
      siblings: parsedSiblings,
      punchLogs: json['punchLogs'] as List? ?? [],
      sessionHistory: json['sessionHistory'] as List? ?? [],
    );
  }
}

