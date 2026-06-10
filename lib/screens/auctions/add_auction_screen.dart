import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/validators.dart';
import '../../providers/auction_provider.dart';
import '../../providers/group_provider.dart';

class AddAuctionScreen extends ConsumerStatefulWidget {
  final String? groupId;
  const AddAuctionScreen({super.key, this.groupId});

  @override
  ConsumerState<AddAuctionScreen> createState() => _AddAuctionScreenState();
}

class _AddAuctionScreenState extends ConsumerState<AddAuctionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _monthCtrl = TextEditingController();
  final _prizeCtrl = TextEditingController();
  String? _selectedGroupId;
  DateTime? _auctionDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.groupId;
  }

  @override
  void dispose() {
    _monthCtrl.dispose();
    _prizeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (date != null) setState(() => _auctionDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGroupId == null) {
      SnackbarHelper.showError(context, 'Please select a group');
      return;
    }
    setState(() => _isLoading = true);
    final notifier = AuctionsNotifier(ref.read(auctionServiceProvider), _selectedGroupId);
    // PHP expects chit_group_id and DATE format (YYYY-MM-DD) not ISO datetime
    final date = _auctionDate ?? DateTime.now();
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final data = {
      'chit_group_id': _selectedGroupId,
      'cycle_month': int.tryParse(_monthCtrl.text) ?? 1,
      'prize_pool': double.tryParse(_prizeCtrl.text.replaceAll(',', '')) ?? 0,
      'auction_date': dateStr,
    };
    final ok = await notifier.addAuction(data);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (ok) {
      context.pop();
    } else {
      SnackbarHelper.showError(context, 'Failed to schedule auction');
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Schedule Auction', style: AppTextStyles.title),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                Text('Auction Details', style: AppTextStyles.subtitle),
                const SizedBox(height: 16),
                if (widget.groupId == null) ...[
                  Text('Select Group', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  groups.when(
                    data: (list) => DropdownButtonFormField<String>(
                      value: _selectedGroupId,
                      decoration: _dec(),
                      hint: Text('Select group', style: AppTextStyles.body.copyWith(color: AppColors.textHint)),
                      items: list.map((g) => DropdownMenuItem(value: g.id, child: Text(g.groupCode, style: AppTextStyles.body))).toList(),
                      onChanged: (v) => setState(() => _selectedGroupId = v),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: 14),
                ],
                _FormField(ctrl: _monthCtrl, label: 'Cycle Month', icon: Icons.calendar_month_rounded,
                    type: TextInputType.number, validator: (v) => Validators.required(v, label: 'Cycle month')),
                const SizedBox(height: 14),
                _FormField(ctrl: _prizeCtrl, label: 'Prize Pool (₹)', icon: Icons.currency_rupee_rounded,
                    type: TextInputType.number, validator: Validators.amount, prefix: '₹ '),
                const SizedBox(height: 14),
                Text('Auction Date', style: AppTextStyles.label),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Text(
                          _auctionDate != null
                              ? '${_auctionDate!.day}/${_auctionDate!.month}/${_auctionDate!.year}'
                              : 'Select auction date',
                          style: AppTextStyles.body.copyWith(color: _auctionDate != null ? AppColors.textPrimary : AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
                    child: _isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text('Schedule Auction', style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec() => InputDecoration(
    filled: true, fillColor: AppColors.background,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

class _FormField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType? type;
  final String? Function(String?)? validator;
  final String? prefix;

  const _FormField({required this.ctrl, required this.label, required this.icon, this.type, this.validator, this.prefix});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: type,
          validator: validator,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            prefixText: prefix,
            prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
            filled: true, fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
