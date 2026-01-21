import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iot_bin_app/pages/janitor/analytic_page.dart';
import 'package:iot_bin_app/pages/janitor/map_page.dart';
import 'package:iot_bin_app/pages/janitor/dashboard_bins.dart';
import 'package:iot_bin_app/pages/profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';

class JanitorDashboardPage extends StatefulWidget {
  const JanitorDashboardPage({super.key});

  @override
  State<JanitorDashboardPage> createState() => _JanitorDashboardPageState();
}

class _JanitorDashboardPageState extends State<JanitorDashboardPage> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    // Set up FCM token registration and listener for auth state changes
    if (supabase.auth.currentUser != null) {
      supabase.auth.onAuthStateChange.listen((event) async {
        // when user signs in, request FCM notification permission and get token
        if (event.event == AuthChangeEvent.signedIn) {
          await FirebaseMessaging.instance.requestPermission();
          final fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) {
            await setFcmToken(fcmToken);
          }
        }
      });
    }
    // Listen for FCM token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmtoken) async {
      await setFcmToken(fcmtoken);
    });
    // Listen for incoming messages while the app is in the foreground
    FirebaseMessaging.onMessage.listen((payload) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTitle()),
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
      body: getSelectedPage(),
      bottomNavigationBar: BottomNavigationBar(
        // uses the first index (0) as the default selected page
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Janitor Dashboard',
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
