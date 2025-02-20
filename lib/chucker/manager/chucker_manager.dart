import 'package:poc_chucker/service/encryption_service.dart';
import '../models/api_request.dart';
import '../models/api_response.dart';
import '../models/encryption_config.dart';

class ChuckerManager {
  static final ChuckerManager _instance = ChuckerManager._internal();
  factory ChuckerManager() => _instance;
  ChuckerManager._internal();

  final List<ApiRequest> _requests = [];
  final Map<String, ApiResponse> _responses = {};
  EncryptionConfig? _encryptionConfig;
  EncryptionService? _encryptionService;

  void initialize({required EncryptionConfig config}) {
    _encryptionConfig = config;
    if (config.enabled) {
      _encryptionService = EncryptionService(
        algorithm: config.algorithm,
        key: config.key,
      );
    }
  }

  void addRequest(ApiRequest request) {
    if (_encryptionConfig?.enabled == true && _encryptionService != null) {
      final encryptedBody =
          _encryptionService!.encrypt(request.body.toString());
      _requests.add(ApiRequest(
        method: request.method,
        path: request.path,
        headers: request.headers,
        body: request.body,
        requestTime: request.requestTime,
        encryptedBody: encryptedBody,
      ));
    } else {
      _requests.add(request);
    }
  }

  void addResponse(String requestPath, ApiResponse response) {
    if (_encryptionConfig?.enabled == true && _encryptionService != null) {
      final encryptedBody =
          _encryptionService!.encrypt(response.body.toString());
      _responses[requestPath] = ApiResponse(
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        responseTime: response.responseTime,
        encryptedBody: encryptedBody,
      );
    } else {
      _responses[requestPath] = response;
    }
  }

  List<ApiRequest> get requests => _requests;
  ApiResponse? getResponse(String requestPath) => _responses[requestPath];
  bool get isEncryptionEnabled => _encryptionConfig?.enabled ?? false;
  String? decryptData(String? encryptedData) {
    if (encryptedData == null || _encryptionService == null) return null;
    return _encryptionService!.decrypt(encryptedData);
  }
}
