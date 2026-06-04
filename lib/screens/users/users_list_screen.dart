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
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';

class UsersListScreen extends ConsumerStatefulWidget {
  const UsersListScreen({super.key});

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  String _search = '';
  String _filter = 'all';

  static const _filters = ['all', 'admin', 'foreman', 'member', 'inactive'];

  List<UserModel> _applyFilter(List<UserModel> users) {
    var list = users;
    if (_search.isNotEmpty) {
      list = list.where((u) =>
          u.name.toLowerCase().contains(_search.toLowerCase()) ||
          u.phone.contains(_search)).toList();
    }
    if (_filter != 'all') {
      if (_filter == 'inactive') {
        list = list.where((u) => !u.isActive).toList();
      } else {
        list = list.where((u) => u.role == _filter && u.isActive).toList();
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Members', style: AppTextStyles.title),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addUser),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _filters.map((f) => Padding(
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
              data: (users) {
                final filtered = _applyFilter(users);
                if (filtered.isEmpty) {
                  return _EmptyState(onAdd: () => context.push(AppRoutes.addUser));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => _UserCard(
                    user: filtered[i],
                    onTap: () => context.push('/users/${filtered[i].id}'),
                    onDeactivate: () => _deactivate(filtered[i]),
                  ).animate(delay: (i * 50).ms).fadeIn().slideX(begin: 0.05),
                );
              },
              loading: () => _ShimmerList(),
              error: (e, _) => Center(child: Text('Error: $e', style: AppTextStyles.bodySecondary)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deactivate(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Deactivate ${user.name}?', style: AppTextStyles.title),
        content: Text('This will deactivate the user account.', style: AppTextStyles.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Deactivate', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final ok = await ref.read(usersNotifierProvider.notifier).deactivateUser(user.id);
      if (!mounted) return;
      if (ok) {
        SnackbarHelper.showSuccess(context, 'User deactivated');
      } else {
        SnackbarHelper.showError(context, 'Failed to deactivate');
      }
    }
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap, onDeactivate;
  const _UserCard({required this.user, required this.onTap, required this.onDeactivate});

  Color get _roleColor {
    switch (user.role) {
      case 'admin': return AppColors.primary;
      case 'foreman': return AppColors.accent;
      default: return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(user.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.person_off_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) async => false,
      onDismissed: (_) => onDeactivate(),
      child: GestureDetector(
        onTap: onTap,
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
              CircleAvatar(
                radius: 22,
                backgroundColor: _roleColor.withOpacity(0.15),
                child: Text(
                  Formatters.initials(user.name),
                  style: AppTextStyles.label.copyWith(color: _roleColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(user.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _roleColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            user.role[0].toUpperCase() + user.role.substring(1),
                            style: AppTextStyles.caption.copyWith(color: _roleColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_rounded, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(Formatters.phone(user.phone), style: AppTextStyles.caption),
                        const Spacer(),
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: user.isActive ? AppColors.success : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(user.isActive ? 'Active' : 'Inactive', style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text('No members found', style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          Text('Add your first member', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add Member'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 72,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
