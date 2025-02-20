class ApiRequest {
  final String method;
  final String path;
  final Map<String, dynamic> headers;
  final dynamic body;
  final DateTime requestTime;
  final String? encryptedBody; // เพิ่มฟิลด์สำหรับเก็บข้อมูลที่เข้ารหัส

  ApiRequest({
    required this.method,
    required this.path,
    required this.headers,
    required this.body,
    required this.requestTime,
    this.encryptedBody,
  });
}
