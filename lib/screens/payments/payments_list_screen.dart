import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';

class PaymentsListScreen extends ConsumerStatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  ConsumerState<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends ConsumerState<PaymentsListScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Payments', style: AppTextStyles.title),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addPayment),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Summary
          state.when(
            data: (payments) => Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem('Collected',
                      Formatters.currency(payments.where((p) => p.isPaid).fold(0.0, (s, p) => s + p.amount)),
                      AppColors.success),
                  Container(width: 1, height: 40, color: Colors.white30),
                  _SummaryItem('Pending', '${payments.where((p) => p.isPending).length}', AppColors.accentLight),
                  Container(width: 1, height: 40, color: Colors.white30),
                  _SummaryItem('Overdue', '${payments.where((p) => p.isOverdue).length}', AppColors.error),
                ],
              ),
            ),
            loading: () => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(height: 80, margin: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            ),
            error: (_, __) => const SizedBox(),
          ),
          // Filters
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['all', 'pending', 'paid', 'overdue'].map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(f[0].toUpperCase() + f.substring(1)),
                  selected: _filter == f,
                  onSelected: (_) => setState(() => _filter = f),
                  selectedColor: AppColors.primary.withOpacity(0.15),
                  checkmarkColor: AppColors.primary,
                  labelStyle: AppTextStyles.label.copyWith(
                    color: _filter == f ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: _filter == f ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.when(
              data: (payments) {
                final filtered = _filter == 'all' ? payments : payments.where((p) => p.status == _filter).toList();
                if (filtered.isEmpty) {
                  return Center(child: Text('No ${_filter == 'all' ? '' : _filter} payments', style: AppTextStyles.bodySecondary));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => _PaymentCard(
                    payment: filtered[i],
                    onMarkPaid: () => _markPaid(filtered[i]),
                  ).animate(delay: (i * 50).ms).fadeIn().slideX(begin: 0.05),
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(height: 72, margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markPaid(PaymentModel payment) async {
    final ok = await ref.read(paymentsProvider.notifier).markPaid(payment.id);
    if (!mounted) return;
    if (ok) {
      SnackbarHelper.showSuccess(context, 'Marked as paid');
    } else {
      SnackbarHelper.showError(context, 'Failed to update');
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.title.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white70)),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback onMarkPaid;
  const _PaymentCard({required this.payment, required this.onMarkPaid});

  Color get _statusColor {
    if (payment.isPaid) return AppColors.success;
    if (payment.isOverdue) return AppColors.error;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(payment.id),
      direction: payment.isPaid ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.check_circle_outline, color: Colors.white),
      ),
      onDismissed: (_) => onMarkPaid(),
      confirmDismiss: (_) async => !payment.isPaid,
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
              width: 44, height: 44,
              decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(
                payment.isPaid ? Icons.check_circle_rounded : Icons.payments_rounded,
                color: _statusColor, size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(payment.memberName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                  Text('Month ${payment.cycleMonth}', style: AppTextStyles.caption),
                  if (payment.dueDate != null && !payment.isPaid)
                    Text('Due: ${Formatters.date(payment.dueDate!)}', style: AppTextStyles.caption.copyWith(color: payment.isOverdue ? AppColors.error : AppColors.textSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Formatters.currency(payment.amount), style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(100)),
                  child: Text(payment.status[0].toUpperCase() + payment.status.substring(1),
                      style: AppTextStyles.caption.copyWith(color: _statusColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
