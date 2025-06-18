import '../../core/api_client.dart';
import '../../core/constants.dart';

class AuthRepository {
  static Future<Map<String, dynamic>> login({
    required int taxCode,
    required String userName,
    required String password,
  }) async {
    final response = await ApiClient.post(
      AppConstants.loginEndpoint,
      data: {
        "tax_code": taxCode,
        "user_name": userName,
        "password": password,
      },
    );

    return response;
  }

  static Future<Map<String, dynamic>> logout() async {
    final response = await ApiClient.post(
      AppConstants.logoutEndpoint,
      data: {},
    );

    return response;
  }

  static Future<Map<String, dynamic>> refreshToken({
    required String token,
  }) async {
    final response = await ApiClient.post(
      AppConstants.refreshTokenEndpoint,
      data: {
        "token": token,
      },
    );

    return response;
  }
}
