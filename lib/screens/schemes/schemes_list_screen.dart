import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../models/scheme_model.dart';
import '../../providers/scheme_provider.dart';

class SchemesListScreen extends ConsumerWidget {
  const SchemesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(schemesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Chit Schemes', style: AppTextStyles.title),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addScheme),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: state.when(
        data: (schemes) {
          if (schemes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('No schemes yet', style: AppTextStyles.subtitle),
                  const SizedBox(height: 8),
                  Text('Create your first chit scheme', style: AppTextStyles.bodySecondary),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: schemes.length,
            itemBuilder: (context, i) => _SchemeCard(scheme: schemes[i])
                .animate(delay: (i * 60).ms).fadeIn().slideX(begin: 0.05),
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (_, __) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 130,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        error: (e, _) => Center(child: Text('Error: $e', style: AppTextStyles.bodySecondary)),
      ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  final SchemeModel scheme;
  const _SchemeCard({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/schemes/${scheme.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scheme.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                      Text(scheme.code, style: AppTextStyles.caption.copyWith(color: AppColors.primaryLight)),
                    ],
                  ),
                ),
                _StatusBadge(status: scheme.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              Formatters.currency(scheme.chitAmount),
              style: AppTextStyles.heading.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _Chip(Icons.calendar_month_rounded, '${scheme.durationMonths} months'),
                _Chip(Icons.people_rounded, '${scheme.totalMembers} members'),
                _Chip(Icons.gavel_rounded, scheme.bidType[0].toUpperCase() + scheme.bidType.substring(1)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'active' ? AppColors.success : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(100)),
      child: Text(status[0].toUpperCase() + status.substring(1),
          style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
