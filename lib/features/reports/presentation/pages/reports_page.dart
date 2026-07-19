import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../complaints/presentation/utils/status_ui_extension.dart';
import '../../../venues/presentation/utils/booking_status_ui_extension.dart';
import '../../domain/entities/analytics_summary_entity.dart';
import '../cubit/reports_cubit.dart';
import '../cubit/reports_state.dart';
import '../widgets/chart_datum.dart';
import '../widgets/donut_chart_card.dart';
import '../widgets/horizontal_bar_list_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/trend_chart_card.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportsCubit>()..load(),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<ReportsCubit>().load(),
          ),
        ],
      ),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading || state is ReportsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReportsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ReportsCubit>().load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final summary = (state as ReportsLoaded).summary;
          return RefreshIndicator(
            onRefresh: () => context.read<ReportsCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Generated ${summary.generatedAt.hour.toString().padLeft(2, '0')}:'
                  '${summary.generatedAt.minute.toString().padLeft(2, '0')} · '
                  '${summary.generatedAt.day}/${summary.generatedAt.month}/${summary.generatedAt.year}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 16),

                // --- Overview ---
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      StatCard(
                        label: 'Total Users',
                        value: '${summary.totalUsers}',
                        icon: Icons.people_outline_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      StatCard(
                        label: 'Total Complaints',
                        value: '${summary.totalComplaints}',
                        icon: Icons.report_problem_outlined,
                        color: AppColors.statusOrange,
                      ),
                      const SizedBox(width: 12),
                      StatCard(
                        label: 'Total Bookings',
                        value: '${summary.totalBookings}',
                        icon: Icons.meeting_room_outlined,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 12),
                      StatCard(
                        label: 'Booking Approval Rate',
                        value:
                            '${(summary.bookingApprovalRate * 100).round()}%',
                        icon: Icons.check_circle_outline_rounded,
                        color: AppColors.statusGreen,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text('Complaints', style: AppTextStyles.h2),
                const SizedBox(height: 12),
                DonutChartCard(
                  title: 'By Status',
                  data: summary.complaintsByStatus.entries
                      .map(
                        (e) => ChartDatum(
                          label: e.key.displayName,
                          value: e.value,
                          color: e.key.color,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                HorizontalBarListCard(
                  title: 'By Category',
                  data: summary.complaintsByCategory.entries
                      .map(
                        (e) => ChartDatum(
                          label: e.key.displayName,
                          value: e.value,
                          color: AppColors.primary,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                HorizontalBarListCard(
                  title: 'By Department',
                  data: summary.complaintsByDepartment.entries
                      .map(
                        (e) => ChartDatum(
                          label: e.key,
                          value: e.value,
                          color: AppColors.secondary,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                TrendChartCard(
                  title: 'Last 30 Days',
                  data: summary.complaintsTrend30d,
                ),
                const SizedBox(height: 28),

                Text('Venue Bookings', style: AppTextStyles.h2),
                const SizedBox(height: 12),
                DonutChartCard(
                  title: 'By Status',
                  data: summary.bookingsByStatus.entries
                      .map(
                        (e) => ChartDatum(
                          label: e.key.displayName,
                          value: e.value,
                          color: e.key.color,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                HorizontalBarListCard(
                  title: 'Most-Booked Venues',
                  data: summary.bookingsByVenue.entries
                      .map(
                        (e) => ChartDatum(
                          label: e.key,
                          value: e.value,
                          color: AppColors.primary,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 28),

                Text('Users', style: AppTextStyles.h2),
                const SizedBox(height: 12),
                DonutChartCard(
                  title: 'By Role',
                  data: summary.usersByRole.entries
                      .map(
                        (e) => ChartDatum(
                          label: _roleLabel(e.key),
                          value: e.value,
                          color: _roleColor(e.key),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
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

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return AppColors.primary;
      case UserRole.departmentStaff:
        return AppColors.statusOrange;
      case UserRole.venueCoordinator:
        return AppColors.secondary;
      case UserRole.admin:
        return AppColors.statusGreen;
    }
  }
}
