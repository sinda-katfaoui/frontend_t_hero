import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_t_hero/screens/auth/login_screen.dart';
import 'package:frontend_t_hero/screens/citoyen/parametres_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';
import 'package:frontend_t_hero/utils/constants/api_constant.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _nom     = 'Citoyen';
  String _email   = '';
  String _userId  = '';
  int    _total   = 0;
  int    _enCours = 0;
  int    _resolus = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ── Extract ID from JWT token ──────────────────────────────
  String _extractIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return '';
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded);
      return map['id'] ?? '';
    } catch (_) { return ''; }
  }

  Future<void> _loadProfile() async {
    final prefs   = await SharedPreferences.getInstance();
    final userRaw = prefs.getString('user') ?? '{}';
    final token   = prefs.getString('token') ?? '';
    final user    = jsonDecode(userRaw);

    // Try all possible keys + token fallback
    String userId = user['_id'] ?? user['id'] ?? '';
    if (userId.isEmpty && token.isNotEmpty) {
      userId = _extractIdFromToken(token);
    }

    _userId = userId;

    setState(() {
      _nom   = user['nom']   ?? 'Citoyen';
      _email = user['email'] ?? '';
    });

    // Also fix SharedPreferences if _id was missing
    if (user['_id'] == null && userId.isNotEmpty) {
      user['_id'] = userId;
      await prefs.setString('user', jsonEncode(user));
    }

    await _loadStats();
  }

  Future<void> _loadStats() async {
    if (_userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/signalements'
          '/GetSignalementsByCitoyen/$_userId'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['data'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
        setState(() {
          _total   = list.length;
          _enCours = list.where((s) =>
            s['statut'] == 'EN_COURS' ||
            s['statut'] == 'EN_ATTENTE').length;
          _resolus = list.where((s) =>
            s['statut'] == 'RESOLU').length;
        });
      }
    } catch (_) {}
  }

  String get _initials {
    final parts = _nom.trim().split(' ');
    if (parts.length >= 2)
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return _nom.length >= 2
      ? _nom.substring(0, 2).toUpperCase()
      : _nom.toUpperCase();
  }

  void _showEditProfile() {
    final nomCtrl = TextEditingController(text: _nom);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          20, 12, 20,
          MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: TColors.borderLight,
                borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 16),
            const Row(children: [
              Text('✏️ ', style: TextStyle(fontSize: 20)),
              Text('Modifier mon nom',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TColors.textPrimary,
                  fontFamily: 'Poppins',
                )),
            ]),
            const SizedBox(height: 6),
            const Text(
              'Votre nom apparaîtra comme "Héros [nom]" 🌟',
              style: TextStyle(
                fontSize: 13,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              )),
            const SizedBox(height: 20),
            _field(
              controller: nomCtrl,
              hint: 'Votre nom',
              icon: Icons.person_outline),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final newName = nomCtrl.text.trim();
                  if (newName.isEmpty) return;
                  try {
                    final prefs =
                      await SharedPreferences.getInstance();
                    final token =
                      prefs.getString('token') ?? '';

                    final response = await http.put(
                      Uri.parse(
                        '${ApiConstants.baseUrl}'
                        '/users/UpdateUser/$_userId'),
                      headers: {
                        'Content-Type':  'application/json',
                        'Authorization': 'Bearer $token',
                      },
                      body: jsonEncode({'nom': newName}),
                    ).timeout(const Duration(seconds: 10));

                    if (response.statusCode == 200) {
                      final userRaw =
                        prefs.getString('user') ?? '{}';
                      final user =
                        Map<String, dynamic>.from(
                          jsonDecode(userRaw));
                      user['nom'] = newName;
                      await prefs.setString(
                        'user', jsonEncode(user));
                      setState(() => _nom = newName);
                      if (mounted) Navigator.pop(context);
                      _showSnack(
                        '🌟 Héros $newName — profil mis à jour !',
                        TColors.success);
                    } else {
                      _showSnack(
                        'Erreur ${response.statusCode}',
                        TColors.error);
                    }
                  } catch (e) {
                    if (mounted) Navigator.pop(context);
                    _showSnack('Erreur serveur', TColors.error);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Enregistrer',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ))),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePassword() {
    final oldCtrl     = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          20, 12, 20,
          MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: TColors.borderLight,
                borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 16),
            const Row(children: [
              Text('🔐 ', style: TextStyle(fontSize: 20)),
              Text('Changer le mot de passe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TColors.textPrimary,
                  fontFamily: 'Poppins',
                )),
            ]),
            const SizedBox(height: 6),
            const Text(
              'Protégez votre compte ! Min. 8 caractères.',
              style: TextStyle(
                fontSize: 13,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              )),
            const SizedBox(height: 20),
            _field(
              controller: oldCtrl,
              hint: 'Mot de passe actuel',
              icon: Icons.lock_outline,
              obscure: true),
            const SizedBox(height: 10),
            _field(
              controller: newCtrl,
              hint: 'Nouveau mot de passe',
              icon: Icons.lock_reset_outlined,
              obscure: true),
            const SizedBox(height: 10),
            _field(
              controller: confirmCtrl,
              hint: 'Confirmer le nouveau mot de passe',
              icon: Icons.lock_reset_outlined,
              obscure: true),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  if (oldCtrl.text.isEmpty) {
                    _showSnack(
                      'Entrez votre mot de passe actuel',
                      TColors.error);
                    return;
                  }
                  if (newCtrl.text.length < 8) {
                    _showSnack(
                      'Au moins 8 caractères requis',
                      TColors.error);
                    return;
                  }
                  if (newCtrl.text != confirmCtrl.text) {
                    _showSnack(
                      'Les mots de passe ne correspondent pas',
                      TColors.error);
                    return;
                  }
                  try {
                    // Verify old password
                    final loginResp = await http.post(
                      Uri.parse(ApiConstants.login),
                      headers: {
                        'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'email':    _email,
                        'password': oldCtrl.text,
                      }),
                    ).timeout(const Duration(seconds: 10));

                    if (loginResp.statusCode != 200) {
                      _showSnack(
                        '❌ Mot de passe actuel incorrect',
                        TColors.error);
                      return;
                    }

                    final prefs =
                      await SharedPreferences.getInstance();
                    final token =
                      prefs.getString('token') ?? '';

                    final response = await http.put(
                      Uri.parse(
                        '${ApiConstants.baseUrl}'
                        '/users/ChangePassword/$_userId'),
                      headers: {
                        'Content-Type':  'application/json',
                        'Authorization': 'Bearer $token',
                      },
                      body: jsonEncode(
                        {'motDePasse': newCtrl.text}),
                    ).timeout(const Duration(seconds: 10));

                    if (mounted) Navigator.pop(context);
                    if (response.statusCode == 200) {
                      _showSnack(
                        '🔐 Mot de passe mis à jour ✓',
                        TColors.success);
                    } else {
                      _showSnack(
                        'Erreur ${response.statusCode}',
                        TColors.error);
                    }
                  } catch (e) {
                    if (mounted) Navigator.pop(context);
                    _showSnack('Erreur serveur', TColors.error);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Mettre à jour',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ))),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
        style: const TextStyle(
          fontSize: 13, fontFamily: 'Poppins')),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
      Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Gradient Header ──────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TColors.primary,
                    Color(0xFFE53935)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(
                16, 20, 16, 24),
              child: Column(children: [

                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 84, height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white
                          .withValues(alpha: 0.2),
                        borderRadius:
                          BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white
                            .withValues(alpha: 0.5),
                          width: 2.5),
                      ),
                      child: Center(
                        child: Text(_initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ))),
                    ),
                    GestureDetector(
                      onTap: _showEditProfile,
                      child: Container(
                        width: 28, height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle),
                        child: const Icon(Icons.edit,
                          size: 14,
                          color: TColors.primary)),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text('🌟 Héros $_nom',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  )),

                const SizedBox(height: 4),

                Text(_email,
                  style: TextStyle(
                    color: Colors.white
                      .withValues(alpha: 0.75),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  )),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white
                      .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white
                        .withValues(alpha: 0.3))),
                  child: const Text('⚡ Citoyen T HERO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    )),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white
                      .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    _statItem('$_total', 'Signalements',
                      Icons.flag_outlined),
                    _vDiv(),
                    _statItem('$_enCours', 'En cours',
                      Icons.pending_outlined),
                    _vDiv(),
                    _statItem('$_resolus', 'Résolus',
                      Icons.check_circle_outline),
                  ]),
                ),
              ]),
            ),

            const SizedBox(height: 16),

            // ── Encouragement ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1565C0),
                      Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  const Text('🌟',
                    style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                        CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Merci pour votre engagement !',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          )),
                        Text(
                          'Chaque signalement améliore votre ville 🇹🇳',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white
                              .withValues(alpha: 0.9),
                            fontFamily: 'Poppins',
                          )),
                      ],
                    ),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 16),

            // ── Menu ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16),
              child: Column(children: [

                _menuItem(
                  emoji: '✏️',
                  label: 'Modifier mon nom',
                  subtitle: 'Votre identité de citoyen',
                  isDark: isDark,
                  onTap: _showEditProfile),

                const SizedBox(height: 10),

                _menuItem(
                  emoji: '🔐',
                  label: 'Changer le mot de passe',
                  subtitle: 'Sécurisez votre compte',
                  isDark: isDark,
                  onTap: _showChangePassword),

                const SizedBox(height: 10),

                _menuItem(
                  emoji: '⚙️',
                  label: 'Paramètres',
                  subtitle: 'Préférences de l\'application',
                  isDark: isDark,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                      builder: (_) =>
                        const ParametresScreen()))),

                const SizedBox(height: 16),

                Divider(
                  color: TColors.borderLight,
                  thickness: 0.5),

                const SizedBox(height: 10),

                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final prefs =
                        await SharedPreferences.getInstance();
                      await prefs.remove('token');
                      await prefs.remove('user');
                      if (!mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                            const LoginScreen()),
                        (r) => false);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: TColors.primaryLight,
                        borderRadius:
                          BorderRadius.circular(16),
                        border: Border.all(
                          color: TColors.primary
                            .withValues(alpha: 0.3),
                          width: 1)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                      child: Row(children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: TColors.primary
                              .withValues(alpha: 0.1),
                            borderRadius:
                              BorderRadius.circular(12)),
                          child: const Icon(
                            Icons.logout_rounded,
                            size: 20,
                            color: TColors.primary)),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                              CrossAxisAlignment.start,
                            children: [
                              Text('Déconnexion',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  color: TColors.primary,
                                )),
                              Text('À bientôt ! 👋',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: TColors.textHint,
                                  fontFamily: 'Poppins',
                                )),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                          size: 15,
                          color: TColors.primary),
                      ]),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String num, String label, IconData icon) {
    return Expanded(
      child: Column(children: [
        Icon(icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 16),
        const SizedBox(height: 3),
        Text(num,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          )),
        const SizedBox(height: 2),
        Text(label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 10,
            fontFamily: 'Poppins',
          )),
      ]),
    );
  }

  Widget _vDiv() => Container(
    width: 1, height: 32,
    color: Colors.white.withValues(alpha: 0.25));

  Widget _menuItem({
    required String emoji,
    required String label,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? TColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: TColors.borderLight, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2)),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: TColors.primaryLight,
                borderRadius: BorderRadius.circular(13)),
              child: Center(
                child: Text(emoji,
                  style: const TextStyle(fontSize: 20)))),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: isDark
                        ? TColors.textWhite
                        : TColors.textPrimary,
                    )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TColors.textHint,
                      fontFamily: 'Poppins',
                    )),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
              size: 14, color: TColors.grey),
          ]),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.light,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TColors.borderLight, width: 0.5)),
      padding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 4),
      child: Row(children: [
        Icon(icon, size: 20, color: TColors.textHint),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            obscureText: obscure,
            style: const TextStyle(
              fontSize: 14,
              color: TColors.textPrimary,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12),
            ),
          ),
        ),
      ]),
    );
  }
}