import 'package:flutter/material.dart';
import 'package:iot_bin_app/features/authentication/auth_gate.dart';
import 'package:iot_bin_app/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:iot_bin_app/config/env.dart';
import 'package:iot_bin_app/config/details.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    // url: AppDetails.supabaseURL,
    // anonKey: AppDetails.supabaseAnonKey,
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // remove debug banner
      debugShowCheckedModeBanner: false,
      title: 'Bin IoT App',
      theme: AppTheme.lightThemeMode,
      home: const AuthGate(),
    );
  }
}
