/// Base type for every error that can surface from a repository call.
/// UI code should only ever need to read [message].
sealed class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// No connection, DNS failure, or request timeout.
class NetworkException extends ApiException {
  const NetworkException([super.message = "No internet connection. Please check your network and try again."]);
}

/// 401 — missing or expired JWT.
class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = "Your session has expired. Please log in again."]);
}

/// 403 — authenticated but not allowed to perform this action.
class ForbiddenException extends ApiException {
  const ForbiddenException([super.message = "You don't have permission to do that."]);
}

/// 404 — resource not found.
class NotFoundException extends ApiException {
  const NotFoundException([super.message = "The requested item could not be found."]);
}

/// 409 — conflict, e.g. duplicate application or duplicate email.
class ConflictException extends ApiException {
  const ConflictException([super.message = "This action conflicts with existing data."]);
}

/// 422 — validation errors from express-validator.
class ValidationException extends ApiException {
  const ValidationException([super.message = "Please check the form for errors."]);
}

/// 5xx — backend failure.
class ServerException extends ApiException {
  const ServerException([super.message = "Something went wrong. Please try again."]);
}

/// Anything else unexpected.
class UnknownApiException extends ApiException {
  const UnknownApiException([super.message = "Something went wrong. Please try again."]);
}
