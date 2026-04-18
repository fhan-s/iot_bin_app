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
    // email and password text fields
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    FocusScope.of(context).unfocus(); // Dismiss keyboard on login attempt
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      await authService.signInWithEmailPassword(email, password);
    } catch (e) {
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // SingleChildScrollView makes the page scrollable to avoid overflow when keyboard is open
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Center(
                child: Column(
                  children: [
                    Text(
                      'BinSense',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/icons/app_icon.jpg'),
                      backgroundColor: Colors.transparent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Text(
                'Login',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please notify administrators to reset your password.',
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      // Remove splash effect on press
                      overlayColor: const Color.fromARGB(0, 0, 0, 0),
                    ),
                    child: const Text('Forgot Password?'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                    : const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
