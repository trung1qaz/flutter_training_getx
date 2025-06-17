import 'package:flutter/material.dart';
import 'base_ui.dart';

class BaseInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const BaseInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.validator,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  State<BaseInputField> createState() => _BaseInputFieldState();
}

class _BaseInputFieldState extends State<BaseInputField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? !_showPassword : false,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hintText,
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: BaseUI.primaryColor),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: BaseUI.primaryColor, width: 2),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: BaseUI.errorColor),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
              icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            )
                : widget.suffixIcon,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
