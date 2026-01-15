import 'package:flutter/material.dart';
import 'package:iot_bin_app/pages/janitor/dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iot_bin_app/pages/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

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
          // User is logged in
          if (session != null) {
            return const JanitorDashboard(); // Replace with your authenticated home page
          } else {
            return const LoginPage();
          }
        } catch (e) {
          return const LoginPage();
        }
      },
    );
  }
}
