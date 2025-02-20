import 'package:dio/dio.dart';
import '../manager/chucker_manager.dart';
import '../models/api_request.dart';
import '../models/api_response.dart';

class ChuckerDioInterceptor extends Interceptor {
  final ChuckerManager _manager;

  ChuckerDioInterceptor({ChuckerManager? manager})
      : _manager = manager ?? ChuckerManager();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final request = ApiRequest(
      method: options.method,
      path: options.path,
      headers: options.headers,
      body: options.data,
      requestTime: DateTime.now(),
    );

    _manager.addRequest(request);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final apiResponse = ApiResponse(
      statusCode: response.statusCode ?? 0,
      headers: response.headers.map,
      body: response.data,
      responseTime: DateTime.now(),
    );

    _manager.addResponse(response.requestOptions.path, apiResponse);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      final apiResponse = ApiResponse(
        statusCode: err.response?.statusCode ?? 0,
        headers: err.response?.headers.map ?? {},
        body: err.response?.data,
        responseTime: DateTime.now(),
      );

      _manager.addResponse(err.requestOptions.path, apiResponse);
    }
    super.onError(err, handler);
  }
}
