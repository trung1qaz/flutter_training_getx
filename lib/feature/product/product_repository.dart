import 'dart:convert';
import '../../core/api_client.dart';
import '../../core/constants.dart';

class ProductRepository {
  static Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int size = 10,
  }) async {
    try {
      final response = await ApiClient.get(
        AppConstants.productsEndpoint,
        queryParameters: {'page': page, 'size': size},
      );
      return response;
    } catch (e) {
      print('Repository Error: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': null,
      };
    }
  }

  static Future<Map<String, dynamic>> addProduct({
    required String name,
    required int price,
    required int quantity,
    required String cover,
  }) async {
    final response = await ApiClient.post(
      AppConstants.productsEndpoint,
      data: jsonEncode({
        'name': name,
        'price': price,
        'quantity': quantity,
        'cover': cover,
      }),
    );
    return response;
  }

  static Future<Map<String, dynamic>> updateProduct({
    required int id,
    required String name,
    required int price,
    required int quantity,
    required String cover,
  }) async {
    final response = await ApiClient.put(
      '${AppConstants.productsEndpoint}/$id',
      data: jsonEncode({
        'name': name,
        'price': price,
        'quantity': quantity,
        'cover': cover,
      }),
    );
    return response;
  }

  static Future<Map<String, dynamic>> deleteProduct(int productId) async {
    final response = await ApiClient.delete(
      '${AppConstants.productsEndpoint}/$productId',
    );
    return response;
  }

  static Future<Map<String, dynamic>> getProductById(int productId) async {
    final response = await ApiClient.get(
      '${AppConstants.productsEndpoint}/$productId',
    );
    return response;
  }
}
