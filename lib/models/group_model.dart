class GroupModel {
  final String id;
  final String companyId;
  final String schemeId;
  final String schemeName;
  final String groupCode;
  final int currentMonth;
  final String status;
  final DateTime? startDate;
  final DateTime? nextAuctionDate;
  final int memberCount;
  final DateTime? createdAt;

  const GroupModel({
    required this.id,
    required this.companyId,
    required this.schemeId,
    required this.schemeName,
    required this.groupCode,
    required this.currentMonth,
    required this.status,
    this.startDate,
    this.nextAuctionDate,
    required this.memberCount,
    this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        id: json['id']?.toString() ?? '',
        companyId: json['company_id']?.toString() ?? '',
        schemeId: json['scheme_id']?.toString() ?? '',
        schemeName: json['scheme_name'] ?? '',
        groupCode: json['group_code'] ?? '',
        currentMonth: int.tryParse(json['current_month']?.toString() ?? '1') ?? 1,
        status: json['status'] ?? 'active',
        startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
        nextAuctionDate: json['next_auction_date'] != null
            ? DateTime.tryParse(json['next_auction_date'])
            : null,
        memberCount: int.tryParse(json['member_count']?.toString() ?? '0') ?? 0,
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      );

  Map<String, dynamic> toJson() => {
        'company_id': companyId,
        'scheme_id': schemeId,
        'group_code': groupCode,
        'current_month': currentMonth,
        'status': status,
        'start_date': startDate?.toIso8601String(),
      };
}
