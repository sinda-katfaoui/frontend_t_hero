// ============================================================
// AgentProfileScreen — Agent Municipal Profile Tab
// ============================================================
// Profile screen for the Agent Municipal role.
// Embedded in AgentHomeScreen's IndexedStack at tab index 2.
//
// Differences from CitoyenProfileScreen:
//   - Shows 3 stat badges inside the header (Assignés, En cours, Résolus)
//   - Has an extra "Analyses IA" menu item
//   - Role badge shows "Agent Municipal" instead of "Citoyen"
//
// Design decisions:
// - Red curved header (26px radius) with stats row inside
// - Square rounded avatar (16px radius) — modern not circle
// - Stats row inside header avoids separate gray stat boxes
// - Vertical dividers between stat numbers for clean separation
// - Menu items are white cards with icon box + arrow
// - Logout card is red tinted — signals destructive action
// - Everything fits on screen — no scrolling needed
//
// TODO: Replace hardcoded data with real agent user info
// from auth state or shared preferences.
// ============================================================

import 'package:flutter/material.dart';
import 'package:frontend_t_hero/screens/auth/login_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class AgentProfileScreen extends StatelessWidget {
  const AgentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── Red Header ───────────────────────────────────
          // Avatar + name + role badge + stats row
          _buildHeader(),

          const SizedBox(height: 10),

          // ── Menu Items ───────────────────────────────────
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
                  // Agent-specific: quick access to AI analyses
                  _menuItem(
                    context,
                    icon: Icons.auto_awesome_outlined,
                    label: 'Analyses IA',
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

                  // Divider before destructive logout action
                  Divider(
                    color: TColors.borderLight,
                    thickness: 0.5,
                    height: 16,
                  ),

                  // Logout — red card, no arrow
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
  // Red background with curved bottom, avatar, name,
  // role badge, and stats row unique to agent profile.
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: TColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
      width: double.infinity,
      child: Column(children: [

        // Square rounded avatar with initials
        // TODO: Replace with real agent profile image
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
            child: Text('AH',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              )),
          ),
        ),

        const SizedBox(height: 8),

        // Agent name — TODO: Replace with real user name
        const Text('Agent Habib',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          )),

        const SizedBox(height: 5),

        // Role badge pill
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Agent Municipal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontFamily: 'Poppins',
            )),
        ),

        const SizedBox(height: 12),

        // Stats row — unique to agent profile
        // Shows performance numbers at a glance
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _statBadge('5', 'Assignés'),
            _verticalDivider(),
            _statBadge('3', 'En cours'),
            _verticalDivider(),
            _statBadge('2', 'Résolus'),
          ],
        ),
      ]),
    );
  }

  // ── Stat Badge ─────────────────────────────────────────────
  // Single stat number + label inside the red header.
  Widget _statBadge(String num, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        Text(num,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          )),
        const SizedBox(height: 1),
        Text(label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 8,
            fontFamily: 'Poppins',
          )),
      ]),
    );
  }

  // ── Vertical Divider ───────────────────────────────────────
  // Thin white line between stat badges in header.
  Widget _verticalDivider() {
    return Container(
      width: 0.5,
      height: 24,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  // ── Menu Item Widget ───────────────────────────────────────
  // White card with icon box + label + optional arrow.
  // isRed = true → red tinted card for logout action.
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

          // Icon box
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: isRed
                ? TColors.primaryLight
                : (isDark ? TColors.dark : TColors.light),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
              size: 15,
              color: TColors.primary),
          ),

          const SizedBox(width: 10),

          // Label
          Expanded(
            child: Text(label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                color: isRed
                  ? TColors.primary
                  : (isDark
                      ? TColors.textWhite
                      : TColors.textPrimary),
              )),
          ),

          // Arrow — hidden for logout
          if (!isRed)
            const Icon(Icons.arrow_forward_ios,
              size: 12, color: TColors.grey),
        ]),
      ),
    );
  }

  // ── Logout Handler ─────────────────────────────────────────
  // Clears navigation stack and returns to LoginScreen.
  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}