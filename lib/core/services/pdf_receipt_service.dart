import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Service responsible for generating, printing, downloading, and sharing
/// official PDF Tax Invoices & Payment Receipts for:
/// - Student Coaching Monthly Fees
/// - Court Booking Reservations & Passes
/// - Membership Passes & Subscriptions
class PdfReceiptService {
  static const PdfColor goldColor = PdfColor.fromInt(0xFFD4AF37);
  static const PdfColor darkTextColor = PdfColor.fromInt(0xFF0F172A);
  static const PdfColor slateTextColor = PdfColor.fromInt(0xFF64748B);
  static const PdfColor emeraldColor = PdfColor.fromInt(0xFF10B981);
  static const PdfColor lightBgColor = PdfColor.fromInt(0xFFF8FAFC);
  static const PdfColor borderColor = PdfColor.fromInt(0xFFE2E8F0);

  /// Generates real PDF document bytes for a payment receipt
  static Future<Uint8List> generateReceiptPdf({
    required String receiptNumber,
    required String receiptType, // 'Fee', 'Booking', 'Membership'
    required String title,
    String? sportName,
    String? schedule,
    required String customerName,
    String customerPhone = '',
    required String dateText,
    required int totalAmount,
    required int baseAmount,
    int discountAmount = 0,
    int taxAmount = 0,
    String status = 'PAID',
    required String razorpayPaymentId,
    String? razorpayOrderId,
    String? notes,
  }) async {
    final pdf = pw.Document();

    // Load Nunito or fallback standard fonts
    pw.Font? ttfBold;
    pw.Font? ttfRegular;
    try {
      final fontDataBold = await rootBundle.load('assets/fonts/Nunito-Bold.ttf');
      final fontDataRegular = await rootBundle.load('assets/fonts/Nunito-Regular.ttf');
      ttfBold = pw.Font.ttf(fontDataBold);
      ttfRegular = pw.Font.ttf(fontDataRegular);
    } catch (_) {
      ttfBold = pw.Font.helveticaBold();
      ttfRegular = pw.Font.helvetica();
    }

    // Try loading logo
    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/logo/logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {}

    String typeHeader = 'COACHING FEE INVOICE';
    if (receiptType.toLowerCase() == 'booking') {
      typeHeader = 'COURT BOOKING INVOICE';
    } else if (receiptType.toLowerCase() == 'membership') {
      typeHeader = 'VIP MEMBERSHIP INVOICE';
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: ttfRegular,
          bold: ttfBold,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER: BRANDING & INVOICE TITLE
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      if (logoImage != null)
                        pw.Container(
                          width: 48,
                          height: 48,
                          margin: const pw.EdgeInsets.only(right: 12),
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            border: pw.Border.all(color: goldColor, width: 1.5),
                          ),
                          child: pw.ClipOval(child: pw.Image(logoImage)),
                        ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'INERTIA SPORTS ACADEMY',
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: darkTextColor,
                            ),
                          ),
                          pw.Text(
                            'GIRISH BADMINTON & SPORTS ARENA',
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 10,
                              color: goldColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          pw.Text(
                            'contact@inertiasports.in • www.inertiasports.in',
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              color: slateTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Invoice Badge & Receipt No
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: emeraldColor,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        ),
                        child: pw.Text(
                          typeHeader,
                          style: pw.TextStyle(
                            font: ttfBold,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'RECEIPT NO: $receiptNumber',
                        style: pw.TextStyle(
                          font: ttfBold,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: darkTextColor,
                        ),
                      ),
                      pw.Text(
                        'DATE: $dateText',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: slateTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Divider(color: goldColor, thickness: 1.5),
              pw.SizedBox(height: 14),

              // 2. BILLED TO & PAYMENT SUMMARY INFO BOX
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Billed To
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: lightBgColor,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        border: pw.Border.all(color: borderColor),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'BILLED TO / CUSTOMER',
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 8.5,
                              fontWeight: pw.FontWeight.bold,
                              color: slateTextColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            customerName,
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                              color: darkTextColor,
                            ),
                          ),
                          if (customerPhone.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'Phone: $customerPhone',
                              style: pw.TextStyle(fontSize: 9.5, color: slateTextColor),
                            ),
                          ],
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Account Category: ${receiptType.toUpperCase()}',
                            style: pw.TextStyle(fontSize: 9.5, color: goldColor, font: ttfBold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 14),

