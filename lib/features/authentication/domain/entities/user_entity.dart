// lib/features/authentication/domain/entities/user_entity.dart
class UserEntity {
  final String userId; // UID from Firebase Auth
  final String fullname;
  final String email;
  final String? phone;

  UserEntity({
    required this.userId,
    required this.fullname,
    required this.email,
    this.phone,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      userId: json['user_id'] as String,
      fullname: json['fullname'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'fullname': fullname,
      'email': email,
      'phone': phone,
    };
  }
}