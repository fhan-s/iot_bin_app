import 'package:flutter/material.dart';
import 'package:iot_bin_app/main.dart';
import 'package:iot_bin_app/pages/janitor/analytic_page.dart';
import 'package:iot_bin_app/pages/janitor/map_page.dart';
import 'package:iot_bin_app/pages/janitor/dashboard_bins.dart';

class JanitorDashboardPage extends StatefulWidget {
  const JanitorDashboardPage({super.key});

  @override
  State<JanitorDashboardPage> createState() => _JanitorDashboardPageState();
}

class _JanitorDashboardPageState extends State<JanitorDashboardPage> {
  int selectedIndex = 0;

  Widget getSelectedPage() {
    switch (selectedIndex) {
      case 0:
        return const JanitorDashboardBinsPage();
      case 1:
        return const JanitorAnalyticPage();
      case 2:
        return const JanitorMapPage();
      default:
        return const JanitorDashboardBinsPage();
    }
  }

  String getTitle() {
    switch (selectedIndex) {
      case 0:
        return 'Janitor Dashboard';
      case 1:
        return 'Analytics';
      case 2:
        return 'Map';
      default:
        return 'Dashboard';
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTitle()),
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
      body: getSelectedPage(),
      bottomNavigationBar: BottomNavigationBar(
        // uses the first index (0) as the default selected page
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        ],
      ),
    );
  }
}
