import 'package:dio/dio.dart';
import '../chucker/manager/chucker_manager.dart';
import '../chucker/interceptors/chucker_dio_interceptor.dart';
import '../chucker/models/encryption_config.dart';
import '../model/user.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../service/encryption_service.dart'; // เพิ่ม import

class ApiService {
  late Dio _dio;
  late EncryptionService _encryptionService; // เพิ่มตัวแปร
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String usersPath = '/users';

  ApiService() {
    _dio = Dio();

    // 1. สร้าง key ที่มีความยาว 256 bits
    const secret = 'your-secret-key';
    final keyBytes = sha256.convert(utf8.encode(secret)).bytes;
    final key = base64.encode(keyBytes);

    // 2. สร้าง encryption service
    _encryptionService = EncryptionService(
      algorithm: 'AES-256',
      key: key,
    );

    // 3. กำหนดค่าการเข้ารหัส
    final encryptionConfig = EncryptionConfig(
      algorithm: 'AES-256',
      key: key,
      enabled: true,
    );

    // 4. เริ่มต้นใช้งาน ChuckerManager
    ChuckerManager().initialize(config: encryptionConfig);

    // 5. เพิ่ม interceptor สำหรับ print ข้อมูล
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.data != null) {
          print('\n🔒 Original Request Data:');
          print(options.data);

          final encrypted =
              _encryptionService.encrypt(json.encode(options.data));
          print('\n🔐 Encrypted Request Data:');
          print(encrypted);
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('\n🔒 Original Response Data:');
        print(response.data);

        if (response.data != null) {
          final encrypted =
              _encryptionService.encrypt(json.encode(response.data));
          print('\n🔐 Encrypted Response Data:');
          print(encrypted);

          final decrypted = _encryptionService.decrypt(encrypted);
          print('\n🔓 Decrypted Response Data:');
          print(decrypted);
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (error.response?.data != null) {
          print('\n❌ Original Error Data:');
          print(error.response?.data);

          final encrypted =
              _encryptionService.encrypt(json.encode(error.response?.data));
          print('\n🔐 Encrypted Error Data:');
          print(encrypted);

          final decrypted = _encryptionService.decrypt(encrypted);
          print('\n🔓 Decrypted Error Data:');
          print(decrypted);
        }
        handler.next(error);
      },
    ));

    // 6. เพิ่ม log interceptor
    _dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (object) {
          print('🌐 Network Log: $object');
        }));

    // 7. ใช้ Custom Chucker Interceptor
    _dio.interceptors.add(ChuckerDioInterceptor());
  }

  Future<List<User>> getUsers() async {
    try {
      const String fullPath = baseUrl + usersPath;
      final response = await _dio.get(fullPath);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => User.fromJson(json, path: fullPath)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }
}
