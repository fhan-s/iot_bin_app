import 'package:flutter/material.dart';

class JanitorDashboardPage extends StatefulWidget {
  const JanitorDashboardPage({super.key});

  @override
  State<JanitorDashboardPage> createState() => _JanitorDashboardPageState();
}

class _JanitorDashboardPageState extends State<JanitorDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Janitor Dashboard')),
      body: const Center(child: Text('Welcome to the Janitor Dashboard!')),
    );
  }
}
