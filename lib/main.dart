import 'package:flutter/material.dart';
import 'package:iot_bin_app/auth/auth_gate.dart';
import 'package:iot_bin_app/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ikbjcupnufrhgrwalqjz.supabase.co',
    anonKey: 'sb_publishable_veDGu6wFXYjZs-AvVLiT3A__sYuNTOt',
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
