import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_t_hero/utils/constants/api_constant.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {

  final _formKey   = GlobalKey<FormState>();
  final _nomCtrl   = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _codeCtrl  = TextEditingController();
  bool _obscure    = true;
  bool _loading    = false;
  int  _role       = 0;
  final _roles     = ['Citoyen', 'Agent', 'Admin'];

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
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
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      String url;
      Map<String, dynamic> body;

      if (_role == 0) {
        url = ApiConstants.createUser;
        body = {
          'nom':        _nomCtrl.text.trim(),
          'email':      _emailCtrl.text.trim(),
          'motDePasse': _passCtrl.text.trim(),
        };
      } else if (_role == 1) {
        url = ApiConstants.createAgent;
        body = {
          'nom':        _nomCtrl.text.trim(),
          'email':      _emailCtrl.text.trim(),
          'motDePasse': _passCtrl.text.trim(),
          'code_Agent': int.tryParse(_codeCtrl.text.trim()) ?? 0,
        };
      } else {
        url = ApiConstants.createAdmin;
        body = {
          'nom':        _nomCtrl.text.trim(),
          'email':      _emailCtrl.text.trim(),
          'motDePasse': _passCtrl.text.trim(),
          'code_Admin': int.tryParse(_codeCtrl.text.trim()) ?? 0,
        };
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;
      setState(() => _loading = false);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Compte créé avec succès ✓',
            style: TextStyle(
              fontSize: 14, fontFamily: 'Poppins')),
          backgroundColor: TColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        ));
      } else {
        final msg = data['message'] ?? data['error']
          ?? 'Erreur inscription';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg,
            style: const TextStyle(
              fontSize: 13, fontFamily: 'Poppins')),
          backgroundColor: TColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          'Impossible de contacter le serveur',
          style: TextStyle(fontSize: 13, fontFamily: 'Poppins')),
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
      backgroundColor: isDark ? TColors.dark : TColors.light,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(children: [

            // ── Gradient Header ───────────────────────────
            Container(
              height: size.height * 0.36,
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
                  top: -20, right: -20,
                  child: Container(
                    width: 130, height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                        .withValues(alpha: 0.05)))),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24, 16, 24, 24),
                  child: Column(
                    mainAxisAlignment:
                      MainAxisAlignment.end,
                    crossAxisAlignment:
                      CrossAxisAlignment.start,
                    children: [

                      // Back + logo row
                      Row(children: [
                        GestureDetector(
                          onTap: () =>
                            Navigator.pop(context),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white
                                .withValues(alpha: 0.2),
                              borderRadius:
                                BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white
                                  .withValues(alpha: 0.3))),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 14)),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                              BorderRadius.circular(10)),
                          child: const Center(
                            child: Text('T',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: TColors.primary,
                                fontFamily: 'Poppins',
                              ))),
                        ),
                        const SizedBox(width: 8),
                        const Text('T HERO',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 2,
                            fontFamily: 'Poppins',
                          )),
                      ]),

                      const SizedBox(height: 16),

                      const Text('Créer un compte 🦸',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        )),
                      const SizedBox(height: 4),
                      Text(
                        'Rejoignez la communauté des héros\nde Tunisie 🇹🇳',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white
                            .withValues(alpha: 0.8),
                          fontFamily: 'Poppins',
                          height: 1.5,
                        )),

                      const SizedBox(height: 16),

                      // Role selector tabs
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white
                            .withValues(alpha: 0.15),
                          borderRadius:
                            BorderRadius.circular(30)),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: List.generate(3, (i) =>
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _role = i),
                                child: AnimatedContainer(
                                  duration: const Duration(
                                    milliseconds: 200),
                                  padding:
                                    const EdgeInsets.symmetric(
                                      vertical: 9),
                                  decoration: BoxDecoration(
                                    color: _role == i
                                      ? Colors.white
                                      : Colors.transparent,
                                    borderRadius:
                                      BorderRadius.circular(26)),
                                  child: Text(
                                    _role == i
                                      ? [
                                          '👤 Citoyen',
                                          '🦸 Agent',
                                          '🛡️ Admin'][i]
                                      : _roles[i],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Poppins',
                                      fontWeight: _role == i
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                      color: _role == i
                                        ? TColors.primary
                                        : Colors.white
                                            .withValues(
                                              alpha: 0.85),
                                    )),
                                ),
                              ),
                            )),
                        ),
                      ),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24),
                    child: Column(
                      mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                      children: [

                        Column(
                          crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                          children: [

                            // Nom
                            _field(
                              controller: _nomCtrl,
                              hint: 'Nom complet',
                              icon: Icons.person_outline,
                              isDark: isDark,
                              validator: (v) =>
                                v!.isEmpty ? 'Requis' : null),
                            const SizedBox(height: 12),

                            // Email
                            _field(
                              controller: _emailCtrl,
                              hint: 'votre@email.com',
                              icon: Icons.email_outlined,
                              isDark: isDark,
                              keyboard:
                                TextInputType.emailAddress,
                              validator: (v) =>
                                v!.isEmpty ? 'Requis' : null),
                            const SizedBox(height: 12),

                            // Password
                            Container(
                              decoration: BoxDecoration(
                                color: isDark
                                  ? TColors.darkContainer
                                  : TColors.cardLight,
                                borderRadius:
                                  BorderRadius.circular(14),
                                border: Border.all(
                                  color: TColors.borderLight,
                                  width: 0.5)),
                              padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 2),
                              child: Row(children: [
                                const Icon(
                                  Icons.lock_outline,
                                  size: 22,
                                  color: TColors.textHint),
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
                                    color: TColors.textHint)),
                              ]),
                            ),

                            // Code field
                            AnimatedSize(
                              duration: const Duration(
                                milliseconds: 250),
                              curve: Curves.easeInOut,
                              child: _role == 1 || _role == 2
                                ? Column(children: [
                                    const SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: TColors.primaryLight,
                                        borderRadius:
                                          BorderRadius.circular(14),
                                        border: Border.all(
                                          color: TColors.primary,
                                          width: 1.5)),
                                      padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 2),
                                      child: Row(children: [
                                        const Icon(
                                          Icons.shield_outlined,
                                          size: 22,
                                          color: TColors.primary),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _codeCtrl,
                                            keyboardType:
                                              TextInputType.number,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: TColors.primary,
                                              fontFamily: 'Poppins'),
                                            decoration:
                                              InputDecoration(
                                                hintText: _role == 1
                                                  ? '🦸 Code Agent'
                                                  : '🛡️ Code Admin',
                                                hintStyle:
                                                  const TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                      TColors.primary,
                                                    fontFamily:
                                                      'Poppins'),
                                                border:
                                                  InputBorder.none,
                                                enabledBorder:
                                                  InputBorder.none,
                                                focusedBorder:
                                                  InputBorder.none,
                                                isDense: true,
                                                contentPadding:
                                                  const EdgeInsets
                                                    .symmetric(
                                                      vertical: 14)),
                                            validator: (v) =>
                                              v!.isEmpty
                                                ? 'Code requis'
                                                : null,
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ])
                                : const SizedBox.shrink(),
                            ),
                          ],
                        ),

                        // Buttons
                        Column(
                          crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                          children: [

                            SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed:
                                  _loading ? null : _register,
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
                                          Icons.person_add_outlined,
                                          size: 18),
                                        SizedBox(width: 8),
                                        Text('S\'inscrire',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                              FontWeight.w700,
                                            fontFamily: 'Poppins',
                                          )),
                                      ]),
                              ),
                            ),

                            const SizedBox(height: 14),

                            Center(
                              child: GestureDetector(
                                onTap: () =>
                                  Navigator.pop(context),
                                child: RichText(
                                  text: const TextSpan(
                                    text: 'Déjà un compte? ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: TColors.textHint,
                                      fontFamily: 'Poppins'),
                                    children: [
                                      TextSpan(
                                        text: 'Se connecter →',
                                        style: TextStyle(
                                          color: TColors.primary,
                                          fontWeight:
                                            FontWeight.w700,
                                          fontFamily: 'Poppins',
                                          fontSize: 13)),
                                    ]),
                                ),
                              ),
                            ),
                          ],
                        ),
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
        color: isDark
          ? TColors.darkContainer : TColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TColors.borderLight, width: 0.5)),
      padding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 2),
      child: Row(children: [
        Icon(icon, size: 22, color: TColors.textHint),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboard,
            style: TextStyle(
              fontSize: 16,
              color: isDark
                ? TColors.textWhite : TColors.textPrimary,
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