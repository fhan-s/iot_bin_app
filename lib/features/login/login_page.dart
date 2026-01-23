import 'package:flutter/material.dart';
import 'package:iot_bin_app/features/authentication/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool obscurePasswordText = true;

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bin IoT App',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Login',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: obscurePasswordText,
              decoration: InputDecoration(
                labelText: 'Password',
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
            const SizedBox(height: 20),
            //
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    attemptLogin();
                  },
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
            //
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
