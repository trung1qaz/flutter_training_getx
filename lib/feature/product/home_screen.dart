import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/product_image.dart';
import '../../core/base_ui.dart';
import 'product_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.put(ProductController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý sản phẩm"),
        backgroundColor: BaseUI.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: () {
              print('Refresh button pressed'); // Debug log
              controller.refreshData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: controller.logout,
          ),
        ],
      ),
      body: Obx(() {
        print('Building home screen - Loading: ${controller.isLoading.value}, Products: ${controller.products.length}'); // Debug log

        if (controller.isLoading.value) {
          return const BaseLoading(message: 'Đang tải dữ liệu...');
        }

        if (controller.errorMessage.isNotEmpty) {
          print('Error message: ${controller.errorMessage.value}'); // Debug log
          return BaseError(
            message: controller.errorMessage.value,
            onRetry: () {
              print('Retry button pressed'); // Debug log
              controller.fetchData();
            },
          );
        }

        if (controller.products.isEmpty) {
          print('No products found'); // Debug log
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text("Chưa có sản phẩm nào."),
                const SizedBox(height: 16),
                BaseButton(
                  text: 'Thêm sản phẩm đầu tiên',
                  onPressed: controller.showAddProductDialog,
                ),
              ],
            ),
          );
        }

        print('Displaying ${controller.products.length} products'); // Debug log
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              try {
                final product = controller.products[index];
                print('Building product at index $index: ${product.name}'); // Debug log

                return BaseCard(
                  onTap: () => controller.navigateToProductDetail(product),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
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
                  ),
                );
              } catch (e) {
                print('Error building product at index $index: $e'); // Debug log
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading product: $e'),
                );
              }
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.showAddProductDialog,
        backgroundColor: BaseUI.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
