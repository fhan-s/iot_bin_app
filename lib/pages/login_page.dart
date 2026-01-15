import 'package:flutter/material.dart';
import 'package:iot_bin_app/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void attemptLogin() async {
    // Get email and password from text fields
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    try {
      await authService.signInWithEmailPassword(email, password);
      print(
        "Email: ${_emailController.text}, Password: ${_passwordController.text}",
      );
    } catch (e) {
      // Handle login error
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Login Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true, // Hide password input
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                attemptLogin();
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
