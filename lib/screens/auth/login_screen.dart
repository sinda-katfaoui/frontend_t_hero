// ============================================================
// LoginScreen — T Hero Authentication
// ============================================================
// Entry point after the splash screen. Handles user login for
// all 3 roles: Citoyen, Agent Municipal, and Administrateur.
//
// Role routing logic (temporary — replace with real API later):
//   - email contains 'admin' → AdminHomeScreen
//   - email contains 'agent' → AgentHomeScreen
//   - anything else          → CitoyenHomeScreen
//
// Design decisions:
// - Red curved header with branding at the top (immersive)
// - White card inputs on light gray background below
// - No scrolling — everything fits in one screen
// - Loading spinner replaces button text during login
// - SingleChildScrollView only for keyboard avoidance
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_t_hero/screens/auth/register_screen.dart';
import 'package:frontend_t_hero/screens/citoyen/citoyen_home_screen.dart';
import 'package:frontend_t_hero/screens/agent/agent_home_screen.dart';
import 'package:frontend_t_hero/screens/admin/admin_home_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // Form key used to trigger validation on all fields at once
  final _formKey   = GlobalKey<FormState>();

  // Controllers to read email and password values on submit
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  // Toggle password visibility — starts hidden
  bool _obscure  = true;

  // Prevents double-tap and shows loading spinner during login
  bool _loading  = false;

  @override
  void initState() {
    super.initState();
    // Make status bar icons dark on light header background
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    // Always dispose controllers to free memory
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Login Handler ──────────────────────────────────────────
  // Validates form, simulates API call, then routes by role.
  // TODO: Replace Future.delayed with real API call to
  // POST /users/login and use token + role from response.
  void _login() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _loading = false);

      final email = _emailCtrl.text.trim().toLowerCase();

      // Route to the correct dashboard based on email keyword
      Widget screen;
      if (email.contains('admin')) {
        screen = const AdminHomeScreen();
      } else if (email.contains('agent')) {
        screen = const AgentHomeScreen();
      } else {
        screen = const CitoyenHomeScreen();
      }

      // Replace login screen so user can't go back to it
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.light,
      // SingleChildScrollView only to handle keyboard pushing content up
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Red Header Section ───────────────────────
              // Contains branding and welcome message.
              // Curved bottom radius gives a modern layered look.
              _buildHeader(isDark),

              // ── Form Section ─────────────────────────────
              // Email, password, forgot password, login button,
              // divider, and register link — all compact.
              _buildForm(isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header Widget ──────────────────────────────────────────
  // Red background with T Hero logo + welcome text.
  // Curved bottom (28px radius) creates visual depth.
  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        color: TColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 56, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Mini logo row — icon + app name + Arabic subtitle
          Row(children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('T',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  )),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('T HERO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontFamily: 'Poppins',
                  )),
                Text('بطل تونس',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white.withValues(alpha: 0.6),
                  )),
              ],
            ),
          ]),

          const SizedBox(height: 16),

          // Welcome message
          const Text('Bon retour 👋',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Poppins',
            )),

          const SizedBox(height: 3),

          Text('Connectez-vous pour continuer',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.6),
              fontFamily: 'Poppins',
            )),
        ],
      ),
    );
  }

  // ── Form Widget ────────────────────────────────────────────
  // Compact form with email, password, forgot link,
  // login button, divider, and register button.
  Widget _buildForm(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // Email field
          _buildInputField(
            controller: _emailCtrl,
            hint: 'votre@email.com',
            icon: Icons.email_outlined,
            isDark: isDark,
            keyboard: TextInputType.emailAddress,
            validator: (v) => v!.isEmpty ? 'Email requis' : null,
          ),

          const SizedBox(height: 8),

          // Password field with visibility toggle
          Container(
            decoration: BoxDecoration(
              color: isDark ? TColors.darkContainer : TColors.cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TColors.borderLight, width: 0.5),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 2),
            child: Row(children: [
              Icon(Icons.lock_outline,
                size: 14, color: TColors.textHint),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? TColors.textWhite : TColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: const TextStyle(
                      fontSize: 10, color: TColors.textHint),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (v) =>
                    v!.length < 6 ? 'Min 6 caractères' : null,
                ),
              ),
              // Visibility toggle icon
              GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                  size: 14, color: TColors.textHint),
              ),
            ]),
          ),

          // Forgot password — right aligned, minimal
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 0, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Mot de passe oublié?',
                style: TextStyle(
                  fontSize: 9,
                  color: TColors.primary,
                  fontFamily: 'Poppins',
                )),
            ),
          ),

          const SizedBox(height: 8),

          // Login button — shows spinner while loading
          SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: _loading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _loading
                ? const SizedBox(
                    height: 18, width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                : const Text('Se connecter',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    )),
            ),
          ),

          const SizedBox(height: 12),

          // Divider with 'ou' text
          Row(children: [
            Expanded(child: Divider(
              color: TColors.borderLight, thickness: 0.5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('ou',
                style: TextStyle(
                  fontSize: 9, color: TColors.textHint,
                  fontFamily: 'Poppins'))),
            Expanded(child: Divider(
              color: TColors.borderLight, thickness: 0.5)),
          ]),

          const SizedBox(height: 12),

          // Register button — outlined, secondary action
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: () => Navigator.push(context,
                MaterialPageRoute(
                  builder: (context) => const RegisterScreen())),
              style: OutlinedButton.styleFrom(
                foregroundColor: TColors.textPrimary,
                side: BorderSide(
                  color: isDark
                    ? TColors.borderDark
                    : TColors.borderLight,
                  width: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Créer un compte',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                    ? TColors.textWhite : TColors.textPrimary,
                  fontFamily: 'Poppins',
                )),
            ),
          ),

          const SizedBox(height: 14),

          // Role hint — tells user which emails route to which role
          Center(
            child: Text('Citoyen · Agent · Admin',
              style: TextStyle(
                fontSize: 9,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              ))),
        ],
      ),
    );
  }

  // ── Reusable Input Field ───────────────────────────────────
  // Used for email (and any future plain text fields).
  // Password has its own widget above due to visibility toggle.
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.darkContainer : TColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12, vertical: 2),
      child: Row(children: [
        Icon(icon, size: 14, color: TColors.textHint),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboard,
            style: TextStyle(
              fontSize: 10,
              color: isDark
                ? TColors.textWhite : TColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 10, color: TColors.textHint),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            validator: validator,
          ),
        ),
      ]),
    );
  }
}