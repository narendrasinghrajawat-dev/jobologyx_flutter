/// Centralized backend configuration. Swap [baseUrl] to point at a different
/// environment — never hardcode a URL anywhere else in the app.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = "https://jobologyx-nodejs-test.onrender.com/api/v1";

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const int defaultPageSize = 10;
}
