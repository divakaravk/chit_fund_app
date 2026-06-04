import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../providers/payment_provider.dart';
import '../../providers/membership_provider.dart';

class AddPaymentScreen extends ConsumerStatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  ConsumerState<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends ConsumerState<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _monthCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _selectedMembershipId;
  DateTime? _dueDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _monthCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMembershipId == null) {
      SnackbarHelper.showError(context, 'Please select a membership');
      return;
    }
    setState(() => _isLoading = true);
    final data = {
      'membership_id': _selectedMembershipId,
      'cycle_month': int.tryParse(_monthCtrl.text) ?? 1,
      'amount': double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0,
      'due_date': _dueDate?.toIso8601String(),
      'notes': _notesCtrl.text.trim(),
      'status': 'pending',
    };
    final ok = await ref.read(paymentsProvider.notifier).addPayment(data);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (ok) {
      SnackbarHelper.showSuccess(context, 'Payment recorded');
      context.pop();
    } else {
      SnackbarHelper.showError(context, 'Failed to record payment');
    }
  }

  @override
  Widget build(BuildContext context) {
    final membershipsAsync = ref.watch(membershipsProvider(null));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Record Payment', style: AppTextStyles.title),
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
                Text('Payment Details', style: AppTextStyles.subtitle),
                const SizedBox(height: 16),
                Text('Select Member', style: AppTextStyles.label),
                const SizedBox(height: 8),
                membershipsAsync.when(
                  data: (list) => DropdownButtonFormField<String>(
                    value: _selectedMembershipId,
                    decoration: _dec(),
                    hint: Text('Select member', style: AppTextStyles.body.copyWith(color: AppColors.textHint)),
                    items: list.map((m) => DropdownMenuItem(value: m.id, child: Text(m.userName, style: AppTextStyles.body))).toList(),
                    onChanged: (v) => setState(() => _selectedMembershipId = v),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 14),
                _field(_monthCtrl, 'Cycle Month', Icons.calendar_month_rounded, type: TextInputType.number, validator: (v) => Validators.required(v, label: 'Cycle month')),
                const SizedBox(height: 14),
                _field(_amountCtrl, 'Amount (₹)', Icons.currency_rupee_rounded, type: TextInputType.number, validator: Validators.amount, prefix: '₹ '),
                const SizedBox(height: 14),
                Text('Due Date', style: AppTextStyles.label),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: AppColors.background, border: Border.all(color: AppColors.divider), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Text(
                          _dueDate != null ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}' : 'Select due date',
                          style: AppTextStyles.body.copyWith(color: _dueDate != null ? AppColors.textPrimary : AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _field(_notesCtrl, 'Notes (Optional)', Icons.notes_rounded),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
                    child: _isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text('Record Payment', style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
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

  Widget _field(TextEditingController ctrl, String label, IconData icon, {TextInputType? type, String? Function(String?)? validator, String? prefix}) {
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
