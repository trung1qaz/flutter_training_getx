class BaseResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;

  BaseResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory BaseResponse.success(T data, {String message = 'Success'}) {
    return BaseResponse(success: true, message: message, data: data);
  }

  factory BaseResponse.error(String error, {String message = 'Error'}) {
    return BaseResponse(success: false, message: message, error: error);
  }

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return BaseResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'],
    );
  }
}

class BaseResponseList<T> extends BaseResponse {
  final List<T> data;

  BaseResponseList({
    required bool success,
    required String message,
    required this.data,
    String? error,
  }) : super(success: success, message: message, error: error);

  factory BaseResponseList.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    List<T> dataList = [];

    if (json['data'] != null && json['data'] is List) {
      dataList = (json['data'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList();
    }

    return BaseResponseList<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: dataList,
      error: json['error'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => (item as dynamic).toJson()).toList(),
      if (error != null) 'error': error,
    };
  }
}
