import 'package:flutter/material.dart';

abstract class BaseUI {
  static const primaryColor = Colors.orange;
  static const errorColor = Colors.red;
  static const successColor = Colors.green;
  static const backgroundColor = Colors.white;

  static const titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const subtitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static const bodyStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );
}
