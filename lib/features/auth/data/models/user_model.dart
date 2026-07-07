import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

/// Data layer's version of UserEntity — adds JSON (de)serialization
/// for Firestore. Domain layer never imports this; it only knows UserEntity.
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.role,
    super.department,
    required super.createdAt,
  });

  /// Builds a UserModel from a Firestore document map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.fromString(json['role'] as String),
      department: json['department'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Converts to a map for writing to Firestore.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.value,
      'department': department,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
