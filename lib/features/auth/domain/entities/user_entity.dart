import 'package:equatable/equatable.dart';
import 'user_role.dart';

/// Core user model used throughout the app (not tied to Firebase).
/// The Data layer will convert Firestore documents into this.
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? department; // relevant for Staff; null for others
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.department,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [uid, email, name, role, department, createdAt];
}
