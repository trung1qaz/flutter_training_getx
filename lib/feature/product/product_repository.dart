import 'dart:convert';
import '../../core/api_client.dart';
import '../../core/constants.dart';

class ProductRepository {
  static Future<dynamic> getProducts({
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
    return response;
  }

  static Future<dynamic> addProduct({
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

  static Future<dynamic> updateProduct({
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

  static Future<dynamic> deleteProduct(int productId) async {
    final response = await ApiClient.delete(
      '${AppConstants.productsEndpoint}/$productId',
    );
    return response;
  }

  static Future<dynamic> getProductById(int productId) async {
    final response = await ApiClient.get(
      '${AppConstants.productsEndpoint}/$productId',
    );
    return response;
  }
}
