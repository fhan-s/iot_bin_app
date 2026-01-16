import 'package:flutter/material.dart';
import 'package:iot_bin_app/main.dart';

class JanitorDashboardPage extends StatefulWidget {
  const JanitorDashboardPage({super.key});

  @override
  State<JanitorDashboardPage> createState() => _JanitorDashboardPageState();
}

class _JanitorDashboardPageState extends State<JanitorDashboardPage> {
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Janitor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () {
              logout();
            },
          ),
        ],
      ),
      body: const Center(child: Text('Welcome to the Janitor Dashboard!')),
    );
  }
}
