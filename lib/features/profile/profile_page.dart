import 'package:flutter/material.dart';
import 'package:iot_bin_app/features/profile/change_password_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iot_bin_app/utils/profile_section_card.dart';
import 'package:iot_bin_app/utils/profile_header_card.dart';
import 'package:iot_bin_app/utils/profile_item.dart';
import 'package:iot_bin_app/utils/profile_section_title.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> displayUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final userData = await supabase
        .from('janitorial_staff')
        .select('full_name, role')
        .eq('id', user.id)
        .maybeSingle();

    if (userData == null) return null;

    return {...userData, 'email': user.email};
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> passwordReset() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
    );
  }

  Future<void> confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colourScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colourScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: colourScheme.surface,
        elevation: 0,
      ),
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
          final fullName =
              (userData['full_name'] as String?)?.trim() ?? 'No Name';
          final role = (userData['role'] as String?)?.trim() ?? 'No Role';
          final email = (userData['email'] as String?)?.trim() ?? 'No Email';

          final initials = userInitials(fullName);

          return ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              32 + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              ProfileHeaderCard(
                initials: initials,
                fullName: fullName,
                email: email,
                role: role,
              ),

              const SizedBox(height: 16),

              SectionTitle('Account'),
              const SizedBox(height: 8),
              ProfileSectionCard(
                children: [
                  ProfileItem(
                    icon: Icons.badge_outlined,
                    title: 'Full name',
                    subtitle: fullName,
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ProfileItem(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: email,
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ProfileItem(
                    icon: Icons.work_outline,
                    title: 'Role',
                    subtitle: role,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SectionTitle('Security'),
              const SizedBox(height: 8),
              ProfileSectionCard(
                children: [
                  ProfileItem(
                    icon: Icons.lock_outline,
                    title: 'Change password',
                    subtitle: 'Update your password',
                    onTap: passwordReset,
                  ),
                ],
              ),

              const SizedBox(height: 16),
              ProfileSectionCard(
                children: [
                  ProfileItem(
                    icon: Icons.logout,
                    title: 'Log out',
                    subtitle: 'Sign out of this account',
                    titleColor: colourScheme.error,
                    iconColor: colourScheme.error,
                    onTap: confirmLogout,
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  String userInitials(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts[0].characters.first + parts[1].characters.first)
        .toUpperCase();
  }
}
