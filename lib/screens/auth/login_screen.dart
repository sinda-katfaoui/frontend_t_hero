// login_screen.dart
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
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;
  bool _loading    = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _loading = false);
      final email = _emailCtrl.text.trim().toLowerCase();
      Widget screen;
      if (email.contains('admin')) screen = const AdminHomeScreen();
      else if (email.contains('agent')) screen = const AgentHomeScreen();
      else screen = const CitoyenHomeScreen();
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => screen));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size   = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.light,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // ── Red header — compact 30% ──────────────────
              Container(
                height: size.height * 0.30,
                decoration: const BoxDecoration(
                  color: TColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft:  Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text('T', style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700,
                            color: Colors.white, fontFamily: 'Poppins',
                          )),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('T HERO', style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: Colors.white, letterSpacing: 2,
                            fontFamily: 'Poppins',
                          )),
                          Text('بطل تونس', style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.7),
                          )),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 16),
                    const Text('Bon retour 👋', style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w700,
                      color: Colors.white, fontFamily: 'Poppins',
                    )),
                    const SizedBox(height: 4),
                    Text('Connectez-vous pour continuer',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.75),
                        fontFamily: 'Poppins',
                      )),
                  ],
                ),
              ),

              // ── Form — fills remaining 70% ────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      // Fields group
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                          // Email field
                          _fieldBox(
                            child: Row(children: [
                              const Icon(Icons.email_outlined,
                                size: 22, color: TColors.textHint),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark
                                      ? TColors.textWhite
                                      : TColors.textPrimary,
                                    fontFamily: 'Poppins',
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'votre@email.com',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      color: TColors.textHint,
                                      fontFamily: 'Poppins'),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 14),
                                  ),
                                  validator: (v) =>
                                    v!.isEmpty ? 'Email requis' : null,
                                ),
                              ),
                            ]),
                            isDark: isDark,
                            hasRedBorder: false,
                          ),

                          const SizedBox(height: 16),

                          // Password field — RED border
                          _fieldBox(
                            child: Row(children: [
                              Icon(Icons.lock_outline,
                                size: 22, color: TColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _passCtrl,
                                  obscureText: _obscure,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark
                                      ? TColors.textWhite
                                      : TColors.textPrimary,
                                    fontFamily: 'Poppins',
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: '••••••••',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      color: TColors.textHint,
                                      fontFamily: 'Poppins'),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 14),
                                  ),
                                  validator: (v) =>
                                    v!.length < 6
                                      ? 'Min 6 caractères' : null,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                  setState(() => _obscure = !_obscure),
                                child: Icon(
                                  _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                  size: 22, color: TColors.primary),
                              ),
                            ]),
                            isDark: isDark,
                            hasRedBorder: true,
                          ),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Mot de passe oublié?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: TColors.primary,
                                  fontFamily: 'Poppins',
                                )),
                            ),
                          ),
                        ],
                      ),

                      // Buttons group
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                          // Se connecter
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                    BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: _loading
                                ? const SizedBox(
                                    height: 22, width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2))
                                : const Text('Se connecter',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                    )),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ou divider
                          Row(children: [
                            Expanded(child: Divider(
                              color: TColors.borderLight,
                              thickness: 0.5)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14),
                              child: Text('ou', style: TextStyle(
                                fontSize: 14,
                                color: TColors.textHint,
                                fontFamily: 'Poppins'))),
                            Expanded(child: Divider(
                              color: TColors.borderLight,
                              thickness: 0.5)),
                          ]),

                          const SizedBox(height: 16),

                          // Créer un compte
                          SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () => Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                    const RegisterScreen())),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark
                                  ? TColors.textWhite
                                  : TColors.textPrimary,
                                side: BorderSide(
                                  color: isDark
                                    ? TColors.borderDark
                                    : TColors.borderLight,
                                  width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                    BorderRadius.circular(16)),
                              ),
                              child: Text('Créer un compte',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                  color: isDark
                                    ? TColors.textWhite
                                    : TColors.textPrimary,
                                )),
                            ),
                          ),
                        ],
                      ),

                      // Role hint
                      Center(
                        child: Text('Citoyen · Agent · Admin',
                          style: TextStyle(
                            fontSize: 12,
                            color: TColors.textHint,
                            fontFamily: 'Poppins',
                          ))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Reusable field box ─────────────────────────────────────
  Widget _fieldBox({
    required Widget child,
    required bool isDark,
    required bool hasRedBorder,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.darkContainer : TColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasRedBorder ? TColors.primary : TColors.borderLight,
          width: hasRedBorder ? 1.5 : 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: child,
    );
  }
}