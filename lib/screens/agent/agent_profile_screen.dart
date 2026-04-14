// agent_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend_t_hero/screens/auth/login_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class AgentProfileScreen extends StatelessWidget {
  const AgentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size   = MediaQuery.of(context).size;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── Red Header ───────────────────────────────────
          Container(
            height: size.height * 0.32,
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
                // Square rounded avatar
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2),
                  ),
                  child: const Center(
                    child: Text('AH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      )),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Agent Habib',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  )),
                const SizedBox(height: 6),
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
                // Stats row
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

          // ── Menu Items ───────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _item(context, Icons.person_outline,
                    'Mon profil', isDark,
                    onTap: () => _showComingSoon(context)),
                  const SizedBox(height: 8),
                  _item(context, Icons.flag_outlined,
                    'Mes signalements', isDark,
                    onTap: () => _showComingSoon(context)),
                  const SizedBox(height: 8),
                  _item(context, Icons.history,
                    'Historique', isDark,
                    onTap: () => _showComingSoon(context)),
                  const SizedBox(height: 8),
                  _item(context, Icons.auto_awesome_outlined,
                    'Analyses IA', isDark,
                    onTap: () => _showComingSoon(context)),
                  const SizedBox(height: 8),
                  _item(context, Icons.settings_outlined,
                    'Paramètres', isDark,
                    onTap: () => _showComingSoon(context)),
                  Divider(
                    color: TColors.borderLight,
                    thickness: 0.5, height: 24),
                  _item(context, Icons.logout_rounded,
                    'Déconnexion', isDark,
                    isRed: true,
                    onTap: () => _logout(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Coming soon snackbar ───────────────────────────────────
  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fonctionnalité bientôt disponible',
          style: TextStyle(
            fontSize: 13, fontFamily: 'Poppins')),
        backgroundColor: TColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
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
    BuildContext context,
    IconData icon,
    String label,
    bool isDark, {
    required VoidCallback onTap,
    bool isRed = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: TColors.primary.withValues(alpha: 0.08),
        highlightColor: TColors.primary.withValues(alpha: 0.04),
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
              horizontal: 16, vertical: 14),
            child: Row(children: [

              // Icon box
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: isRed
                    ? TColors.primaryLight
                    : (isDark ? TColors.dark : TColors.light),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon,
                  size: 20, color: TColors.primary),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: isRed
                      ? TColors.primary
                      : (isDark
                          ? TColors.textWhite
                          : TColors.textPrimary),
                  )),
              ),

              if (!isRed)
                const Icon(Icons.arrow_forward_ios,
                  size: 16, color: TColors.grey),
            ]),
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (r) => false,
    );
  }
}