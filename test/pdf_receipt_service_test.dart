import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/pdf_receipt_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PdfReceiptService generates valid PDF document bytes for Fee, Booking, and Membership', () async {
    final feeBytes = await PdfReceiptService.generateReceiptPdf(
      receiptNumber: 'REC-71898A7E',
      receiptType: 'Fee',
      title: 'kids_begineer',
      sportName: 'Badminton',
      schedule: 'November 2026',
      customerName: 'RUTHVI PANDIAN',
      customerPhone: '9876543210',
      dateText: 'Nov 09, 2026 • 08:45 PM',
      totalAmount: 2500,
      baseAmount: 2500,
      discountAmount: 0,
      taxAmount: 0,
      status: 'PAID',
      razorpayPaymentId: 'pay_Ty7euCxfIjbff',
      razorpayOrderId: 'order_Ty7enInyZTnINP',
      notes: 'Paid via Razorpay',
    );
    expect(feeBytes.length, greaterThan(1000));

    final bookingBytes = await PdfReceiptService.generateReceiptPdf(
      receiptNumber: 'RCP-BK123456',
      receiptType: 'Booking',
      title: 'Badminton - Court 1',
      sportName: 'Badminton',
      schedule: 'Nov 10, 2026 • 06:00 - 07:00 AM',
      customerName: 'Arun Coach',
      customerPhone: '9876543210',
      dateText: 'Nov 10, 2026',
      totalAmount: 600,
      baseAmount: 600,
      discountAmount: 0,
      taxAmount: 0,
      status: 'PAID',
      razorpayPaymentId: 'pay_bk_12345',
      razorpayOrderId: 'order_bk_12345',
      notes: 'Court Reservation PIN: 489201',
    );
    expect(bookingBytes.length, greaterThan(1000));

    final memberBytes = await PdfReceiptService.generateReceiptPdf(
      receiptNumber: 'RCP-VIP999',
      receiptType: 'Membership',
      title: 'VIP Gold Annual Pass',
      sportName: 'All Arena Sports',
      schedule: 'Nov 2026 - Nov 2027',
      customerName: 'Academy Member',
      customerPhone: '9876543210',
      dateText: 'Nov 09, 2026',
      totalAmount: 15000,
      baseAmount: 15000,
      discountAmount: 1000,
      taxAmount: 0,
      status: 'PAID',
      razorpayPaymentId: 'pay_vip_12345',
      razorpayOrderId: 'order_vip_12345',
      notes: 'VIP Lounge & Locker Access Included',
    );
    expect(memberBytes.length, greaterThan(1000));
  });
}
