import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:iot_bin_app/features/profile/profile_page.dart';
import 'package:iot_bin_app/features/maps/map_page.dart';
import 'package:iot_bin_app/features/analytics/janitor/analytic_page.dart';
import 'package:iot_bin_app/features/dashboard/manager/dashboard_staff.dart';
import 'package:iot_bin_app/features/dashboard/manager/dashboard_bins.dart';

class ManagerDashboardPage extends StatefulWidget {
  const ManagerDashboardPage({super.key});

  @override
  State<ManagerDashboardPage> createState() => _ManagerDashboardPageState();
}

class _ManagerDashboardPageState extends State<ManagerDashboardPage> {
  final supabase = Supabase.instance.client;
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();

    if (supabase.auth.currentUser != null) {
      supabase.auth.onAuthStateChange.listen((event) async {
        // when user signs in, request FCM notification permission and get token
        if (event.event == AuthChangeEvent.signedIn) {
          await FirebaseMessaging.instance.requestPermission();
          final fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) {
            // Store the FCM token in the database
            await setFcmToken(fcmToken);
          }
        }
      });
    }
    // listens for FCM token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmtoken) async {
      // Update the stored FCM token in the database
      await setFcmToken(fcmtoken);
    });
    // listens for incoming messages while the app is in the foreground
    FirebaseMessaging.onMessage.listen((payload) {
      if (!mounted) return;
      final notification = payload.notification;
      if (notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${notification.title}: ${notification.body}'),
          ),
        );
      }
    });
  }

  Future<void> setFcmToken(String fcmToken) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      await supabase.from('fcm_push_token').upsert({
        'user_id': userId,
        'fcm_token': fcmToken,
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  Widget getSelectedPage() {
    switch (selectedIndex) {
      case 0:
        return const ManagerDashboardBinsPage();
      case 1:
        return const JanitorAnalyticPage();
      case 2:
        return const JanitorMapPage();
      default:
        return const ManagerDashboardBinsPage();
    }
  }

  String getTitle() {
    switch (selectedIndex) {
      case 0:
        return 'Manager Dashboard';
      case 1:
        return 'Analytics';
      case 2:
        return 'Map';
      default:
        return 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColourScheme = Theme.of(context).colorScheme;
    return Scaffold(
      // app bar with title and profile button
      backgroundColor: appColourScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text(getTitle()),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: "Profile",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: getSelectedPage(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // uses the first index (0) as the default selected page
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Manager Dashboard',
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
