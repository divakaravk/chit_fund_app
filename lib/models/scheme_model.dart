class SchemeModel {
  final String id;
  final String companyId;
  final String name;
  final String code;
  final double chitAmount;
  final int durationMonths;
  final int totalMembers;
  final double monthlyContribution;
  final double foremanCommissionPercent;
  final String bidType;
  final String status;
  final DateTime? createdAt;

  const SchemeModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.code,
    required this.chitAmount,
    required this.durationMonths,
    required this.totalMembers,
    required this.monthlyContribution,
    required this.foremanCommissionPercent,
    required this.bidType,
    required this.status,
    this.createdAt,
  });

  factory SchemeModel.fromJson(Map<String, dynamic> json) => SchemeModel(
        id: json['id']?.toString() ?? '',
        companyId: json['company_id']?.toString() ?? '',
        name: json['name'] ?? '',
        code: json['code'] ?? '',
        chitAmount: double.tryParse(json['chit_amount']?.toString() ?? '0') ?? 0,
        durationMonths: int.tryParse(json['duration_months']?.toString() ?? '0') ?? 0,
        totalMembers: int.tryParse(json['total_members']?.toString() ?? '0') ?? 0,
        monthlyContribution:
            double.tryParse(json['monthly_contribution']?.toString() ?? '0') ?? 0,
        foremanCommissionPercent:
            double.tryParse(json['foreman_commission_percent']?.toString() ?? '0') ?? 0,
        bidType: json['bid_type'] ?? 'open',
        status: json['status'] ?? 'active',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'company_id': companyId,
        'name': name,
        'code': code,
        'chit_amount': chitAmount,
        'duration_months': durationMonths,
        'total_members': totalMembers,
        'monthly_contribution': monthlyContribution,
        'foreman_commission_percent': foremanCommissionPercent,
        'bid_type': bidType,
        'status': status,
      };
}
