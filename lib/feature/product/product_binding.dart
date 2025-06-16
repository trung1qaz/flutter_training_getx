import 'package:get/get.dart';
import 'package:sds_mobile_training_p2/feature/product/product_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProductController());
  }
}
