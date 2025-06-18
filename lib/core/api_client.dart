import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'constants.dart';

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
    final response = await _dio.get(
      path,
      queryParameters: queryParameters,
      options: _options,
    );
    return response.data;
  }

  static Future<dynamic> post(
      String path, {
        Map<String, dynamic>? queryParameters,
        Object? data,
      }) async {
    final response = await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _options,
    );
    return response.data;
  }

  static Future<dynamic> put(
      String path, {
        Map<String, dynamic>? queryParameters,
        Object? data,
      }) async {
    final response = await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _options,
    );
    return response.data;
  }

  static Future<dynamic> delete(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) async {
    final response = await _dio.delete(
      path,
      queryParameters: queryParameters,
      options: _options,
    );
    return response.data;
  }
}
