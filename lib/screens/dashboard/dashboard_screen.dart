import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/storage/local_storage.dart';
import '../../core/utils/formatters.dart';
import '../../models/group_model.dart';
import '../../models/user_model.dart';
import '../../models/payment_model.dart';
import '../../models/auction_model.dart';
import '../../providers/group_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auction_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await LocalStorage.getUserName();
    setState(() => _userName = name ?? 'User');
  }

  static const _navItems = [
    NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.group_rounded), label: 'Groups'),
    NavigationDestination(icon: Icon(Icons.payments_rounded), label: 'Payments'),
    NavigationDestination(icon: Icon(Icons.people_rounded), label: 'Members'),
    NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
  ];

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 1:
        context.push(AppRoutes.groups);
      case 2:
        context.push(AppRoutes.payments);
      case 3:
        context.push(AppRoutes.users);
      case 4:
        context.push(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadCountProvider);
    final groups = ref.watch(groupsProvider);
    final users = ref.watch(usersNotifierProvider);
    final payments = ref.watch(paymentsProvider);
    final auctions = ref.watch(auctionsProvider(null));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(unreadCount)),
            SliverToBoxAdapter(child: _buildSummaryCards(groups, users, payments)),
            SliverToBoxAdapter(child: _buildQuickActions()),
            SliverToBoxAdapter(child: _buildUpcomingAuctions(auctions)),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavTap,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withOpacity(0.1),
        destinations: _navItems,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }

  Widget _buildHeader(int unreadCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Formatters.greeting(),
                  style: AppTextStyles.bodyWhite.copyWith(color: Colors.white70),
                ),
                Text(
                  _userName,
                  style: AppTextStyles.titleWhite,
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () => context.push(AppRoutes.notifications),
                icon: const Icon(Icons.notifications_rounded, color: Colors.white, size: 28),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.push(AppRoutes.profile),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                Formatters.initials(_userName),
                style: AppTextStyles.label.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildSummaryCards(
    AsyncValue<List<GroupModel>> groupsState,
    AsyncValue<List<UserModel>> usersState,
    AsyncValue<List<PaymentModel>> paymentsState,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview', style: AppTextStyles.subtitle),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _SummaryCard(
                  title: 'Total Groups',
                  value: groupsState.when(
                    data: (groups) => '${groups.length}',
                    loading: () => '—',
                    error: (_, __) => '—',
                  ),
                  icon: Icons.group_work_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                _SummaryCard(
                  title: 'Active Members',
                  value: usersState.when(
                    data: (users) => '${users.where((u) => u.isActive).length}',
                    loading: () => '—',
                    error: (_, __) => '—',
                  ),
                  icon: Icons.people_rounded,
                  color: AppColors.success,
                ),
                const SizedBox(width: 12),
                _SummaryCard(
                  title: 'Pending',
                  value: paymentsState.when(
                    data: (p) => '${p.where((x) => x.isPending || x.isOverdue).length}',
                    loading: () => '—',
                    error: (_, __) => '—',
                  ),
                  icon: Icons.pending_actions_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 12),
                _SummaryCard(
                  title: 'Collected',
                  value: paymentsState.when(
                    data: (p) {
                      final total = p.where((x) => x.isPaid).fold(0.0, (s, x) => s + x.amount);
                      return Formatters.currency(total);
                    },
                    loading: () => '—',
                    error: (_, __) => '—',
                  ),
                  icon: Icons.account_balance_wallet_rounded,
                  color: const Color(0xFF9333EA),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1);
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction('Add Member', Icons.person_add_rounded, AppColors.primary, AppRoutes.addUser),
      _QuickAction('New Auction', Icons.gavel_rounded, AppColors.accent, AppRoutes.addAuction),
      _QuickAction('Record Payment', Icons.add_card_rounded, AppColors.success, AppRoutes.addPayment),
      _QuickAction('View Groups', Icons.group_work_rounded, AppColors.primaryLight, AppRoutes.groups),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppTextStyles.subtitle),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85,
            children: actions
                .map((a) => _QuickActionTile(action: a, onTap: () => context.push(a.route)))
                .toList(),
          ),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1);
  }

  Widget _buildUpcomingAuctions(AsyncValue<List<AuctionModel>> auctionsState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Upcoming Auctions', style: AppTextStyles.subtitle),
              TextButton(
                onPressed: () => context.push(AppRoutes.auctions),
                child: Text('See All', style: AppTextStyles.label.copyWith(color: AppColors.primaryLight)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          auctionsState.when(
            data: (auctions) {
              final upcoming = auctions
                  .where((a) => a.isScheduled || a.isOpen)
                  .take(3)
                  .toList();
              if (upcoming.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text('No upcoming auctions', style: AppTextStyles.bodySecondary),
                  ),
                );
              }
              return Column(
                children: upcoming.map((a) => _AuctionTile(auction: a)).toList(),
              );
            },
            loading: () => _ShimmerList(count: 3),
            error: (_, __) => Text('Failed to load', style: AppTextStyles.bodySecondary),
          ),
        ],
      ),
    ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.1);
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _QuickAction(this.label, this.icon, this.color, this.route);
}

class _QuickActionTile extends StatelessWidget {
  final _QuickAction action;
  final VoidCallback onTap;
  const _QuickActionTile({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(action.icon, color: action.color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            action.label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _SummaryCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.title.copyWith(color: color, fontSize: 20)),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _AuctionTile extends StatelessWidget {
  final dynamic auction;
  const _AuctionTile({required this.auction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.gavel_rounded, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Month ${auction.cycleMonth}', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  auction.auctionDate != null
                      ? Formatters.date(auction.auctionDate!)
                      : 'Date TBD',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          _StatusChip(status: auction.status),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'open':
        color = AppColors.success;
      case 'closed':
        color = AppColors.textSecondary;
      default:
        color = AppColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  final int count;
  const _ShimmerList({required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (_) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 64,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      )),
    );
  }
}
