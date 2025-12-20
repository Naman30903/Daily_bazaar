// ...existing code...
import 'package:flutter/material.dart';
import 'package:daily_bazaar_frontend/screens/login_page.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/hive.dart';

/// Centralized route names (avoids stringly-typed navigation spread across app).
abstract final class Routes {
  static const splash = '/';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
}

/// Centralized router (single place for navigation evolution).
abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SplashPage(),
        );
      case Routes.login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginPage(),
        );
      case Routes.home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomePage(),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => UnknownRoutePage(routeName: settings.name),
        );
    }
  }
}

/// Placeholder: bootstrapping screen. Later: load auth token/session then redirect.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // TODO: check TokenStorage.getToken() and decide route.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // simple default: go to login. Change to HOME if authenticated.
    Navigator.of(context).pushReplacementNamed(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

/// Placeholder home page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Daily Bazaar')),
    body: const Center(child: Text('Home')),
  );
}

class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({super.key, required this.routeName});
  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(child: Text('Route not found: ${routeName ?? '(null)'}')),
    );
  }
}
// ...existing code...