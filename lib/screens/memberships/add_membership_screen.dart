import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../providers/user_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/membership_provider.dart';

class AddMembershipScreen extends ConsumerStatefulWidget {
  final String? groupId;
  const AddMembershipScreen({super.key, this.groupId});

  @override
  ConsumerState<AddMembershipScreen> createState() => _AddMembershipScreenState();
}

class _AddMembershipScreenState extends ConsumerState<AddMembershipScreen> {
  String? _selectedUserId;
  String? _selectedGroupId;
  final _slotCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.groupId;
  }

  @override
  void dispose() {
    _slotCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedUserId == null || _selectedGroupId == null || _slotCtrl.text.isEmpty) {
      SnackbarHelper.showError(context, 'Please fill all fields');
      return;
    }
    setState(() => _isLoading = true);
    final notifier = MembershipsNotifier(ref.read(membershipServiceProvider), _selectedGroupId);
    // PHP expects: chit_group_id, user_id, ticket_number
    final data = {
      'chit_group_id': _selectedGroupId,
      'user_id': _selectedUserId,
      'ticket_number': int.tryParse(_slotCtrl.text) ?? 1,
    };
    final ok = await notifier.addMembership(data);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (ok) {
      context.pop();
    } else {
      SnackbarHelper.showError(context, 'Failed to add membership');
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersNotifierProvider);
    final groups = ref.watch(groupsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add Membership', style: AppTextStyles.title),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Member to Group', style: AppTextStyles.subtitle),
              const SizedBox(height: 16),
              if (widget.groupId == null) ...[
                Text('Select Group', style: AppTextStyles.label),
                const SizedBox(height: 8),
                groups.when(
                  data: (list) => DropdownButtonFormField<String>(
                    value: _selectedGroupId,
                    decoration: _dropdownDecor(),
                    hint: Text('Select group', style: AppTextStyles.body.copyWith(color: AppColors.textHint)),
                    items: list.map((g) => DropdownMenuItem(value: g.id, child: Text(g.groupCode, style: AppTextStyles.body))).toList(),
                    onChanged: (v) => setState(() => _selectedGroupId = v),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 14),
              ],
              Text('Select Member', style: AppTextStyles.label),
              const SizedBox(height: 8),
              users.when(
                data: (list) => DropdownButtonFormField<String>(
                  value: _selectedUserId,
                  decoration: _dropdownDecor(),
                  hint: Text('Select member', style: AppTextStyles.body.copyWith(color: AppColors.textHint)),
                  items: list.where((u) => u.isActive).map((u) => DropdownMenuItem(value: u.id, child: Text(u.name, style: AppTextStyles.body))).toList(),
                  onChanged: (v) => setState(() => _selectedUserId = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 14),
              Text('Slot Number', style: AppTextStyles.label),
              const SizedBox(height: 8),
              TextFormField(
                controller: _slotCtrl,
                keyboardType: TextInputType.number,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.tag_rounded, size: 20, color: AppColors.textSecondary),
                  hintText: 'e.g. 1',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text('Add to Group', style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecor() => InputDecoration(
    filled: true,
    fillColor: AppColors.background,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
