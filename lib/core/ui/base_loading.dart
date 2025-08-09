import 'package:flutter/material.dart';
import 'base_ui.dart';

class BaseLoading extends StatelessWidget {
  final String? message;

  const BaseLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(BaseUI.primaryColor),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: BaseUI.bodyStyle),
          ],
        ],
      ),
    );
  }
}
