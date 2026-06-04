class SuretyBondModel {
  final String id;
  final String membershipId;
  final String suretorId;
  final String suretorName;
  final String status;
  final DateTime? createdAt;

  const SuretyBondModel({
    required this.id,
    required this.membershipId,
    required this.suretorId,
    required this.suretorName,
    required this.status,
    this.createdAt,
  });

  factory SuretyBondModel.fromJson(Map<String, dynamic> json) => SuretyBondModel(
        id: json['id']?.toString() ?? '',
        membershipId: json['membership_id']?.toString() ?? '',
        suretorId: json['suretor_id']?.toString() ?? '',
        suretorName: json['suretor_name'] ?? '',
        status: json['status'] ?? 'active',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'membership_id': membershipId,
        'suretor_id': suretorId,
        'status': status,
      };
}
