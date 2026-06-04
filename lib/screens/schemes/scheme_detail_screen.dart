import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../providers/scheme_provider.dart';

class SchemeDetailScreen extends ConsumerWidget {
  final String schemeId;
  const SchemeDetailScreen({super.key, required this.schemeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemes = ref.watch(schemesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Scheme Details', style: AppTextStyles.title),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: schemes.when(
        data: (list) {
          final scheme = list.where((s) => s.id == schemeId).firstOrNull;
          if (scheme == null) return Center(child: Text('Scheme not found', style: AppTextStyles.body));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(scheme.name, style: AppTextStyles.titleWhite),
                              Text(scheme.code, style: AppTextStyles.bodyWhite.copyWith(color: Colors.white70)),
                            ],
                          )),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(100)),
                            child: Text(scheme.status[0].toUpperCase() + scheme.status.substring(1),
                                style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(Formatters.currency(scheme.chitAmount), style: AppTextStyles.displayWhite),
                      Text('Total Chit Value', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _InfoGrid(items: [
                  _InfoItem('Duration', '${scheme.durationMonths} months', Icons.calendar_month_rounded),
                  _InfoItem('Members', '${scheme.totalMembers}', Icons.people_rounded),
                  _InfoItem('Monthly', Formatters.currency(scheme.monthlyContribution), Icons.payments_rounded),
                  _InfoItem('Commission', '${scheme.foremanCommissionPercent}%', Icons.percent_rounded),
                  _InfoItem('Bid Type', scheme.bidType[0].toUpperCase() + scheme.bidType.substring(1), Icons.gavel_rounded),
                ]),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final List<_InfoItem> items;
  const _InfoGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: items.map((item) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 8),
            Text(item.value, style: AppTextStyles.subtitle.copyWith(color: AppColors.primary)),
            Text(item.label, style: AppTextStyles.caption),
          ],
        ),
      )).toList(),
    );
  }
}

class _InfoItem {
  final String label, value;
  final IconData icon;
  const _InfoItem(this.label, this.value, this.icon);
}
