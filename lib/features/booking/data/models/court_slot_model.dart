/// Represents a Sport returned from `/api/v1/sports`.
class SportItem {
  final String id;
  final String name;
  final String slug;
  final String type;
  final String icon;
  final int defaultDurationMinutes;
  final bool active;

  const SportItem({
    required this.id,
    required this.name,
    required this.slug,
    this.type = 'court',
    this.icon = '',
    this.defaultDurationMinutes = 60,
    this.active = true,
  });

  factory SportItem.fromJson(Map<String, dynamic> json) {
    return SportItem(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? (json['name'] ?? '').toString().toLowerCase().replaceAll(' ', '-'),
      type: json['type'] ?? 'court',
      icon: json['icon'] ?? '',
      defaultDurationMinutes: json['defaultDurationMinutes'] ?? 60,
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'type': type,
        'icon': icon,
        'defaultDurationMinutes': defaultDurationMinutes,
        'active': active,
      };
}

/// Represents a generic sports court or turf resource.
class CourtModel {
  final String id;
  final String name;
  final String code;
  final String sportId;
  final String sport;
  final String sportCode;
  final String surfaceType;
  final double basePrice;
  final double peakPrice;
  final double weekendPrice;
  final double memberPrice;
  final double dayShiftPrice;
  final double nightShiftPrice;
  final String pricingModel;
  final bool isUnderMaintenance;

  const CourtModel({
    required this.id,
    required this.name,
    this.code = '',
    this.sportId = '',
    required this.sport,
    required this.sportCode,
    required this.surfaceType,
    required this.basePrice,
    required this.peakPrice,
    required this.weekendPrice,
    required this.memberPrice,
    this.dayShiftPrice = 600,
    this.nightShiftPrice = 1000,
    this.pricingModel = 'hourly',
    this.isUnderMaintenance = false,
  });

  factory CourtModel.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'] is Map ? json['pricing'] as Map : <String, dynamic>{};
    final sportObj = json['sportId'];
    String sportName = (json['sport'] ?? '').toString();
    String sportSlug = (json['sportCode'] ?? '').toString();
    String sportIdStr = '';

    if (sportObj is Map) {
      sportIdStr = (sportObj['_id'] ?? sportObj['id'] ?? '').toString();
      sportName = (sportObj['name'] ?? sportName).toString();
      sportSlug = (sportObj['slug'] ?? sportSlug).toString();
    } else if (sportObj != null) {
      sportIdStr = sportObj.toString();
    }

    if (sportSlug.isEmpty && sportName.isNotEmpty) {
      sportSlug = sportName.toLowerCase().replaceAll(' ', '-');
    }

    final base = (pricing['basePrice'] ?? json['basePrice'] ?? 300).toDouble();
    final peak = (pricing['peakPrice'] ?? json['peakPrice'] ?? base).toDouble();
    final weekend = (pricing['weekendPrice'] ?? json['weekendPrice'] ?? base).toDouble();
    final member = (pricing['memberPrice'] ?? json['memberPrice'] ?? base).toDouble();
    final dayShift = (pricing['dayShiftPrice'] ?? json['dayShiftPrice'] ?? 600).toDouble();
    final nightShift = (pricing['nightShiftPrice'] ?? json['nightShiftPrice'] ?? 1000).toDouble();

    final maintObj = json['maintenance'];
    bool inMaint = json['status'] == 'maintenance' || json['isUnderMaintenance'] == true;
    if (maintObj is Map && maintObj['isUnderMaintenance'] == true) {
      inMaint = true;
    }

    return CourtModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      sportId: sportIdStr,
      sport: sportName.isNotEmpty ? sportName : 'Sports',
      sportCode: sportSlug.isNotEmpty ? sportSlug : 'general',
      surfaceType: json['surface'] ?? json['surfaceType'] ?? 'synthetic',
      basePrice: base,
      peakPrice: peak,
      weekendPrice: weekend,
      memberPrice: member,
      dayShiftPrice: dayShift,
      nightShiftPrice: nightShift,
      pricingModel: pricing['pricingModel'] ?? json['pricingModel'] ?? 'hourly',
      isUnderMaintenance: inMaint,
    );
  }
}

