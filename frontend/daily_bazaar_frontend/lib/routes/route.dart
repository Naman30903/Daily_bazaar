import 'package:daily_bazaar_frontend/screens/Profile/address_screen.dart';
import 'package:daily_bazaar_frontend/screens/category_browse.dart';
import 'package:daily_bazaar_frontend/screens/home_page.dart';
import 'package:daily_bazaar_frontend/screens/product_detail_screen.dart';
import 'package:daily_bazaar_frontend/screens/Profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:daily_bazaar_frontend/screens/login_page.dart';
import 'package:daily_bazaar_frontend/screens/register_page.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/hive.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/category_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/product_model.dart';

/// Centralized route names (avoids stringly-typed navigation spread across app).
abstract final class Routes {
  static const splash = '/';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const profile = '/profile';
  static const addresses = '/addresses';
  static const categoryBrowse = '/category-browse';
  static const productDetail = '/product-detail';
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
      case Routes.addresses:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AddressesPage(),
        );
      case Routes.login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginPage(),
        );
      case Routes.register:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const RegisterPage(),
        );
      case Routes.home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomePage(),
        );
      case Routes.profile:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProfilePage(),
        );
      case Routes.categoryBrowse:
        final category = settings.arguments as Category;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => CategoryBrowsePage(parentCategory: category),
        );
      case Routes.productDetail:
        final args = settings.arguments as Map<String, dynamic>;
        final product = args['product'] as Product;
        final similarProducts = args['similarProducts'] as List<Product>? ?? [];
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ProductDetailScreen(
            product: product,
            similarProducts: similarProducts,
          ),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => UnknownRoutePage(routeName: settings.name),
        );
    }
  }
}

/// Placeholder: bootstrapping screen. Check token and route accordingly.
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
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Check if user is logged in
    final token = TokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushReplacementNamed(Routes.home);
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.login);
    }
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
