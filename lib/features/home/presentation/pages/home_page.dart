import 'package:campus_hub/features/auth/domain/usecases/logout_usecase.dart';
import 'package:campus_hub/features/auth/presentation/cubit/auth_state_cubit/auth_state.dart';
import 'package:campus_hub/features/auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../notifications/presentation/cubit/notifications_cubit/notifications_cubit.dart';
import '../../../notifications/presentation/cubit/notifications_cubit/notifications_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthStateCubit>().state;
    final roleLabel = authState is AuthAuthenticated
        ? _roleLabel(authState.user.role)
        : '';
    final name = authState is AuthAuthenticated ? authState.user.name : '';
    final role = authState is AuthAuthenticated ? authState.user.role : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CampusHub'),
        actions: [
          BlocProvider(
            create: (_) => sl<NotificationsCubit>(),
            child: Builder(
              builder: (context) {
                return BlocBuilder<NotificationsCubit, NotificationsState>(
                  builder: (context, state) {
                    final unread = state is NotificationsLoaded
                        ? state.unreadCount
                        : 0;
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () => context.push('/notifications'),
                        ),
                        if (unread > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                unread > 9 ? '9+' : '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => sl<LogoutUseCase>().call(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome, $name', style: AppTextStyles.h1),
              const SizedBox(height: 6),
              Text(roleLabel, style: AppTextStyles.bodySecondary),
              const SizedBox(height: 32),
              ..._buildRoleButtons(context, role),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRoleButtons(BuildContext context, UserRole? role) {
    switch (role) {
      case UserRole.venueCoordinator:
        return [
          _HomeActionButton(
            icon: Icons.fact_check_outlined,
            label: 'Approval Requests',
            onTap: () => context.push('/coordinator/approvals'),
          ),
        ];
      case UserRole.departmentStaff:
        return [
          _HomeActionButton(
            icon: Icons.build_outlined,
            label: 'Manage Complaints',
            onTap: () => context.push('/staff/complaints'),
          ),
        ];
      case UserRole.student:
      case UserRole.admin:
      case null:
        return [
          _HomeActionButton(
            icon: Icons.report_problem_outlined,
            label: 'My Complaints',
            onTap: () => context.push('/complaints'),
          ),
          const SizedBox(height: 12),
          _HomeActionButton(
            icon: Icons.meeting_room_outlined,
            label: 'Book a Venue',
            onTap: () => context.push('/venues'),
          ),
        ];
    }
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

class _HomeActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _HomeActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}
