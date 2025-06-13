
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sds_mobile_training_p2/data/user.dart';
import 'dart:convert';
import '../controller/product_controller.dart';

class AuthController extends GetxController {

  var isLoading = false.obs;
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
      final userList = box.get('userList', defaultValue: []);

      if (savedToken != null) {
        token.value = savedToken;
        isAuthenticated.value = true;
      }

      recentUsers.value = List<User>.from(userList);

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

      final dio = Dio();
      final url = "https://training-api-unrp.onrender.com/login2";
      final body = jsonEncode({
        "tax_code": int.tryParse(taxCtrl.text),
        "user_name": userCtrl.text.trim(),
        "password": passCtrl.text.trim(),
      });

      final response = await dio.post(url, data: body);
      final data = response.data;

      if (response.statusCode == 200 && data["success"] == true) {
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

        final box = Hive.box('authBox');
        box.put('userList', recentUsers.toList());
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
        Get.snackbar(
          'Lỗi',
          errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = "Lỗi kết nối: ${e.toString()}";
      Get.snackbar(
        'Lỗi kết nối',
        errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
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
    box.put('userList', recentUsers.toList());
  }

  @override
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
}