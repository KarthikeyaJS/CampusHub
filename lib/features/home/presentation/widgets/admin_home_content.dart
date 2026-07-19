import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../di/injection_container.dart';
import '../../../reports/presentation/cubit/reports_cubit.dart';
import '../../../reports/presentation/cubit/reports_state.dart';

/// Note: this re-runs the same three-collection aggregation Module 8's
/// Reports page does, every time Home loads — fine at your current scale,
/// but worth knowing if usage grows: revisit before this becomes a
/// frequently-hit read-cost concern.
class AdminHomeContent extends StatelessWidget {
  const AdminHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportsCubit>()..load(),
      child: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading || state is ReportsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReportsError) {
            return Center(child: Text(state.message));
          }
          final summary = (state as ReportsLoaded).summary;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  StatCard(
                    label: 'Total Users',
                    value: '${summary.totalUsers}',
                    icon: Icons.people_outline_rounded,
                    color: AppColors.primary,
                  ),
                  StatCard(
                    label: 'Total Complaints',
                    value: '${summary.totalComplaints}',
                    icon: Icons.report_problem_outlined,
                    color: AppColors.statusOrange,
                  ),
                  StatCard(
                    label: 'Total Bookings',
                    value: '${summary.totalBookings}',
                    icon: Icons.meeting_room_outlined,
                    color: AppColors.secondary,
                  ),
                  StatCard(
                    label: 'Approval Rate',
                    value: '${(summary.bookingApprovalRate * 100).round()}%',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.statusGreen,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/admin'),
                      icon: const Icon(Icons.admin_panel_settings_outlined),
                      label: const Text('Admin Panel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/admin/reports'),
                      icon: const Icon(Icons.bar_chart_rounded),
                      label: const Text('Full Report'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
