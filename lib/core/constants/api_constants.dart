/// Centralized backend configuration. Swap [baseUrl] to point at a different
/// environment — never hardcode a URL anywhere else in the app.
class ApiConstants {
  ApiConstants._();

  /// Android emulator loopback to the host machine's localhost.
  /// For a physical device, replace with your dev machine's LAN IP,
  /// e.g. "http://192.168.1.10:5000/api/v1".
  static const String baseUrl = "http://10.0.2.2:5000/api/v1";

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const int defaultPageSize = 10;
}
