import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/siblings/data/models/sibling_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Profile Sibling Shifting and Switching Models', () {
    test('parses GET /students/my/profile payload with sibling details', () {
      final sampleResponse = {
        'success': true,
        'message': 'Student profile retrieved',
        'data': {
          'familyPhone': '9894789477',
          'parentName': 'arunmozhidevan',
          'siblingGroupId': '6af4929053cf12c1662f4b5a',
          'student': {
            '_id': '6af1e2ae185e913f71898a76',
            'firstName': 'RUTHVI',
            'lastName': 'PANDIAN',
            'fullName': 'RUTHVI PANDIAN',
            'regNo': 'isabd006',
            'phone': '9444154854',
            'parentName': 'arunmozhidevan',
            'parentPhone': '9894789477',
            'hasSiblings': true,
            'siblingCount': 2,
            'enrollments': [
              {
                'status': 'active',
                'batchId': {
                  '_id': '6ae3be5a51203568f13cc0e5',
                  'name': 'kids_begineer',
                  'code': 'BEGINNER-0600',
                  'sportId': {'name': 'Badminton'}
                }
              }
            ],
            'siblings': [
              {
                '_id': '6af1e2ae185e913f71898a76',
                'studentId': '6af1e2ae185e913f71898a76',
                'fullName': 'RUTHVI PANDIAN',
                'regNo': 'isabd006',
                'phone': '9444154854',
                'isCurrent': true,
                'isSelected': true,
                'batchName': 'kids_begineer',
                'sportName': 'Badminton'
              },
              {
                '_id': '6ae3bfa56989d6280874ef35',
                'studentId': '6ae3bfa56989d6280874ef35',
                'fullName': 'keshika devan',
                'regNo': 'isabd003',
                'phone': '9894789477',
                'isCurrent': false,
                'isSelected': false,
                'batchName': 'kids_begineer',
                'sportName': 'Badminton'
              }
            ]
          }
        }
      };

      final data = sampleResponse['data'] as Map<String, dynamic>;
      final details = StudentSiblingDetailsModel.fromJson(data);

      expect(details.hasSiblings, isTrue);
      expect(details.parentName, 'arunmozhidevan');
      expect(details.familyPhone, '9894789477');
      expect(details.siblings.length, 2);

      final current = details.siblings.firstWhere((s) => s.isCurrent || s.isSelected);
      expect(current.fullName, 'RUTHVI PANDIAN');
      expect(current.regNo, 'isabd006');
      expect(current.sportName, 'Badminton');

      final sibling = details.siblings.firstWhere((s) => !s.isCurrent && !s.isSelected);
      expect(sibling.fullName, 'keshika devan');
      expect(sibling.regNo, 'isabd003');
      expect(sibling.studentId, '6ae3bfa56989d6280874ef35');
    });
  });
}
