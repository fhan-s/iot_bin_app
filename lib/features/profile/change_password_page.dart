import 'package:flutter/material.dart';
import 'package:iot_bin_app/features/profile/profile_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final profileService = ProfileService();
  final newpasswordController = TextEditingController();
  final confirmpasswordController = TextEditingController();

  bool obscureNewPasswordText = true;
  bool obscureConfirmPasswordText = true;
  bool isLoading = false;

  Future<void> changePassword() async {
    if (isLoading) return;

    final newPassword = newpasswordController.text.trim();
    final confirmPassword = confirmpasswordController.text.trim();

    FocusScope.of(context).unfocus(); // Dismiss keyboard if open

    // Password validation
    if (newPassword.isEmpty) {
      passwordMessage('Password cannot be empty');
      return;
    }
    if (newPassword != confirmPassword) {
      passwordMessage('Passwords do not match');
      return;
    }
    if (newPassword.length < 6) {
      passwordMessage('Password must be at least 6 characters long');
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(newPassword)) {
      passwordMessage('Password must contain at least one uppercase letter');
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      await profileService.updatePassword(newPassword);
      if (!mounted) return;
      passwordMessage('Password changed successfully');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      passwordMessage('Password change failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void passwordMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    newpasswordController.dispose();
    confirmpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final appColourScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Color(
        0xFFf0f0f0,
      ), //appColourScheme.surfaceContainerHighest,
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Reset Password',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newpasswordController,
              obscureText: obscureNewPasswordText,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock_outline),
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
            const SizedBox(height: 20),
            TextField(
              controller: confirmpasswordController,
              obscureText: obscureConfirmPasswordText,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (!isLoading) {
                  changePassword();
                }
              },
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline),
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
            // Buttons
            FilledButton(
              onPressed: isLoading ? null : changePassword,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Change Password'),
              ),
            ),
            const SizedBox(height: 10),
            //cancel button
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
