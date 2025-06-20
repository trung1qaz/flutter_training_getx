import '../../core/api_client.dart';
import '../../core/api_error_handler.dart';
import '../../core/constants.dart';
import '../../core/ui/base_response.dart';
import 'login_response.dart';

class AuthRepository {
  static Future<BaseResponse<LoginResponse>> login({
    required int taxCode,
    required String userName,
    required String password,
  }) async {
    final response = await ApiClient.post(
      AppConstants.loginEndpoint,
      data: {"tax_code": taxCode, "user_name": userName, "password": password},
    );
    return BaseResponse<LoginResponse>.fromJson(
      ApiErrorHandler.createSuccessResponse(response),
      (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<BaseResponse<LoginResponse>> logout() async {
    final response = await ApiClient.post(
      AppConstants.logoutEndpoint,
      data: {},
    );
    return BaseResponse<LoginResponse>.fromJson(
      ApiErrorHandler.createSuccessResponse(response),
      (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<BaseResponse<LoginResponse>> refreshToken({
    required String token,
  }) async {
    final response = await ApiClient.post(
      AppConstants.refreshTokenEndpoint,
      data: {"token": token},
    );
    return BaseResponse<LoginResponse>.fromJson(
      ApiErrorHandler.createSuccessResponse(response),
      (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
