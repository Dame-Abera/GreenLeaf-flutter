import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/auth_provider.dart';
import '../presentation/admin_dashboard_page.dart';

class LoginPage extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    if (authState.user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (authState.user!.isAdmin) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardPage()));
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/greenleaf_bg.jpg'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/greenleaf_bg.jpg',
                height: 100,
                width: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Log in', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.green[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline),
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.green[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot Password?', style: TextStyle(color: Colors.teal)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: authState.isLoading
                          ? null
                          : () {
                              authNotifier.login(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                            },
                      child: authState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Login', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text('Sign Up', style: TextStyle(color: Colors.teal)),
                      ),
                    ],
                  ),
                  if (authState.failure != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        authState.failure!.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 