import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sds_mobile_training_p2/feature/product/product_detail_screen.dart';
import 'package:sds_mobile_training_p2/feature/product/product_repository.dart';
import '../../core/ui/base_ui.dart';
import '../auth/auth_controller.dart';
import 'product.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var nextId = 21.obs;

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final quantityCtrl = TextEditingController();
  final coverCtrl = TextEditingController();
  var isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('ProductController initialized');
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

  Future<void> fetchData() async {
    try {
      print('Starting fetchData...');
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ProductRepository.getProducts(page: 1, size: 10);
      print('Repository response: success=${response.success}, data length=${response.data.length}');

      if (response.success) {
        products.value = response.data;
        products.refresh(); // Force UI update
        print('Products loaded: ${products.length} items');
      } else {
        errorMessage.value = response.error ?? 'Failed to load products';
        print('Error loading products: ${errorMessage.value}');
        _showErrorSnackbar(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Error loading products: ${e.toString()}';
      print('Fetch data error: $e');
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
      print('fetchData completed. Loading: ${isLoading.value}, Products: ${products.length}');
    }
  }

  Future<void> addProduct() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSubmitting.value = true;
      final response = await ProductRepository.addProduct(
        name: nameCtrl.text.trim(),
        price: int.parse(priceCtrl.text),
        quantity: int.parse(quantityCtrl.text),
        cover: coverCtrl.text.trim(),
      );

      if (response['success'] == true && response['data'] != null) {
        final productData = response['data'];
        final newProduct = Product(
          id: productData['id'] ?? nextId.value++,
          name: productData['name'] ?? nameCtrl.text.trim(),
          price: productData['price'] ?? int.parse(priceCtrl.text),
          quantity: productData['quantity'] ?? int.parse(quantityCtrl.text),
          cover: productData['cover'] ?? coverCtrl.text.trim(),
        );

        products.add(newProduct);
        products.refresh();
        Get.back();
        _showSuccessSnackbar('Thêm sản phẩm thành công');
      } else {
        _showErrorSnackbar(response['error'] ?? 'Failed to add product');
      }
    } catch (e) {
      _showErrorSnackbar('Lỗi thêm sản phẩm: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

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
        final response = await ProductRepository.deleteProduct(product.id);
        if (response['success'] == true) {
          products.removeAt(index);
          products.refresh();
          _showSuccessSnackbar('Xóa sản phẩm thành công');
        } else {
          _showErrorSnackbar(response['error'] ?? 'Failed to delete product');
        }
      } catch (e) {
        _showErrorSnackbar('Lỗi xóa sản phẩm: $e');
      }
    }
  }

  void showAddProductDialog() {
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

  void logout() {
    final box = Hive.box('authBox');
    box.delete('authToken');
    box.delete('currentUser');
    if (Get.isRegistered<AuthController>()) {
      Get.find<AuthController>().logout();
    }
    Get.offAllNamed('/login');
  }

  Future<void> refreshData() async {
    await fetchData();
  }

  void navigateToProductDetail(Product product) {
    Get.to(() => ProductDetailScreen(product: product));
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Lỗi',
      message,
      backgroundColor: BaseUI.errorColor,
      colorText: Colors.white,
      mainButton: TextButton(
        onPressed: fetchData,
        child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Thành công',
      message,
      backgroundColor: BaseUI.successColor,
      colorText: Colors.white,
    );
  }
}
