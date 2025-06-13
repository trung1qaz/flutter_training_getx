import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/product_api.dart';
import '../controller/auth_controller.dart';
import '../pages/product_detail_screen.dart';


class Product {
  final int id;
  final String name;
  final int price;
  final int quantity;
  final String cover;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.cover,
  });
}

class ProductController extends GetxController {
  // Observable variables
  var products = <Product>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var nextId = 21.obs;

  // Form controllers for add product dialog
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final quantityCtrl = TextEditingController();
  final coverCtrl = TextEditingController();
  var isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    quantityCtrl.dispose();
    coverCtrl.dispose();
    super.onClose();
  }

  // Fetch products from API
  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final apiProducts = await fetchProductsFromApi();
      products.value = apiProducts;
    } catch (e) {
      errorMessage.value = e.toString();

      if (e.toString().contains('Unauthorized')) {
        handleUnauthorized();
      } else {
        Get.snackbar(
          'Lỗi',
          'Lỗi tải dữ liệu: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          mainButton: TextButton(
            onPressed: fetchData,
            child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
          ),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Handle unauthorized access
  void handleUnauthorized() {
    Get.dialog(
      AlertDialog(
        title: const Text('Phiên đăng nhập hết hạn'),
        content: const Text('Vui lòng đăng nhập lại'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              logout();
            },
            child: const Text('Đăng nhập lại'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Show add product dialog
  void showAddProductDialog() {
    // Clear form
    nameCtrl.clear();
    priceCtrl.clear();
    quantityCtrl.clear();
    coverCtrl.clear();
    isSubmitting.value = false;

    Get.dialog(
      AlertDialog(
        title: const Text('Thêm sản phẩm'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Bắt buộc' : null,
                ),
                TextFormField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Giá (vnđ)'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value == null || int.tryParse(value) == null
                      ? 'Phải là số'
                      : null,
                ),
                TextFormField(
                  controller: quantityCtrl,
                  decoration: const InputDecoration(labelText: 'Số lượng'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value == null || int.tryParse(value) == null
                      ? 'Phải là số'
                      : null,
                ),
                TextFormField(
                  controller: coverCtrl,
                  decoration: const InputDecoration(labelText: 'URL hình ảnh'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Bắt buộc' : null,
                ),
                Obx(() => isSubmitting.value
                    ? const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
        actions: [
          Obx(() => TextButton(
            onPressed: isSubmitting.value ? null : () => Get.back(),
            child: const Text('Hủy'),
          )),
          Obx(() => ElevatedButton(
            onPressed: isSubmitting.value ? null : addProduct,
            child: const Text('Thêm'),
          )),
        ],
      ),
    );
  }

  // Add product
  Future<void> addProduct() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSubmitting.value = true;

      final newProduct = Product(
        id: nextId.value++,
        name: nameCtrl.text.trim(),
        price: int.parse(priceCtrl.text),
        quantity: int.parse(quantityCtrl.text),
        cover: coverCtrl.text.trim(),
      );

      final addedProduct = await addProductToApi(newProduct);
      products.add(addedProduct);

      Get.back();
      Get.snackbar(
        'Thành công',
        'Thêm sản phẩm thành công',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      if (e.toString().contains('Unauthorized')) {
        Get.back();
        handleUnauthorized();
      } else {
        Get.snackbar(
          'Lỗi',
          'Lỗi thêm sản phẩm: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  // Remove product
  Future<void> removeProduct(int index) async {
    final product = products[index];

    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa sản phẩm "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await deleteProductFromApi(product.id);
        products.removeAt(index);

        Get.snackbar(
          'Thành công',
          'Xóa sản phẩm thành công',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        if (e.toString().contains('Unauthorized')) {
          handleUnauthorized();
        } else {
          Get.snackbar(
            'Lỗi',
            'Lỗi xóa sản phẩm: $e',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    }
  }

  // Logout
  void logout() {
    final box = Hive.box('authBox');
    box.delete('authToken');
    box.delete('currentUser');

    // Clear auth controller if it exists
    if (Get.isRegistered<AuthController>()) {
      Get.find<AuthController>().logout();
    }

    Get.offAllNamed('/login');
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchData();
  }

  // Navigate to product detail
  void navigateToProductDetail(Product product) {
    Get.to(() => ProductDetailScreen(product: product));
  }
}