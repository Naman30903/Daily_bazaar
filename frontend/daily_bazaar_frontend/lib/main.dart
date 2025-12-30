import 'package:daily_bazaar_frontend/routes/route.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/hive.dart';
import 'package:daily_bazaar_frontend/shared_feature/constant/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenStorage.init();
  runApp(const ProviderScope(child: DailyBazaarApp()));
}

class DailyBazaarApp extends StatelessWidget {
  const DailyBazaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Bazaar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: Routes.splash,
    );
  }
}
