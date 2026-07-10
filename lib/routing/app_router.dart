import 'package:go_router/go_router.dart';
import '../di/injection_container.dart';
import '../core/utils/go_router_refresh_stream.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';
import '../features/auth/presentation/cubit/auth_state_cubit/auth_state.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/complaints/presentation/pages/complaint_list_page.dart';
import '../features/complaints/presentation/pages/new_complaint_page.dart';
import '../features/complaints/presentation/pages/complaint_detail_page.dart';
import '../features/venues/presentation/pages/venue_list_page.dart';
import '../features/venues/presentation/pages/venue_detail_page.dart';
import '../features/venues/presentation/pages/my_bookings_page.dart';
import '../features/venues/presentation/pages/booking_detail_page.dart';

import '../features/venues/presentation/pages/coordinator_dashboard_page.dart';
import '../features/venues/presentation/pages/approval_detail_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(sl<AuthStateCubit>().stream),
    redirect: (context, state) {
      final authState = sl<AuthStateCubit>().state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isInitial = authState is AuthInitial;

      final goingToSplash = state.matchedLocation == '/';
      final goingToAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (isInitial) {
        return goingToSplash ? null : '/';
      }
      if (!isAuthenticated && !goingToAuth) {
        return '/login';
      }
      if (isAuthenticated && (goingToSplash || goingToAuth)) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/complaints',
        name: 'complaints',
        builder: (context, state) => const ComplaintListPage(),
      ),
      GoRoute(
        path: '/new-complaint',
        name: 'newComplaint',
        builder: (context, state) => const NewComplaintPage(),
      ),
      GoRoute(
        path: '/complaint/:id',
        name: 'complaintDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ComplaintDetailPage(complaintId: id);
        },
      ),
      GoRoute(
        path: '/venues',
        name: 'venues',
        builder: (context, state) => const VenueListPage(),
      ),
      GoRoute(
        path: '/venue/:id',
        name: 'venueDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return VenueDetailPage(venueId: id);
        },
      ),
      GoRoute(
        path: '/my-bookings',
        name: 'myBookings',
        builder: (context, state) => const MyBookingsPage(),
      ),
      GoRoute(
        path: '/booking/:id',
        name: 'bookingDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BookingDetailPage(bookingId: id);
        },
      ),
      GoRoute(
        path: '/coordinator/approvals',
        name: 'coordinatorApprovals',
        builder: (context, state) => const CoordinatorDashboardPage(),
      ),
      GoRoute(
        path: '/approval/:id',
        name: 'approvalDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ApprovalDetailPage(bookingId: id);
        },
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
  );
}
