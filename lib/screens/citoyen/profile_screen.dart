import 'package:flutter/material.dart';
import 'package:frontend_t_hero/screens/auth/login_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size   = MediaQuery.of(context).size;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── Red header ───────────────────────────────────
          Container(
            height: size.height * 0.28,
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
                    child: Text('AB',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      )),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Amira Bouazizi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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
                  child: const Text('Citoyen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    )),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Menu items ───────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _item(context, Icons.person_outline,
                    'Mon profil', () {}, isDark),
                  const SizedBox(height: 8),
                  _item(context, Icons.flag_outlined,
                    'Mes signalements', () {}, isDark),
                  const SizedBox(height: 8),
                  _item(context, Icons.settings_outlined,
                    'Paramètres', () {}, isDark),
                  Divider(
                    color: TColors.borderLight,
                    thickness: 0.5,
                    height: 24),
                  _item(context, Icons.logout_rounded,
                    'Déconnexion',
                    () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
                      (r) => false),
                    isDark,
                    isRed: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
    bool isDark, {
    bool isRed = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
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
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: isRed
                ? TColors.primaryLight
                : (isDark ? TColors.dark : TColors.light),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon,
              size: 18, color: TColors.primary),
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
    );
  }
}