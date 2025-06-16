import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../core/base_ui.dart';
import 'auth_controller.dart';

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
              BaseInputField(
                label: "Mã số thuế",
                controller: authController.taxCtrl,
                hintText: 'Điền mã số thuế',
                validator: authController.validateTaxCode,
                keyboardType: TextInputType.number,
              ),
              BaseInputField(
                label: "Tài khoản",
                controller: authController.userCtrl,
                hintText: 'Điền tài khoản',
                validator: authController.validateUsername,
              ),
              BaseInputField(
                label: "Mật khẩu",
                controller: authController.passCtrl,
                hintText: 'Điền mật khẩu',
                isPassword: true,
                validator: authController.validatePassword,
              ),
              BaseButton(
                text: "Đăng nhập",
                onPressed: authController.login,
                isLoading: authController.isLoading.value,
              ),
              const Spacer(),
              BaseButton(
                text: "Tài khoản gần đây",
                onPressed: authController.showRecentLoginsDialog,
                backgroundColor: Colors.white,
                textColor: BaseUI.primaryColor,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
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
                      children: [
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
                      children: [
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
