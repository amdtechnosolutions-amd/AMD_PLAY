import 'package:intl/intl.dart';
import '../../../home/presentation/controllers/home_controller.dart';

/// Response model for GET /api/v1/students/my/payments
class StudentPaymentsResponse {
  final String familyPhone;
  final String parentName;
  final String siblingGroupId;
  final int totalStudents;
  final FamilyPaymentSummary summary;
  final List<SiblingPaymentGroup> siblings;

  const StudentPaymentsResponse({
    this.familyPhone = '',
    this.parentName = '',
    this.siblingGroupId = '',
    this.totalStudents = 0,
    required this.summary,
    this.siblings = const [],
  });

  factory StudentPaymentsResponse.fromJson(Map<String, dynamic> json) {
    final summaryMap = json['summary'] is Map
        ? Map<String, dynamic>.from(json['summary'] as Map)
        : <String, dynamic>{};
    final rawSiblings = json['siblings'] as List? ?? [];
    final parsedSiblings = rawSiblings
        .whereType<Map>()
        .map((e) => SiblingPaymentGroup.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return StudentPaymentsResponse(
      familyPhone: (json['familyPhone'] ?? '').toString().trim(),
      parentName: (json['parentName'] ?? '').toString().trim(),
      siblingGroupId: (json['siblingGroupId'] ?? '').toString().trim(),
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? parsedSiblings.length,
      summary: FamilyPaymentSummary.fromJson(summaryMap),
      siblings: parsedSiblings,
    );
  }
}

class FamilyPaymentSummary {
  final int totalAmount;
  final int totalPaid;
  final int totalPending;
  final int totalInvoices;
  final int paidInvoices;
  final int pendingInvoices;
  final int paymentTransactions;

  const FamilyPaymentSummary({
    this.totalAmount = 0,
    this.totalPaid = 0,
    this.totalPending = 0,
    this.totalInvoices = 0,
    this.paidInvoices = 0,
    this.pendingInvoices = 0,
    this.paymentTransactions = 0,
  });

  factory FamilyPaymentSummary.fromJson(Map<String, dynamic> json) {
    return FamilyPaymentSummary(
      totalAmount: (json['totalAmount'] as num?)?.toInt() ?? 0,
      totalPaid: (json['totalPaid'] as num?)?.toInt() ?? 0,
      totalPending: (json['totalPending'] as num?)?.toInt() ?? 0,
      totalInvoices: (json['totalInvoices'] as num?)?.toInt() ?? 0,
      paidInvoices: (json['paidInvoices'] as num?)?.toInt() ?? 0,
      pendingInvoices: (json['pendingInvoices'] as num?)?.toInt() ?? 0,
      paymentTransactions: (json['paymentTransactions'] as num?)?.toInt() ?? 0,
    );
  }
}

class SiblingPaymentGroup {
  final String studentId;
  final String fullName;
  final String firstName;
  final String lastName;
  final String regNo;
  final String phone;
  final String parentPhone;
  final SiblingPaymentSummary summary;
  final List<SiblingFeeEntry> fees;
  final List<SiblingPaymentTransaction> payments;

  const SiblingPaymentGroup({
    required this.studentId,
    required this.fullName,
    this.firstName = '',
    this.lastName = '',
    this.regNo = '',
    this.phone = '',
    this.parentPhone = '',
    required this.summary,
    this.fees = const [],
    this.payments = const [],
  });

  factory SiblingPaymentGroup.fromJson(Map<String, dynamic> json) {
    final fName = (json['firstName'] ?? '').toString().trim();
    final lName = (json['lastName'] ?? '').toString().trim();
    final combined = '$fName $lName'.trim();
    final rawFull = (json['fullName'] ?? json['name'] ?? '').toString().trim();
    final resolvedName = rawFull.isNotEmpty ? rawFull : (combined.isNotEmpty ? combined : 'Trainee');

    final summaryMap = json['summary'] is Map
        ? Map<String, dynamic>.from(json['summary'] as Map)
        : <String, dynamic>{};

    final rawFees = json['fees'] as List? ?? [];
    final parsedFees = rawFees
        .whereType<Map>()
        .map((e) => SiblingFeeEntry.fromJson(
              Map<String, dynamic>.from(e),
              studentName: resolvedName,
            ))
        .toList();

    final rawPayments = json['payments'] as List? ?? [];
    final parsedPayments = rawPayments
        .whereType<Map>()
        .map((e) => SiblingPaymentTransaction.fromJson(
              Map<String, dynamic>.from(e),
              studentName: resolvedName,
              regNo: (json['regNo'] ?? json['employeeNo'] ?? '').toString().trim(),
            ))
        .toList();

    return SiblingPaymentGroup(
      studentId: (json['studentId'] ?? json['id'] ?? json['_id'] ?? '').toString(),
      fullName: resolvedName,
      firstName: fName,
      lastName: lName,
      regNo: (json['regNo'] ?? json['employeeNo'] ?? '').toString().trim(),
      phone: (json['phone'] ?? '').toString().trim(),
      parentPhone: (json['parentPhone'] ?? '').toString().trim(),
      summary: SiblingPaymentSummary.fromJson(summaryMap),
      fees: parsedFees,
      payments: parsedPayments,
    );
  }
}

class SiblingPaymentSummary {
  final int totalAmount;
  final int totalPaid;
  final int totalPending;
  final int invoiceCount;
  final int paidCount;
  final int pendingCount;
  final int paymentTransactionCount;

