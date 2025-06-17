import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sds_mobile_training_p2/data/user.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../product/product_controller.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  var isAuthenticated = false.obs;
  var token = Rxn<String>();
  var currentUser = Rxn<User>();
  var recentUsers = <User>[].obs;
  var errorMessage = ''.obs;

  final taxCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var autovalidateMode = AutovalidateMode.disabled.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  @override
  void onClose() {
    taxCtrl.dispose();
    userCtrl.dispose();
    passCtrl.dispose();
    super.onClose();
  }

  void _initializeAuth() {
    try {
      final box = Hive.box('authBox');
      final savedToken = box.get('authToken');
      final userList = box.get('userList', defaultValue: <Map>[]);

      if (savedToken != null) {
        token.value = savedToken;
        isAuthenticated.value = true;
      }

      recentUsers.value = List<User>.from(
        userList.map((userData) => User(
          taxCtrl: userData['tax_code'],
          userCtrl: userData['user_name'],
        )),
      );

      final currentUserData = box.get('currentUser');
      if (currentUserData != null) {
        currentUser.value = User(
          taxCtrl: currentUserData['tax_code'],
          userCtrl: currentUserData['user_name'],
        );
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      autovalidateMode.value = AutovalidateMode.always;
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Use the new ApiClient method that returns raw dynamic data
      final response = await ApiClient.post(
        AppConstants.loginEndpoint,
        data: {
          "tax_code": int.tryParse(taxCtrl.text),
          "user_name": userCtrl.text.trim(),
          "password": passCtrl.text.trim(),
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        if (data["success"] == true) {
          token.value = data["data"]["token"];
          isAuthenticated.value = true;

          final newUser = User(
            taxCtrl: int.parse(taxCtrl.text),
            userCtrl: userCtrl.text,
          );
          currentUser.value = newUser;

          recentUsers.removeWhere((u) =>
          u.taxCtrl == newUser.taxCtrl && u.userCtrl == newUser.userCtrl);
          recentUsers.add(newUser);

          // Save to Hive
          final box = Hive.box('authBox');
          box.put('userList', recentUsers.map((user) => {
            'tax_code': user.taxCtrl,
            'user_name': user.userCtrl,
          }).toList());
          box.put('authToken', token.value);
          box.put('currentUser', {
            'tax_code': int.parse(taxCtrl.text),
            'user_name': userCtrl.text,
          });

          Get.offAllNamed('/home');
          Get.snackbar(
            'Thành công',
            'Đăng nhập thành công',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          errorMessage.value = "Đăng nhập thất bại, sai tên đăng nhập hoặc mật khẩu";
          _showErrorSnackbar(errorMessage.value);
        }
      } else {
        errorMessage.value = response['error'] ?? "Đăng nhập thất bại";
        _showErrorSnackbar(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = "Lỗi kết nối: ${e.toString()}";
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Lỗi',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void showRecentLoginsDialog() {
    if (recentUsers.isEmpty) {
      Get.snackbar(
        'Thông báo',
        'Không có tài khoản nào trước đó',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Chọn tài khoản'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() => ListView.builder(
            shrinkWrap: true,
            itemCount: recentUsers.length,
            itemBuilder: (context, index) {
              final user = recentUsers[index];
              return ListTile(
                title: Text(user.userCtrl),
                subtitle: Text(user.taxCtrl.toString()),
                trailing: IconButton(
                  icon: const Icon(Icons.backspace_outlined),
                  onPressed: () => removeRecentUser(index),
                ),
                onTap: () => selectRecentUser(user),
              );
            },
          )),
        ),
      ),
    );
  }

  void selectRecentUser(User user) {
    taxCtrl.text = user.taxCtrl.toString();
    userCtrl.text = user.userCtrl;
    Get.back();
  }

  void removeRecentUser(int index) {
    recentUsers.removeAt(index);
    final box = Hive.box('authBox');
    box.put('userList', recentUsers.map((user) => {
      'tax_code': user.taxCtrl,
      'user_name': user.userCtrl,
    }).toList());
  }

  void logout() {
    token.value = null;
    currentUser.value = null;
    isAuthenticated.value = false;
    final box = Hive.box('authBox');
    box.delete('authToken');
    box.delete('currentUser');
    if (Get.isRegistered<ProductController>()) {
      Get.delete<ProductController>();
    }

    Get.offAllNamed('/login');
  }

  void clearForm() {
    taxCtrl.clear();
    userCtrl.clear();
    passCtrl.clear();
    autovalidateMode.value = AutovalidateMode.disabled;
    errorMessage.value = '';
  }

  // Validation methods using constants
  String? validateTaxCode(String? value) {
    if (value == null || value.trim().length != AppConstants.taxCodeLength) {
      return "Mã số thuế phải có ${AppConstants.taxCodeLength} chữ số";
    }
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Tên đăng nhập không được để trống";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null ||
        value.trim().length < AppConstants.minPasswordLength ||
        value.trim().length > AppConstants.maxPasswordLength) {
      return "Mật khẩu phải từ ${AppConstants.minPasswordLength} đến ${AppConstants.maxPasswordLength} ký tự";
    }
    return null;
  }
}
