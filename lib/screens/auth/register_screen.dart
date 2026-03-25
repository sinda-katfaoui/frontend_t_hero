// ============================================================
// RegisterScreen — T Hero Account Creation
// ============================================================
// Allows new users to create an account with one of 3 roles:
//   - Citoyen    → basic fields only (nom, email, password)
//   - Agent      → + code_Agent field (provided by admin)
//   - Admin      → + code_Admin field (secret admin code)
//
// Design decisions:
// - Red curved header matches LoginScreen for visual consistency
// - Animated role selector tabs — selected tab slides white card
// - Code field appears/disappears with animation based on role
// - No scrolling — everything fits in one screen
// - Form validates all fields before submitting
// - On success: pops back to login + shows success snackbar
//
// TODO: Connect to real API endpoints:
//   - Citoyen → POST /users/CreateUser
//   - Agent   → POST /users/CreateAgent
//   - Admin   → POST /users/CreateUserAdmin
// ============================================================

import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  // Form key for validating all fields at once on submit
  final _formKey  = GlobalKey<FormState>();

  // Text controllers for each input field
  final _nomCtrl  = TextEditingController();
  final _emailCtrl= TextEditingController();
  final _passCtrl = TextEditingController();
  final _codeCtrl = TextEditingController(); // Only used for Agent/Admin

  // Password visibility toggle — starts hidden for security
  bool _obscure = true;

  // Selected role index: 0=Citoyen, 1=Agent, 2=Admin
  int _role = 0;

  // Role labels displayed in the tab selector
  final _roles = ['Citoyen', 'Agent', 'Admin'];

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  // ── Submit Handler ─────────────────────────────────────────
  // Validates form then shows success and goes back to login.
  // TODO: Replace with real API call based on _role value.
  void _register() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Compte créé avec succès ✓',
          style: TextStyle(
            fontSize: 12, fontFamily: 'Poppins')),
        backgroundColor: TColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.light,
      body: SingleChildScrollView(
        // SingleChildScrollView only for keyboard avoidance
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Red Header ───────────────────────────────
              _buildHeader(isDark),

              // ── Form Fields ──────────────────────────────
              _buildForm(isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header Widget ──────────────────────────────────────────
  // Red background with back button, title, and role selector.
  // Role selector is inside the header for a premium look.
  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        color: TColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 52, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Back button — white arrow on red background
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Screen title
          const Text('Créer un compte',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Poppins',
            )),

          const SizedBox(height: 3),

          Text('Choisissez votre rôle',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.6),
              fontFamily: 'Poppins',
            )),

          const SizedBox(height: 14),

          // ── Role Selector Tabs ────────────────────────
          // Three animated tabs — active tab has white background.
          // Tapping changes _role and shows/hides code field below.
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: List.generate(3, (i) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _role = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      // Active: white card | Inactive: transparent
                      color: _role == i
                        ? Colors.white
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(_roles[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Poppins',
                        fontWeight: _role == i
                          ? FontWeight.w600 : FontWeight.w400,
                        // Active: red text | Inactive: white faded
                        color: _role == i
                          ? TColors.primary
                          : Colors.white.withValues(alpha: 0.65),
                      )),
                  ),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }

  // ── Form Widget ────────────────────────────────────────────
  // Compact input fields + submit + login link.
  // Code field appears only for Agent (1) and Admin (2) roles.
  Widget _buildForm(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // Full name field
          _inputField(
            controller: _nomCtrl,
            hint: 'Nom complet',
            icon: Icons.person_outline,
            isDark: isDark,
            validator: (v) => v!.isEmpty ? 'Requis' : null,
          ),

          const SizedBox(height: 7),

          // Email field
          _inputField(
            controller: _emailCtrl,
            hint: 'Email',
            icon: Icons.email_outlined,
            isDark: isDark,
            keyboard: TextInputType.emailAddress,
            validator: (v) => v!.isEmpty ? 'Requis' : null,
          ),

          const SizedBox(height: 7),

          // Password field with toggle visibility
          _passwordField(isDark),

          // Code field — only visible for Agent or Admin role
          // AnimatedSize smoothly expands/collapses the field
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _role == 1 || _role == 2
              ? Column(children: [
                  const SizedBox(height: 7),
                  _codeField(isDark),
                ])
              : const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          // Register button
          SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('S\'inscrire',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                )),
            ),
          ),

          const SizedBox(height: 12),

          // Already have account — link back to login
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: RichText(
                text: TextSpan(
                  text: 'Déjà un compte? ',
                  style: const TextStyle(
                    fontSize: 10,
                    color: TColors.textHint,
                    fontFamily: 'Poppins',
                  ),
                  children: [
                    TextSpan(
                      text: 'Se connecter',
                      style: TextStyle(
                        color: TColors.primary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Reusable Input Field ───────────────────────────────────
  // Clean card-style container wrapping a bare TextFormField.
  // Removes default Flutter input decoration for custom look.
  Widget _inputField({
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
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: TColors.textHint),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboard,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? TColors.textWhite : TColors.textPrimary,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 10, color: TColors.textHint,
                fontFamily: 'Poppins'),
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

  // ── Password Field ─────────────────────────────────────────
  // Same card-style as _inputField but with visibility toggle.
  Widget _passwordField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.darkContainer : TColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(children: [
        const Icon(Icons.lock_outline, size: 14, color: TColors.textHint),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: _passCtrl,
            obscureText: _obscure,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? TColors.textWhite : TColors.textPrimary,
              fontFamily: 'Poppins',
            ),
            decoration: const InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(
                fontSize: 10, color: TColors.textHint,
                fontFamily: 'Poppins'),
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
        GestureDetector(
          onTap: () => setState(() => _obscure = !_obscure),
          child: Icon(
            _obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
            size: 14, color: TColors.textHint),
        ),
      ]),
    );
  }

  // ── Code Field ─────────────────────────────────────────────
  // Shown only for Agent and Admin roles.
  // Has a red tinted background to signal it's special/required.
  // The label changes based on selected role.
  Widget _codeField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        // Red tint signals this is a privileged field
        color: TColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.primary, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(children: [
        const Icon(Icons.shield_outlined,
          size: 14, color: TColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 10,
              color: TColors.primary,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              // Label changes based on which role is selected
              hintText: _role == 1
                ? 'Code Agent (fourni par l\'admin)'
                : 'Code Admin (accès restreint)',
              hintStyle: const TextStyle(
                fontSize: 10, color: TColors.primary,
                fontFamily: 'Poppins'),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            validator: (v) =>
              v!.isEmpty ? 'Code requis' : null,
          ),
        ),
      ]),
    );
  }
}