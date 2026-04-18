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
    with TickerProviderStateMixin {

  late AnimationController _mainCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _textCtrl;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _pulse;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: TColors.primary,
    ));

    // Logo animation
    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoFade = CurvedAnimation(
      parent: _mainCtrl, curve: Curves.easeIn);
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl, curve: Curves.easeOutBack));

    // Pulse animation
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseCtrl, curve: Curves.easeInOut));

    // Text slide up animation
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textFade = CurvedAnimation(
      parent: _textCtrl, curve: Curves.easeIn);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textCtrl, curve: Curves.easeOut));

    // Sequence: logo first, then text
    _mainCtrl.forward().then((_) => _textCtrl.forward());

    // Navigate after 4s
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) => const LoginScreen(),
          transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFC1272D),
              Color(0xFFE53935),
              Color(0xFFB71C1C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(children: [

          // ── Background circles decoration ──────────────
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white
                  .withValues(alpha: 0.05)),
            )),
          Positioned(
            bottom: -80, left: -40,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white
                  .withValues(alpha: 0.04)),
            )),
          Positioned(
            top: size.height * 0.3, left: -30,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white
                  .withValues(alpha: 0.04)),
            )),

          // ── Main content ───────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // ── Hero Logo ─────────────────────────────
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: ScaleTransition(
                      scale: _pulse,
                      child: _buildHeroLogo(),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // ── Text block ────────────────────────────
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(children: [

                      // T HERO
                      const Text(
                        'T HERO',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 10,
                          fontFamily: 'Poppins',
                        )),

                      const SizedBox(height: 6),

                      // Divider
                      Row(
                        mainAxisAlignment:
                          MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30, height: 1.5,
                            color: Colors.white
                              .withValues(alpha: 0.4)),
                          const SizedBox(width: 10),
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white
                                .withValues(alpha: 0.6))),
                          const SizedBox(width: 10),
                          Container(
                            width: 30, height: 1.5,
                            color: Colors.white
                              .withValues(alpha: 0.4)),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Tagline
                      Text(
                        'SMART CITY GUARDIAN',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white
                            .withValues(alpha: 0.7),
                          letterSpacing: 4,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        )),

                      const SizedBox(height: 24),

                      // Encouragement phrase
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 32),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white
                            .withValues(alpha: 0.12),
                          borderRadius:
                            BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white
                              .withValues(alpha: 0.2))),
                        child: Column(children: [
                          const Text(
                            '🦸 Sois le Héros de ta Ville !',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            )),
                          const SizedBox(height: 6),
                          Text(
                            'Signalez, agissez, transformez\nla Tunisie ensemble 🇹🇳',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white
                                .withValues(alpha: 0.85),
                              fontFamily: 'Poppins',
                              height: 1.5,
                            )),
                        ]),
                      ),

                      const SizedBox(height: 8),

                      // Arabic
                      Text(
                        'كن بطل مدينتك',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white
                            .withValues(alpha: 0.6),
                          letterSpacing: 1,
                        )),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom loading bar ─────────────────────────
          Positioned(
            bottom: 48,
            left: 0, right: 0,
            child: FadeTransition(
              opacity: _textFade,
              child: Column(children: [
                Text(
                  'Chargement...',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white
                      .withValues(alpha: 0.4),
                    fontFamily: 'Poppins',
                    letterSpacing: 1,
                  )),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white
                        .withValues(alpha: 0.15),
                      valueColor:
                        const AlwaysStoppedAnimation(
                          Colors.white),
                      minHeight: 3,
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeroLogo() {
    return SizedBox(
      width: 160, height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [

          // Outer glow ring
          Container(
            width: 160, height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1)),
          ),

          // Middle ring
          Container(
            width: 128, height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1)),
          ),

          // Inner white circle
          Container(
            width: 92, height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8)),
              ]),
            child: const Center(
              child: Text('T',
                style: TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.w800,
                  color: TColors.primary,
                  height: 1.1,
                  fontFamily: 'Poppins',
                ))),
          ),

          // Star badge top right
          Positioned(
            top: 10, right: 12,
            child: Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle),
              child: const Center(
                child: Text('⭐',
                  style: TextStyle(fontSize: 14))),
            ),
          ),

          // Shield badge bottom left
          Positioned(
            bottom: 12, left: 14,
            child: Container(
              width: 26, height: 26,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle),
              child: const Center(
                child: Text('🛡️',
                  style: TextStyle(fontSize: 12))),
            ),
          ),

          // Tunisia flag bottom right
          Positioned(
            bottom: 12, right: 14,
            child: Container(
              width: 26, height: 26,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle),
              child: const Center(
                child: Text('🇹🇳',
                  style: TextStyle(fontSize: 12))),
            ),
          ),
        ],
      ),
    );
  }
}