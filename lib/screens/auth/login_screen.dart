import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _companyCodeCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _role = 'admin';
  late AnimationController _shakeController;

  static const _roles = ['admin', 'foreman', 'member'];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _companyCodeCtrl.dispose();
    _phoneCtrl.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _shake() {
    _shakeController.forward(from: 0);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _shake();
      return;
    }
    final success = await ref.read(authProvider.notifier).login(
          companyCode: _companyCodeCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          role: _role,
        );
    if (!mounted) return;
    if (success) {
      context.go(AppRoutes.dashboard);
    } else {
      _shake();
      final error = ref.read(authProvider).error ?? 'Login failed';
      SnackbarHelper.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          // Top gradient background
          Container(
            height: size.height * 0.45,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Bottom white background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.6,
            child: Container(color: AppColors.background),
          ),
          // Curved white overlay
          Positioned(
            top: size.height * 0.32,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Logo + welcome
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'asssets/images/chitfundlogo.png',
                          fit: BoxFit.contain,
                        ),
                      )
                          .animate()
                          .scale(duration: 500.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.welcomeBack,
                        style: AppTextStyles.headingWhite,
                      ).animate(delay: 200.ms).fadeIn().slideY(begin: -0.2),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.loginToContinue,
                        style: AppTextStyles.bodyWhite.copyWith(
                          color: Colors.white70,
                        ),
                      ).animate(delay: 300.ms).fadeIn(),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Form card with shake
                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      final shake = (_shakeController.value < 0.5
                              ? _shakeController.value
                              : 1 - _shakeController.value) *
                          16;
                      return Transform.translate(
                        offset: Offset(shake * _shakeOffset(), 0),
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xxl),
                      child: Card(
                        elevation: 12,
                        shadowColor: AppColors.primary.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.xxl),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Login to ChitFlow', style: AppTextStyles.title),
                                const SizedBox(height: 24),
                                _AppTextField(
                                  controller: _companyCodeCtrl,
                                  label: AppStrings.companyCode,
                                  hint: 'Enter company code',
                                  prefixIcon: Icons.business_rounded,
                                  validator: (v) => Validators.required(v, label: 'Company code'),
                                  textCapitalization: TextCapitalization.characters,
                                ),
                                const SizedBox(height: 16),
                                _AppTextField(
                                  controller: _phoneCtrl,
                                  label: AppStrings.phoneNumber,
                                  hint: '10-digit mobile number',
                                  prefixIcon: Icons.phone_rounded,
                                  keyboardType: TextInputType.phone,
                                  validator: Validators.phone,
                                ),
                                const SizedBox(height: 16),
                                Text('Role', style: AppTextStyles.label),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.divider),
                                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _role,
                                      isExpanded: true,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                      items: _roles.map((r) {
                                        IconData icon;
                                        switch (r) {
                                          case 'admin':
                                            icon = Icons.admin_panel_settings_rounded;
                                          case 'foreman':
                                            icon = Icons.manage_accounts_rounded;
                                          default:
                                            icon = Icons.person_rounded;
                                        }
                                        return DropdownMenuItem(
                                          value: r,
                                          child: Row(
                                            children: [
                                              Icon(icon, size: 18, color: AppColors.primary),
                                              const SizedBox(width: 8),
                                              Text(
                                                r[0].toUpperCase() + r.substring(1),
                                                style: AppTextStyles.body,
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (v) => setState(() => _role = v!),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(AppSizes.radiusPill),
                                        ),
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : Text(
                                              AppStrings.login,
                                              style: AppTextStyles.subtitle.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ).animate(delay: 400.ms).slideY(begin: 0.3, duration: 500.ms).fadeIn(),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.register),
                    child: Text(
                      AppStrings.newCompany,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primaryLight,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _shakeOffset() {
    final v = _shakeController.value;
    return (v < 0.25 ? v : v < 0.5 ? 0.5 - v : v < 0.75 ? v - 0.5 : 1 - v) * 2 - 0.5;
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;

  const _AppTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
            prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
