class AuctionModel {
  final String id;
  final String groupId;
  final int cycleMonth;
  final DateTime? auctionDate;
  final double prizePool;
  final String status;
  final String? winnerId;
  final String? winnerName;
  final double? winningBid;
  final double? foremanCommission;
  final double? dividend;
  final DateTime? createdAt;

  const AuctionModel({
    required this.id,
    required this.groupId,
    required this.cycleMonth,
    this.auctionDate,
    required this.prizePool,
    required this.status,
    this.winnerId,
    this.winnerName,
    this.winningBid,
    this.foremanCommission,
    this.dividend,
    this.createdAt,
  });

  bool get isOpen => status == 'open';
  bool get isScheduled => status == 'scheduled';
  bool get isClosed => status == 'closed';

  // DB columns: chit_group_id, winning_bid_amount, dividend_per_member, winner_membership_id
  factory AuctionModel.fromJson(Map<String, dynamic> json) => AuctionModel(
        id: json['id']?.toString() ?? '',
        groupId: json['chit_group_id']?.toString() ??
            json['group_id']?.toString() ?? '',
        cycleMonth: int.tryParse(json['cycle_month']?.toString() ?? '1') ?? 1,
        auctionDate: json['auction_date'] != null
            ? DateTime.tryParse(json['auction_date'])
            : null,
        prizePool: double.tryParse(json['prize_pool']?.toString() ?? '0') ?? 0,
        status: json['status'] ?? 'scheduled',
        winnerId: json['winner_membership_id']?.toString() ??
            json['winner_id']?.toString(),
        winnerName: json['winner_name'],
        winningBid: json['winning_bid_amount'] != null
            ? double.tryParse(json['winning_bid_amount'].toString())
            : json['winning_bid'] != null
                ? double.tryParse(json['winning_bid'].toString())
                : null,
        foremanCommission: json['foreman_commission'] != null
            ? double.tryParse(json['foreman_commission'].toString())
            : null,
        dividend: json['dividend_per_member'] != null
            ? double.tryParse(json['dividend_per_member'].toString())
            : json['dividend'] != null
                ? double.tryParse(json['dividend'].toString())
                : null,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'chit_group_id': groupId,
        'cycle_month': cycleMonth,
        'auction_date': auctionDate != null
            ? '${auctionDate!.year}-${auctionDate!.month.toString().padLeft(2, '0')}-${auctionDate!.day.toString().padLeft(2, '0')}'
            : null,
        'prize_pool': prizePool,
        'status': status,
      };
}
