import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/storage/local_storage.dart';
import '../../providers/user_provider.dart';

class AddUserScreen extends ConsumerStatefulWidget {
  const AddUserScreen({super.key});

  @override
  ConsumerState<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends ConsumerState<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  String _role = 'member';
  bool _showAddress = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final companyId = await LocalStorage.getCompanyId() ?? '';
    // Schema uses full_name, phone_number; address is a JSON object
    final hasAddress = _streetCtrl.text.isNotEmpty ||
        _cityCtrl.text.isNotEmpty ||
        _stateCtrl.text.isNotEmpty ||
        _pincodeCtrl.text.isNotEmpty;
    final data = {
      'company_id': companyId,
      'full_name': _nameCtrl.text.trim(),
      'phone_number': _phoneCtrl.text.trim(),
      'role': _role,
      if (hasAddress)
        'address': {
          if (_streetCtrl.text.isNotEmpty) 'street': _streetCtrl.text.trim(),
          if (_cityCtrl.text.isNotEmpty) 'city': _cityCtrl.text.trim(),
          if (_stateCtrl.text.isNotEmpty) 'state': _stateCtrl.text.trim(),
          if (_pincodeCtrl.text.isNotEmpty) 'pincode': _pincodeCtrl.text.trim(),
        },
    };
    final ok = await ref.read(usersNotifierProvider.notifier).addUser(data);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (ok) {
      SnackbarHelper.showSuccess(context, 'Member added successfully');
      context.pop();
    } else {
      SnackbarHelper.showError(context, 'Failed to add member');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add New Member', style: AppTextStyles.title),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Personal Information', style: AppTextStyles.subtitle),
                    const SizedBox(height: 16),
                    _FormField(ctrl: _nameCtrl, label: 'Full Name', icon: Icons.person_rounded,
                        validator: (v) => Validators.required(v, label: 'Full name')),
                    const SizedBox(height: 14),
                    _FormField(ctrl: _phoneCtrl, label: 'Phone Number', icon: Icons.phone_rounded,
                        type: TextInputType.phone, validator: Validators.phone),
                    const SizedBox(height: 14),
                    Text('Role', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    _RoleSelector(value: _role, onChange: (v) => setState(() => _role = v)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => setState(() => _showAddress = !_showAddress),
                      child: Row(
                        children: [
                          Text('Address (Optional)', style: AppTextStyles.subtitle),
                          const Spacer(),
                          Icon(
                            _showAddress ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    if (_showAddress) ...[
                      const SizedBox(height: 16),
                      _FormField(ctrl: _streetCtrl, label: 'Street', icon: Icons.location_on_rounded),
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(child: _FormField(ctrl: _cityCtrl, label: 'City', icon: Icons.location_city_rounded)),
                        const SizedBox(width: 12),
                        Expanded(child: _FormField(ctrl: _stateCtrl, label: 'State', icon: Icons.map_rounded)),
                      ]),
                      const SizedBox(height: 14),
                      _FormField(ctrl: _pincodeCtrl, label: 'Pincode', icon: Icons.pin_drop_rounded, type: TextInputType.number),
                    ],
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
                      : Text('Add Member', style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: child,
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType? type;
  final String? Function(String?)? validator;

  const _FormField({required this.ctrl, required this.label, required this.icon, this.type, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      validator: validator,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChange;
  const _RoleSelector({required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final roles = ['member', 'foreman', 'admin'];
    return Row(
      children: roles.map((r) {
        final selected = value == r;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChange(r),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                  border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  r[0].toUpperCase() + r.substring(1),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(color: selected ? AppColors.primary : AppColors.textSecondary),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
