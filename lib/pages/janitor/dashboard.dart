import 'package:flutter/material.dart';

class JanitorDashboard extends StatefulWidget {
  const JanitorDashboard({super.key});

  @override
  State<JanitorDashboard> createState() => _JanitorDashboardState();
}

class _JanitorDashboardState extends State<JanitorDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Janitor Dashboard')),
      body: const Center(child: Text('Welcome to the Janitor Dashboard!')),
    );
  }
}