                  // Payment Settlement Meta
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: lightBgColor,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        border: pw.Border.all(color: borderColor),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'PAYMENT SETTLEMENT',
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 8.5,
                              fontWeight: pw.FontWeight.bold,
                              color: slateTextColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Gateway: Razorpay UPI / Online Gateway',
                            style: pw.TextStyle(font: ttfBold, fontSize: 10, color: darkTextColor),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Payment ID: $razorpayPaymentId',
                            style: pw.TextStyle(fontSize: 8.5, color: slateTextColor),
                          ),
                          if (razorpayOrderId != null && razorpayOrderId.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'Order ID: $razorpayOrderId',
                              style: pw.TextStyle(fontSize: 8.5, color: slateTextColor),
                            ),
                          ],
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Status: $status',
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 9.5,
                              color: emeraldColor,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // 3. ITEMIZED CHARGES TABLE
              pw.Text(
                'INVOICE ITEM BREAKDOWN',
                style: pw.TextStyle(
                  font: ttfBold,
                  fontSize: 9.5,
                  fontWeight: pw.FontWeight.bold,
                  color: darkTextColor,
                  letterSpacing: 0.8,
                ),
              ),
              pw.SizedBox(height: 8),

              pw.Table(
                border: pw.TableBorder.all(color: borderColor, width: 1),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2.5),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: lightBgColor),
                    children: [
                      _buildTableCell('Description / Program', isHeader: true, ttfBold: ttfBold),
                      _buildTableCell('Category', isHeader: true, ttfBold: ttfBold),
                      _buildTableCell('Schedule / Period', isHeader: true, ttfBold: ttfBold),
                      _buildTableCell('Amount (INR)', isHeader: true, alignRight: true, ttfBold: ttfBold),
                    ],
                  ),
                  // Table Row
                  pw.TableRow(
                    children: [
                      _buildTableCell(title, isBold: true, ttfBold: ttfBold),
                      _buildTableCell(sportName ?? 'Badminton'),
                      _buildTableCell(schedule ?? dateText),
                      _buildTableCell('₹$baseAmount', alignRight: true, isBold: true, ttfBold: ttfBold),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 16),

              // 4. SUMMARY & CALCULATION SECTION
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Reference Notes / Access code
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (notes != null && notes.isNotEmpty) ...[
                          pw.Text(
                            'NOTES & ACCESS DETAILS:',
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 8.5,
                              color: slateTextColor,
                              letterSpacing: 0.6,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            notes,
                            style: pw.TextStyle(fontSize: 9.5, color: darkTextColor),
                          ),
                          pw.SizedBox(height: 8),
                        ],
                        pw.Text(
                          'Terms & Conditions:',
                          style: pw.TextStyle(font: ttfBold, fontSize: 8.5, color: slateTextColor),
                        ),
                        pw.Text(
                          '1. Non-transferable official academy receipt.\n2. In accordance with Indian GST Rule 46 for educational & sports training services.\n3. Turnstile access requires presenting access PIN or confirmed QR pass.',
                          style: pw.TextStyle(fontSize: 7.5, color: slateTextColor, height: 1.3),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(width: 24),

                  // Total Breakdown Box
                  pw.Container(
                    width: 220,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: lightBgColor,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      border: pw.Border.all(color: borderColor),
                    ),
                    child: pw.Column(
                      children: [
                        _buildCalculationRow('Base Amount', '₹$baseAmount'),
                        if (taxAmount > 0)
                          _buildCalculationRow('GST / Taxes', '₹$taxAmount'),
                        if (discountAmount > 0)
                          _buildCalculationRow('Discounts', '-₹$discountAmount', isDiscount: true),
                        pw.Divider(color: borderColor),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'TOTAL PAID:',
                              style: pw.TextStyle(
                                font: ttfBold,
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: darkTextColor,
                              ),
                            ),
                            pw.Text(
                              '₹$totalAmount',
                              style: pw.TextStyle(
                                font: ttfBold,
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: emeraldColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // 5. OFFICIAL FOOTER WITH SECURITY & STAMP
              pw.Divider(color: borderColor),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'This is a computer-generated tax invoice verified by AMD Play Engine.',
                        style: pw.TextStyle(fontSize: 8, color: slateTextColor),
                      ),
                      pw.Text(
                        'No physical signature required • Authenticated via Razorpay Live Gateway',
                        style: pw.TextStyle(fontSize: 7.5, color: slateTextColor),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: goldColor, width: 1),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      'OFFICIALLY VERIFIED',
                      style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: goldColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Downloads or opens the PDF printing/saving sheet natively.
  /// Returns the local file path where the PDF is stored.
  static Future<String> downloadOrShareReceipt({
    required String receiptNumber,
    required String receiptType,
    required String title,
    String? sportName,
    String? schedule,
    required String customerName,
    String customerPhone = '',
    required String dateText,
    required int totalAmount,
    required int baseAmount,
    int discountAmount = 0,
    int taxAmount = 0,
    String status = 'PAID',
    required String razorpayPaymentId,
    String? razorpayOrderId,
    String? notes,
  }) async {
    // 1. Generate PDF bytes
    final bytes = await generateReceiptPdf(
      receiptNumber: receiptNumber,
      receiptType: receiptType,
      title: title,
      sportName: sportName,
      schedule: schedule,
      customerName: customerName,
      customerPhone: customerPhone,
      dateText: dateText,
      totalAmount: totalAmount,
      baseAmount: baseAmount,
      discountAmount: discountAmount,
      taxAmount: taxAmount,
      status: status,
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
      notes: notes,
    );

    final cleanFileName = 'Invoice_${receiptNumber.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '')}.pdf';
    String savedPath = '';

    // 2. Save directly to app documents / local storage
    try {
      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/$cleanFileName');
      await file.writeAsBytes(bytes, flush: true);
      savedPath = file.path;
    } catch (_) {}

    // 2b. On Android, also attempt saving to public Downloads directory
    try {
      if (Platform.isAndroid) {
        final publicDownloads = Directory('/storage/emulated/0/Download');
        if (publicDownloads.existsSync()) {
          final downloadFile = File('${publicDownloads.path}/$cleanFileName');
          await downloadFile.writeAsBytes(bytes, flush: true);
          savedPath = downloadFile.path;
        }
      }
    } catch (_) {}

    // 2c. Fallback local temporary directory
    if (savedPath.isEmpty) {
      try {
        final tmp = await getTemporaryDirectory();
        final tmpFile = File('${tmp.path}/$cleanFileName');
        await tmpFile.writeAsBytes(bytes, flush: true);
        savedPath = tmpFile.path;
      } catch (_) {}
    }

    // 3. Open native system Share / Save to Downloads sheet (if native plugin channel is registered)
    try {
      await Printing.sharePdf(
        bytes: bytes,
        filename: cleanFileName,
      );
    } catch (e) {
      // Native printing plugin channel net.nfet.printing is not registered in the currently running debug process
      // (a full cold app restart / flutter run registers the native code in APK).
      // The PDF is already 100% saved to device disk above.
    }

    return savedPath;
  }

  /// Directly triggers the native OS "Save as PDF" / Print layout
  static Future<void> layoutPrintReceipt({
    required String receiptNumber,
    required String receiptType,
    required String title,
    String? sportName,
    String? schedule,
    required String customerName,
    String customerPhone = '',
    required String dateText,
    required int totalAmount,
    required int baseAmount,
    int discountAmount = 0,
    int taxAmount = 0,
    String status = 'PAID',
    required String razorpayPaymentId,
    String? razorpayOrderId,
    String? notes,
  }) async {
    final cleanFileName = 'Invoice_${receiptNumber.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '')}';

    await Printing.layoutPdf(
      name: cleanFileName,
      onLayout: (PdfPageFormat format) async {
        return generateReceiptPdf(
          receiptNumber: receiptNumber,
          receiptType: receiptType,
          title: title,
          sportName: sportName,
          schedule: schedule,
          customerName: customerName,
          customerPhone: customerPhone,
          dateText: dateText,
          totalAmount: totalAmount,
          baseAmount: baseAmount,
          discountAmount: discountAmount,
          taxAmount: taxAmount,
          status: status,
          razorpayPaymentId: razorpayPaymentId,
          razorpayOrderId: razorpayOrderId,
          notes: notes,
        );
      },
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    bool alignRight = false,
    pw.Font? ttfBold,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          font: (isHeader || isBold) ? ttfBold : null,
          fontSize: isHeader ? 8.5 : 9.5,
          fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? slateTextColor : darkTextColor,
        ),
      ),
    );
  }

  static pw.Widget _buildCalculationRow(String label, String value, {bool isDiscount = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 9, color: slateTextColor),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9.5,
              color: isDiscount ? PdfColors.red : darkTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
