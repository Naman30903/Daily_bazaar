import 'package:daily_bazaar_frontend/routes/route.dart';
import 'package:daily_bazaar_frontend/screens/login_page.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/hive.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenStorage.init();
  runApp(const DailyBazaarApp());
}

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
