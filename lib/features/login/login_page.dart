import 'package:flutter/material.dart';
import 'package:iot_bin_app/features/authentication/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePasswordText = true;
  bool isLoading = false;

  void attemptLogin() async {
    // Get email and password from text fields
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      await authService.signInWithEmailPassword(email, password);
      debugPrint(
        "Email: ${emailController.text}, Password: ${passwordController.text}",
      );
    } catch (e) {
      // Handle login error
      debugPrint("Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colourScheme.surfaceContainerHighest,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bin IoT App',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Icon(
              Icons.image_search,
              size: 100,
              color: const Color.fromARGB(255, 73, 170, 77),
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
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              onSubmitted: (value) => attemptLogin(),
              obscureText: obscurePasswordText,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
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
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     TextButton(
            //       onPressed: () {
            //         // attemptLogin();
            //       },
            //       child: const Text('Forgot Password?'),
            //     ),
            //   ],
            // ),
            // Login button
            FilledButton(
              onPressed: isLoading ? null : attemptLogin,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Login'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
