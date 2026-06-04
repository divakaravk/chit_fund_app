import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class SnackbarHelper {
  SnackbarHelper._();

  static void showSuccess(BuildContext context, String message) {
    Flushbar(
      message: message,
      backgroundColor: AppColors.success,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      messageText: Text(message, style: AppTextStyles.bodyWhite),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  static void showError(BuildContext context, String message) {
    Flushbar(
      message: message,
      backgroundColor: AppColors.error,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      messageText: Text(message, style: AppTextStyles.bodyWhite),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  static void showWarning(BuildContext context, String message) {
    Flushbar(
      message: message,
      backgroundColor: AppColors.warning,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.warning_amber, color: Colors.white),
      messageText: Text(message, style: AppTextStyles.bodyWhite),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  static void showInfo(BuildContext context, String message) {
    Flushbar(
      message: message,
      backgroundColor: AppColors.primaryLight,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.info_outline, color: Colors.white),
      messageText: Text(message, style: AppTextStyles.bodyWhite),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }
}
