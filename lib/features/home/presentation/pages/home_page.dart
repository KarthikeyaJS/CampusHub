import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../../auth/presentation/cubit/auth_state_cubit/auth_state.dart';
import '../../../auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';
import 'package:go_router/go_router.dart';

/// Temporary landing page shown after login, regardless of role.
/// Will be replaced by role-specific dashboards in later modules
/// (Student Dashboard, Department Dashboard, Coordinator Dashboard).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthStateCubit>().state;
    final roleLabel = authState is AuthAuthenticated
        ? _roleLabel(authState.user.role)
        : '';
    final name = authState is AuthAuthenticated ? authState.user.name : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CampusHub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => sl<LogoutUseCase>().call(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, $name', style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text('Role: $roleLabel', style: AppTextStyles.bodySecondary),
            const SizedBox(height: 24),
            Text('Dashboard coming soon', style: AppTextStyles.bodySecondary),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/complaints'),
              icon: const Icon(Icons.report_problem_outlined),
              label: const Text('My Complaints'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.push('/venues'),
              icon: const Icon(Icons.meeting_room_outlined),
              label: const Text('Book a Venue'),
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.departmentStaff:
        return 'Department Staff';
      case UserRole.venueCoordinator:
        return 'Venue Coordinator';
      case UserRole.admin:
        return 'Admin';
    }
  }
}
