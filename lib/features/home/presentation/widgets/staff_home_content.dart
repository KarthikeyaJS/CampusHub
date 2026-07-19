import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/inline_empty_note.dart';
import '../../../../core/widgets/recent_item_tile.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/presentation/cubit/auth_state_cubit/auth_state.dart';
import '../../../auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';
import '../../../complaints/presentation/cubit/staff_complaints_cubit/staff_complaints_cubit.dart';
import '../../../complaints/presentation/cubit/staff_complaints_cubit/staff_complaints_state.dart';
import '../../../complaints/presentation/utils/status_ui_extension.dart';

class StaffHomeContent extends StatelessWidget {
  const StaffHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = sl<AuthStateCubit>().state;
    final department = authState is AuthAuthenticated
        ? (authState.user.department ?? '')
        : '';

    return BlocProvider(
      create: (_) => sl<StaffComplaintsCubit>()..load(department),
      child: BlocBuilder<StaffComplaintsCubit, StaffComplaintsState>(
        builder: (context, state) {
          if (state is StaffComplaintsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StaffComplaintsError) {
            return Center(child: Text(state.message));
          }
          final loaded = state as StaffComplaintsLoaded;
          final recentActive = loaded.active.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              if (department.isNotEmpty) ...[
                Text(
                  department,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Active Complaints',
                      value: '${loaded.active.length}',
                      icon: Icons.build_outlined,
                      color: AppColors.statusOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Resolved',
                      value: '${loaded.resolved.length}',
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.statusGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionHeader(
                icon: Icons.build_outlined,
                title: 'Needs Attention',
                actionLabel: 'View all',
                onAction: () => context.push('/staff/complaints'),
              ),
              const SizedBox(height: 12),
              if (recentActive.isEmpty)
                const InlineEmptyNote(
                  message: 'No active complaints. Nice and quiet.',
                )
              else
                Column(
                  children: recentActive.take(3).map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: RecentItemTile(
                        icon: Icons.build_outlined,
                        iconColor: AppColors.statusOrange,
                        title: c.title,
                        subtitle: c.studentName,
                        statusLabel: c.status.displayName,
                        statusColor: c.status.color,
                        onTap: () => context.push('/staff/complaint/${c.id}'),
                      ),
                    );
                  }).toList(),
                ),
            ],
          );
        },
      ),
    );
  }
}
