class DisbursementModel {
  final String id;
  final String auctionId;
  final String membershipId;
  final String recipientName;
  final double amount;
  final String status;
  final DateTime? disbursedAt;

  const DisbursementModel({
    required this.id,
    required this.auctionId,
    required this.membershipId,
    required this.recipientName,
    required this.amount,
    required this.status,
    this.disbursedAt,
  });

  factory DisbursementModel.fromJson(Map<String, dynamic> json) => DisbursementModel(
        id: json['id']?.toString() ?? '',
        auctionId: json['auction_id']?.toString() ?? '',
        membershipId: json['membership_id']?.toString() ?? '',
        recipientName: json['recipient_name'] ?? '',
        amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
        status: json['status'] ?? 'pending',
        disbursedAt: json['disbursed_at'] != null
            ? DateTime.tryParse(json['disbursed_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'auction_id': auctionId,
        'membership_id': membershipId,
        'amount': amount,
      };
}
