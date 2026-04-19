import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_t_hero/screens/auth/register_screen.dart';
import 'package:frontend_t_hero/screens/citoyen/citoyen_home_screen.dart';
import 'package:frontend_t_hero/screens/agent/agent_home_screen.dart';
import 'package:frontend_t_hero/screens/admin/admin_home_screen.dart';
import 'package:frontend_t_hero/services/auth_service.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;
  bool _loading    = false;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final result = await AuthService.login(
      _emailCtrl.text, _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result['success']) {
      final user = result['user'] as Map<String, dynamic>;
      final role = user['role'] as String;
      Widget screen;
      switch (role) {
        case 'ADMIN':           screen = const AdminHomeScreen();  break;
        case 'AGENT_MUNICIPAL': screen = const AgentHomeScreen();  break;
        default:                screen = const CitoyenHomeScreen();
      }
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => screen));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          result['message'] ?? 'Erreur de connexion',
          style: const TextStyle(
            fontSize: 13, fontFamily: 'Poppins')),
        backgroundColor: TColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size   = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDark
        ? TColors.dark : const Color(0xFFEEEEEE),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(children: [

            // ── Gradient Header ───────────────────────────
            Container(
              height: size.height * 0.38,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFC1272D),
                    Color(0xFFE53935),
                    Color(0xFFB71C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Stack(children: [
                Positioned(
                  top: -30, right: -30,
                  child: Container(
                    width: 150, height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                        .withValues(alpha: 0.05)))),
                Positioned(
                  bottom: 10, left: -20,
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                        .withValues(alpha: 0.05)))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24, 20, 24, 28),
                  child: Column(
                    mainAxisAlignment:
                      MainAxisAlignment.end,
                    crossAxisAlignment:
                      CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                              BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                  .withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3)),
                            ]),
                          child: const Center(
                            child: Text('T',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: TColors.primary,
                                fontFamily: 'Poppins',
                              ))),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment:
                            CrossAxisAlignment.start,
                          children: [
                            const Text('T HERO',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 3,
                                fontFamily: 'Poppins',
                              )),
                            Text('Smart City Guardian',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white
                                  .withValues(alpha: 0.7),
                                fontFamily: 'Poppins',
                              )),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white
                              .withValues(alpha: 0.2),
                            borderRadius:
                              BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white
                                .withValues(alpha: 0.3))),
                          child: const Text('🇹🇳 Tunisie',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ))),
                      ]),
                      const SizedBox(height: 20),
                      const Text('Bon retour 👋',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        )),
                      const SizedBox(height: 4),
                      Text(
                        'Connectez-vous pour continuer\nà protéger votre ville',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white
                            .withValues(alpha: 0.8),
                          fontFamily: 'Poppins',
                          height: 1.5,
                        )),
                      const SizedBox(height: 16),
                      Row(children: [
                        _roleBadge('👤 Citoyen'),
                        const SizedBox(width: 8),
                        _roleBadge('🦸 Agent'),
                        const SizedBox(width: 8),
                        _roleBadge('🛡️ Admin'),
                      ]),
                    ],
                  ),
                ),
              ]),
            ),

            // ── Form ─────────────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24),
                    child: Column(
                      crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                      children: [

                        const SizedBox(height: 24),

                        // Email
                        _field(
                          controller: _emailCtrl,
                          hint: 'votre@email.com',
                          icon: Icons.email_outlined,
                          isDark: isDark,
                          keyboard:
                            TextInputType.emailAddress,
                          validator: (v) =>
                            v!.isEmpty
                              ? 'Email requis' : null),

                        const SizedBox(height: 14),

                        // Password
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                              BorderRadius.circular(14),
                            border: Border.all(
                              color: TColors.primary,
                              width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                  .withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3)),
                            ]),
                          padding:
                            const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 2),
                          child: Row(children: [
                            const Icon(
                              Icons.lock_outline,
                              size: 22,
                              color: TColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscure,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: TColors.textPrimary,
                                  fontFamily: 'Poppins'),
                                decoration:
                                  const InputDecoration(
                                    hintText: '••••••••',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      color: TColors.textHint,
                                      fontFamily: 'Poppins'),
                                    border: InputBorder.none,
                                    enabledBorder:
                                      InputBorder.none,
                                    focusedBorder:
                                      InputBorder.none,
                                    isDense: true,
                                    contentPadding:
                                      EdgeInsets.symmetric(
                                        vertical: 14)),
                                validator: (v) =>
                                  v!.length < 6
                                    ? 'Min 6 caractères'
                                    : null,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(
                                () => _obscure = !_obscure),
                              child: Icon(
                                _obscure
                                  ? Icons.visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                                size: 22,
                                color: TColors.primary)),
                          ]),
                        ),

                        const SizedBox(height: 4),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize:
                                MaterialTapTargetSize
                                  .shrinkWrap),
                            child: const Text(
                              'Mot de passe oublié?',
                              style: TextStyle(
                                fontSize: 13,
                                color: TColors.primary,
                                fontFamily: 'Poppins',
                              ))),
                        ),

                        const SizedBox(height: 24),

                        // Login button
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed:
                              _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                  BorderRadius.circular(16)),
                              elevation: 0),
                            child: _loading
                              ? const SizedBox(
                                  height: 22, width: 22,
                                  child:
                                    CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2))
                              : const Row(
                                  mainAxisAlignment:
                                    MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.login_rounded,
                                      size: 18),
                                    SizedBox(width: 8),
                                    Text('Se connecter',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                          FontWeight.w700,
                                        fontFamily: 'Poppins',
                                      )),
                                  ]),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(children: [
                          Expanded(child: Divider(
                            color: TColors.borderLight,
                            thickness: 0.5)),
                          Padding(
                            padding:
                              const EdgeInsets.symmetric(
                                horizontal: 14),
                            child: Text('ou',
                              style: TextStyle(
                                fontSize: 13,
                                color: TColors.textHint,
                                fontFamily: 'Poppins'))),
                          Expanded(child: Divider(
                            color: TColors.borderLight,
                            thickness: 0.5)),
                        ]),

                        const SizedBox(height: 16),

                        // Register button
                        SizedBox(
                          height: 54,
                          child: OutlinedButton(
                            onPressed: () =>
                              Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                    const RegisterScreen())),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: TColors.primary,
                              side: const BorderSide(
                                color: TColors.primary,
                                width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                  BorderRadius.circular(16))),
                            child: const Row(
                              mainAxisAlignment:
                                MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_add_outlined,
                                  size: 18,
                                  color: TColors.primary),
                                SizedBox(width: 8),
                                Text('Créer un compte',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    color: TColors.primary,
                                  )),
                              ]),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: Text(
                            '🦸 Sois le Héros de ta Ville !',
                            style: TextStyle(
                              fontSize: 12,
                              color: TColors.textHint,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ))),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _roleBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25))),
      child: Text(label,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        )),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFDDDDDD), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3)),
        ]),
      padding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 2),
      child: Row(children: [
        Icon(icon, size: 22, color: TColors.textHint),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboard,
            style: const TextStyle(
              fontSize: 16,
              color: TColors.textPrimary,
              fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 16,
                color: TColors.textHint,
                fontFamily: 'Poppins'),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14)),
            validator: validator,
          ),
        ),
      ]),
    );
  }
}