class AppEnvironment {
  const AppEnvironment._();
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://daily-bazaar.onrender.com',
  );
}
