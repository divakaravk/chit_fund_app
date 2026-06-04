import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notifications', style: AppTextStyles.title),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: state.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('No notifications', style: AppTextStyles.subtitle),
                ],
              ),
            );
          }
          final today = notifications.where((n) => _isToday(n.createdAt)).toList();
          final yesterday = notifications.where((n) => _isYesterday(n.createdAt)).toList();
          final earlier = notifications.where((n) => !_isToday(n.createdAt) && !_isYesterday(n.createdAt)).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (today.isNotEmpty) ...[
                _SectionHeader('Today'),
                ...today.map((n) => _NotificationCard(notification: n, ref: ref)),
              ],
              if (yesterday.isNotEmpty) ...[
                _SectionHeader('Yesterday'),
                ...yesterday.map((n) => _NotificationCard(notification: n, ref: ref)),
              ],
              if (earlier.isNotEmpty) ...[
                _SectionHeader('Earlier'),
                ...earlier.map((n) => _NotificationCard(notification: n, ref: ref)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  bool _isToday(DateTime? dt) {
    if (dt == null) return false;
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  bool _isYesterday(DateTime? dt) {
    if (dt == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day;
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final WidgetRef ref;
  const _NotificationCard({required this.notification, required this.ref});

  IconData get _icon {
    switch (notification.type) {
      case 'payment_due': return Icons.payments_rounded;
      case 'auction_result': return Icons.gavel_rounded;
      case 'disbursement': return Icons.account_balance_wallet_rounded;
      default: return Icons.campaign_rounded;
    }
  }

  Color get _color {
    switch (notification.type) {
      case 'payment_due': return AppColors.warning;
      case 'auction_result': return AppColors.accent;
      case 'disbursement': return AppColors.success;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => ref.read(notificationsProvider.notifier).deleteNotification(notification.id),
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            ref.read(notificationsProvider.notifier).markRead(notification.id);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notification.isRead ? const Color(0xFFF5F5F5) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: notification.isRead ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(_icon, color: _color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.title, style: AppTextStyles.body.copyWith(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(notification.body, style: AppTextStyles.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (notification.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(Formatters.timeAgo(notification.createdAt!), style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
                    ],
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
