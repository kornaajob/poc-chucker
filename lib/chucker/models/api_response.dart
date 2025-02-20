class ApiResponse {
  final int statusCode;
  final Map<String, dynamic> headers;
  final dynamic body;
  final DateTime responseTime;
  final String? encryptedBody;

  ApiResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
    required this.responseTime,
    this.encryptedBody,
  });
}
