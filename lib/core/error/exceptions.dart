/// Thrown by data sources (Firebase, etc). Caught and converted to
/// Failure by the Repository implementation — Domain layer never
/// sees raw exceptions.
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}
