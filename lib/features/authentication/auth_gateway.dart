import 'package:flutter/material.dart';
import 'package:iot_bin_app/features/dashboards/janitor/dashboard.dart';
import 'package:iot_bin_app/features/dashboards/manager/dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iot_bin_app/features/login/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String?> getUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return null;
    }
    final response = await Supabase.instance.client
        .from('janitorial_staff')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();
    return response?['role'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    return StreamBuilder(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        try {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final session = supabase.auth.currentSession;
          // User is already logged in
          if (session != null) {
            return FutureBuilder<String?>(
              future: getUserRole(),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                final role = roleSnapshot.data;
                // Navigate based on user role
                if (role == "manager") {
                  debugPrint("<LOGIN OK: $role");
                  return const ManagerDashboardPage();
                } else if (role == "janitor") {
                  debugPrint("<LOGIN OK: $role");
                  return const JanitorDashboardPage();
                } else {
                  // Unknown role or no role assigned
                  debugPrint("LOGIN FAILED: $role");
                  return const LoginPage();
                }
              },
            );
          } else {
            // User is not logged in
            return const LoginPage();
          }
        } catch (e) {
          debugPrint("LOGIN FAILED: $e");
          // In case of any error, redirect to login page
          return const LoginPage();
        }
      },
    );
  }
}
