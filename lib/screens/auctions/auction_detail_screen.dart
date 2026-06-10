import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../models/auction_model.dart';
import '../../models/membership_model.dart';
import '../../providers/auction_provider.dart';
import '../../providers/membership_provider.dart';

class AuctionDetailScreen extends ConsumerWidget {
  final String auctionId;
  const AuctionDetailScreen({super.key, required this.auctionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auctionsAsync = ref.watch(auctionByIdProvider(auctionId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Auction Details', style: AppTextStyles.title),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: auctionsAsync.when(
        data: (auction) {
          if (auction == null) return Center(child: Text('Auction not found', style: AppTextStyles.body));
          return _AuctionDetailBody(auction: auction);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AuctionDetailBody extends ConsumerWidget {
  final AuctionModel auction;
  const _AuctionDetailBody({required this.auction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bidsAsync = ref.watch(bidsProvider(auction.id));
    ref.watch(membershipsProvider(auction.groupId)); // pre-load for Add Bid sheet

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Prize pool header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text('Prize Pool', style: AppTextStyles.bodyWhite.copyWith(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(Formatters.currency(auction.prizePool), style: AppTextStyles.displayWhite),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (auction.auctionDate != null) ...[
                      const Icon(Icons.calendar_today_rounded, color: Colors.white60, size: 16),
                      const SizedBox(width: 6),
                      Text(Formatters.date(auction.auctionDate!), style: AppTextStyles.bodyWhite.copyWith(color: Colors.white70)),
                      const SizedBox(width: 16),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(100)),
                      child: Text(auction.status[0].toUpperCase() + auction.status.substring(1),
                          style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Winner section if closed
          if (auction.isClosed && auction.winnerName != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: AppColors.success, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Winner', style: AppTextStyles.label.copyWith(color: AppColors.success)),
                        Text(auction.winnerName!, style: AppTextStyles.subtitle.copyWith(color: AppColors.success)),
                        if (auction.winningBid != null)
                          Text('Winning Bid: ${Formatters.currency(auction.winningBid!)}', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Bids
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Bids', style: AppTextStyles.subtitle),
                    if (!auction.isClosed)
                      TextButton.icon(
                        onPressed: () => _showAddBidSheet(context, ref),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Bid'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                bidsAsync.when(
                  data: (bids) {
                    if (bids.isEmpty) return Text('No bids yet', style: AppTextStyles.bodySecondary);
                    final sorted = [...bids]..sort((a, b) => b.amount.compareTo(a.amount));
                    return Column(
                      children: sorted.asMap().entries.map((e) {
                        final bid = e.value;
                        final isHighest = e.key == 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isHighest ? AppColors.success.withOpacity(0.08) : AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: isHighest ? Border.all(color: AppColors.success.withOpacity(0.3)) : null,
                          ),
                          child: Row(
                            children: [
                              if (isHighest) const Icon(Icons.star_rounded, color: AppColors.success, size: 18),
                              if (!isHighest) Text('#${e.key + 1}', style: AppTextStyles.label),
                              const SizedBox(width: 8),
                              Expanded(child: Text(bid.bidderName, style: AppTextStyles.body)),
                              Text(Formatters.currency(bid.amount),
                                  style: AppTextStyles.body.copyWith(
                                    color: isHighest ? AppColors.success : AppColors.textPrimary,
                                    fontWeight: isHighest ? FontWeight.bold : FontWeight.normal,
                                  )),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e', style: AppTextStyles.bodySecondary),
                ),
              ],
            ),
          ),

          // Close auction button
          if (!auction.isClosed) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCloseSheet(context, ref),
                icon: const Icon(Icons.gavel_rounded),
                label: const Text('Close Auction'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddBidSheet(BuildContext context, WidgetRef ref) {
    final amountCtrl = TextEditingController();
    final memberships = ref.read(membershipsProvider(auction.groupId)).valueOrNull ?? [];
    MembershipModel? selected;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16,
              MediaQuery.viewInsetsOf(ctx).bottom + MediaQuery.paddingOf(ctx).bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(100))),
              const SizedBox(height: 16),
              Text('Add Bid', style: AppTextStyles.title),
              const SizedBox(height: 16),
              if (memberships.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text('No members in this group', style: AppTextStyles.bodySecondary),
                )
              else
                DropdownButtonFormField<MembershipModel>(
                  value: selected,
                  decoration: const InputDecoration(labelText: 'Select Member', border: OutlineInputBorder()),
                  items: memberships
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text('${m.userName} (Slot ${m.slotNumber})'),
                          ))
                      .toList(),
                  onChanged: (m) => setState(() => selected = m),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Bid Amount (₹)', border: OutlineInputBorder(), prefixText: '₹ '),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  onPressed: () async {
                    final amount = double.tryParse(amountCtrl.text.trim());
                    if (selected == null) {
                      SnackbarHelper.showError(context, 'Please select a member');
                      return;
                    }
                    if (amount == null || amount <= 0) {
                      SnackbarHelper.showError(context, 'Enter a valid bid amount');
                      return;
                    }
                    final service = ref.read(auctionServiceProvider);
                    final result = await service.addBid({
                      'auction_cycle_id': auction.id,
                      'membership_id': selected!.id,
                      'bid_amount': amount,
                    });
                    if (!ctx.mounted) return;
                    if (result.success) {
                      Navigator.pop(ctx);
                      ref.invalidate(bidsProvider(auction.id));
                      SnackbarHelper.showSuccess(context, 'Bid added successfully');
                    } else {
                      SnackbarHelper.showError(context, result.message ?? 'Failed to add bid');
                    }
                  },
                  child: const Text('Submit Bid'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCloseSheet(BuildContext context, WidgetRef ref) {
    final winnerCtrl = TextEditingController();
    final commissionCtrl = TextEditingController();
    final dividendCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16,
            MediaQuery.viewInsetsOf(ctx).bottom + MediaQuery.paddingOf(ctx).bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(100))),
            const SizedBox(height: 16),
            Text('Close Auction', style: AppTextStyles.title),
            const SizedBox(height: 16),
            TextField(controller: winnerCtrl, decoration: const InputDecoration(labelText: 'Winner Membership ID', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: commissionCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Commission Amount (₹)', border: OutlineInputBorder(), prefixText: '₹ ')),
            const SizedBox(height: 12),
            TextField(controller: dividendCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dividend per member (₹)', border: OutlineInputBorder(), prefixText: '₹ ')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                onPressed: () async {
                  final service = ref.read(auctionServiceProvider);
                  await service.closeAuction(auction.id, {
                    'winner_membership_id': winnerCtrl.text,
                    'foreman_commission': double.tryParse(commissionCtrl.text) ?? 0,
                    'dividend': double.tryParse(dividendCtrl.text) ?? 0,
                  });
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ref.invalidate(auctionByIdProvider);
                    ref.invalidate(auctionsProvider);
                    SnackbarHelper.showSuccess(context, 'Auction closed successfully');
                  }
                },
                child: const Text('Confirm & Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