/// Slot availability status enum
enum SlotStatus { available, hold, confirmed, checkedIn, maintenance, coachingBatch }

/// Represents a bookable slot on a court.
class SlotModel {
  final String courtId;
  final String timeText; // e.g. "06:00 - 07:00" or "06:00 AM - 07:00 AM"
  final String startTime; // "06:00"
  final String endTime;   // "07:00"
  final double price;
  final String rateType;
  final SlotStatus status;
  final String? reason;
  final bool isCoachingBatch;
  final bool heldByYou;
  final String? sessionName;
  final String? sessionType;
  final String? customerName;
  final String? accessPin;
  final int? holdSecondsRemaining;

  const SlotModel({
    required this.courtId,
    required this.timeText,
    required this.startTime,
    required this.endTime,
    required this.price,
    this.rateType = 'base',
    required this.status,
    this.reason,
    this.isCoachingBatch = false,
    this.heldByYou = false,
    this.sessionName,
    this.sessionType,
    this.customerName,
    this.accessPin,
    this.holdSecondsRemaining,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json, {String courtId = ''}) {
    final start = json['startTime'] ?? '';
    final end = json['endTime'] ?? '';
    final pricing = json['pricing'] is Map ? json['pricing'] as Map : <String, dynamic>{};
    final price = (pricing['finalPrice'] ?? pricing['basePrice'] ?? json['price'] ?? 300).toDouble();
    final rateType = (pricing['rateType'] ?? json['rateType'] ?? 'base').toString();

    final statusStr = (json['status'] ?? 'available').toString().toLowerCase();
    SlotStatus status = SlotStatus.available;
    if (statusStr == 'booked' || statusStr == 'confirmed') {
      status = SlotStatus.confirmed;
    } else if (statusStr == 'held' || statusStr == 'hold') {
      status = SlotStatus.hold;
    } else if (statusStr == 'maintenance') {
      status = SlotStatus.maintenance;
    } else if (statusStr == 'coaching_batch' || json['isCoachingBatch'] == true) {
      status = SlotStatus.coachingBatch;
    }

    // Format 12-hour time display
    String formattedText = json['sessionName'] ?? '';
    if (formattedText.isEmpty && start.isNotEmpty && end.isNotEmpty) {
      formattedText = '${_format12(start)} - ${_format12(end)}';
    }

    return SlotModel(
      courtId: courtId,
      timeText: formattedText.isNotEmpty ? formattedText : '$start - $end',
      startTime: start,
      endTime: end,
      price: price,
      rateType: rateType,
      status: status,
      reason: json['reason'],
      isCoachingBatch: json['isCoachingBatch'] ?? false,
      heldByYou: json['heldByYou'] ?? false,
      sessionName: json['sessionName'],
      sessionType: json['sessionType'],
      customerName: json['customerName'],
      accessPin: json['accessPin'],
      holdSecondsRemaining: json['holdSecondsRemaining'],
    );
  }

  static String _format12(String timeStr) {
    if (!timeStr.contains(':')) return timeStr;
    final parts = timeStr.split(':');
    int h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? parts[1] : '00';
    final ampm = h >= 12 ? 'PM' : 'AM';
    h = h % 12;
    if (h == 0) h = 12;
    return '${h.toString().padLeft(2, '0')}:$m $ampm';
  }

  bool get isAvailable => status == SlotStatus.available;
  bool get isHold => status == SlotStatus.hold;
  bool get isBooked => status == SlotStatus.confirmed || status == SlotStatus.checkedIn;
  bool get isMaintenance => status == SlotStatus.maintenance;
  bool get isBatchConflict => status == SlotStatus.coachingBatch;

  /// Returns true if this slot's start time on the given date is in the past
  bool isPast(DateTime date, [DateTime? referenceNow]) {
    final now = referenceNow ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate.isBefore(today)) return true;
    if (targetDate.isAfter(today)) return false;

    if (startTime.isEmpty) return false;

    try {
      final clean = startTime.trim();
      final parts = clean.split(':');
      if (parts.isNotEmpty) {
        int hour = int.parse(parts[0].replaceAll(RegExp(r'[^0-9]'), ''));
        int minute = 0;
        if (parts.length > 1) {
          final mStr = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
          if (mStr.isNotEmpty) minute = int.parse(mStr);
        }

        final lower = clean.toLowerCase();
        if (lower.contains('pm') && hour < 12) hour += 12;
        if (lower.contains('am') && hour == 12) hour = 0;

        final slotDateTime = DateTime(targetDate.year, targetDate.month, targetDate.day, hour, minute);
        return slotDateTime.isBefore(now);
      }
    } catch (_) {}

    return false;
  }
}


