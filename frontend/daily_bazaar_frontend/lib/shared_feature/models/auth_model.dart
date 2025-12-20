class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    required this.confirmPassword,
  });

  final String name;
  final String email;
  final String mobile;
  final String password;
  final String confirmPassword;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'mobile': mobile,
    'password': password,
    'confirmPassword': confirmPassword,
  };
}

/// Generic/loose response model; adjust keys once backend contract is finalized.
class AuthResponse {
  const AuthResponse({required this.raw, this.token, this.userId});

  final Map<String, dynamic> raw;
  final String? token;
  final String? userId;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      raw: json,
      token: (json['token'] ?? json['access_token'])?.toString(),
      userId: (json['userId'] ?? json['user_id'] ?? json['id'])?.toString(),
    );
  }
}
