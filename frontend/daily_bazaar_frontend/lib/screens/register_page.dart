import 'package:daily_bazaar_frontend/routes/route.dart';
import 'package:daily_bazaar_frontend/shared_feature/api/auth_api.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/config.dart';
import 'package:daily_bazaar_frontend/shared_feature/helper/api_exception.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/auth_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/button.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/snackbar.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/textfield.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _isLoading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  late final ApiClient _client = ApiClient(baseUrl: AppEnvironment.apiBaseUrl);
  late final AuthApi _authApi = AuthApi(_client);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _mobile.dispose();
    _password.dispose();
    _confirm.dispose();
    _client.close();
    super.dispose();
  }

  String? _required(String? v, String label) {
    if ((v ?? '').trim().isEmpty) return '$label is required';
    return null;
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Email is required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    if (!ok) return 'Enter a valid email';
    return null;
  }

  String? _validateMobile(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Mobile number is required';
    final ok = RegExp(r'^\d{10,15}$').hasMatch(value);
    if (!ok) return 'Enter a valid mobile number';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = (v ?? '');
    if (value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Minimum 8 characters';
    return null;
  }

  String? _validateConfirm(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return 'Confirm password is required';
    if (value != _password.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final res = await _authApi.register(
        RegisterRequest(
          name: _name.text.trim(),
          email: _email.text.trim(),
          mobile: _mobile.text.trim(),
          password: _password.text,
          confirmPassword: _confirm.text,
        ),
      );

      if (!mounted) return;

      showAppSnackBar(context, 'Account created. Please login.');
      Navigator.of(context).pushReplacementNamed(Routes.login);
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
      appBar: AppBar(title: const Text('Create account')),
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
                  color: cs.surface.withValues(alpha: 0.92),
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
                            'Let’s get started',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Create your Daily Bazaar account in seconds.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(height: 24),
                          AppTextField(
                            controller: _name,
                            label: 'Full name',
                            hint: 'Naman Jain',
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.person_outline,
                            validator: (v) => _required(v, 'Full name'),
                          ),
                          const SizedBox(height: 14),
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
                            controller: _mobile,
                            label: 'Mobile number',
                            hint: '9876543210',
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.phone_outlined,
                            validator: _validateMobile,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _password,
                            label: 'Password',
                            hint: 'Minimum 8 characters',
                            obscureText: _obscure1,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.lock_outline,
                            validator: _validatePassword,
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure1 = !_obscure1),
                              icon: Icon(
                                _obscure1
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _confirm,
                            label: 'Confirm password',
                            hint: 'Re-enter password',
                            obscureText: _obscure2,
                            textInputAction: TextInputAction.done,
                            prefixIcon: Icons.verified_user_outlined,
                            validator: _validateConfirm,
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure2 = !_obscure2),
                              icon: Icon(
                                _obscure2
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 18),
                          CustomButton(
                            label: 'Create account',
                            isLoading: _isLoading,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'By continuing, you agree to our Terms and Privacy Policy.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
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
