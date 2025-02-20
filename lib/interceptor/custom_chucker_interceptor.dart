// lib/interceptor/custom_chucker_interceptor.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:poc_chucker/chucker/helper/chucker_ui_helper.dart';
import '../service/encryption_service.dart';

class CustomChuckerInterceptor extends Interceptor {
  final EncryptionService _encryptionService;

  CustomChuckerInterceptor(this._encryptionService);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final requestTime = DateTime.now();

    // Store original request data before encryption
    String originalData = '';
    if (options.data != null) {
      originalData = json.encode(options.data);
      final encryptedData = _encryptionService.encrypt(originalData);
      options.data = encryptedData;
    }

    // Log request to Chucker
    ChuckerUiHelper.showNotification(
      method: options.method,
      statusCode: 0, // No status code for request
      path: options.uri.toString(),
      requestTime: requestTime,
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Decrypt response data
    String decryptedData = '';
    if (response.data != null) {
      try {
        decryptedData = _encryptionService.decrypt(response.data.toString());
        response.data = json.decode(decryptedData);
      } catch (e) {
        print('Error decrypting response: $e');
        decryptedData = response.data.toString();
      }
    }

    // Log response to Chucker
    ChuckerUiHelper.showNotification(
      method: response.requestOptions.method,
      statusCode: response.statusCode ?? 0,
      path: response.requestOptions.uri.toString(),
      requestTime: DateTime.now(),
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle encrypted error responses
    String decryptedError = '';
    if (err.response?.data != null) {
      try {
        decryptedError =
            _encryptionService.decrypt(err.response!.data.toString());
        err.response!.data = json.decode(decryptedError);
      } catch (e) {
        print('Error decrypting error response: $e');
        decryptedError = err.response!.data.toString();
      }
    }

    // Log error to Chucker
    ChuckerUiHelper.showNotification(
      method: err.requestOptions.method,
      statusCode: err.response?.statusCode ?? 0,
      path: err.requestOptions.uri.toString(),
      requestTime: DateTime.now(),
    );

    handler.next(err);
  }
}
