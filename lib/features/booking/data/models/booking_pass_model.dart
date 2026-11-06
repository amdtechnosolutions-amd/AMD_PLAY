import 'package:mobile_app/features/home/presentation/controllers/home_controller.dart';

/// Represents a confirmed court reservation with digital 6-digit access PIN and QR pass.
class BookingPassModel {
  final String id;
  final String bookingReference;
  final String courtName;
  final String sportName;
  final String dateText;
  final String timeWindow;
  final String accessPin;
  final String qrPassUrl;
  final double amount;
  final double taxAmount;
  final double totalAmount;
  final String status;
  final String venueName;
  final String venueAddress;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? playerName;
  final bool isMultiSlot;
  final String? groupId;
  final String? groupBookingNumber;
  final int totalSlots;
  final List<BookingPassModel> subBookings;

  const BookingPassModel({
    required this.id,
    required this.bookingReference,
    required this.courtName,
    required this.sportName,
    required this.dateText,
    required this.timeWindow,
    required this.accessPin,
    required this.qrPassUrl,
    required this.amount,
    required this.taxAmount,
    required this.totalAmount,
    this.status = 'CONFIRMED',
    this.venueName = 'Apex Sports Arena, Central Flagship',
    this.venueAddress = '100ft Road, Indiranagar, Bangalore',
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.playerName,
    this.isMultiSlot = false,
    this.groupId,
    this.groupBookingNumber,
    this.totalSlots = 1,
    this.subBookings = const [],
  });

  factory BookingPassModel.fromJson(Map<String, dynamic> json) {
    // If this is a multi-slot group wrapper, parse subBookings
    final rawSubBookings = json['bookings'] is List ? (json['bookings'] as List) : [];
    final List<BookingPassModel> parsedSubs = rawSubBookings
        .whereType<Map<String, dynamic>>()
        .map((b) => BookingPassModel.fromJson(b))
        .toList();

    final isMulti = json['isMultiSlot'] == true || parsedSubs.length > 1;
    final grpId = json['groupId']?.toString();
    final grpNum = json['groupBookingNumber']?.toString();

    final res = json['resourceId'] is Map ? json['resourceId'] as Map<String, dynamic> : null;
    final sport = json['sportId'] is Map ? json['sportId'] as Map<String, dynamic> : null;
    final branch = json['branchId'] is Map ? json['branchId'] as Map<String, dynamic> : null;
    final pricing = json['pricing'] is Map ? json['pricing'] as Map<String, dynamic> : null;
    final payment = json['payment'] is Map ? json['payment'] as Map<String, dynamic> : null;

    final bookingRef = json['bookingNumber']?.toString() ??
        json['bookingReference']?.toString() ??
        grpNum ??
        'APX-78210';
    final courtName = res?['name']?.toString() ??
        json['courtName']?.toString() ??
        (parsedSubs.isNotEmpty ? parsedSubs.first.courtName : 'Court 01');
    final sportName = sport?['name']?.toString() ??
        json['sportName']?.toString() ??
        (parsedSubs.isNotEmpty ? parsedSubs.first.sportName : 'Badminton');
    final date = json['date']?.toString() ??
        json['dateText']?.toString() ??
        (parsedSubs.isNotEmpty ? parsedSubs.first.dateText : 'Today');

    final startTime = json['startTime']?.toString() ?? '';
    final endTime = json['endTime']?.toString() ?? '';
    final timeWin = (startTime.isNotEmpty && endTime.isNotEmpty)
        ? '$startTime - $endTime'
        : (json['timeWindow']?.toString() ?? (parsedSubs.isNotEmpty ? parsedSubs.first.timeWindow : '07:00 PM - 08:00 PM'));

    final accessPin = json['accessCode']?.toString() ??
        json['accessPin']?.toString() ??
        json['pin']?.toString() ??
        (parsedSubs.isNotEmpty ? parsedSubs.first.accessPin : '519283');

    final qrUrl = json['qrCodeUrl']?.toString() ??
        json['qrPassUrl']?.toString() ??
        json['qrCode']?.toString() ??
        (parsedSubs.isNotEmpty ? parsedSubs.first.qrPassUrl : 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=APX-PASS-$accessPin');

    final baseAmt = (pricing?['basePrice'] ?? pricing?['finalPrice'] ?? json['amount'] ?? json['basePrice'] ?? 600).toDouble();
    final taxAmt = (pricing?['taxAmount'] ?? json['taxAmount'] ?? 0).toDouble();
    final totalAmt = (pricing?['totalAmount'] ?? json['totalAmount'] ?? (baseAmt + taxAmt)).toDouble();

    final rzpPayId = payment?['gatewayPaymentId']?.toString() ??
        payment?['transactionId']?.toString() ??
        json['razorpayPaymentId']?.toString();
    final rzpOrderId = payment?['gatewayOrderId']?.toString() ??
        json['razorpayOrderId']?.toString();

    final branchName = branch?['name']?.toString() ??
        json['venueName']?.toString() ??
        'Apex Sports Arena, Central Flagship';
    final branchAddr = branch?['address']?.toString() ??
        json['venueAddress']?.toString() ??
        '100ft Road, Indiranagar, Bangalore';

    final user = json['userId'] is Map ? json['userId'] as Map<String, dynamic> : null;
    final fName = user?['firstName']?.toString() ?? '';
    final lName = user?['lastName']?.toString() ?? '';
    final pName = (user?['fullName'] ?? (fName.isNotEmpty ? '$fName $lName' : '')).toString().trim();
    final resolvedPlayerName = pName.isNotEmpty
        ? pName
        : (json['customerName']?.toString() ?? json['userName']?.toString());

    return BookingPassModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      bookingReference: bookingRef,
      courtName: courtName,
      sportName: sportName,
      dateText: date,
      timeWindow: timeWin,
      accessPin: accessPin,
      qrPassUrl: qrUrl,
      amount: baseAmt,
      taxAmount: taxAmt,
      totalAmount: totalAmt,
      status: json['status']?.toString().toUpperCase() ?? 'CONFIRMED',
      venueName: branchName,
      venueAddress: branchAddr,
      razorpayPaymentId: rzpPayId,
      razorpayOrderId: rzpOrderId,
      playerName: resolvedPlayerName,
      isMultiSlot: isMulti,
      groupId: grpId,
      groupBookingNumber: grpNum,
      totalSlots: json['totalSlots'] ?? (parsedSubs.isNotEmpty ? parsedSubs.length : 1),
      subBookings: parsedSubs,
    );
  }

  /// Converts booking pass into official FeeItem receipt for instant receipt viewing
  FeeItem toFeeItem() {
    return FeeItem(
      id: id.isNotEmpty ? id : bookingReference,
      title: '$sportName - $courtName',
      dueDate: dateText,
      amount: totalAmount.round(),
      status: status.toLowerCase() == 'confirmed' ? 'paid' : status.toLowerCase(),
      month: DateTime.now().month,
      year: DateTime.now().year,
      baseFee: amount.round(),
      discountAmount: 0,
      paidAmount: totalAmount.round(),
      paidAt: dateText,
      razorpayPaymentId: razorpayPaymentId ?? 'pay_rzp_${bookingReference.replaceAll('-', '_')}',
      razorpayOrderId: razorpayOrderId,
      sportName: sportName,
      schedule: timeWindow,
      notes: 'Court Reservation: $courtName ($timeWindow)',
    );
  }
}
