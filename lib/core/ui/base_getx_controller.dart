import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../api_error_handler.dart';

abstract class BaseGetxController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  void handleError(dynamic error, {String? customMessage}) {
    String message = customMessage ?? ApiErrorHandler.parseErrorMessage(error);
    errorMessage.value = message;
    ApiErrorHandler.showErrorSnackbar(message);
  }

  void handleSuccess(String message) {
    ApiErrorHandler.showSuccessSnackbar(message);
  }

  void setLoading(bool loading) {
    isLoading.value = loading;
  }

  void clearError() {
    errorMessage.value = '';
  }
}
