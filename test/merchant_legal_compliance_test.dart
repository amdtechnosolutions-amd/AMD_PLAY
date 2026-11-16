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
    });
  });
}

