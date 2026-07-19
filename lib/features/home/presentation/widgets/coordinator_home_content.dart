import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/inline_empty_note.dart';
import '../../../../core/widgets/recent_item_tile.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../di/injection_container.dart';
import '../../../venues/presentation/cubit/coordinator_approvals_cubit/coordinator_approvals_cubit.dart';
import '../../../venues/presentation/cubit/coordinator_approvals_cubit/coordinator_approvals_state.dart';
import '../../../venues/presentation/utils/booking_status_ui_extension.dart';

class CoordinatorHomeContent extends StatelessWidget {
  const CoordinatorHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CoordinatorApprovalsCubit>(),
      child: BlocBuilder<CoordinatorApprovalsCubit, CoordinatorApprovalsState>(
        builder: (context, state) {
          if (state is CoordinatorApprovalsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CoordinatorApprovalsError) {
            return Center(child: Text(state.message));
          }
          final loaded = state as CoordinatorApprovalsLoaded;
          final recentPending = loaded.pending.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Pending Requests',
                      value: '${loaded.pending.length}',
                      icon: Icons.pending_actions_outlined,
                      color: AppColors.statusYellow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Decided',
                      value: '${loaded.history.length}',
                      icon: Icons.history_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionHeader(
                icon: Icons.fact_check_outlined,
                title: 'Awaiting Your Decision',
                actionLabel: 'View all',
                onAction: () => context.push('/coordinator/approvals'),
              ),
              const SizedBox(height: 12),
              if (recentPending.isEmpty)
                const InlineEmptyNote(message: 'No pending requests right now.')
              else
                Column(
                  children: recentPending.take(3).map((b) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: RecentItemTile(
                        icon: Icons.event_note_outlined,
                        iconColor: AppColors.statusYellow,
                        title: b.venueName,
                        subtitle: '${b.studentName} · ${b.purpose}',
                        statusLabel: b.status.displayName,
                        statusColor: b.status.color,
                        onTap: () => context.push('/approval/${b.id}'),
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
