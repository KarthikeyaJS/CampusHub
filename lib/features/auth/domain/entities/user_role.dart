/// The 4 roles in CampusHub. Stored as a string in Firestore (see .value).
enum UserRole {
  student('student'),
  departmentStaff('department_staff'),
  venueCoordinator('venue_coordinator'),
  admin('admin');

  final String value;
  const UserRole(this.value);

  /// Converts a Firestore string back into a UserRole.
  /// Defaults to student if somehow an unknown value is stored (safe fallback).
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.student,
    );
  }
}
