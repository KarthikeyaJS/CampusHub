import 'package:campus_hub/features/complaints/presentation/pages/complaint_detail_page.dart';
import 'package:campus_hub/features/venues/presentation/pages/venue_list_page.dart';
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

      // Still resolving initial auth check -> stay on splash.
      if (isInitial) {
        return goingToSplash ? null : '/';
      }

      // Not logged in, trying to reach a protected page -> send to login.
      if (!isAuthenticated && !goingToAuth) {
        return '/login';
      }

      // Logged in, but sitting on splash or login/register -> send to home.
      if (isAuthenticated && (goingToSplash || goingToAuth)) {
        return '/home';
      }

      // No redirect needed.
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
    ],
  );
}
