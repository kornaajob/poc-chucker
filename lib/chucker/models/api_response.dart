class ApiResponse {
  final int statusCode;
  final Map<String, dynamic> headers;
  final dynamic body;
  final DateTime responseTime;
  final String? encryptedBody; // เพิ่มฟิลด์สำหรับเก็บข้อมูลที่เข้ารหัส

  ApiResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
    required this.responseTime,
    this.encryptedBody,
  });
}
