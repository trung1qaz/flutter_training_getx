class LoginResponse {
  final String? token;
  final bool? success;
  final String? message;

  LoginResponse({required this.token, this.success, this.message});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return LoginResponse(
      token: data?['token'] as String?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'success': success,
    'message': message,
  };
}
