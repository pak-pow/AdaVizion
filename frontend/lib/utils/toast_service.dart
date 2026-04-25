import 'package:flutter/material.dart';

class ToastService {
  static void _showToast(
      BuildContext context, String message, Color bgColor, IconData icon) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: bgColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
  }

  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, Colors.green.shade700, Icons.check_circle);
  }

  static void showError(BuildContext context, String message) {
    _showToast(context, message, const Color(0xFF7A1D1D), Icons.error);
  }

  static void showInfo(BuildContext context, String message) {
    _showToast(context, message, Colors.grey.shade800, Icons.info);
  }
}
