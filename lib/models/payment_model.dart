class PaymentModel {
  final String id;
  final String membershipId;
  final String memberName;
  final String paymentType;
  final String paymentMode;
  final int cycleMonth;
  final double amount;
  final String status;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final String? notes;

  const PaymentModel({
    required this.id,
    required this.membershipId,
    required this.memberName,
    required this.paymentType,
    required this.paymentMode,
    required this.cycleMonth,
    required this.amount,
    required this.status,
    this.dueDate,
    this.paidAt,
    this.notes,
  });

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isOverdue => status == 'overdue';

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['id']?.toString() ?? '',
        membershipId: json['membership_id']?.toString() ?? '',
        memberName: json['member_name'] ?? json['full_name'] ?? '',
        paymentType: json['payment_type'] ?? '',
        paymentMode: json['payment_mode'] ?? '',
        cycleMonth: int.tryParse(json['cycle_month']?.toString() ?? '1') ?? 1,
        amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
        status: json['status'] ?? 'pending',
        dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date']) : null,
        paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at']) : null,
        notes: json['notes'],
      );

  Map<String, dynamic> toJson() => {
        'membership_id': membershipId,
        'cycle_month': cycleMonth,
        'amount': amount,
        'status': status,
        'due_date': dueDate?.toIso8601String(),
        'notes': notes,
      };
}
