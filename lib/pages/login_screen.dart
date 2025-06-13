import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(() => Form(
          key: authController.formKey,
          autovalidateMode: authController.autovalidateMode.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset('assets/icon/logo.svg'),
              const SizedBox(height: 20),

              CustomInputField(
                label: "Mã số thuế",
                controller: authController.taxCtrl,
                hintText: 'Điền mã số thuế',
                validator: (value) {
                  if (value == null || value.trim().length != 10) {
                    return "Mã số thuế phải có 10 chữ số";
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),

              CustomInputField(
                label: "Tài khoản",
                controller: authController.userCtrl,
                hintText: 'Điền tài khoản',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Tên đăng nhập không được để trống";
                  }
                  return null;
                },
              ),

              CustomInputField(
                label: "Mật khẩu",
                controller: authController.passCtrl,
                hintText: 'Điền mật khẩu',
                isPassword: true,
                validator: (value) {
                  if (value == null ||
                      value.trim().length < 6 ||
                      value.trim().length > 50) {
                    return "Mật khẩu phải từ 6 đến 50 ký tự";
                  }
                  return null;
                },
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authController.isLoading.value
                      ? null
                      : authController.login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: authController.isLoading.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    "Đăng nhập",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authController.showRecentLoginsDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Tài khoản gần đây",
                    style: TextStyle(fontSize: 18, color: Colors.orange),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        SvgPicture.asset(
                          'assets/icon/headphone.svg',
                          width: 18,
                        ),
                        const SizedBox(width: 1),
                        const Text('Trợ giúp'),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        SvgPicture.asset(
                          'assets/icon/social_link.svg',
                          width: 18,
                        ),
                        const SizedBox(width: 2),
                        const Text('Group'),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        SvgPicture.asset('assets/icon/vector.svg', width: 18),
                        const SizedBox(width: 2),
                        const Text('Tra cứu'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        )),
      ),
    );
  }
}

class CustomInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?) validator;
  final bool isPassword;
  final TextInputType keyboardType;

  const CustomInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    required this.validator,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _showSuffix = false;
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    Widget? suffixIcon;
    if (widget.isPassword && _showSuffix) {
      suffixIcon = IconButton(
        icon: _showPassword
            ? SvgPicture.asset('assets/icon/eye_slash.svg')
            : SvgPicture.asset('assets/icon/eye.svg'),
        onPressed: () => setState(() => _showPassword = !_showPassword),
      );
    } else if (_showSuffix) {
      suffixIcon = IconButton(
        icon: SvgPicture.asset('assets/icon/delete.svg'),
        onPressed: () {
          widget.controller.clear();
          setState(() => _showSuffix = false);
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? !_showPassword : false,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: (value) {
            setState(() {
              _showSuffix = value.isNotEmpty;
            });
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orangeAccent),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}