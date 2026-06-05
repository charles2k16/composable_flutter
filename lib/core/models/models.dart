// ─── Client Model ─────────────────────────────────────────────────────────────

class ClientModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final List<DeviceModel> devices;

  ClientModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.devices,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
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
  final String method;
  final String? note;

  PaymentModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.method,
    this.note,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
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
  final bool paid;

  ScheduleItem({
    required this.week,
    required this.dueDate,
    required this.amount,
    required this.paid,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      week: json['week'],
      dueDate: DateTime.parse(json['dueDate']),
      amount: (json['amount'] as num).toDouble(),
      paid: json['paid'] ?? false,
    );
  }
}