/// Represents a slot selected by the user for multi-slot cart/checkout.
class SelectedSlot {
  final String resourceId;
  final String courtName;
  final String sportName;
  final String date;       // "YYYY-MM-DD"
  final String startTime;  // "HH:mm"
  final String endTime;    // "HH:mm"
  final String timeText;   // "06:00 - 07:00"
  final double price;

  const SelectedSlot({
    required this.resourceId,
    required this.courtName,
    this.sportName = '',
    required this.date,
    required this.startTime,
    required this.endTime,
    this.timeText = '',
    this.price = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'resourceId': resourceId,
    'date': date,
    'startTime': startTime,
    'endTime': endTime,
  };

  SelectedSlot copyWith({
    String? resourceId,
    String? courtName,
    String? sportName,
    String? date,
    String? startTime,
    String? endTime,
    String? timeText,
    double? price,
  }) {
    return SelectedSlot(
      resourceId: resourceId ?? this.resourceId,
      courtName: courtName ?? this.courtName,
      sportName: sportName ?? this.sportName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timeText: timeText ?? this.timeText,
      price: price ?? this.price,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedSlot &&
          runtimeType == other.runtimeType &&
          resourceId == other.resourceId &&
          date == other.date &&
          startTime == other.startTime &&
          endTime == other.endTime;

  @override
  int get hashCode =>
      resourceId.hashCode ^ date.hashCode ^ startTime.hashCode ^ endTime.hashCode;
}

/// Quote response from POST /api/v1/slots/calculate-price
class MultiSlotPricingQuote {
  final double basePrice;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;
  final int totalSlots;
  final List<dynamic> itemizedPrices;

  const MultiSlotPricingQuote({
    required this.basePrice,
    this.taxRate = 18.0,
    required this.taxAmount,
    required this.totalAmount,
    this.totalSlots = 1,
    this.itemizedPrices = const [],
  });

  factory MultiSlotPricingQuote.fromJson(Map<String, dynamic> json) {
    final base = (json['basePrice'] ?? 0).toDouble();
    final tax = (json['taxAmount'] ?? 0).toDouble();
    final total = (json['totalAmount'] ?? (base + tax)).toDouble();
    final slots = (json['slots'] as List?) ?? (json['itemizedPrices'] as List?) ?? [];
    return MultiSlotPricingQuote(
      basePrice: base,
      taxRate: (json['taxRate'] ?? 18).toDouble(),
      taxAmount: tax,
      totalAmount: total,
      totalSlots: json['totalSlots'] ?? (slots.isNotEmpty ? slots.length : 1),
      itemizedPrices: slots,
    );
  }
}

/// Hold Lock response from POST /api/v1/slots/hold
class MultiSlotHoldResult {
  final String holdId;
  final String expiresAt;
  final int expiresInSeconds;
  final int heldSlotsCount;

  const MultiSlotHoldResult({
    required this.holdId,
    required this.expiresAt,
    required this.expiresInSeconds,
    required this.heldSlotsCount,
  });

  factory MultiSlotHoldResult.fromJson(Map<String, dynamic> json) {
    return MultiSlotHoldResult(
      holdId: json['holdId']?.toString() ?? '',
      expiresAt: json['expiresAt']?.toString() ?? '',
      expiresInSeconds: json['expiresInSeconds'] ?? json['ttlSeconds'] ?? 300,
      heldSlotsCount: json['heldSlotsCount'] ?? json['totalSlots'] ?? 1,
    );
  }
}
