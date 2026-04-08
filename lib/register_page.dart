import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api-tcg-backend.vercel.app/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": _usernameController.text,
          "email": _emailController.text,
          "password_hash": _passwordController.text,
          "confirm_password": _confirmPasswordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🎉 Registration successful! Welcome to the gym!',
              style: TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration failed: ${response.body}',
              style: const TextStyle(fontSize: 16),
            ),
            backgroundColor: const Color(0xFFE3350D),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred: $e',
            style: const TextStyle(fontSize: 16),
          ),
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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText ?? false,
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
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF3B4CCA),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Icon(icon, color: const Color(0xFF3B4CCA), size: 32),
          ),
          suffixIcon: isPassword
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    icon: Icon(
                      obscureText! ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFFE3350D),
                      size: 32,
                    ),
                    onPressed: onToggleVisibility,
                  ),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Color(0xFF3B4CCA), width: 5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Color(0xFF3B4CCA), width: 5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Color(0xFFE3350D), width: 5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Colors.red, width: 5),
          ),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Animated Glowing Container
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
                              0xFF3B4CCA,
                            ).withOpacity(0.6), // Glowing Blue
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1,
                        size: 90,
                        color: Color(0xFFE3350D), // Pokemon Red
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                const Text(
                  'NEW TRAINER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
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
                _buildTextField(
                  controller: _usernameController,
                  label: 'Trainer Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Name missing!';
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email missing!';
                    if (!value.contains('@')) return 'Enter a valid email!';
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Secret Password',
                  icon: Icons.lock,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onToggleVisibility: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Password missing!';
                    if (value.length < 6) return 'Minimum 6 characters!';
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Confirm it!';
                    if (value != _passwordController.text)
                      return 'Passwords mismatch!';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF3B4CCA,
                    ), // Pokemon Blue for Register
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
                          'REGISTER!',
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
                  onPressed: () => context.pop(),
                  child: const Text(
                    "Already a Trainer? Login!",
                    style: TextStyle(
                      color: Color(0xFFFFCC00),
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
