import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _newpasswordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  bool obscurePasswordText = true;
  Future<void> changePassword() async {
    final newPassword = _newpasswordController.text.trim();
    final confirmPassword = _confirmpasswordController.text.trim();
    final supabase = Supabase.instance.client;
    try {
      if (newPassword != confirmPassword) {
        throw Exception('Passwords do not match');
      }
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
      // Call Supabase or relevant service to change password
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Password change failed: $e')));
    } finally {
      _newpasswordController.clear();
      _confirmpasswordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _newpasswordController,
              obscureText: obscurePasswordText,
              decoration: InputDecoration(
                labelText: 'New Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePasswordText
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePasswordText = !obscurePasswordText;
                    });
                  },
                ),
              ),
            ),
            TextField(
              controller: _confirmpasswordController,
              obscureText: obscurePasswordText,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePasswordText
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePasswordText = !obscurePasswordText;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
