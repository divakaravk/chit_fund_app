import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/storage/local_storage.dart';
import '../../providers/group_provider.dart';
import '../../providers/scheme_provider.dart';

class AddGroupScreen extends ConsumerStatefulWidget {
  const AddGroupScreen({super.key});

  @override
  ConsumerState<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends ConsumerState<AddGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  String? _selectedSchemeId;
  DateTime? _startDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _startDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSchemeId == null) {
      SnackbarHelper.showError(context, 'Please select a scheme');
      return;
    }
    setState(() => _isLoading = true);
    final companyId = await LocalStorage.getCompanyId() ?? '';
    // foreman_user_id is required by PHP — use logged-in user as default foreman
    final foremanUserId = await LocalStorage.getUserId() ?? '';
    final startDateStr = _startDate != null
        ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}'
        : DateTime.now().toIso8601String().substring(0, 10);
    final data = {
      'company_id': companyId,
      'scheme_id': _selectedSchemeId,
      'group_code': _codeCtrl.text.trim(),
      'foreman_user_id': foremanUserId,
      'start_date': startDateStr,
    };
    final ok = await ref.read(groupsProvider.notifier).addGroup(data);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (ok) {
      context.pop();
    } else {
      final err = ref.read(groupsProvider).error;
      SnackbarHelper.showError(context, err?.toString() ?? 'Failed to create group');
    }
  }

  @override
  Widget build(BuildContext context) {
    final schemes = ref.watch(schemesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add Chit Group', style: AppTextStyles.title),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Group Information', style: AppTextStyles.subtitle),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codeCtrl,
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) => Validators.required(v, label: 'Group code'),
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        labelText: 'Group Code',
                        prefixIcon: const Icon(Icons.tag_rounded, size: 20, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Select Scheme', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    schemes.when(
                      data: (schemeList) => DropdownButtonFormField<String>(
                        value: _selectedSchemeId,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.description_rounded, size: 20, color: AppColors.textSecondary),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        hint: Text('Select a scheme', style: AppTextStyles.body.copyWith(color: AppColors.textHint)),
                        items: schemeList.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, style: AppTextStyles.body))).toList(),
                        onChanged: (v) => setState(() => _selectedSchemeId = v),
                        validator: (v) => v == null ? 'Please select a scheme' : null,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => Text('Failed to load schemes', style: AppTextStyles.bodySecondary),
                    ),
                    const SizedBox(height: 14),
                    Text('Start Date', style: AppTextStyles.label),
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
                              _startDate != null
                                  ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                  : 'Select start date',
                              style: AppTextStyles.body.copyWith(
                                color: _startDate != null ? AppColors.textPrimary : AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text('Create Group', style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
