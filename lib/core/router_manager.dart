import 'package:go_router/go_router.dart';
import 'package:hey_smile/features/home/presentation/pages/shell_page.dart';
import 'package:hey_smile/features/home/presentation/pages/home_page.dart';
import 'package:hey_smile/features/home/presentation/pages/tracker_page.dart';
import 'package:hey_smile/features/home/presentation/pages/capture_page.dart';
import 'package:hey_smile/features/home/presentation/pages/treatments_page.dart';
import 'package:hey_smile/features/home/presentation/pages/shop_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RouterManager {
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    /*redirect: (context, state) async {
      final loggedIn = await isUserLoggedIn();

      final authRoutes = ['/auth', '/authgate', '/onboarding'];
      final isAuthRoute = authRoutes.any(
        (route) => state.matchedLocation.startsWith(route),
      );

      if (!loggedIn && !isAuthRoute) {
        return '/authgate';
      }
      return null;
    },*/
    routes: [
      ShellRoute(
        builder: (context, state, child) => ShellPage(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: '/tracker',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TrackerPage()),
          ),
          GoRoute(
            path: '/treatments',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TreatmentsPage()),
          ),
          GoRoute(
            path: '/shop',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ShopPage()),
          ),
        ],
      ),

      GoRoute(
        path: '/capture',
        builder: (context, state) => const CapturePage(),
      ),
    ],
  );
}
