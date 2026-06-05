class MembershipModel {
  final String id;
  final String groupId;
  final String userId;
  final String userName;
  final String userPhone;
  final int slotNumber;
  final String status;
  final bool hasWon;
  final DateTime? joinedAt;

  const MembershipModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.slotNumber,
    required this.status,
    required this.hasWon,
    this.joinedAt,
  });

  // DB columns: chit_group_id, ticket_number, has_won_auction, joined_at
  factory MembershipModel.fromJson(Map<String, dynamic> json) => MembershipModel(
        id: json['id']?.toString() ?? '',
        groupId: json['chit_group_id']?.toString() ?? json['group_id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        userName: json['user_name'] ?? json['full_name'] ?? '',
        userPhone: json['user_phone'] ?? json['phone_number'] ?? '',
        slotNumber: int.tryParse(
              json['ticket_number']?.toString() ??
              json['slot_number']?.toString() ??
              '0',
            ) ?? 0,
        status: json['status'] ?? 'active',
        hasWon: json['has_won_auction'] == 1 ||
            json['has_won_auction'] == true ||
            json['has_won_auction'] == '1' ||
            json['has_won'] == 1 ||
            json['has_won'] == true,
        joinedAt: json['joined_at'] != null
            ? DateTime.tryParse(json['joined_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'chit_group_id': groupId,
        'user_id': userId,
        'ticket_number': slotNumber,
        'status': status,
      };
}
