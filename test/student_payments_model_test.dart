import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/finance/data/models/student_payments_model.dart';

void main() {
  test('StudentPaymentsResponse parses GET /students/my/payments family & sibling records', () {
    final parsed = StudentPaymentsResponse.fromJson({
      'familyPhone': '9894789477',
      'parentName': 'arunmozhidevan',
      'siblingGroupId': '6af4929053cf12c1662f4b5a',
      'totalStudents': 2,
      'summary': {
        'totalAmount': 7500,
        'totalPaid': 7500,
        'totalPending': 0,
        'totalInvoices': 3,
        'paidInvoices': 3,
        'pendingInvoices': 0,
        'paymentTransactions': 3,
      },
      'siblings': [
        {
          'studentId': '6ae3bfa56989d6280874ef35',
          'fullName': 'keshika devan',
          'firstName': 'keshika',
          'lastName': 'devan',
          'regNo': 'isabd003',
          'phone': '9894789477',
          'parentPhone': '9894789477',
          'summary': {
            'totalAmount': 5000,
            'totalPaid': 5000,
            'totalPending': 0,
            'invoiceCount': 2,
            'paidCount': 2,
            'pendingCount': 0,
            'paymentTransactionCount': 2,
          },
          'fees': [
            {
              '_id': '6ae535a941a64984822e1c89',
              'month': 11,
              'year': 2026,
              'finalAmount': 2500,
              'paidAmount': 2500,
              'status': 'paid',
              'receiptNo': 'REC-STU-202611-7128',
              'batchDisplayName': 'kids_begineer (keshika devan)',
              'paidAt': '2026-11-11T20:25:02.474Z',
            },
          ],
          'payments': [
            {
              '_id': '6af4cf1ea04eca3b90eb2d16',
              'amount': 2500,
              'paymentMethod': 'upi',
              'status': 'success',
              'createdAt': '2026-11-11T20:25:02.474Z',
            },
          ],
        },
        {
          'studentId': '6af1e2ae185e913f71898a76',
          'fullName': 'RUTHVI PANDIAN',
          'firstName': 'RUTHVI',
          'lastName': 'PANDIAN',
          'regNo': 'isabd006',
          'phone': '9444154854',
          'parentPhone': '9894789477',
          'summary': {
            'totalAmount': 2500,
            'totalPaid': 2500,
            'totalPending': 0,
            'invoiceCount': 1,
            'paidCount': 1,
            'pendingCount': 0,
            'paymentTransactionCount': 1,
          },
          'fees': [
            {
              '_id': '6af1e2ae185e913f71898a7e',
              'month': 11,
              'year': 2026,
              'finalAmount': 2500,
              'paidAmount': 2500,
              'status': 'paid',
              'receiptNo': 'REC-STU-202611-7129',
              'batchDisplayName': 'kids_begineer (RUTHVI PANDIAN)',
              'paidAt': '2026-11-11T20:25:02.474Z',
            },
          ],
          'payments': [
            {
              '_id': '6af1e37a185e913f71898ad7',
              'amount': 2500,
              'paymentMethod': 'upi',
              'status': 'success',
              'createdAt': '2026-11-11T20:25:02.474Z',
            },
          ],
        },
      ],
    });

    expect(parsed.totalStudents, 2);
    expect(parsed.parentName, 'arunmozhidevan');
    expect(parsed.summary.totalPaid, 7500);
    expect(parsed.summary.totalPending, 0);
    expect(parsed.summary.paidInvoices, 3);
    expect(parsed.siblings.length, 2);
    expect(parsed.siblings[0].fees.first.feeItem.title, 'kids_begineer (keshika devan)');
    expect(parsed.siblings[0].fees.first.receiptNo, 'REC-STU-202611-7128');
    expect(parsed.siblings[1].regNo, 'isabd006');
    expect(parsed.siblings[1].payments.first.paymentMethod, 'UPI');
    expect(parsed.siblings[1].payments.first.status, 'SUCCESS');
  });
}

