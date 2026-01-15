import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  void attemptLogin() {
    try {
      print(
        "Email: ${_emailController.text}, Password: ${_passwordController.text}",
      );
      // authService.signInWithEmailPassword(
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
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
