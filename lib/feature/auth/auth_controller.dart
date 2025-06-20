import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sds_mobile_training_p2/data/user.dart';
import '../../core/constants.dart';
import '../../core/ui/base_getx_controller.dart';
import '../product/product_controller.dart';
import 'auth_repository.dart';

class AuthController extends BaseGetxController {
  var isAuthenticated = false.obs;
  var token = Rxn<String>();
  var currentUser = Rxn<User>();
  var recentUsers = <User>[].obs;

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
      final userList = box.get('userList', defaultValue: []);

      if (savedToken != null) {
        token.value = savedToken;
        isAuthenticated.value = true;
      }

      recentUsers.value = List.from(
        userList.map(
          (userData) => User(
            taxCtrl: userData['tax_code'],
            userCtrl: userData['user_name'],
          ),
        ),
      );

      final currentUserData = box.get('currentUser');
      if (currentUserData != null) {
        currentUser.value = User(
          taxCtrl: currentUserData['tax_code'],
          userCtrl: currentUserData['user_name'],
        );
      }
    } catch (e) {
      handleError(e, customMessage: 'Lỗi khởi tạo xác thực');
    }
  }

  Future login() async {
    if (!formKey.currentState!.validate()) {
      autovalidateMode.value = AutovalidateMode.always;
      return;
    }

    try {
      setLoading(true);
      clearError();

      final response = await AuthRepository.login(
        taxCode: int.parse(taxCtrl.text),
        userName: userCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      if (response.success == true && response.data != null) {
        final loginResponse = response.data!;

        if (loginResponse.success == true &&
            loginResponse.token != null &&
            loginResponse.token!.isNotEmpty) {
          token.value = loginResponse.token;
          isAuthenticated.value = true;

          final newUser = User(
            taxCtrl: int.parse(taxCtrl.text),
            userCtrl: userCtrl.text,
          );
          currentUser.value = newUser;

          recentUsers.removeWhere(
            (u) =>
                u.taxCtrl == newUser.taxCtrl && u.userCtrl == newUser.userCtrl,
          );
          recentUsers.add(newUser);

          final box = Hive.box('authBox');
          box.put(
            'userList',
            recentUsers
                .map(
                  (user) => {
                    'tax_code': user.taxCtrl,
                    'user_name': user.userCtrl,
                  },
                )
                .toList(),
          );
          box.put('authToken', token.value);
          box.put('currentUser', {
            'tax_code': int.parse(taxCtrl.text),
            'user_name': userCtrl.text,
          });

          handleSuccess(loginResponse.message ?? 'Đăng nhập thành công');
          Get.offAllNamed('/home');
        } else {
          handleError(
            loginResponse.message ??
                'Đăng nhập thất bại, sai tên đăng nhập hoặc mật khẩu',
          );
        }
      } else {
        handleError(response.error ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      handleError(e, customMessage: 'Lỗi kết nối: ${e.toString()}');
    } finally {
      setLoading(false);
    }
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
          child: Obx(
            () => ListView.builder(
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
            ),
          ),
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
    box.put(
      'userList',
      recentUsers
          .map((user) => {'tax_code': user.taxCtrl, 'user_name': user.userCtrl})
          .toList(),
    );
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
    clearError();
  }

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
