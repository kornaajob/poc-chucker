// lib/service/api_service.dart
import 'package:dio/dio.dart';
import '../chucker/manager/chucker_manager.dart';
import '../chucker/interceptors/chucker_dio_interceptor.dart';
import '../chucker/models/encryption_config.dart';
import '../model/user.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'encryption_service.dart';

class ApiService {
  late Dio _dio;
  late EncryptionService _encryptionService;
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String usersPath = '/users';

  ApiService() {
    _dio = Dio();
    _initializeEncryption();
  }

  Future<void> _initializeEncryption() async {
    try {
      // Initialize with temporary key
      const secret = 'temporary-key';
      final keyBytes = sha256.convert(utf8.encode(secret)).bytes;
      final initialKey = base64.encode(keyBytes);

      // Create encryption service
      _encryptionService = EncryptionService(
        algorithm: 'AES-256-GCM', // Using GCM mode
        key: initialKey,
      );

      // Perform key exchange
      final sharedKey = await _encryptionService.exchangeKey();
      print('🔑 Key Exchange Success: ${sharedKey.substring(0, 10)}...');

      // Update config with shared key
      final encryptionConfig = EncryptionConfig(
        algorithm: 'AES-256-GCM',
        key: sharedKey,
        enabled: true,
      );

      // Initialize ChuckerManager
      ChuckerManager().initialize(config: encryptionConfig);

      // Set up interceptors
      _setupInterceptors();
    } catch (e) {
      print('❌ Key Exchange Failed: $e');
      print('Using fallback encryption...');
      _setupBasicEncryption();
    }
  }

  void _setupBasicEncryption() {
    const secret = 'fallback-secret-key';
    final keyBytes = sha256.convert(utf8.encode(secret)).bytes;
    final fallbackKey = base64.encode(keyBytes);

    final encryptionConfig = EncryptionConfig(
      algorithm: 'AES-256-GCM',
      key: fallbackKey,
      enabled: true,
    );

    ChuckerManager().initialize(config: encryptionConfig);
    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Encryption logging interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.data != null) {
          print('\n🔒 Original Request Data:');
          print(options.data);

          final encrypted =
              _encryptionService.encrypt(json.encode(options.data));
          print('\n🔐 Encrypted Request Data:');
          print(encrypted);
          options.data = encrypted; // Send encrypted data
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('\n🔒 Original Response Data:');
        print(response.data);

        if (response.data != null) {
          try {
            final decrypted =
                _encryptionService.decrypt(response.data.toString());
            response.data = json.decode(decrypted);

            print('\n🔓 Decrypted Response Data:');
            print(response.data);
          } catch (e) {
            print('Warning: Could not decrypt response - might be unencrypted');
          }
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (error.response?.data != null) {
          print('\n❌ Original Error Data:');
          print(error.response?.data);

          try {
            final decrypted =
                _encryptionService.decrypt(error.response!.data.toString());
            error.response!.data = json.decode(decrypted);

            print('\n🔓 Decrypted Error Data:');
            print(error.response?.data);
          } catch (e) {
            print('Warning: Could not decrypt error - might be unencrypted');
          }
        }
        handler.next(error);
      },
    ));

    // Logging interceptor
    _dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (object) {
          print('🌐 Network Log: $object');
        }));

    // Custom Chucker interceptor
    _dio.interceptors.add(ChuckerDioInterceptor());
  }

  Future<List<User>> getUsers() async {
    try {
      final String fullPath = baseUrl + usersPath;
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
