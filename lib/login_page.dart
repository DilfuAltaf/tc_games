import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'user');
  final _passwordController = TextEditingController(text: '1234567890');

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api-tcg-backend.vercel.app/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": _usernameController.text,
          "password": _passwordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🎉 Login Successful! Ready to battle!',
              style: TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Oh no! Login failed: ${response.body}',
              style: const TextStyle(fontSize: 16),
            ),
            backgroundColor: const Color(0xFFE3350D), // Pokemon Red
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: $e'),
          backgroundColor: const Color(0xFFE3350D),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Keeps consistent dark theme
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fun bouncy Pokeball Container for Kids
                Center(
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.elasticOut,
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFFCC00,
                            ).withOpacity(0.6), // Glowing Yellow
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.catching_pokemon,
                        size: 90,
                        color: Color(0xFFE3350D), // Pokemon Red
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                const Text(
                  'TRAINER LOGIN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900, // Very chunk attractive font
                    color: Color(0xFFFFCC00), // Pokemon Yellow
                    letterSpacing: 3,
                    shadows: [
                      Shadow(
                        color: Color(0xFF3B4CCA), // Pokemon Blue
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Kid-friendly chunky textfields
                TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 24,
                    ),
                    labelText: 'Trainer Name',
                    labelStyle: const TextStyle(
                      color: Color(0xFF3B4CCA),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF3B4CCA),
                        size: 36,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: Color(0xFF3B4CCA),
                        width: 5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: Color(0xFF3B4CCA),
                        width: 5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: Color(0xFFE3350D),
                        width: 5,
                      ),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Name missing!' : null,
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 24,
                    ),
                    labelText: 'Secret Password',
                    labelStyle: const TextStyle(
                      color: Color(0xFF3B4CCA),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(
                        Icons.lock,
                        color: Color(0xFF3B4CCA),
                        size: 32,
                      ),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFFE3350D),
                          size: 32,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: Color(0xFF3B4CCA),
                        width: 5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: Color(0xFF3B4CCA),
                        width: 5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: Color(0xFFE3350D),
                        width: 5,
                      ),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Password missing!' : null,
                ),
                const SizedBox(height: 48),

                // Huge "GO" Button which kids love pressing
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE3350D), // Pokemon Red
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.white, width: 4),
                    ),
                    elevation: 10,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'GO!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 32),

                TextButton(
                  onPressed: () => context.push('/register'),
                  child: const Text(
                    "New Trainer? Register here!",
                    style: TextStyle(
                      color: Color(0xFFFFCC00), // Pokemon Yellow
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFFFFCC00),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
