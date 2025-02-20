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
    // Create a 32-byte (256-bit) key
    final List<int> keyBytes;
    if (base64.decode(key).length != KEY_SIZE) {
      final hash = sha256.convert(utf8.encode(key));
      keyBytes = hash.bytes;
    } else {
      keyBytes = base64.decode(key);
    }

    _encryptionKey = Key(Uint8List.fromList(keyBytes));
    _iv = IV.fromSecureRandom(16);

    // Set up AES encryption in GCM mode for authenticated encryption
    switch (algorithm.toUpperCase()) {
      case 'AES-256-GCM':
      case 'AES-256':
        _encrypter = Encrypter(AES(_encryptionKey, mode: AESMode.gcm));
        break;
      default:
        throw UnsupportedError('Unsupported encryption algorithm: $algorithm');
    }
  }

  Future<String> exchangeKey() async {
    // Mock key exchange process
    final serverKey = await _mockServerKeyExchange();
    final clientKey = _generateClientKey();
    final sharedKey = _deriveSharedKey(serverKey, clientKey);
    _initializeWithKey(sharedKey);
    return sharedKey;
  }

  Future<String> _mockServerKeyExchange() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
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
    final hash = sha256.convert(combined);
    return base64.encode(hash.bytes);
  }

  String encrypt(String data) {
    try {
      final encrypted = _encrypter.encrypt(data, iv: _iv);
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
