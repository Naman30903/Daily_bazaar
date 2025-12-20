import 'package:daily_bazaar_frontend/screens/login_page.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DailyBazaarApp());
}

/// Root app widget (kept free of feature/business logic for scalability).
class DailyBazaarApp extends StatelessWidget {
  const DailyBazaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Bazaar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: Routes.splash,
    );
  }
}

/// Centralized route names (avoids stringly-typed navigation spread across app).
abstract final class Routes {
  static const splash = '/';
  static const home = '/home';
  static const login = '/login';
}

/// Centralized router (a single place to evolve navigation as the app grows).
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

/// Placeholder: bootstrapping screen.
/// Later: load auth token, config, remote feature flags, etc., then redirect.
///
/// Keeping this separate prevents complicated startup logic living in `main()`.
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
    // TODO: initialize dependencies, load persisted session, warm caches, etc.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    // TODO: if authenticated => Routes.home else Routes.login
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

/// Placeholder: first feature screen.
/// In clean architecture, this becomes a "feature module" entry point
/// (presentation only; no networking/database logic here).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Bazaar')),
      body: const Center(child: Text('Home')),
    );
  }
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
