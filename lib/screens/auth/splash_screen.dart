// ============================================================
// SplashScreen — T Hero App Entry Point
// ============================================================
// This is the first screen the user sees when opening the app.
// It displays the T Hero brand logo with a smooth fade + scale
// animation, then automatically navigates to LoginScreen after
// 3 seconds using a fade page transition.
//
// Design decisions:
// - Full red background (light) / full black (dark) — brand immersive
// - Logo uses concentric circles + cape shapes = hero identity
// - AnimationController runs once on init, disposed on exit
// - Navigator.pushReplacement so user can't go back to splash
// - mounted check before navigation prevents memory leaks
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

  // Animation controller drives both fade and scale animations
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    // Make status bar transparent so red fills the entire screen
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // Animation runs for 1.4s — fast enough to feel snappy
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Fade: content appears smoothly from transparent to opaque
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    // Scale: content grows from 85% to 100% with a springy overshoot
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );

    // Start animation immediately on screen load
    _ctrl.forward();

    // After 3s, navigate to login with a smooth fade transition
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return; // Safety check — widget might be gone
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) =>
                  FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    // Always dispose AnimationController to prevent memory leaks
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Full brand color background — red in light, black in dark
      backgroundColor: isDark ? TColors.black : TColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Hero logo — circle + cape silhouette
                _buildLogo(),

                const SizedBox(height: 28),

                // App name — bold, wide letter spacing for impact
                const Text(
                  'T HERO',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 7,
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 6),

                // Thin divider line — visual breathing room
                Container(
                  width: 20,
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.25),
                ),

                const SizedBox(height: 8),

                // Arabic subtitle — بطل تونس = Hero of Tunisia
                Text(
                  'بطل تونس',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.75),
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 20),

                // Progress indicator — shows app is loading
                _buildProgressDots(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Logo Widget ──────────────────────────────────────────
  // Three concentric circles create a glow/depth effect.
  // The white inner circle holds the bold "T" letter.
  // Two rotated rectangles act as hero cape panels below.
  Widget _buildLogo() {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [

          // Outer glow ring — very subtle, 5% opacity
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),

          // Middle ring — slightly more visible, 10% opacity
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),

          // Main white circle — the actual logo background
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Center(
              child: Text(
                'T',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  color: TColors.primary,
                  height: 1.1,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),

          // Left cape panel — rotated slightly inward
          Positioned(
            bottom: 6,
            left: 22,
            child: Transform.rotate(
              angle: 0.2, // ~11 degrees
              child: Container(
                width: 22,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: const BorderRadius.only(
                    topLeft:    Radius.circular(10),
                    bottomLeft: Radius.circular(16),
                    bottomRight:Radius.circular(5),
                  ),
                ),
              ),
            ),
          ),

          // Right cape panel — mirror of left
          Positioned(
            bottom: 6,
            right: 22,
            child: Transform.rotate(
              angle: -0.2, // ~-11 degrees
              child: Container(
                width: 22,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: const BorderRadius.only(
                    topRight:    Radius.circular(10),
                    bottomRight: Radius.circular(16),
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

  // ── Progress Dots ────────────────────────────────────────
  // Three pill shapes — first one wider to indicate progress.
  // Gives the user a visual cue that the app is loading.
  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Active dot — wider pill in white
        Container(
          width: 18,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        // Inactive dot 1
        Container(
          width: 5,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        // Inactive dot 2
        Container(
          width: 5,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}