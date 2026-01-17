import 'package:flutter/material.dart';
import 'package:iot_bin_app/pages/change_password_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> displayUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return null;
    }
    final userData = await supabase
        .from('janitorial_staff')
        .select('full_name,role')
        .eq('id', user.id)
        .maybeSingle();
    if (userData == null) {
      return null;
    }
    // Combine user data with email using spread operator ('...')
    return {...userData, 'email': user.email};
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> passwordReset() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
      );
    }
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Page')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: displayUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data found.'));
          }
          final userData = snapshot.data!;
          return Center(
            child: Column(
              children: [
                Text(
                  userData['full_name'] ?? 'No Name',
                  style: const TextStyle(fontSize: 24),
                ),
                Text(
                  userData['role'] ?? 'No Role',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  userData['email'] ?? 'No Email',
                  style: const TextStyle(fontSize: 18),
                ),
                TextButton(
                  child: const Text('Change Password'),
                  onPressed: () async {
                    await passwordReset();
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('logout'),
                  onPressed: () async {
                    await logout();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
