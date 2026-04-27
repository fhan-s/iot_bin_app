import 'package:flutter/material.dart';
import 'package:iot_bin_app/features/analytics/analytic_view.dart';
import 'package:iot_bin_app/features/maps/map_page.dart';
import 'package:iot_bin_app/features/dashboard/janitor/dashboard_bins.dart';
import 'package:iot_bin_app/features/profile/profile_page.dart';
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

  //default is dashboard page
  int selectedIndex = 0;

  StreamSubscription? authSubscription;
  StreamSubscription? tokenRefreshSubscription;
  StreamSubscription? snackbarMessageSubscription;

  Widget getSelectedPage() {
    switch (selectedIndex) {
      case 0:
        return const JanitorDashboardBinsPage();
      case 1:
        return const BinAnalyticPage();
      case 2:
        return const JanitorMapPage();
      default:
        return const JanitorDashboardBinsPage();
    }
  }

  String getPageTitle() {
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

  // store FCM token in the database
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
  void initState() {
    super.initState();
    if (supabase.auth.currentUser != null) {
      authSubscription = supabase.auth.onAuthStateChange.listen((event) async {
        // when janitor logs in, request new FCM token
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

    // FCM refreshes tokens periodically, so listen for token refresh events then update the database
    tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(
      (fcmtoken) async {
        await setFcmToken(fcmtoken);
      },
    );
    // if app is in the foreground, display incoming bin alerts as snackbars
    snackbarMessageSubscription = FirebaseMessaging.onMessage.listen((payload) {
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

  @override
  void dispose() {
    authSubscription?.cancel();
    tokenRefreshSubscription?.cancel();
    snackbarMessageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColourScheme = Theme.of(context).colorScheme;
    return Scaffold(
      // app bar with title and profile button
      backgroundColor: appColourScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text(getPageTitle()),
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
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
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
