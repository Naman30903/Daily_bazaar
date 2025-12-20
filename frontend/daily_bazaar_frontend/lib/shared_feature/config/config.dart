class AppEnvironment {
  const AppEnvironment._();

  /// Backend base URL (Go API). Example: http://localhost:8080
  ///
  /// Run:
  /// `flutter run --dart-define=API_BASE_URL=http://localhost:8080`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}
