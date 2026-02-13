class User {
  final int userId;
  final String email;
  final String plan;
  final DateTime? expiresAt;

  User({
    required this.userId,
    required this.email,
    required this.plan,
    this.expiresAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as int,
      email: json['email'] as String,
      plan: json['plan'] as String,
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'plan': plan,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  bool get isActive {
    if (expiresAt == null) return true; // No expiry = active
    return DateTime.now().isBefore(expiresAt!);
  }

  String get planDisplayName {
    switch (plan.toLowerCase()) {
      case 'free':
        return 'Free Trial';
      case 'basic':
        return 'Basic';
      case 'pro':
        return 'Pro';
      case 'premium':
        return 'Premium';
      default:
        return plan;
    }
  }
}
