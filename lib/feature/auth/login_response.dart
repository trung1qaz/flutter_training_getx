class LoginResponse {
  final String token;

  LoginResponse({required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    if (json['token'] == null) {
      throw Exception('Token is missing in the response');
    }
    return LoginResponse(token: json['token'] as String);
  }

  Map<String, dynamic> toJson() => {'token': token};
}