import 'package:go_router/go_router.dart';
import 'package:hey_smile/features/auth/presentation/pages/auth_page.dart';
import 'package:hey_smile/features/auth/presentation/pages/log_in_page.dart';
import 'package:hey_smile/features/auth/presentation/pages/sign_up_page.dart';
import 'package:hey_smile/features/camera/presentation/pages/camera_page.dart';
import 'package:hey_smile/features/home/presentation/pages/shell_page.dart';
import 'package:hey_smile/features/home/presentation/pages/home_page.dart';
import 'package:hey_smile/features/home/presentation/pages/capture_page.dart';
import 'package:hey_smile/features/threatments/presentation/pages/treatments_page.dart';
import 'package:hey_smile/features/shop/presentation/pages/shop_page.dart';
import 'package:hey_smile/features/tracker/presentation/pages/tracker_page.dart';
import 'package:hey_smile/features/profile/presentation/pages/profile_page.dart';
import 'package:hey_smile/features/profile/presentation/pages/analysis_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RouterManager {
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    redirect: (context, state) async {
      final loggedIn = await isUserLoggedIn();

      final authRoutes = ['/auth'];
      final isAuthRoute = authRoutes.any(
        (route) => state.matchedLocation.startsWith(route),
      );

      // Kullanıcı giriş yapmamışsa ve auth sayfasında değilse, auth'a yönlendir
      if (!loggedIn && !isAuthRoute) {
        return '/auth';
      }

      // Kullanıcı giriş yapmışsa ve auth sayfasındaysa, home'a yönlendir
      if (loggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },
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
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfilePage()),
          ),
          GoRoute(
            path: '/analysis',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AnalysisPage()),
          ),
        ],
      ),

      GoRoute(
        path: '/capture',
        builder: (context, state) => const CapturePage(),
      ),

      GoRoute(path: '/camera', builder: (context, state) => const CameraPage()),

      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthPage(),
        routes: [
          GoRoute(
            path: 'login',
            builder: (context, state) => const LogInPage(),
          ),
          GoRoute(
            path: 'signup',
            builder: (context, state) => const SignUpPage(),
          ),
        ],
      ),
    ],
  );
}
