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
    final response = await ApiClient.get(
      AppConstants.productsEndpoint,
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    return BaseResponseList<Product>.fromJson(
      {
        ...response,
        'data': response['data']['data'] ?? [],
      },
          (json) => Product.fromJson(json),
    );
  }

  static Future<Map<String, dynamic>> addProduct({
    required String name,
    required int price,
    required int quantity,
    required String cover,
  }) async {
    final productData = {
      'name': name,
      'price': price,
      'quantity': quantity,
      'cover': cover,
    };

    final response = await ApiClient.post(
      AppConstants.productsEndpoint,
      data: jsonEncode(productData),
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
    final productData = {
      'name': name,
      'price': price,
      'quantity': quantity,
      'cover': cover,
    };

    final response = await ApiClient.put(
      '${AppConstants.productsEndpoint}/$id',
      data: jsonEncode(productData),
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
