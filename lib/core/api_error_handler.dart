import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ui/base_ui.dart';

class ApiErrorHandler {
  static String parseErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    } else if (error is Map && error.containsKey('error')) {
      return error['error'].toString();
    } else if (error is Map && error.containsKey('message')) {
      return error['message'].toString();
    } else if (error is DioException) {
      return _handleDioException(error);
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    } else {
      return 'Đã xảy ra lỗi không xác định';
    }
  }

  static String _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout';
      case DioExceptionType.badResponse:
        return 'Server error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error';
      default:
        return 'Network error: ${error.message}';
    }
  }

  static void showErrorSnackbar(String message) {
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

  static void showSuccessSnackbar(String message) {
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

  static Map<String, dynamic> createErrorResponse(dynamic error) {
    return {
      'success': false,
      'error': parseErrorMessage(error),
    };
  }

  static Map<String, dynamic> createSuccessResponse(dynamic data) {
    return {
      'success': true,
      'data': data,
    };
  }
}
