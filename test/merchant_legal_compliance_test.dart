import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/legal/presentation/screens/merchant_legal_info_screen.dart';

void main() {
  group('Cashfree & Payment Gateway Legal Merchant Compliance Tests', () {
    test('Merchant legal constants match Cashfree verification mandate', () {
      expect(MerchantLegalInfoScreen.businessLegalName, 'TEAM INERTIA ENTERPRISES');
      expect(MerchantLegalInfoScreen.proprietorLegalName, 'KRISHNAN ROHITH KUMAR');
      expect(MerchantLegalInfoScreen.officialEmail, 'Teaminertia3499@gmail.com');
      expect(MerchantLegalInfoScreen.officialPhone, '9789006925');
    });

    test('web/index.html contains exact legal merchant details and policies for web auditors', () {
      final indexHtml = File('web/index.html').readAsStringSync();

      expect(indexHtml.contains('TEAM INERTIA ENTERPRISES'), isTrue,
          reason: 'web/index.html must contain TEAM INERTIA ENTERPRISES');
      expect(indexHtml.contains('KRISHNAN ROHITH KUMAR'), isTrue,
          reason: 'web/index.html must contain KRISHNAN ROHITH KUMAR');
      expect(indexHtml.contains('Teaminertia3499@gmail.com'), isTrue,
          reason: 'web/index.html must contain Teaminertia3499@gmail.com');
      expect(indexHtml.contains('9789006925'), isTrue,
          reason: 'web/index.html must contain 9789006925');
      expect(indexHtml.contains('Cancellation & Refund Policy'), isTrue,
          reason: 'web/index.html must contain Cancellation & Refund Policy');
      expect(indexHtml.contains('id="inertia-legal-bar"'), isFalse,
          reason: 'web/index.html must not contain fixed floating bar that blocks scrolling');
    });

    test('Login screen contains legal merchant details footer', () {
      final loginScreen = File('lib/features/auth/presentation/screens/login_screen.dart').readAsStringSync();
      expect(loginScreen.contains('TEAM INERTIA ENTERPRISES'), isTrue);
      expect(loginScreen.contains('KRISHNAN ROHITH KUMAR'), isTrue);
      expect(loginScreen.contains('Teaminertia3499@gmail.com'), isTrue);
      expect(loginScreen.contains('9789006925'), isTrue);

      final loginV2Screen = File('lib/features/auth/presentation/screens/login_v2_screen.dart').readAsStringSync();
      expect(loginV2Screen.contains('TEAM INERTIA ENTERPRISES'), isTrue);
      expect(loginV2Screen.contains('KRISHNAN ROHITH KUMAR'), isTrue);
      expect(loginV2Screen.contains('Teaminertia3499@gmail.com'), isTrue);
      expect(loginV2Screen.contains('9789006925'), isTrue);
    });
  });
}

