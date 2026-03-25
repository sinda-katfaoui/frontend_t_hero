// ============================================================
// ProfileScreen — Citoyen Profile Tab
// ============================================================
// Displays the logged-in citoyen's profile information and
// navigation menu. Embedded in CitoyenHomeScreen's IndexedStack
// at tab index 4 — not a separate route.
//
// Sections:
//   - Red header with avatar, name, and role badge
//   - Menu items: Mon profil, Mes signalements, Historique,
//     Paramètres, and Déconnexion (red, destructive action)
//
// Design decisions:
// - Red curved header (28px radius) matches app style
// - Square rounded avatar (16px radius) — modern not circle
// - Role badge is a white semi-transparent pill
// - Menu items are white cards with icon box + arrow
// - Logout is red tinted card — visually signals danger
// - Everything fits on screen — no scrolling needed
//
// TODO: Replace hardcoded name/initials with real user data
// from shared preferences or auth state management.
// ============================================================

import 'package:flutter/material.dart';
import 'package:frontend_t_hero/screens/auth/login_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── Red Header ───────────────────────────────────
          // Avatar + name + role badge on red background.
          // Curved bottom creates visual depth below header.
          _buildHeader(),

          const SizedBox(height: 10),

          // ── Menu Items ───────────────────────────────────
          // Each item is a white card with icon + label + arrow.
          // Padding keeps consistent spacing from screen edges.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  _menuItem(
                    context,
                    icon: Icons.person_outline,
                    label: 'Mon profil',
                    onTap: () {},
                    isDark: isDark,
                  ),
                  const SizedBox(height: 5),
                  _menuItem(
                    context,
                    icon: Icons.flag_outlined,
                    label: 'Mes signalements',
                    onTap: () {},
                    isDark: isDark,
                  ),
                  const SizedBox(height: 5),
                  _menuItem(
                    context,
                    icon: Icons.history,
                    label: 'Historique',
                    onTap: () {},
                    isDark: isDark,
                  ),
                  const SizedBox(height: 5),
                  _menuItem(
                    context,
                    icon: Icons.settings_outlined,
                    label: 'Paramètres',
                    onTap: () {},
                    isDark: isDark,
                  ),
                  const SizedBox(height: 5),

                  // Thin divider before destructive action
                  Divider(
                    color: TColors.borderLight,
                    thickness: 0.5,
                    height: 16,
                  ),

                  // Logout — red tinted card, no arrow
                  _menuItem(
                    context,
                    icon: Icons.logout_rounded,
                    label: 'Déconnexion',
                    isDark: isDark,
                    isRed: true,
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header Widget ──────────────────────────────────────────
  // Red background with curved bottom, avatar, name, role badge.
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: TColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 18),
      width: double.infinity,
      child: Column(children: [

        // Square rounded avatar with initials
        // TODO: Replace with user profile image if available
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5),
          ),
          child: const Center(
            child: Text('AB',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              )),
          ),
        ),

        const SizedBox(height: 8),

        // Full name — TODO: Replace with real user name
        const Text('Amira Bouazizi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          )),

        const SizedBox(height: 5),

        // Role badge — semi-transparent white pill
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Citoyen',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontFamily: 'Poppins',
            )),
        ),
      ]),
    );
  }

  // ── Menu Item Widget ───────────────────────────────────────
  // White card with:
  // - Colored icon box on the left (red tint for logout)
  // - Label text in the middle
  // - Arrow chevron on the right (hidden for logout)
  // isRed = true turns the card and icon red for logout action
  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool isRed = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          // Red tint for logout, white card for normal items
          color: isRed
            ? TColors.primaryLight
            : (isDark ? TColors.cardDark : TColors.cardLight),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRed
              ? TColors.primary.withValues(alpha: 0.15)
              : TColors.borderLight,
            width: 0.5),
        ),
        child: Row(children: [

          // Icon box — red for logout, primary tint for others
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: isRed
                ? TColors.primaryLight
                : (isDark
                    ? TColors.dark
                    : TColors.light),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 15,
              color: isRed ? TColors.primary : TColors.primary,
            ),
          ),

          const SizedBox(width: 10),

          // Label text
          Expanded(
            child: Text(label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                // Red text for logout action
                color: isRed
                  ? TColors.primary
                  : (isDark
                      ? TColors.textWhite
                      : TColors.textPrimary),
              )),
          ),

          // Arrow — hidden for logout since it's a destructive action
          if (!isRed)
            const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: TColors.grey,
            ),
        ]),
      ),
    );
  }

  // ── Logout Handler ─────────────────────────────────────────
  // Removes all routes and goes back to LoginScreen.
  // pushAndRemoveUntil ensures clean navigation stack.
  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}