  const SiblingPaymentSummary({
    this.totalAmount = 0,
    this.totalPaid = 0,
    this.totalPending = 0,
    this.invoiceCount = 0,
    this.paidCount = 0,
    this.pendingCount = 0,
    this.paymentTransactionCount = 0,
  });

  factory SiblingPaymentSummary.fromJson(Map<String, dynamic> json) {
    return SiblingPaymentSummary(
      totalAmount: (json['totalAmount'] as num?)?.toInt() ?? 0,
      totalPaid: (json['totalPaid'] as num?)?.toInt() ?? 0,
      totalPending: (json['totalPending'] as num?)?.toInt() ?? 0,
      invoiceCount: (json['invoiceCount'] as num?)?.toInt() ?? 0,
      paidCount: (json['paidCount'] as num?)?.toInt() ?? 0,
      pendingCount: (json['pendingCount'] as num?)?.toInt() ?? 0,
      paymentTransactionCount: (json['paymentTransactionCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class SiblingFeeEntry {
  final FeeItem feeItem;
  final String studentName;
  final String receiptNo;

  const SiblingFeeEntry({
    required this.feeItem,
    required this.studentName,
    this.receiptNo = '',
  });

  factory SiblingFeeEntry.fromJson(
    Map<String, dynamic> f, {
    required String studentName,
  }) {
    final id = (f['_id'] ?? f['id'] ?? '').toString();
    final month = (f['month'] as num?)?.toInt() ?? DateTime.now().month;
    final year = (f['year'] as num?)?.toInt() ?? DateTime.now().year;
    final baseFee = (f['baseFee'] as num?)?.toInt() ?? (f['finalAmount'] as num?)?.toInt() ?? (f['amount'] as num?)?.toInt() ?? 0;
    final discountAmount = (f['discountAmount'] as num?)?.toInt() ?? 0;
    final amount = (f['finalAmount'] ?? f['amount'] ?? baseFee as num?)?.toInt() ?? 0;
    final status = (f['status']?.toString() ?? 'pending').toLowerCase();
    final paidAmount = (f['paidAmount'] as num?)?.toInt() ?? (status == 'paid' ? amount : 0);
    final receiptNo = (f['receiptNo'] ?? '').toString().trim();
    final title = (f['batchDisplayName'] ?? f['batchName'] ?? 'Monthly Coaching Fee').toString().trim();

    String? paidAtStr;
    if (f['paidAt'] != null) {
      final dt = DateTime.tryParse(f['paidAt'].toString());
      if (dt != null) {
        paidAtStr = DateFormat('MMM dd, yyyy • hh:mm a').format(dt.toLocal());
      } else {
        paidAtStr = f['paidAt'].toString();
      }
    }

    final monthName = DateFormat('MMM').format(DateTime(year, month));
    final dueDateStr = f['dueDate'] != null
        ? 'Due: ${DateFormat('MMM dd, yyyy').format(DateTime.tryParse(f['dueDate'].toString()) ?? DateTime(year, month, 28))}'
        : 'Due: $monthName 30, $year';

    return SiblingFeeEntry(
      studentName: studentName,
      receiptNo: receiptNo,
      feeItem: FeeItem(
        id: id,
        title: title,
        dueDate: dueDateStr,
        amount: amount,
        status: status,
        month: month,
        year: year,
        baseFee: baseFee,
        discountAmount: discountAmount,
        paidAmount: paidAmount,
        paidAt: paidAtStr,
        razorpayPaymentId: receiptNo.isNotEmpty
            ? receiptNo
            : f['razorpayPaymentId']?.toString(),
        razorpayOrderId: f['razorpayOrderId']?.toString(),
        notes: f['notes']?.toString(),
        sportName: f['sportName']?.toString(),
        schedule: receiptNo.isNotEmpty ? 'Receipt: $receiptNo' : null,
      ),
    );
  }
}

class SiblingPaymentTransaction {
  final String id;
  final int amount;
  final String paymentMethod;
  final String status;
  final String createdAtFormatted;
  final String studentName;
  final String regNo;

  const SiblingPaymentTransaction({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.createdAtFormatted,
    required this.studentName,
    this.regNo = '',
  });

  factory SiblingPaymentTransaction.fromJson(
    Map<String, dynamic> json, {
    required String studentName,
    String regNo = '',
  }) {
    String formattedDate = '';
    if (json['createdAt'] != null) {
      final dt = DateTime.tryParse(json['createdAt'].toString());
      if (dt != null) {
        formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(dt.toLocal());
      } else {
        formattedDate = json['createdAt'].toString();
      }
    }

    return SiblingPaymentTransaction(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      paymentMethod: (json['paymentMethod'] ?? 'upi').toString().toUpperCase(),
      status: (json['status'] ?? 'success').toString().toUpperCase(),
      createdAtFormatted: formattedDate,
      studentName: studentName,
      regNo: regNo,
    );
  }
}

