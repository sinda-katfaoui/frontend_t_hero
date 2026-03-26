// ============================================================
// SplashScreen — T Hero App Entry Point
// ============================================================
// First screen shown when app launches.
// Full red background with logo + fade/scale animation.
// Navigates to LoginScreen after 4 seconds.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_t_hero/screens/auth/login_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    // Full red status bar + nav bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: TColors.primary,
    ));

    // Animation: 1.6s fade + scale in
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    _scale = Tween<double>(begin: 0.80, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );

    // Start animation immediately
    _ctrl.forward();

    // Navigate after 4 seconds — direct call, no postFrameCallback
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) =>
                  FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColors.primary,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // ── Logo ──────────────────────────────────
                _buildLogo(),

                const SizedBox(height: 32),

                // ── App name ──────────────────────────────
                const Text(
                  'T HERO',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 8,
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 8),

                // Thin divider
                Container(
                  width: 24, height: 1.5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),

                const SizedBox(height: 10),

                // Arabic subtitle
                Text(
                  'بطل تونس',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 6),

                // Tagline
                Text(
                  'SMART CITY GUARDIAN',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.35),
                    letterSpacing: 3,
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 48),

                // Progress dots
                _buildProgressDots(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Logo Widget ────────────────────────────────────────────
  Widget _buildLogo() {
    return SizedBox(
      width: 160, height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [

          // Outer ring
          Container(
            width: 160, height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),

          // Middle ring
          Container(
            width: 128, height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),

          // Inner white circle with T
          Container(
            width: 90, height: 90,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Center(
              child: Text(
                'T',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  color: TColors.primary,
                  height: 1.1,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),

          // Left cape
          Positioned(
            bottom: 8, left: 20,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                width: 24, height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: const BorderRadius.only(
                    topLeft:     Radius.circular(10),
                    bottomLeft:  Radius.circular(18),
                    bottomRight: Radius.circular(5),
                  ),
                ),
              ),
            ),
          ),

          // Right cape
          Positioned(
            bottom: 8, right: 20,
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                width: 24, height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: const BorderRadius.only(
                    topRight:    Radius.circular(10),
                    bottomRight: Radius.circular(18),
                    bottomLeft:  Radius.circular(5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress Dots ──────────────────────────────────────────
  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 22, height: 4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Container(
          width: 6, height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Container(
          width: 6, height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}