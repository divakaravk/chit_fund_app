class BidModel {
  final String id;
  final String auctionId;
  final String membershipId;
  final String bidderName;
  final double amount;
  final DateTime? createdAt;

  const BidModel({
    required this.id,
    required this.auctionId,
    required this.membershipId,
    required this.bidderName,
    required this.amount,
    this.createdAt,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) => BidModel(
        id: json['id']?.toString() ?? '',
        auctionId: json['auction_id']?.toString() ?? '',
        membershipId: json['membership_id']?.toString() ?? '',
        bidderName: json['bidder_name'] ?? '',
        amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'auction_id': auctionId,
        'membership_id': membershipId,
        'amount': amount,
      };
}
