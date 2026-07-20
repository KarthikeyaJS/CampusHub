import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/inline_empty_note.dart';
import '../../../../core/widgets/recent_item_tile.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../di/injection_container.dart';
import '../../../complaints/domain/entities/complaint_status.dart';
import '../../../complaints/presentation/cubit/my_complaints_cubit/my_complaints_cubit.dart';
import '../../../complaints/presentation/cubit/my_complaints_cubit/my_complaints_state.dart';
import '../../../complaints/presentation/utils/status_ui_extension.dart';
import '../../../venues/domain/entities/booking_status.dart';
import '../../../venues/presentation/cubit/my_bookings_cubit/my_booking_cubit.dart';
import '../../../venues/presentation/cubit/my_bookings_cubit/my_bookings_state.dart';
import '../../../venues/presentation/utils/booking_status_ui_extension.dart';

class StudentHomeContent extends StatelessWidget {
  const StudentHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<MyComplaintsCubit>()),
        BlocProvider(create: (_) => sl<MyBookingsCubit>()),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          // --- Quick stats ---
          Row(
            children: [
              Expanded(
                child: BlocBuilder<MyComplaintsCubit, MyComplaintsState>(
                  builder: (context, state) {
                    final open = state is MyComplaintsLoaded
                        ? state.complaints
                              .where(
                                (c) => c.status != ComplaintStatus.resolved,
                              )
                              .length
                        : 0;
                    return StatCard(
                      label: 'Open Complaints',
                      value: '$open',
                      icon: Icons.report_problem_outlined,
                      color: AppColors.statusOrange,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BlocBuilder<MyBookingsCubit, MyBookingsState>(
                  builder: (context, state) {
                    final active = state is MyBookingsLoaded
                        ? state.bookings
                              .where(
                                (b) =>
                                    b.status == BookingStatus.pending ||
                                    b.status == BookingStatus.approved,
                              )
                              .length
                        : 0;
                    return StatCard(
                      label: 'Active Bookings',
                      value: '$active',
                      icon: Icons.meeting_room_outlined,
                      color: AppColors.secondary,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Recent complaints ---
          SectionHeader(
            icon: Icons.report_problem_outlined,
            title: 'Recent Complaints',
            actionLabel: 'View all',
            onAction: () => context.push('/complaints'),
          ),
          const SizedBox(height: 12),
          BlocBuilder<MyComplaintsCubit, MyComplaintsState>(
            builder: (context, state) {
              if (state is MyComplaintsLoading) return const _SectionLoading();
              if (state is MyComplaintsError) {
                return InlineEmptyNote(message: state.message);
              }
              final complaints =
                  (state as MyComplaintsLoaded).complaints.toList()
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              if (complaints.isEmpty) {
                return const InlineEmptyNote(
                  message: "You haven't filed any complaints yet.",
                );
              }
              return Column(
                children: complaints.take(3).map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RecentItemTile(
                      icon: Icons.report_problem_outlined,
                      iconColor: AppColors.statusOrange,
                      title: c.title,
                      subtitle: c.category.displayName,
                      statusLabel: c.status.displayName,
                      statusColor: c.status.color,
                      onTap: () => context.push('/complaint/${c.id}'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),

          // --- Recent bookings ---
          SectionHeader(
            icon: Icons.meeting_room_outlined,
            title: 'Recent Bookings',
            actionLabel: 'View all',
            onAction: () => context.push('/my-bookings'),
          ),
          const SizedBox(height: 12),
          BlocBuilder<MyBookingsCubit, MyBookingsState>(
            builder: (context, state) {
              if (state is MyBookingsLoading) return const _SectionLoading();
              if (state is MyBookingsError) {
                return InlineEmptyNote(message: state.message);
              }
              final bookings = (state as MyBookingsLoaded).bookings.toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              if (bookings.isEmpty) {
                return const InlineEmptyNote(
                  message: 'Reserve a venue and it will show up here.',
                );
              }
              return Column(
                children: bookings.take(3).map((b) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RecentItemTile(
                      icon: Icons.event_note_outlined,
                      iconColor: AppColors.secondary,
                      title: b.venueName,
                      subtitle: b.purpose,
                      statusLabel: b.status.displayName,
                      statusColor: b.status.color,
                      onTap: () => context.push('/booking/${b.id}'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),

          // --- Quick actions ---
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/new-complaint'),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('New Complaint'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/venues'),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Book a Venue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLoading extends StatelessWidget {
  const _SectionLoading();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
