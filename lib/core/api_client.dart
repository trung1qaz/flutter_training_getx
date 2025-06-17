import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'constants.dart';
import 'base_response.dart';

class ApiClient {
  static final _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  static String? get _token => Hive.box('authBox').get('authToken');

  static Options get _options => Options(
    headers: {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': _token,
    },
  );

  static Future<dynamic> get(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: _options,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<dynamic> post(
      String path, {
        Map<String, dynamic>? queryParameters,
        Object? data,
      }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _options,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<dynamic> put(
      String path, {
        Map<String, dynamic>? queryParameters,
        Object? data,
      }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _options,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<dynamic> delete(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: _options,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<BaseResponse<T>> getWithParser<T>(
      String path,
      T Function(dynamic) fromJson,
      ) async {
    try {
      final response = await _dio.get(path, options: _options);
      return _handleResponseWithParser(response, fromJson);
    } catch (e) {
      return _handleErrorWithParser(e);
    }
  }

  static Future<BaseResponse<T>> postWithParser<T>(
      String path,
      T Function(dynamic) fromJson, {
        dynamic data,
      }) async {
    try {
      final response = await _dio.post(path, data: data, options: _options);
      return _handleResponseWithParser(response, fromJson);
    } catch (e) {
      return _handleErrorWithParser(e);
    }
  }

  static Future<BaseResponse<T>> putWithParser<T>(
      String path,
      T Function(dynamic) fromJson, {
        dynamic data,
      }) async {
    try {
      final response = await _dio.put(path, data: data, options: _options);
      return _handleResponseWithParser(response, fromJson);
    } catch (e) {
      return _handleErrorWithParser(e);
    }
  }

  static Future<BaseResponse<bool>> deleteWithParser(String path) async {
    try {
      final response = await _dio.delete(path, options: _options);
      return BaseResponse.success(
        response.statusCode == 200 || response.statusCode == 204,
        message: 'Deleted successfully',
      );
    } catch (e) {
      return _handleErrorWithParser(e);
    }
  }

  static dynamic _handleResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } else {
      return {
        'success': false,
        'error': 'HTTP ${response.statusCode}: ${response.statusMessage}',
        'statusCode': response.statusCode,
      };
    }
  }

  static dynamic _handleError(dynamic error) {
    String errorMessage = 'Unknown error occurred';

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'Server error: ${error.response?.statusCode}';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Connection error';
          break;
        default:
          errorMessage = 'Network error: ${error.message}';
      }
    } else {
      errorMessage = 'Unknown error: ${error.toString()}';
    }

    print('API Error: $errorMessage');
    return {
      'success': false,
      'error': errorMessage,
    };
  }

  static BaseResponse<T> _handleResponseWithParser<T>(
      Response response,
      T Function(dynamic) fromJson,
      ) {
    try {
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        if (response.data != null) {
          return BaseResponse.success(fromJson(response.data));
        } else {
          return BaseResponse.error('Empty response data');
        }
      } else {
        return BaseResponse.error('HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } catch (e) {
      print('Response parsing error: $e');
      return BaseResponse.error('Failed to parse response: $e');
    }
  }

  static BaseResponse<T> _handleErrorWithParser<T>(dynamic error) {
    String errorMessage = 'Unknown error occurred';

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'Server error: ${error.response?.statusCode}';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Connection error';
          break;
        default:
          errorMessage = 'Network error: ${error.message}';
      }
    } else {
      errorMessage = 'Unknown error: ${error.toString()}';
    }

    print('API Error: $errorMessage');
    return BaseResponse.error(errorMessage);
  }
}
