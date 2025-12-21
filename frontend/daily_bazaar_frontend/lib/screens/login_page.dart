import 'package:daily_bazaar_frontend/routes/route.dart';
import 'package:daily_bazaar_frontend/screens/register_page.dart';
import 'package:daily_bazaar_frontend/shared_feature/api/auth_api.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/config.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/hive.dart';
import 'package:daily_bazaar_frontend/shared_feature/helper/api_exception.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/auth_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/button.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/snackbar.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/textfield.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isLoading = false;
  bool _obscure = true;

  late final ApiClient _client = ApiClient(baseUrl: AppEnvironment.apiBaseUrl);
  late final AuthApi _authApi = AuthApi(_client);

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _client.close();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Email is required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    if (!ok) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = (v ?? '');
    if (value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Minimum 8 characters';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final res = await _authApi.login(
        LoginRequest(email: _email.text.trim(), password: _password.text),
      );

      final token = res.token;
      if (token != null) {
        await TokenStorage.saveToken(token);
      }

      if (!mounted) return;

      // Navigate to home
      Navigator.of(context).pushReplacementNamed(Routes.home);
    } catch (e) {
      showAppSnackBar(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary.withValues(alpha: 0.18),
              cs.tertiary.withValues(alpha: 0.12),
              cs.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  elevation: 0,
                  color: cs.surface.withValues(alpha: 0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome back',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Login to continue shopping fresh groceries.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(height: 24),
                          AppTextField(
                            controller: _email,
                            label: 'Email',
                            hint: 'name@example.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.email_outlined,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _password,
                            label: 'Password',
                            hint: '••••••••',
                            obscureText: _obscure,
                            prefixIcon: Icons.lock_outline,
                            textInputAction: TextInputAction.done,
                            validator: _validatePassword,
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 18),
                          CustomButton(
                            label: 'Login',
                            isLoading: _isLoading,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => const RegisterPage(),
                                      ),
                                    );
                                  },
                            child: const Text('New here? Create an account'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
