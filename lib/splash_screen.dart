import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Initial 3 second timer for navigation
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark premium background
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF2C2C2C), Color(0xFF121212)],
                center: Alignment.center,
                radius: 1.0,
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Top Red Half
                        Positioned(
                          top: 0,
                          child: Container(
                            width: 150,
                            height: 75,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE3350D), // Pokemon Red
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(75),
                                topRight: Radius.circular(75),
                              ),
                            ),
                          ),
                        ),
                        // Bottom White Half
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: 150,
                            height: 75,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(75),
                                bottomRight: Radius.circular(75),
                              ),
                            ),
                          ),
                        ),
                        // Black divider
                        Container(
                          width: 150,
                          height: 12,
                          color: const Color(0xFF232323),
                        ),
                        // Outer middle circle
                        Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                            color: Color(0xFF232323),
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Inner middle circle
                        Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF232323),
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'POKÉMON',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: Color(0xFFFFCC00), // Pokemon Yellow
                          shadows: [
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 3.0,
                              color: Color(0xFF3B4CCA), // Pokemon Blue Base
                            ),
                            Shadow(
                              offset: Offset(-2.0, -2.0),
                              blurRadius: 3.0,
                              color: Color(0xFF3B4CCA),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3350D),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'TRADING CARD GAME',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
