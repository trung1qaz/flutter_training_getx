import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sds_mobile_training_p2/pages/home_screen.dart';
import 'package:sds_mobile_training_p2/pages/login_screen.dart';
import '../controller/product_binding.dart';
import '../controller/auth_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('authBox');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter GetX Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => LoginScreen(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/home',
          page: () => HomeScreen(),
          binding: ProductBinding(),
        ),
      ],
    );
  }
}