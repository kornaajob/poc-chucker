// lib/chucker/helper/chucker_ui_helper.dart
import 'package:flutter/material.dart';
import '../view/chucker_screen.dart'; // เพิ่ม import

class ChuckerUiHelper {
  static void showNotification({
    required String method,
    required int statusCode,
    required String path,
    required DateTime requestTime,
  }) {
    debugPrint('🔍 API Call: $method $path');
    debugPrint('📊 Status: $statusCode');
    debugPrint('⏰ Time: $requestTime');
  }

  static void showChuckerScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChuckerScreen(), // เรียกใช้ widget class
      ),
    );
  }
}
