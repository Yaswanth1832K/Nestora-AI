/// Base exception for data layer errors.
sealed class AppException implements Exception {
  const AppException({this.message, this.code});

  final String? message;
  final String? code;

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class ServerException extends AppException {
  const ServerException({super.message, super.code});
}

class CacheException extends AppException {
  const CacheException({super.message, super.code});
}

class AuthException extends AppException {
  const AuthException({super.message, super.code});
}

class ValidationException extends AppException {
  const ValidationException({super.message, super.code});
}

class NetworkException extends AppException {
  const NetworkException({super.message, super.code});
}
