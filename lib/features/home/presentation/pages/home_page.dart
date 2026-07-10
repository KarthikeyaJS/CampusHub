import 'package:campus_hub/features/auth/domain/usecases/logout_usecase.dart';
import 'package:campus_hub/features/auth/presentation/cubit/auth_state_cubit/auth_state.dart';
import 'package:campus_hub/features/auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/domain/entities/user_role.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../di/injection_container.dart';
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
            if (authState is AuthAuthenticated &&
                authState.user.role == UserRole.venueCoordinator) ...[
              ElevatedButton.icon(
                onPressed: () => context.push('/coordinator/approvals'),
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Approval Requests'),
              ),
            ] else ...[
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
