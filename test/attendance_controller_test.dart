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
}
