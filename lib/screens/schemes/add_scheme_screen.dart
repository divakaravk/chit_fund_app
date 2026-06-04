import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/storage/local_storage.dart';
import '../../providers/scheme_provider.dart';

class AddSchemeScreen extends ConsumerStatefulWidget {
  const AddSchemeScreen({super.key});

  @override
  ConsumerState<AddSchemeScreen> createState() => _AddSchemeScreenState();
}

class _AddSchemeScreenState extends ConsumerState<AddSchemeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  int _duration = 12;
  int _members = 20;
  double _commission = 5.0;
  String _bidType = 'open';
  bool _isLoading = false;

  double get _monthly {
    final amt = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
    return _duration > 0 ? amt / _duration : 0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final companyId = await LocalStorage.getCompanyId() ?? '';
    final chitAmount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
    final data = {
      'company_id': companyId,
      'name': _nameCtrl.text.trim(),
      'code': _codeCtrl.text.trim(),
      'chit_amount': chitAmount,
      'duration_months': _duration,
      'total_members': _members,
      'monthly_contribution': _monthly,
      'foreman_commission_percent': _commission,
      'bid_type': _bidType,
    };
    final ok = await ref.read(schemesProvider.notifier).addScheme(data);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (ok) {
      SnackbarHelper.showSuccess(context, 'Scheme created successfully');
      context.pop();
    } else {
      SnackbarHelper.showError(context, 'Failed to create scheme');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add Chit Scheme', style: AppTextStyles.title),
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
              _Card(children: [
                Text('Scheme Details', style: AppTextStyles.subtitle),
                const SizedBox(height: 16),
                _Field(ctrl: _nameCtrl, label: 'Scheme Name', icon: Icons.description_rounded,
                    validator: (v) => Validators.required(v, label: 'Scheme name')),
                const SizedBox(height: 14),
                _Field(ctrl: _codeCtrl, label: 'Scheme Code', icon: Icons.tag_rounded,
                    caps: TextCapitalization.characters,
                    validator: (v) => Validators.required(v, label: 'Scheme code')),
                const SizedBox(height: 14),
                _Field(
                  ctrl: _amountCtrl,
                  label: 'Chit Amount (₹)',
                  icon: Icons.currency_rupee_rounded,
                  type: TextInputType.number,
                  validator: Validators.amount,
                  prefix: '₹ ',
                  onChange: (_) => setState(() {}),
                ),
              ]),
              const SizedBox(height: 12),
              _Card(children: [
                Text('Duration & Members', style: AppTextStyles.subtitle),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Duration: $_duration months', style: AppTextStyles.body),
                    Text('${_duration} months', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                  ],
                ),
                Slider(
                  value: _duration.toDouble(),
                  min: 6, max: 60,
                  divisions: 54,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _duration = v.round()),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Members: $_members', style: AppTextStyles.body),
                    Text('$_members', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                  ],
                ),
                Slider(
                  value: _members.toDouble(),
                  min: 5, max: 100,
                  divisions: 95,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _members = v.round()),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Commission: ${_commission.toStringAsFixed(1)}%', style: AppTextStyles.body),
                    Text('${_commission.toStringAsFixed(1)}%', style: AppTextStyles.label.copyWith(color: AppColors.accent)),
                  ],
                ),
                Slider(
                  value: _commission,
                  min: 0, max: 10,
                  divisions: 100,
                  activeColor: AppColors.accent,
                  onChanged: (v) => setState(() => _commission = double.parse(v.toStringAsFixed(1))),
                ),
              ]),
              const SizedBox(height: 12),
              _Card(children: [
                Text('Bid Type', style: AppTextStyles.subtitle),
                const SizedBox(height: 12),
                Row(
                  children: ['open', 'sealed', 'lucky_draw'].map((t) {
                    final label = t == 'lucky_draw' ? 'Lucky Draw' : t[0].toUpperCase() + t.substring(1);
                    final selected = _bidType == t;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _bidType = t),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                              border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(label, textAlign: TextAlign.center,
                                style: AppTextStyles.caption.copyWith(
                                    color: selected ? AppColors.primary : AppColors.textSecondary,
                                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ]),
              const SizedBox(height: 12),
              // Preview card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preview', style: AppTextStyles.bodyWhite.copyWith(color: Colors.white70)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Monthly Contribution', style: AppTextStyles.bodyWhite.copyWith(color: Colors.white70)),
                        Text(Formatters.currency(_monthly), style: AppTextStyles.titleWhite),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Payout', style: AppTextStyles.bodyWhite.copyWith(color: Colors.white70)),
                        Text(
                          Formatters.currency(double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0),
                          style: AppTextStyles.bodyWhite,
                        ),
                      ],
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
                      : Text('Create Scheme', style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
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
  final List<Widget> children;
  const _Card({required this.children});

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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType? type;
  final String? Function(String?)? validator;
  final TextCapitalization caps;
  final String? prefix;
  final ValueChanged<String>? onChange;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.type,
    this.validator,
    this.caps = TextCapitalization.sentences,
    this.prefix,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      textCapitalization: caps,
      validator: validator,
      onChanged: onChange,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
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
