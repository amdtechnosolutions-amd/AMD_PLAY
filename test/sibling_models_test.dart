import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/siblings/data/models/sibling_models.dart';

void main() {
  test('SiblingBatchScheduleFormatter formats daysOfWeek map schedule cleanly', () {
    final formatted = SiblingBatchScheduleFormatter.format({
      'daysOfWeek': [1, 3, 5],
      'startTime': '17:00',
      'endTime': '18:30',
    });
    expect(formatted, 'Mon, Wed, Fri • 17:00 - 18:30');
  });

  test('SiblingStudentModel parses GET /students/my/siblings item', () {
    final sibling = SiblingStudentModel.fromJson({
      'id': '6af1e2ae185e913f71898a76',
      'studentId': '6af1e2ae185e913f71898a76',
      'firstName': 'RUTHVI',
      'lastName': 'PANDIAN',
      'fullName': 'RUTHVI PANDIAN',
      'regNo': 'isabd006',
      'employeeNo': 'isabd006',
      'cardNo': 'CARD98211',
      'phone': '9444154854',
      'siblingGroupId': '6af4929053cf12c1662f4b5a',
      'parentPhone': '9894789477',
      'enrollments': [
        {
          '_id': '6af1e2ae185e913f71898888',
          'batchId': {
            '_id': '6ae101a9185e913f71898777',
            'name': 'Evening Badminton Stars',
            'schedule': {
              'daysOfWeek': [1, 3, 5],
              'startTime': '17:00',
              'endTime': '18:30',
            },
          },
          'status': 'active',
        },
      ],
    });

    expect(sibling.studentId, '6af1e2ae185e913f71898a76');
    expect(sibling.fullName, 'RUTHVI PANDIAN');
    expect(sibling.regNo, 'isabd006');
    expect(sibling.batchName, 'Evening Badminton Stars');
    expect(sibling.enrollments.first.scheduleText, 'Mon, Wed, Fri • 17:00 - 18:30');
  });

  test('StudentSiblingDetailsModel parses GET /students/:id/siblings payload', () {
    final details = StudentSiblingDetailsModel.fromJson({
      'student': {
        'id': '6ae3bfa56989d6280874ef35',
        'studentId': '6ae3bfa56989d6280874ef35',
        'fullName': 'Keshika Devan',
        'regNo': 'isabd001',
        'phone': '9894789477',
        'siblingGroupId': '6af4929053cf12c1662f4b5a',
        'batchName': 'Badminton Morning Elite Stars',
        'status': 'active',
      },
      'hasSiblings': true,
      'siblingCount': 1,
      'siblingGroupId': '6af4929053cf12c1662f4b5a',
      'familyPhone': '9894789477',
      'parentName': 'Arunmozhidevan',
      'siblings': [
        {
          'id': '6af1e2ae185e913f71898a76',
          'studentId': '6af1e2ae185e913f71898a76',
          'fullName': 'RUTHVI PANDIAN',
          'regNo': 'isabd006',
          'phone': '9444154854',
          'batchName': 'Evening Badminton Stars',
          'siblingGroupId': '6af4929053cf12c1662f4b5a',
          'status': 'active',
        },
      ],
    });

    expect(details.hasSiblings, true);
    expect(details.siblingCount, 1);
    expect(details.student?.fullName, 'Keshika Devan');
    expect(details.siblings.first.fullName, 'RUTHVI PANDIAN');
  });
}
