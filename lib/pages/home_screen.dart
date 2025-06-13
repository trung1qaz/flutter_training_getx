import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/product_image.dart';
import 'product_detail_screen.dart';
import '../controller/product_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.put(ProductController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý sản phẩm"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: controller.refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: controller.logout,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Có lỗi xảy ra',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchData,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (controller.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text("Chưa có sản phẩm nào."),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.showAddProductDialog,
                  child: const Text('Thêm sản phẩm đầu tiên'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              final product = controller.products[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ProductImage(imageUrl: product.cover),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.deepOrange,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Giá: ${product.price} đ\nSố lượng: ${product.quantity}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => controller.removeProduct(index),
                  ),
                  onTap: () => controller.navigateToProductDetail(product),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.showAddProductDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
