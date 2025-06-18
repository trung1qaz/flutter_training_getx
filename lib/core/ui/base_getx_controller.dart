import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'base_ui.dart';

abstract class BaseGetxController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  void handleError(dynamic error, {String? customMessage}) {
    String message = customMessage ?? _parseErrorMessage(error);
    errorMessage.value = message;
    _showErrorSnackbar(message);
  }

  void handleSuccess(String message) {
    _showSuccessSnackbar(message);
  }

  String _parseErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    } else if (error is Map && error.containsKey('error')) {
      return error['error'].toString();
    } else if (error is Map && error.containsKey('message')) {
      return error['message'].toString();
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    } else {
      return 'Đã xảy ra lỗi không xác định';
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Lỗi',
      message,
      backgroundColor: BaseUI.errorColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Thành công',
      message,
      backgroundColor: BaseUI.successColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void setLoading(bool loading) {
    isLoading.value = loading;
  }

  void clearError() {
    errorMessage.value = '';
  }
}
