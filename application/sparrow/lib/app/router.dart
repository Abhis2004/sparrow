import 'package:go_router/go_router.dart';

import '../screens/home/home_screen.dart';
import '../screens/incidents/incidents_screen.dart';
import '../screens/new_incident/new_incident_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/report_generation/report_generation_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/timeline/timeline_screen.dart';
import 'app_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: '/timeline/:id',
      builder: (context, state) => TimelineScreen(
        incidentId: state.pathParameters['id'] ?? 'inc_002',
      ),
    ),
    GoRoute(
      path: '/incidents/:id',
      builder: (context, state) => TimelineScreen(
        incidentId: state.pathParameters['id'] ?? 'inc_002',
      ),
    ),



    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(
          navigationShell: navigationShell,
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/incidents',
              builder: (context, state) => const IncidentsScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/new-incident',
              builder: (context, state) => const NewIncidentScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/report-generation',
              builder: (context, state) => const ReportGenerationScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);