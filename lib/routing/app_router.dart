import 'package:go_router/go_router.dart';
import 'package:iot_bin_app/features/dashboard/janitor/janitor_dashboard.dart';
import 'package:iot_bin_app/features/dashboard/manager/manager_dashboard.dart';
import 'package:iot_bin_app/features/login/login_page.dart';
import 'package:iot_bin_app/features/maps/map_page.dart';
import 'package:iot_bin_app/features/analytics/janitor/analytic_page.dart';
import 'package:iot_bin_app/features/dashboard/bin_information.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    GoRoute(
      path: '/janitor/dashboard',
      builder: (context, state) => JanitorDashboardPage(),
    ),
    GoRoute(
      path: '/janitor/map',
      builder: (context, state) => JanitorMapPage(),
    ),
    GoRoute(
      path: '/janitor/analytics',
      builder: (context, state) => JanitorAnalyticPage(),
    ),
    GoRoute(
      path: '/manager/dashboard',
      builder: (context, state) => ManagerDashboardPage(),
    ),
    GoRoute(
      path: '/bin/:id',
      builder: (context, state) {
        final binId = state.pathParameters['id']!;
        return BinInformationPage(binId: binId);
      },
    ),
  ],
);
