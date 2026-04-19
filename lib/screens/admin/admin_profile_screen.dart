import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';
import 'package:frontend_t_hero/utils/constants/api_constant.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});
  @override
  State<AdminProfileScreen> createState() =>
      _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  String _nom   = '';
  String _email = '';
  String _userId = '';
  bool   _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs   = await SharedPreferences.getInstance();
    final userRaw = prefs.getString('user') ?? '{}';
    final token   = prefs.getString('token') ?? '';
    final user    = jsonDecode(userRaw);

    String uid = user['_id'] ?? user['id'] ?? '';
    if (uid.isEmpty && token.isNotEmpty) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final norm    = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(norm));
          final map = jsonDecode(decoded);
          uid = map['id'] ?? '';
        }
      } catch (_) {}
    }

    setState(() {
      _nom    = user['nom']   ?? 'Admin';
      _email  = user['email'] ?? '';
      _userId = uid;
      _loading = false;
    });
  }

  Future<void> _updateName(String newNom) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.put(
        Uri.parse(
          '${ApiConstants.baseUrl}/users/UpdateUser/$_userId'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'nom': newNom}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Update SharedPreferences
        final prefs   = await SharedPreferences.getInstance();
        final userRaw = prefs.getString('user') ?? '{}';
        final user    = jsonDecode(userRaw);
        user['nom']   = newNom;
        await prefs.setString('user', jsonEncode(user));
        setState(() => _nom = newNom);
        _snack('Nom mis à jour ✓', TColors.success);
      } else {
        _snack('Erreur mise à jour', TColors.error);
      }
    } catch (_) {
      _snack('Erreur serveur', TColors.error);
    }
  }

  Future<void> _changePassword(
      String oldPass, String newPass) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // Verify old password via login
      final loginResp = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email':      _email,
          'password':   oldPass,
        }),
      ).timeout(const Duration(seconds: 10));

      if (loginResp.statusCode != 200) {
        _snack('Ancien mot de passe incorrect', TColors.error);
        return;
      }

      // Change password
      final response = await http.put(
        Uri.parse(
          '${ApiConstants.baseUrl}/users/ChangePassword/$_userId'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'motDePasse': newPass}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _snack('Mot de passe modifié ✓', TColors.success);
      } else {
        _snack('Erreur modification', TColors.error);
      }
    } catch (_) {
      _snack('Erreur serveur', TColors.error);
    }
  }

  void _snack(String msg, Color color) {
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

  void _showEditNameDialog() {
    final ctrl = TextEditingController(text: _nom);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28))),
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
              Text('✏️ ', style: TextStyle(fontSize: 18)),
              Text('Modifier le nom',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TColors.textPrimary,
                  fontFamily: 'Poppins',
                )),
            ]),
            const SizedBox(height: 20),
            _sheetField(
              controller: ctrl,
              hint: 'Nom complet',
              icon: Icons.person_outline),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (ctrl.text.trim().isNotEmpty) {
                    Navigator.pop(context);
                    _updateName(ctrl.text.trim());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                  elevation: 0),
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

  void _showChangePasswordDialog() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confCtrl = TextEditingController();
    bool obscOld = true;
    bool obscNew = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28))),
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
                Text('🔒 ', style: TextStyle(fontSize: 18)),
                Text('Changer le mot de passe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
              ]),
              const SizedBox(height: 20),
              _sheetField(
                controller: oldCtrl,
                hint: 'Ancien mot de passe',
                icon: Icons.lock_outline,
                obscure: obscOld,
                trailing: GestureDetector(
                  onTap: () =>
                    setSheet(() => obscOld = !obscOld),
                  child: Icon(
                    obscOld
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                    size: 20,
                    color: TColors.textHint))),
              const SizedBox(height: 10),
              _sheetField(
                controller: newCtrl,
                hint: 'Nouveau mot de passe',
                icon: Icons.lock_open_outlined,
                obscure: obscNew,
                trailing: GestureDetector(
                  onTap: () =>
                    setSheet(() => obscNew = !obscNew),
                  child: Icon(
                    obscNew
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                    size: 20,
                    color: TColors.textHint))),
              const SizedBox(height: 10),
              _sheetField(
                controller: confCtrl,
                hint: 'Confirmer le mot de passe',
                icon: Icons.check_circle_outline,
                obscure: true),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (oldCtrl.text.isEmpty ||
                        newCtrl.text.isEmpty) {
                      _snack('Remplissez tous les champs',
                        TColors.warning);
                      return;
                    }
                    if (newCtrl.text != confCtrl.text) {
                      _snack('Mots de passe non identiques',
                        TColors.error);
                      return;
                    }
                    if (newCtrl.text.length < 6) {
                      _snack('Min 6 caractères', TColors.error);
                      return;
                    }
                    Navigator.pop(context);
                    _changePassword(
                      oldCtrl.text.trim(),
                      newCtrl.text.trim());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                        BorderRadius.circular(16)),
                    elevation: 0),
                  child: const Text('Modifier',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String nom) {
    final parts = nom.trim().split(' ');
    if (parts.length >= 2)
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return nom.length >= 2
      ? nom.substring(0, 2).toUpperCase() : nom.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.light,
      body: SafeArea(
        child: Column(children: [

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
                bottomLeft:  Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              16, 16, 16, 28),
            child: Column(children: [

              // Back row
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white
                        .withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white
                          .withValues(alpha: 0.3))),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white, size: 14)),
                ),
                const SizedBox(width: 12),
                const Text('Mon Profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  )),
              ]),

              const SizedBox(height: 20),

              // Avatar + name
              _loading
                ? const CircularProgressIndicator(
                    color: Colors.white)
                : Column(children: [

                  // Avatar circle
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                            .withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4)),
                      ]),
                    child: Center(
                      child: Text(_initials(_nom),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: TColors.primary,
                          fontFamily: 'Poppins',
                        ))),
                  ),

                  const SizedBox(height: 12),

                  Text('🛡️ $_nom',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    )),

                  const SizedBox(height: 4),

                  Text(_email,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white
                        .withValues(alpha: 0.8),
                      fontFamily: 'Poppins',
                    )),

                  const SizedBox(height: 10),

                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white
                        .withValues(alpha: 0.2),
                      borderRadius:
                        BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white
                          .withValues(alpha: 0.3))),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_outlined,
                          size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text('Administrateur',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          )),
                      ]),
                  ),
                ]),
            ]),
          ),

          // ── Body ─────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // Encouragement
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        TColors.primary,
                        Color(0xFFE53935)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: TColors.primary
                          .withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                    ]),
                  child: Row(children: [
                    const Text('🏛️',
                      style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                          CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gardien de la ville 🛡️',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            )),
                          Text(
                            'Vous protégez la Tunisie 🇹🇳',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white
                                .withValues(alpha: 0.85),
                              fontFamily: 'Poppins',
                            )),
                        ],
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: 20),

                // Section: Compte
                _sectionTitle('👤  Mon compte'),
                const SizedBox(height: 10),

                _actionTile(
                  icon: Icons.person_outline,
                  label: 'Modifier le nom',
                  subtitle: _nom,
                  onTap: _showEditNameDialog),

                const SizedBox(height: 10),

                _actionTile(
                  icon: Icons.email_outlined,
                  label: 'Adresse email',
                  subtitle: _email,
                  onTap: null),

                const SizedBox(height: 20),

                // Section: Sécurité
                _sectionTitle('🔒  Sécurité'),
                const SizedBox(height: 10),

                _actionTile(
                  icon: Icons.lock_outline,
                  label: 'Changer le mot de passe',
                  subtitle: 'Modifier votre mot de passe',
                  onTap: _showChangePasswordDialog),

                const SizedBox(height: 32),

                // Branding
                Center(
                  child: Column(children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            TColors.primary,
                            Color(0xFFE53935)]),
                        borderRadius:
                          BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: TColors.primary
                              .withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4)),
                        ]),
                      child: const Center(
                        child: Text('T',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          )))),
                    const SizedBox(height: 10),
                    const Text('T HERO',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: TColors.textPrimary,
                        letterSpacing: 4,
                        fontFamily: 'Poppins',
                      )),
                    const SizedBox(height: 4),
                    const Text('🌟 Smart City Guardian',
                      style: TextStyle(
                        fontSize: 12,
                        color: TColors.primary,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      )),
                    const SizedBox(height: 4),
                    const Text('© 2025 T HERO Tunisia 🇹🇳',
                      style: TextStyle(
                        fontSize: 11,
                        color: TColors.textHint,
                        fontFamily: 'Poppins',
                      )),
                  ]),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: TColors.textSecondary,
          letterSpacing: 0.5,
          fontFamily: 'Poppins',
        )),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TColors.borderLight, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
          ]),
        padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 14),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: TColors.primaryLight,
              borderRadius: BorderRadius.circular(13)),
            child: Icon(icon,
              size: 20, color: TColors.primary)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
                const SizedBox(height: 2),
                Text(subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TColors.textHint,
                    fontFamily: 'Poppins',
                  )),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.arrow_forward_ios,
              size: 14, color: TColors.grey),
        ]),
      ),
    );
  }

  Widget _sheetField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? trailing,
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
            obscureText: obscure,
            style: const TextStyle(
              fontSize: 14,
              color: TColors.textPrimary,
              fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: TColors.textHint,
                fontFamily: 'Poppins'),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12)),
          ),
        ),
        if (trailing != null) trailing,
      ]),
    );
  }
}