import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import 'session_expiry_notifier.dart';

/// The single Dio instance used by every repository. Attaches the JWT to
/// every request automatically and flags session expiry on 401 — repository
/// code never touches headers or auth state directly.
Dio buildDioClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {"Accept": "application/json"},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await ref.read(secureStorageServiceProvider).getToken();
        if (token != null && token.isNotEmpty) {
          options.headers["Authorization"] = "Bearer $token";
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Only a 401 on a request that actually carried a token means the
        // session itself is invalid/expired. A 401 from /auth/login or
        // /auth/register (no Authorization header sent) just means wrong
        // credentials — that must stay as the specific error message on the
        // login/register screen, not trigger a global forced logout.
        final hadAuthHeader = error.requestOptions.headers.containsKey("Authorization");
        if (error.response?.statusCode == 401 && hadAuthHeader) {
          ref.read(sessionExpiryProvider.notifier).notify();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
}

final dioClientProvider = Provider<Dio>((ref) => buildDioClient(ref));
