import 'package:flutter/material.dart';
import 'package:frontend_t_hero/screens/auth/login_screen.dart';
import 'package:frontend_t_hero/screens/agent/agent_analyses_ia_screen.dart';
import 'package:frontend_t_hero/screens/agent/agent_parametres_screen.dart';
import 'package:frontend_t_hero/screens/agent/agent_mes_signalements_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class AgentProfileScreen extends StatefulWidget {
  const AgentProfileScreen({super.key});
  @override
  State<AgentProfileScreen> createState() =>
      _AgentProfileScreenState();
}

class _AgentProfileScreenState extends State<AgentProfileScreen> {
  String _nom   = 'Agent Habib';
  String _email = 'habib@thero.com';

  String get _initials {
    final parts = _nom.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _nom.substring(0, 2).toUpperCase();
  }

  void _showEditProfile() {
    final nomCtrl   = TextEditingController(text: _nom);
    final emailCtrl = TextEditingController(text: _email);

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
            const Text('Modifier mon profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
                fontFamily: 'Poppins',
              )),
            const SizedBox(height: 20),
            _field(
              controller: nomCtrl,
              hint: 'Nom complet',
              icon: Icons.person_outline),
            const SizedBox(height: 10),
            _field(
              controller: emailCtrl,
              hint: 'Email',
              icon: Icons.email_outlined,
              keyboard: TextInputType.emailAddress),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (nomCtrl.text.isNotEmpty) {
                    setState(() {
                      _nom   = nomCtrl.text.trim();
                      _email = emailCtrl.text.trim();
                    });
                    Navigator.pop(context);
                    _showSnack('Profil mis à jour ✓',
                      TColors.success);
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
            const Text('Changer le mot de passe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
                fontFamily: 'Poppins',
              )),
            const SizedBox(height: 6),
            const Text(
              'Choisissez un mot de passe fort d\'au moins 8 caractères.',
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
                onPressed: () {
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
                  Navigator.pop(context);
                  _showSnack(
                    'Mot de passe mis à jour ✓',
                    TColors.success);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size   = MediaQuery.of(context).size;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── Red Header ────────────────────────────────────
          Container(
            height: size.height * 0.34,
            decoration: const BoxDecoration(
              color: TColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 76, height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 2),
                      ),
                      child: Center(
                        child: Text(_initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          )),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showEditProfile,
                      child: Container(
                        width: 24, height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit,
                          size: 13, color: TColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(_nom,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  )),
                const SizedBox(height: 4),
                Text(_email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  )),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Agent Municipal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    )),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _stat('5', 'Assignés'),
                    _vDiv(),
                    _stat('3', 'En cours'),
                    _vDiv(),
                    _stat('2', 'Résolus'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Menu Items ────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _item(context,
                    icon: Icons.person_outline,
                    label: 'Modifier mon profil',
                    subtitle: 'Nom, email',
                    isDark: isDark,
                    onTap: _showEditProfile),
                  const SizedBox(height: 8),
                  _item(context,
                    icon: Icons.lock_outline,
                    label: 'Changer le mot de passe',
                    subtitle: 'Sécurité du compte',
                    isDark: isDark,
                    onTap: _showChangePassword),
                  const SizedBox(height: 8),

  // ── FIXED: Mes signalements ────────────────
  _item(context,
    icon: Icons.flag_outlined,
    label: 'Mes signalements',
    subtitle: 'Voir mes rapports',
    isDark: isDark,
    onTap: () => Navigator.push(context,
      MaterialPageRoute(
        builder: (_) =>
          const AgentMesSignalementsScreen()))),
  const SizedBox(height: 8),

                  // ── FIXED: Analyses IA ─────────────────────
                  _item(context,
                    icon: Icons.auto_awesome_outlined,
                    label: 'Analyses IA',
                    subtitle: 'Rapports intelligents',
                    isDark: isDark,
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                        builder: (_) =>
                          const AgentAnalysesIAScreen()))),
                  const SizedBox(height: 8),

                  // ── FIXED: Paramètres agent ────────────────
                  _item(context,
                    icon: Icons.settings_outlined,
                    label: 'Paramètres',
                    subtitle: 'Préférences de l\'app',
                    isDark: isDark,
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                        builder: (_) =>
                          const AgentParametresScreen()))),

                  Divider(
                    color: TColors.borderLight,
                    thickness: 0.5, height: 24),
                  _item(context,
                    icon: Icons.logout_rounded,
                    label: 'Déconnexion',
                    isDark: isDark,
                    isRed: true,
                    onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
                      (r) => false)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String num, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        Text(num,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          )),
        const SizedBox(height: 2),
        Text(label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
            fontFamily: 'Poppins',
          )),
      ]),
    );
  }

  Widget _vDiv() {
    return Container(
      width: 1, height: 28,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? subtitle,
    required bool isDark,
    required VoidCallback onTap,
    bool isRed = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: TColors.primary.withValues(alpha: 0.06),
        child: Ink(
          decoration: BoxDecoration(
            color: isRed
              ? TColors.primaryLight
              : (isDark ? TColors.cardDark : TColors.cardLight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRed
                ? TColors.primary.withValues(alpha: 0.2)
                : TColors.borderLight,
              width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 13),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: isRed
                    ? TColors.primaryLight
                    : (isDark ? TColors.dark : TColors.light),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon,
                  size: 20, color: TColors.primary)),
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
                        color: isRed
                          ? TColors.primary
                          : (isDark
                              ? TColors.textWhite
                              : TColors.textPrimary),
                      )),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: TColors.textHint,
                          fontFamily: 'Poppins',
                        )),
                    ],
                  ],
                ),
              ),
              if (!isRed)
                const Icon(Icons.arrow_forward_ios,
                  size: 15, color: TColors.grey),
            ]),
          ),
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
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
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