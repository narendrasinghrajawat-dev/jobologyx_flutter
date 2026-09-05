import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobologyx_flutter/core/errors/api_exception.dart';
import 'package:jobologyx_flutter/core/network/dio_exception_mapper.dart';

DioException _errorWithStatus(int statusCode, {Map<String, dynamic>? data}) {
  final requestOptions = RequestOptions(path: '/test');
  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: requestOptions, statusCode: statusCode, data: data),
  );
}

void main() {
  test('mapDioException maps status codes, prefers the backend message, and flags timeouts', () {
    expect(mapDioException(_errorWithStatus(401)), isA<UnauthorizedException>());
    expect(mapDioException(_errorWithStatus(404)), isA<NotFoundException>());
    expect(mapDioException(_errorWithStatus(422)), isA<ValidationException>());
    expect(mapDioException(_errorWithStatus(500)), isA<ServerException>());

    final withMessage = mapDioException(
      _errorWithStatus(401, data: {'success': false, 'message': 'Invalid email or password'}),
    );
    expect(withMessage.message, 'Invalid email or password');

    final timeout = DioException(
      requestOptions: RequestOptions(path: '/test'),
      type: DioExceptionType.connectionTimeout,
    );
    expect(mapDioException(timeout), isA<NetworkException>());
  });
}
