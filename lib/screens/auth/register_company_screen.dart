import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/router/app_router.dart';
import '../../services/auth_service.dart';

class RegisterCompanyScreen extends ConsumerStatefulWidget {
  const RegisterCompanyScreen({super.key});

  @override
  ConsumerState<RegisterCompanyScreen> createState() => _RegisterCompanyScreenState();
}

class _RegisterCompanyScreenState extends ConsumerState<RegisterCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _ownerCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  int _step = 0;
  bool _isLoading = false;
  bool _success = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _ownerCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _step = 1);
  }

  Future<void> _register() async {
    setState(() => _isLoading = true);
    final service = AuthService();
    final result = await service.registerCompany(
      name: _nameCtrl.text.trim(),
      code: _codeCtrl.text.trim(),
      ownerName: _ownerCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (result.success) {
      setState(() => _success = true);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      context.go(AppRoutes.login);
    } else {
      SnackbarHelper.showError(context, result.message ?? 'Registration failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: _step == 1
              ? () => setState(() => _step = 0)
              : () => context.go(AppRoutes.login),
        ),
        title: Text('Register Company', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: _success ? _buildSuccess() : _buildForm(),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 60),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text('Company Registered!', style: AppTextStyles.heading).animate(delay: 300.ms).fadeIn(),
          const SizedBox(height: 8),
          Text('Redirecting to login...', style: AppTextStyles.bodySecondary).animate(delay: 500.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator
          Row(
            children: [
              _StepDot(step: 1, current: _step + 1, label: 'Company Info'),
              Expanded(child: Container(height: 2, color: _step >= 1 ? AppColors.primary : AppColors.divider)),
              _StepDot(step: 2, current: _step + 1, label: 'Confirm'),
            ],
          ),
          const SizedBox(height: 32),
          if (_step == 0) _buildStep1() else _buildStep2(),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _TextField(ctrl: _nameCtrl, label: 'Company Name', icon: Icons.business_rounded,
              validator: (v) => Validators.required(v, label: 'Company name')),
          const SizedBox(height: 16),
          _TextField(ctrl: _codeCtrl, label: 'Company Code (Unique)', icon: Icons.tag_rounded,
              hint: 'e.g. CHITCO2024',
              validator: (v) => Validators.required(v, label: 'Company code'),
              caps: TextCapitalization.characters),
          const SizedBox(height: 16),
          _TextField(ctrl: _ownerCtrl, label: 'Owner Name', icon: Icons.person_rounded,
              validator: (v) => Validators.required(v, label: 'Owner name')),
          const SizedBox(height: 16),
          _TextField(ctrl: _emailCtrl, label: 'Email', icon: Icons.email_rounded,
              type: TextInputType.emailAddress, validator: Validators.email),
          const SizedBox(height: 16),
          _TextField(ctrl: _phoneCtrl, label: 'Phone Number', icon: Icons.phone_rounded,
              type: TextInputType.phone, validator: Validators.phone),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: Text('Next', style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ).animate().fadeIn().slideY(begin: 0.1),
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review your information', style: AppTextStyles.title),
        const SizedBox(height: 20),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _InfoRow('Company Name', _nameCtrl.text),
                _InfoRow('Company Code', _codeCtrl.text),
                _InfoRow('Owner Name', _ownerCtrl.text),
                _InfoRow('Email', _emailCtrl.text),
                _InfoRow('Phone', _phoneCtrl.text),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: _isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Text('Confirm & Register', style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}

class _StepDot extends StatelessWidget {
  final int step, current;
  final String label;
  const _StepDot({required this.step, required this.current, required this.label});

  @override
  Widget build(BuildContext context) {
    final done = current >= step;
    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: done ? AppColors.primary : AppColors.divider,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text('$step', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.label)),
          Expanded(child: Text(value, style: AppTextStyles.body, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType? type;
  final String? Function(String?)? validator;
  final TextCapitalization caps;

  const _TextField({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.hint,
    this.type,
    this.validator,
    this.caps = TextCapitalization.words,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      textCapitalization: caps,
      validator: validator,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
        prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
      ),
    );
  }
}
