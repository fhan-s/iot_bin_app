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
  bool obscureNewPasswordText = true;
  bool obscureConfirmPasswordText = true;
  Future<void> changePassword() async {
    final newPassword = _newpasswordController.text.trim();
    final confirmPassword = _confirmpasswordController.text.trim();
    final supabase = Supabase.instance.client;

    try {
      if (newPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password cannot be empty')),
        );
        return;
      }
      if (newPassword.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password must be at least 6 characters long'),
          ),
        );
        return;
      }
      if (!RegExp(r'[A-Z]').hasMatch(newPassword)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password must contain at least one uppercase letter',
            ),
          ),
        );
        return;
      }
      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
        return;
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
    }
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _newpasswordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bin IoT App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Reset Password',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _newpasswordController,
              obscureText: obscureNewPasswordText,
              decoration: InputDecoration(
                labelText: 'New Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureNewPasswordText
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureNewPasswordText = !obscureNewPasswordText;
                    });
                  },
                ),
              ),
            ),
            TextField(
              controller: _confirmpasswordController,
              obscureText: obscureConfirmPasswordText,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmPasswordText
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureConfirmPasswordText = !obscureConfirmPasswordText;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: changePassword,
              child: const Text('Change Password'),
            ),
            //cancel button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
