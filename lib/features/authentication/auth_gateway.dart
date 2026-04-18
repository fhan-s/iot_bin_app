import 'package:flutter/material.dart';
import 'package:iot_bin_app/features/authentication/auth_service.dart';
import 'package:iot_bin_app/features/dashboard/janitor/janitor_dashboard.dart';
import 'package:iot_bin_app/features/dashboard/manager/manager_dashboard.dart';
import 'package:iot_bin_app/features/login/login_page.dart';

class AuthenticationGate extends StatelessWidget {
  const AuthenticationGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        try {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final loginSession = authService.currentSession;
          // User is already logged in
          if (loginSession != null) {
            return FutureBuilder<String?>(
              future: authService.getUserRole(),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                final role = roleSnapshot.data;
                // Navigate based on user role
                if (role == "manager") {
                  return const ManagerDashboardPage();
                }
                if (role == "janitor") {
                  return const JanitorDashboardPage();
                }

                return const LoginPage();
              },
            );
          } else {
            // User is not logged in
            return const LoginPage();
          }
        } catch (e) {
          // In case of any error, redirect to login page
          return const LoginPage();
        }
      },
    );
  }
}
