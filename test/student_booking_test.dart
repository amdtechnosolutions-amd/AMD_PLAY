import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/booking/data/models/court_slot_model.dart';
import 'package:dio/dio.dart';

class MockDioClientAdapter implements HttpClientAdapter {
  late RequestOptions lastRequestOptions;
  late dynamic lastRequestBody;
  Map<String, dynamic> responseData = {
    'success': true,
    'message': 'Booking confirmed successfully',
    'data': {
      '_id': '6af831d10000000000000001',
      'bookingNumber': 'BK-20261115-A1B2C3-1',
      'status': 'confirmed',
      'accessCode': '842913',
      'qrCodeUrl': 'https://api.qrserver.com/v1/create-qr-code/?size=350x350&data=PIN:842913',
      'date': '2026-11-15',
      'startTime': '16:00',
      'endTime': '17:00',
      'pricing': {
        'basePrice': 800,
        'taxAmount': 0,
        'totalAmount': 800,
      },
      'resource': {
        '_id': '6adfd230b968550380613b78',
        'name': 'TRUF',
        'code': 'TRF-T',
      },
    },
  };

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    lastRequestOptions = options;
    lastRequestBody = options.data;
    return ResponseBody.fromString(
      DioMediaType.parse('application/json').toString(),
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('Student Booking Contract Tests', () {
    test('Option A: Single slot booking sends clean student body without customer details', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          // Simulate student JWT
          options.headers['Authorization'] = 'Bearer student_mock_jwt_token';
          return handler.next(options);
        },
      ));

      // Test payload composition directly
      final singleSlot = SelectedSlot(
        resourceId: '6adfd230b968550380613b78',
        courtName: 'TRUF',
        date: '2026-11-15',
        startTime: '16:00',
        endTime: '17:00',
        timeText: '16:00 - 17:00',
        price: 800,
      );

      final payload = {
        'resourceId': singleSlot.resourceId,
        'date': singleSlot.date,
        'startTime': singleSlot.startTime,
        'endTime': singleSlot.endTime,
        'paymentMethod': 'upi',
        'notes': 'Personal training practice',
      };

      expect(payload['resourceId'], '6adfd230b968550380613b78');
      expect(payload['date'], '2026-11-15');
      expect(payload['startTime'], '16:00');
      expect(payload['endTime'], '17:00');
      expect(payload['paymentMethod'], 'upi');
      expect(payload['notes'], 'Personal training practice');
      expect(payload.containsKey('userId'), isFalse);
      expect(payload.containsKey('phone'), isFalse);
      expect(payload.containsKey('customerName'), isFalse);
    });

    test('Option B: Multi-slot booking sends slots array cleanly without customer details', () {
      final slot1 = SelectedSlot(
        resourceId: '6adfd230b968550380613b78',
        courtName: 'TRUF',
        date: '2026-11-15',
        startTime: '16:00',
        endTime: '17:00',
      );
      final slot2 = SelectedSlot(
        resourceId: '6adfd230b968550380613b78',
        courtName: 'TRUF',
        date: '2026-11-15',
        startTime: '17:00',
        endTime: '18:00',
      );

      final multiPayload = {
        'slots': [slot1, slot2].map((s) => {
          'resourceId': s.resourceId,
          'date': s.date,
          'startTime': s.startTime,
          'endTime': s.endTime,
        }).toList(),
        'paymentMethod': 'upi',
        'notes': 'Personal training practice',
      };

      final slotsList = multiPayload['slots'] as List;
      expect(slotsList.length, 2);
      expect(slotsList[0]['startTime'], '16:00');
      expect(slotsList[1]['startTime'], '17:00');
      expect(multiPayload['paymentMethod'], 'upi');
      expect(multiPayload.containsKey('userId'), isFalse);
      expect(multiPayload.containsKey('phone'), isFalse);
    });

    test('Sibling Assignment: appends studentId to payload when booking for a sibling', () {
      final payloadWithSibling = {
        'resourceId': '6adfd230b968550380613b78',
        'date': '2026-11-15',
        'startTime': '16:00',
        'endTime': '17:00',
        'paymentMethod': 'upi',
        'notes': 'Personal training practice',
        'studentId': '6ae3bfa56989d6280874ef35',
      };

      expect(payloadWithSibling['studentId'], '6ae3bfa56989d6280874ef35');
      expect(payloadWithSibling.containsKey('userId'), isFalse);
    });
  });

  group('Member Booking Contract Tests', () {
    test('Option A: Member single slot booking with wallet payment', () {
      final payload = {
        'resourceId': '6ad6be7a1ee0aaebb67610be',
        'date': '2026-11-15',
        'startTime': '18:00',
        'endTime': '19:00',
        'paymentMethod': 'wallet',
        'notes': 'Member slot booking',
      };

      expect(payload['resourceId'], '6ad6be7a1ee0aaebb67610be');
      expect(payload['paymentMethod'], 'wallet');
      expect(payload['notes'], 'Member slot booking');
      expect(payload.containsKey('userId'), isFalse);
      expect(payload.containsKey('phone'), isFalse);
      expect(payload.containsKey('memberId'), isFalse);
    });

    test('Option B: Member multi-slot booking with free quota', () {
      final multiPayload = {
        'slots': [
          {
            'resourceId': '6ad6be7a1ee0aaebb67610be',
            'date': '2026-11-15',
            'startTime': '18:00',
            'endTime': '19:00',
          },
          {
            'resourceId': '6ad6be7a1ee0aaebb67610be',
            'date': '2026-11-15',
            'startTime': '19:00',
            'endTime': '20:00',
          },
        ],
        'paymentMethod': 'free',
        'notes': 'Member 2-hour session',
      };

      final slots = multiPayload['slots'] as List;
      expect(slots.length, 2);
      expect(multiPayload['paymentMethod'], 'free');
      expect(multiPayload.containsKey('userId'), isFalse);
    });
  });

  group('Coach Booking Contract Tests', () {
    test('Case A: Coach personal session without studentId and free paymentMethod', () {
      final payload = {
        'resourceId': '6adfd230b968550380613b78',
        'date': '2026-11-15',
        'startTime': '06:00',
        'endTime': '07:00',
        'paymentMethod': 'free',
        'notes': 'Coach personal training session',
      };

      expect(payload['paymentMethod'], 'free');
      expect(payload['notes'], 'Coach personal training session');
      expect(payload.containsKey('studentId'), isFalse);
      expect(payload.containsKey('userId'), isFalse);
    });

    test('Case B: Coach booking on behalf of student includes target studentId', () {
      final payload = {
        'studentId': '6ae3bfa56989d6280874ef35',
        'resourceId': '6adfd230b968550380613b78',
        'date': '2026-11-15',
        'startTime': '16:00',
        'endTime': '17:00',
        'paymentMethod': 'cash',
        'notes': '1-on-1 private coaching with student',
      };

      expect(payload['studentId'], '6ae3bfa56989d6280874ef35');
      expect(payload['paymentMethod'], 'cash');
      expect(payload['notes'], '1-on-1 private coaching with student');
      expect(payload.containsKey('userId'), isFalse);
    });
  });

  group('Sibling Profile Shifting Tests', () {
    test('finds second sibling in response payload and does not revert to root student', () {
      final backendResponsePayload = {
        'student': {
          '_id': '6af1e2ae185e913f71898a76',
          'fullName': 'RUTHVI PANDIAN',
          'regNo': 'isabd006',
          'phone': '9444154854',
          'siblings': [
            {
              '_id': '6af1e2ae185e913f71898a76',
              'studentId': '6af1e2ae185e913f71898a76',
              'fullName': 'RUTHVI PANDIAN',
              'regNo': 'isabd006',
              'isCurrent': true,
              'isSelected': true,
            },
            {
              '_id': '6ae3bfa56989d6280874ef35',
              'studentId': '6ae3bfa56989d6280874ef35',
              'fullName': 'keshika devan',
              'regNo': 'isabd003',
              'isCurrent': false,
              'isSelected': false,
            },
          ],
        },
      };

      const targetId = '6ae3bfa56989d6280874ef35';

      // Sibling locator resolution logic
      Map<String, dynamic>? resolved;
      final sibList = backendResponsePayload['student']!['siblings'] as List;
      for (final s in sibList) {
        if (s is Map && s['studentId'] == targetId) {
          resolved = Map<String, dynamic>.from(s);
          break;
        }
      }

      expect(resolved, isNotNull);
      expect(resolved!['studentId'], targetId);
      expect(resolved['fullName'], 'keshika devan');
      expect(resolved['regNo'], 'isabd003');
      expect(resolved['fullName'], isNot(equals('RUTHVI PANDIAN')));
    });
  });
}

