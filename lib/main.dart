import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sds_mobile_training_p2/data/user.dart';

import 'feature/auth/auth_binding.dart';
import 'feature/auth/login_screen.dart';
import 'feature/product/home_screen.dart';
import 'feature/product/product_binding.dart'; // Added this line

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter()); // Added this line
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
