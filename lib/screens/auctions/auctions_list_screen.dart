import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../models/auction_model.dart';
import '../../providers/auction_provider.dart';

class AuctionsListScreen extends ConsumerWidget {
  const AuctionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auctionsAsync = ref.watch(auctionsProvider(null));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Auctions', style: AppTextStyles.title),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addAuction),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: auctionsAsync.when(
        data: (auctions) {
          final upcoming = auctions.where((a) => !a.isClosed).toList();
          final past = auctions.where((a) => a.isClosed).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            children: [
              if (upcoming.isNotEmpty) ...[
                Text('Upcoming Auctions', style: AppTextStyles.subtitle),
                const SizedBox(height: 8),
                ...upcoming.asMap().entries.map((e) => _AuctionCard(auction: e.value)
                    .animate(delay: (e.key * 60).ms).fadeIn().slideX(begin: 0.05)),
                const SizedBox(height: 16),
              ],
              if (past.isNotEmpty) ...[
                Text('Past Auctions', style: AppTextStyles.subtitle),
                const SizedBox(height: 8),
                ...past.asMap().entries.map((e) => _AuctionCard(auction: e.value)
                    .animate(delay: (e.key * 60).ms).fadeIn().slideX(begin: 0.05)),
              ],
              if (auctions.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Icon(Icons.gavel_outlined, size: 64, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      Text('No auctions yet', style: AppTextStyles.subtitle),
                    ],
                  ),
                ),
            ],
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (_, __) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(height: 80, margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
          ),
        ),
        error: (e, _) => Center(child: Text('Error: $e', style: AppTextStyles.bodySecondary)),
      ),
    );
  }
}

class _AuctionCard extends StatelessWidget {
  final AuctionModel auction;
  const _AuctionCard({required this.auction});

  Color get _statusColor {
    if (auction.isClosed) return AppColors.textSecondary;
    if (auction.isOpen) return AppColors.success;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/auctions/${auction.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('${auction.cycleMonth}', style: AppTextStyles.title.copyWith(color: AppColors.accent)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Month ${auction.cycleMonth}', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                  if (auction.auctionDate != null)
                    Text(Formatters.date(auction.auctionDate!), style: AppTextStyles.caption),
                  if (auction.winnerName != null)
                    Text('Winner: ${auction.winnerName}', style: AppTextStyles.caption.copyWith(color: AppColors.success)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(auction.status[0].toUpperCase() + auction.status.substring(1),
                      style: AppTextStyles.caption.copyWith(color: _statusColor, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 4),
                Text(Formatters.currency(auction.prizePool), style: AppTextStyles.label.copyWith(color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
