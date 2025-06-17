import 'package:flutter/material.dart';
import 'base_button.dart';
import 'base_ui.dart';

class BaseError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const BaseError({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: BaseUI.errorColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            BaseButton(
              text: 'Thử lại',
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}
