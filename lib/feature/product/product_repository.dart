import 'dart:convert';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../core/ui/base_response_list.dart';
import 'product.dart';

class ProductRepository {
  static Future<BaseResponseList<Product>> getProducts({
    int page = 1,
    int size = 10,
  }) async {
    try {
      final response = await ApiClient.get(
        AppConstants.productsEndpoint,
        queryParameters: {'page': page, 'size': size},
      );

      print('Raw API Response: $response');

      if (response['success'] == true && response['data'] != null) {
        dynamic data = response['data'];
        final dataList = (data is Map && data.containsKey('data'))
            ? data['data']
            : (data is List ? data : []);
        print('Product data list: $dataList');

        return BaseResponseList.fromJson({
          'success': true,
          'message': 'Products loaded successfully',
          'data': dataList,
        }, (json) => Product.fromJson(json));
      } else {
        return BaseResponseList<Product>(
          success: false,
          message: response['error'] ?? 'Failed to load products',
          data: [],
          error: response['error'],
        );
      }
    } catch (e) {
      print('Repository Error: $e');
      return BaseResponseList<Product>(
        success: false,
        message: 'Error loading products: $e',
        data: [],
        error: e.toString(),
      );
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
