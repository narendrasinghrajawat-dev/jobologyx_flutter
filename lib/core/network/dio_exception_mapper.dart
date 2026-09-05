import 'package:dio/dio.dart';

import '../errors/api_exception.dart';

/// Converts a raw [DioException] into one [ApiException] type, reading the
/// backend's `{ success, message, data }` envelope when present. Repositories
/// call this once in a catch block instead of re-implementing status-code
/// handling per screen.
ApiException mapDioException(DioException error) {
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError) {
    return const NetworkException();
  }

  final response = error.response;
  if (response == null) {
    return const UnknownApiException();
  }

  final backendMessage = _extractMessage(response.data);

  switch (response.statusCode) {
    case 401:
      return UnauthorizedException(backendMessage ?? "Your session has expired. Please log in again.");
    case 403:
      return ForbiddenException(backendMessage ?? "You don't have permission to do that.");
    case 404:
      return NotFoundException(backendMessage ?? "The requested item could not be found.");
    case 409:
      return ConflictException(backendMessage ?? "This action conflicts with existing data.");
    case 422:
      return ValidationException(backendMessage ?? "Please check the form for errors.");
    default:
      final code = response.statusCode ?? 0;
      if (code >= 500) {
        return ServerException(backendMessage ?? "Something went wrong. Please try again.");
      }
      return UnknownApiException(backendMessage ?? "Something went wrong. Please try again.");
  }
}

String? _extractMessage(dynamic data) {
  if (data is Map<String, dynamic> && data["message"] is String) {
    return data["message"] as String;
  }
  return null;
}
