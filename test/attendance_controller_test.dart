import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/attendance/presentation/controllers/attendance_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('When there is no attendance records, overallPercentage is 0% even if API returns 100%', () {
    final controller = AttendanceController();

    // Simulating API response when student has 0 sessions but backend returns 100
    controller.parseAttendanceDataForTest({
      'totalSessions': 0,
      'presentCount': 0,
      'absentCount': 0,
      'attendancePercentage': 100,
      'sessionHistory': [],
      'punchLogs': [],
    });

    expect(controller.totalSessions.value, 0);
    expect(controller.presentCount.value, 0);
    expect(controller.absentCount.value, 0);
    expect(controller.overallPercentage.value, 0, reason: 'Must be 0% when there is no attendance');
  });

  test('When student has valid attendance sessions, calculates correct percentage', () {
    final controller = AttendanceController();

    controller.parseAttendanceDataForTest({
      'totalSessions': 10,
      'presentCount': 8,
      'absentCount': 2,
      'attendancePercentage': 80,
      'sessionHistory': [
        {
          'date': '2026-11-01',
          'status': 'present',
          'sport': 'Badminton',
        },
        {
          'date': '2026-11-02',
          'status': 'absent',
          'sport': 'Badminton',
        },
      ],
      'punchLogs': [],
    });

    expect(controller.totalSessions.value, 10);
    expect(controller.presentCount.value, 8);
    expect(controller.absentCount.value, 2);
    expect(controller.overallPercentage.value, 80);
  });

  test('Parses live GET /students/my/attendance with sibling switcher payload', () {
    final controller = AttendanceController();

    final liveSiblingPayload = {
      "studentId": "6af1e2ae185e913f71898a76",
      "studentName": "RUTHVI PANDIAN",
      "regNo": "isabd006",
      "batchName": "kids_begineer",
      "sportName": "Badminton",
      "totalSessions": 12,
      "presentCount": 11,
      "absentCount": 1,
      "attendancePercentage": 92,
      "hasSiblings": true,
      "siblingCount": 1,
      "siblingGroupId": "6af4929053cf12c1662f4b5a",
      "familyPhone": "9894789477",
      "selectedStudent": {
        "studentId": "6af1e2ae185e913f71898a76",
        "fullName": "RUTHVI PANDIAN",
        "batchName": "kids_begineer",
        "sportName": "Badminton",
        "attendancePercentage": 92
      },
      "siblings": [
        {
          "studentId": "6af1e2ae185e913f71898a76",
          "fullName": "RUTHVI PANDIAN",
          "regNo": "isabd006",
          "batchName": "kids_begineer",
          "sportName": "Badminton",
          "totalSessions": 12,
          "presentCount": 11,
          "absentCount": 1,
          "attendancePercentage": 92,
          "isSelected": true
        },
        {
          "studentId": "6ae3bfa56989d6280874ef35",
          "fullName": "keshika devan",
          "regNo": "isabd003",
          "batchName": "kids_begineer",
          "sportName": "Badminton",
          "totalSessions": 14,
          "presentCount": 13,
          "absentCount": 1,
          "attendancePercentage": 93,
          "isSelected": false
        }
      ],
      "punchLogs": [],
      "sessionHistory": [
        {
          "date": "2026-11-10",
          "status": "Present",
          "batchName": "kids_begineer",
          "sport": "Badminton",
          "time": "05:00 PM - 06:00 PM"
        }
      ]
    };

    controller.parseAttendanceDataForTest(liveSiblingPayload);

    expect(controller.hasSiblings.value, true);
    expect(controller.siblings.length, 2);
    expect(controller.selectedSiblingId.value, "6af1e2ae185e913f71898a76");
    expect(controller.selectedStudentName.value, "RUTHVI PANDIAN");
    expect(controller.selectedRegNo.value, "isabd006");
    expect(controller.selectedBatchName.value, "kids_begineer");
    expect(controller.selectedSportName.value, "Badminton");
    expect(controller.overallPercentage.value, 92);
    expect(controller.presentCount.value, 11);
    expect(controller.absentCount.value, 1);
    expect(controller.totalSessions.value, 12);
    expect(controller.familyPhone.value, "9894789477");

    // Verify sibling items
    expect(controller.siblings[0].fullName, "RUTHVI PANDIAN");
    expect(controller.siblings[0].isSelected, true);
    expect(controller.siblings[1].fullName, "keshika devan");
    expect(controller.siblings[1].regNo, "isabd003");
    expect(controller.siblings[1].attendancePercentage, 93);
    expect(controller.siblings[1].isSelected, false);
  });
}

