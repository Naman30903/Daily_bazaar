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

  /// Matches backend `models.RegisterRequest`:
  /// { "email": "...", "password": "...", "full_name": "...", "phone": "..." }
  Map<String, dynamic> toJson() => {
    'full_name': name,
    'email': email,
    'phone': mobile,
    'password': password,
  };
}

/// Typed representation of the user object returned by the backend.
class User {
  const User({
    required this.id,
    required this.email,
    this.fullName,
    this.createdAt,
  });

  final String id;
  final String email;
  final String? fullName;
  final DateTime? createdAt;

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime? created;
    if (json['created_at'] is String) {
      created = DateTime.tryParse(json['created_at'] as String);
    } else if (json['createdAt'] is String) {
      created = DateTime.tryParse(json['createdAt'] as String);
    }
    return User(
      id: (json['id'] ?? json['user_id'] ?? json['userId'])?.toString() ?? '',
      email: (json['email'] ?? '')!.toString(),
      fullName: (json['full_name'] ?? json['fullName'])?.toString(),
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    if (fullName != null) 'full_name': fullName,
    if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
  };
}

class AuthResponse {
  const AuthResponse({required this.raw, this.token, this.userId, this.user});

  final Map<String, dynamic> raw;
  final String? token;
  final String? userId;
  final User? user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final parsedUser = userJson is Map<String, dynamic>
        ? User.fromJson(userJson)
        : null;

    final tokenVal = (json['token'] ?? json['access_token'])?.toString();
    final idFromUser = parsedUser?.id;
    final idFallback = (json['userId'] ?? json['user_id'] ?? json['id'])
        ?.toString();

    return AuthResponse(
      raw: json,
      token: tokenVal,
      user: parsedUser,
      userId: idFromUser ?? idFallback,
    );
  }
}
