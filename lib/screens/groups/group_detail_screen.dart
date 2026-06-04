import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../models/group_model.dart';
import '../../models/membership_model.dart';
import '../../models/auction_model.dart';
import '../../providers/group_provider.dart';
import '../../providers/membership_provider.dart';
import '../../providers/auction_provider.dart';

class GroupDetailScreen extends ConsumerWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: groupAsync.when(
        data: (group) => _GroupDetailBody(group: group),
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }
}

class _GroupDetailBody extends ConsumerStatefulWidget {
  final GroupModel group;
  const _GroupDetailBody({required this.group});

  @override
  ConsumerState<_GroupDetailBody> createState() => _GroupDetailBodyState();
}

class _GroupDetailBodyState extends ConsumerState<_GroupDetailBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    return NestedScrollView(
      headerSliverBuilder: (context, _) => [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(group.groupCode, style: AppTextStyles.titleWhite),
          expandedHeight: 180,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              padding: const EdgeInsets.fromLTRB(16, 80, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.schemeName, style: AppTextStyles.bodyWhite.copyWith(color: Colors.white70)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Month ${group.currentMonth}', style: AppTextStyles.titleWhite),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(group.status[0].toUpperCase() + group.status.substring(1),
                            style: AppTextStyles.caption.copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.accent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Members'),
              Tab(text: 'Auctions'),
              Tab(text: 'Payments'),
            ],
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(group: group),
          _MembersTab(groupId: group.id),
          _AuctionsTab(groupId: group.id),
          _PaymentsTab(groupId: group.id),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final GroupModel group;
  const _OverviewTab({required this.group});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _StatCard(
            children: [
              _StatRow('Group Code', group.groupCode),
              _StatRow('Scheme', group.schemeName),
              _StatRow('Status', group.status[0].toUpperCase() + group.status.substring(1)),
              _StatRow('Members', '${group.memberCount}'),
              if (group.startDate != null) _StatRow('Start Date', Formatters.date(group.startDate!)),
              if (group.nextAuctionDate != null)
                _StatRow('Next Auction', Formatters.date(group.nextAuctionDate!)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push('${AppRoutes.addAuction}?group_id=${group.id}'),
            icon: const Icon(Icons.gavel_rounded),
            label: const Text('Schedule Auction'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _MembersTab extends ConsumerWidget {
  final String groupId;
  const _MembersTab({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipsAsync = ref.watch(membershipsProvider(groupId));
    return membershipsAsync.when(
      data: (list) => list.isEmpty
          ? _Empty(label: 'No members yet', icon: Icons.people_outline_rounded,
              onAdd: () => context.push('${AppRoutes.addMembership}?group_id=$groupId'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) => _MemberTile(m: list[i]),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

class _AuctionsTab extends ConsumerWidget {
  final String groupId;
  const _AuctionsTab({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auctionsAsync = ref.watch(auctionsProvider(groupId));
    return auctionsAsync.when(
      data: (list) => list.isEmpty
          ? _Empty(label: 'No auctions yet', icon: Icons.gavel_outlined,
              onAdd: () => context.push('${AppRoutes.addAuction}?group_id=$groupId'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) => _AuctionTile(a: list[i]),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

class _PaymentsTab extends ConsumerWidget {
  final String groupId;
  const _PaymentsTab({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Text('Payments for group $groupId', style: AppTextStyles.bodySecondary),
    );
  }
}

class _StatCard extends StatelessWidget {
  final List<Widget> children;
  const _StatCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(children: children),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label, value;
  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.label),
          Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final MembershipModel m;
  const _MemberTile({required this.m});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            child: Text(Formatters.initials(m.userName), style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.userName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
              Text(Formatters.phone(m.userPhone), style: AppTextStyles.caption),
            ],
          )),
          Text('Slot ${m.slotNumber}', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
          if (m.hasWon) ...[
            const SizedBox(width: 8),
            const Icon(Icons.emoji_events_rounded, color: AppColors.accent, size: 18),
          ],
        ],
      ),
    );
  }
}

class _AuctionTile extends StatelessWidget {
  final AuctionModel a;
  const _AuctionTile({required this.a});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/auctions/${a.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.gavel_rounded, color: AppColors.accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Month ${a.cycleMonth}', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
                if (a.auctionDate != null) Text(Formatters.date(a.auctionDate!), style: AppTextStyles.caption),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (a.isClosed ? AppColors.textSecondary : a.isOpen ? AppColors.success : AppColors.warning).withOpacity(0.12),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(a.status[0].toUpperCase() + a.status.substring(1),
                  style: AppTextStyles.caption.copyWith(
                    color: a.isClosed ? AppColors.textSecondary : a.isOpen ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onAdd;
  const _Empty({required this.label, required this.icon, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(label, style: AppTextStyles.bodySecondary),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
