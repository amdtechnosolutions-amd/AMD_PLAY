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

  test('SiblingFamilyGroupModel parses GET /students/siblings payload', () {
    final family = SiblingFamilyGroupModel.fromJson({
      'siblingGroupId': '6af4929053cf12c1662f4b5a',
      'familyPhone': '9894789477',
      'parentName': 'Arunmozhidevan',
      'studentCount': 2,
      'students': [
        {
          'id': '6ae3bfa56989d6280874ef35',
          'studentId': '6ae3bfa56989d6280874ef35',
          'fullName': 'Keshika Devan',
          'firstName': 'Keshika',
          'lastName': 'Devan',
          'regNo': 'isabd001',
          'phone': '9894789477',
          'parentPhone': '9894789477',
          'parentName': 'Arunmozhidevan',
          'batchName': 'Badminton Morning Elite Stars',
          'status': 'active',
        },
        {
          'id': '6af1e2ae185e913f71898a76',
          'studentId': '6af1e2ae185e913f71898a76',
          'fullName': 'RUTHVI PANDIAN',
          'firstName': 'RUTHVI',
          'lastName': 'PANDIAN',
          'regNo': 'isabd006',
          'phone': '9444154854',
          'parentPhone': '9894789477',
          'parentName': 'Arunmozhidevan',
          'batchName': 'Evening Badminton Stars',
          'status': 'active',
        },
      ],
    });

    expect(family.siblingGroupId, '6af4929053cf12c1662f4b5a');
    expect(family.familyPhone, '9894789477');
    expect(family.parentName, 'Arunmozhidevan');
    expect(family.studentCount, 2);
    expect(family.students.length, 2);
    expect(family.students[0].regNo, 'isabd001');
    expect(family.students[1].phone, '9444154854');
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
