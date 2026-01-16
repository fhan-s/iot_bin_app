import 'package:flutter/material.dart';
import 'package:iot_bin_app/pages/janitor/dashboard.dart';
import 'package:iot_bin_app/pages/manager/dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iot_bin_app/pages/login_page.dart';

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
        .single();
    return response['role'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        try {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final session = Supabase.instance.client.auth.currentSession;
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
                  return const ManagerDashboardPage();
                } else if (role == "janitor") {
                  return const JanitorDashboardPage();
                } else {
                  // Unknown role or no role assigned
                  return const LoginPage();
                }
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
