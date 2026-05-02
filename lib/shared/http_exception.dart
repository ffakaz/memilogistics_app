class HttpException implements Exception {
  final String message;
  final int statusCode;

  const HttpException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'HttpException: $message (status: $statusCode)';
}