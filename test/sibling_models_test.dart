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

  test('StudentSiblingDetailsModel parses GET /students/my/profile payload with nested siblings and isCurrent flags', () {
    final payload = {
      "student": {
        "_id": "6af1e2ae185e913f71898a76",
        "firstName": "RUTHVI",
        "lastName": "PANDIAN",
        "fullName": "RUTHVI PANDIAN",
        "regNo": "isabd006",
        "phone": "9444154854",
        "parentName": "arunmozhidevan",
        "parentPhone": "9894789477",
        "siblingGroupId": "6af4929053cf12c1662f4b5a",
        "hasSiblings": true,
        "siblingCount": 2,
        "enrollments": [
          {
            "status": "active",
            "batchId": {
              "_id": "6ae3be5a51203568f13cc0e5",
              "name": "kids_begineer",
              "code": "BEGINNER-0600",
              "sportId": {"name": "Badminton"}
            }
          }
        ],
        "siblings": [
          {
            "_id": "6af1e2ae185e913f71898a76",
            "studentId": "6af1e2ae185e913f71898a76",
            "fullName": "RUTHVI PANDIAN",
            "regNo": "isabd006",
            "phone": "9444154854",
            "isCurrent": true,
            "isSelected": true,
            "batchName": "kids_begineer",
            "sportName": "Badminton"
          },
          {
            "_id": "6ae3bfa56989d6280874ef35",
            "studentId": "6ae3bfa56989d6280874ef35",
            "fullName": "keshika devan",
            "regNo": "isabd003",
            "phone": "9894789477",
            "isCurrent": false,
            "isSelected": false,
            "batchName": "kids_begineer",
            "sportName": "Badminton"
          }
        ]
      },
      "siblings": [],
      "hasSiblings": true,
      "siblingCount": 2,
      "siblingGroupId": "6af4929053cf12c1662f4b5a",
      "familyPhone": "9894789477",
      "parentName": "arunmozhidevan"
    };

    final details = StudentSiblingDetailsModel.fromJson(payload);

    expect(details.student, isNotNull);
    expect(details.student!.studentId, '6af1e2ae185e913f71898a76');
    expect(details.student!.fullName, 'RUTHVI PANDIAN');
    expect(details.student!.regNo, 'isabd006');
    expect(details.student!.parentName, 'arunmozhidevan');
    expect(details.student!.parentPhone, '9894789477');
    expect(details.student!.enrollments.first.batchName, 'kids_begineer');
    expect(details.student!.enrollments.first.sportName, 'Badminton');

    expect(details.hasSiblings, true);
    expect(details.siblingCount, 2);
    expect(details.siblings.length, 2);

    final sib1 = details.siblings[0];
    expect(sib1.studentId, '6af1e2ae185e913f71898a76');
    expect(sib1.fullName, 'RUTHVI PANDIAN');
    expect(sib1.regNo, 'isabd006');
    expect(sib1.isCurrent, true);
    expect(sib1.isSelected, true);
    expect(sib1.sportName, 'Badminton');

    final sib2 = details.siblings[1];
    expect(sib2.studentId, '6ae3bfa56989d6280874ef35');
    expect(sib2.fullName, 'keshika devan');
    expect(sib2.regNo, 'isabd003');
    expect(sib2.isCurrent, false);
    expect(sib2.isSelected, false);
    expect(sib2.batchName, 'kids_begineer');
  });
}
