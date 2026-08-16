// ─── Client Model ─────────────────────────────────────────────────────────────

class ClientModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? reference;
  final DateTime? nextDueDate;
  final List<DeviceModel> devices;

  ClientModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.reference,
    this.nextDueDate,
    required this.devices,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      reference: json['reference'],
      nextDueDate: json['nextDueDate'] != null ? DateTime.parse(json['nextDueDate']) : null,
      devices: (json['devices'] as List?)
              ?.map((d) => DeviceModel.fromJson(d))
              .toList() ??
          [],
    );
  }
}

// ─── Device Model ─────────────────────────────────────────────────────────────

class DeviceModel {
  final String id;
  final String model;
  final String serialNumber;
  final String? variant;
  final String? color;
  final double originalPrice;
  final double markup;
  final double sellingPrice;
  final double downPayment;
  final double balanceToFinance;
  final double weeklyInstallment;
  final int totalWeeks;
  final DateTime startDate;
  final String status;

  // Calculated fields from backend
  final double totalPaid;
  final double balance;
  final int pct;
  final int weeksLeft;
  final bool overdue;
  final DateTime? nextDueDate;
  final List<PaymentModel> payments;
  final List<ScheduleItem> schedule;

  DeviceModel({
    required this.id,
    required this.model,
    required this.serialNumber,
    this.variant,
    this.color,
    required this.originalPrice,
    required this.markup,
    required this.sellingPrice,
    required this.downPayment,
    required this.balanceToFinance,
    required this.weeklyInstallment,
    required this.totalWeeks,
    required this.startDate,
    required this.status,
    required this.totalPaid,
    required this.balance,
    required this.pct,
    required this.weeksLeft,
    required this.overdue,
    this.nextDueDate,
    required this.payments,
    required this.schedule,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'],
      model: json['model'],
      serialNumber: json['serialNumber'],
      variant: json['variant'],
      color: json['color'],
      originalPrice: (json['originalPrice'] as num).toDouble(),
      markup: (json['markup'] as num).toDouble(),
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      downPayment: (json['downPayment'] as num).toDouble(),
      balanceToFinance: (json['balanceToFinance'] as num).toDouble(),
      weeklyInstallment: (json['weeklyInstallment'] as num).toDouble(),
      totalWeeks: json['totalWeeks'],
      startDate: DateTime.parse(json['startDate']),
      status: json['status'],
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      pct: json['pct'] ?? 0,
      weeksLeft: json['weeksLeft'] ?? 0,
      overdue: json['overdue'] ?? false,
      nextDueDate: json['nextDueDate'] != null ? DateTime.parse(json['nextDueDate']) : null,
      payments: (json['payments'] as List?)
              ?.map((p) => PaymentModel.fromJson(p))
              .toList() ??
          [],
      schedule: (json['schedule'] as List?)
              ?.map((s) => ScheduleItem.fromJson(s))
              .toList() ??
          [],
    );
  }

  bool get isCompleted => status == 'COMPLETED' || balance <= 0;
  bool get isLocked => status == 'LOCKED';
}

// ─── Payment Model ────────────────────────────────────────────────────────────

class PaymentModel {
  final String id;
  final double amount;
  final DateTime date;
  final DateTime? createdAt;
  final String method;
  final String? note;

  PaymentModel({
    required this.id,
    required this.amount,
    required this.date,
    this.createdAt,
    required this.method,
    this.note,
  });

  DateTime get recordedAt => createdAt ?? date;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      method: json['method'] ?? 'MOBILE_MONEY',
      note: json['note'],
    );
  }

  String get methodLabel => {
        'MOBILE_MONEY': 'Mobile Money',
        'CASH': 'Cash',
        'BANK_TRANSFER': 'Bank Transfer',
      }[method] ??
      method;
}

// ─── Schedule Item ────────────────────────────────────────────────────────────

class ScheduleItem {
  final int week;
  final DateTime dueDate;
  final double amount;
  final double amountPaid;
  final String? _status;
  final bool paid;

  ScheduleItem({
    required this.week,
    required this.dueDate,
    required this.amount,
    required this.amountPaid,
    String? status,
    required this.paid,
  }) : _status = status;

  String get status => _status ?? (paid ? 'paid' : 'active');

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    final paid = json['paid'] == true;
    final rawStatus = json['status'];
    final parsedStatus = rawStatus is String && rawStatus.isNotEmpty
        ? rawStatus
        : (paid ? 'paid' : 'active');
    final amountValue = json['amount'] ?? json['amountDue'];

    return ScheduleItem(
      week: (json['week'] as num).toInt(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      amount: (amountValue as num).toDouble(),
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0,
      status: parsedStatus,
      paid: paid || parsedStatus == 'paid',
    );
  }

  String get resolvedStatus => status;

  bool get isOverdue => status == 'overdue';
  bool get isPartial => status == 'partial';
  bool get isActive => status == 'active';
}

// ─── Client Notification ──────────────────────────────────────────────────────

class ClientNotification {
  final String id;
  final String type;
  final String channel;
  final String message;
  final String status;
  final DateTime? sentAt;
  final DateTime createdAt;

  ClientNotification({
    required this.id,
    required this.type,
    required this.channel,
    required this.message,
    required this.status,
    this.sentAt,
    required this.createdAt,
  });

  factory ClientNotification.fromJson(Map<String, dynamic> json) {
    return ClientNotification(
      id: json['id'],
      type: json['type'],
      channel: json['channel'] ?? '',
      message: json['message'],
      status: json['status'] ?? '',
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get typeLabel => {
        'PAYMENT_REMINDER': 'Payment Reminder',
        'PAYMENT_CONFIRMED': 'Payment Confirmed',
        'OVERDUE_WARNING': 'Overdue Warning',
        'DEVICE_LOCKED': 'Device Locked',
        'DEVICE_UNLOCKED': 'Device Unlocked',
        'ONBOARDING': 'Welcome',
        'COMPLETION': 'Fully Paid',
        'CUSTOM': 'Message',
      }[type] ??
      type;
}
