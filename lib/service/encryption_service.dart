// lib/service/encryption_service.dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  static const int KEY_SIZE = 32; // 256 bits
  late final Key _encryptionKey;
  late final IV _iv;
  late final Encrypter _encrypter;
  final String algorithm;

  EncryptionService({
    required this.algorithm,
    String? key,
  }) {
    if (key != null) {
      _initializeWithKey(key);
    }
  }

  void _initializeWithKey(String key) {
    // สร้าง key ที่มีความยาว 32 bytes (256 bits)
    final List<int> keyBytes;
    if (base64.decode(key).length != KEY_SIZE) {
      // ถ้า key ไม่ได้ 32 bytes ให้ทำการ hash ด้วย SHA-256 เพื่อให้ได้ความยาวที่ถูกต้อง
      final hash = sha256.convert(utf8.encode(key));
      keyBytes = hash.bytes;
    } else {
      keyBytes = base64.decode(key);
    }

    _encryptionKey = Key(Uint8List.fromList(keyBytes));
    _iv = IV.fromSecureRandom(16); // สร้าง IV แบบสุ่มที่ปลอดภัย

    switch (algorithm.toUpperCase()) {
      case 'AES-256':
        _encrypter = Encrypter(AES(_encryptionKey, mode: AESMode.gcm));
        break;
      default:
        throw UnsupportedError('Unsupported encryption algorithm: $algorithm');
    }
  }

  // Mock key exchange
  Future<String> exchangeKey() async {
    // Simulate server response with a secure random key
    final serverKey = await _mockServerKeyExchange();
    final clientKey = _generateClientKey();
    final sharedKey = _deriveSharedKey(serverKey, clientKey);
    _initializeWithKey(sharedKey);
    return sharedKey;
  }

  Future<String> _mockServerKeyExchange() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(values);
  }

  String _generateClientKey() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(values);
  }

  String _deriveSharedKey(String serverKey, String clientKey) {
    final combined = utf8.encode(serverKey + clientKey);
    final hash =
        sha256.convert(combined); // ใช้ SHA-256 เพื่อให้ได้ key 256 bits
    return base64.encode(hash.bytes);
  }

  String encrypt(String data) {
    try {
      final encrypted = _encrypter.encrypt(data, iv: _iv);
      // รวม IV กับข้อมูลที่เข้ารหัสเพื่อให้สามารถถอดรหัสได้
      final combined = _iv.bytes + encrypted.bytes;
      return base64.encode(combined);
    } catch (e) {
      print('Encryption error: $e');
      rethrow;
    }
  }

  String decrypt(String encryptedData) {
    try {
      final decoded = base64.decode(encryptedData);
      // แยก IV และข้อมูลที่เข้ารหัส
      final iv = IV(decoded.sublist(0, 16));
      final encryptedBytes = decoded.sublist(16);
      final encrypted = Encrypted(encryptedBytes);
      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      print('Decryption error: $e');
      rethrow;
    }
  }
}
