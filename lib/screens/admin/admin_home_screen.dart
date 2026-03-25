// ============================================================
// AdminHomeScreen — Main Dashboard for Administrateur Role
// ============================================================
// Main screen for admin users after login.
// Uses IndexedStack with BottomNavigationBar for 4 tabs:
//   0 → Dashboard (stats grid + chart + recent signalements)
//   1 → AdminUsersScreen
//   2 → AdminSignalementsScreen
//   3 → AdminCategoriesScreen
//
// Design decisions:
// - White card header with name + role badge + logout button
// - 4 colored stat cards in 2x2 grid — each has its own color
// - Bar chart shows signalements per category
// - Recent signalements list with "Voir tout" link to tab 2
// - No scrolling — everything fits on one screen
// - Logout icon in header — always visible for quick access
//
// TODO: Replace mock data with real API calls:
//   - GET /users/GetAllUsers → count by role
//   - GET /signalements/GetAllSignalements → count + recent
//   - GET /categories/GetAllCategories → chart data
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_t_hero/screens/admin/admin_users_screen.dart';
import 'package:frontend_t_hero/screens/admin/admin_signalements_screen.dart';
import 'package:frontend_t_hero/screens/admin/admin_categories_screen.dart';
import 'package:frontend_t_hero/screens/auth/login_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {

  // Active bottom nav tab index
  int _index = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.light,

      // IndexedStack keeps all tabs alive — no rebuild on switch
      body: IndexedStack(
        index: _index,
        children: [
          _dashboardTab(isDark),
          const AdminUsersScreen(),
          const AdminSignalementsScreen(),
          const AdminCategoriesScreen(),
        ],
      ),

      // ── Bottom Navigation Bar ──────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        selectedItemColor: TColors.primary,
        unselectedItemColor: TColors.grey,
        backgroundColor: isDark ? TColors.cardDark : TColors.cardLight,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 7,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(
          fontSize: 7, fontFamily: 'Poppins'),
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded, size: 19),
            label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline, size: 19),
            label: 'Utilisateurs'),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined, size: 19),
            label: 'Signalements'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined, size: 19),
            label: 'Catégories'),
        ],
      ),
    );
  }

  // ── Dashboard Tab ──────────────────────────────────────────
  // Shows: white header, 2x2 stat grid, bar chart, recent list.
  // Everything fits without scrolling.
  Widget _dashboardTab(bool isDark) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── White Header ────────────────────────────────
          // Name + role badge + logout button
          Container(
            color: isDark ? TColors.cardDark : TColors.cardLight,
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dashboard Admin',
                      style: TextStyle(
                        fontSize: 9,
                        color: TColors.textHint,
                        fontFamily: 'Poppins',
                      )),
                    const Text('Admin Principal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TColors.textPrimary,
                        fontFamily: 'Poppins',
                      )),
                  ],
                ),
                Row(children: [
                  // Admin role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: TColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Admin',
                      style: TextStyle(
                        fontSize: 8,
                        color: TColors.primary,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      )),
                  ),
                  const SizedBox(width: 4),
                  // Logout button — always visible in header
                  IconButton(
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: TColors.primary, size: 18),
                    onPressed: () => _logout(),
                    padding: const EdgeInsets.all(8),
                  ),
                ]),
              ],
            ),
          ),

          // ── 2x2 Stat Cards Grid ─────────────────────────
          // Each card has its own color to distinguish metrics
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 2.0,
              children: [
                _statCard('14', 'Utilisateurs',
                  Icons.people_outline, TColors.primary,
                  TColors.primaryLight, isDark),
                _statCard('4', 'Signalements',
                  Icons.flag_outlined, TColors.info,
                  TColors.infoLight, isDark),
                _statCard('1', 'Résolus',
                  Icons.check_circle_outline, TColors.success,
                  TColors.successLight, isDark),
                _statCard('3', 'Agents',
                  Icons.engineering_outlined, TColors.warning,
                  TColors.warningLight, isDark),
              ],
            ),
          ),

          // ── Bar Chart Card ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? TColors.cardDark : TColors.cardLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: TColors.borderLight, width: 0.5),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Par catégorie',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: TColors.textSecondary,
                      fontFamily: 'Poppins',
                    )),
                  const SizedBox(height: 10),
                  _buildBarChart(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ── Recent Signalements Card ────────────────────
          // Shows last 2 signalements with link to full list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? TColors.cardDark : TColors.cardLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: TColors.borderLight, width: 0.5),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Récents',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: TColors.textSecondary,
                        fontFamily: 'Poppins',
                      )),
                    GestureDetector(
                      onTap: () => setState(() => _index = 2),
                      child: const Text('Voir tout →',
                        style: TextStyle(
                          fontSize: 9,
                          color: TColors.primary,
                          fontFamily: 'Poppins',
                        )),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Two recent signalement rows
                ...[
                  'Nid de poule — Bourguiba',
                  'Lampadaire cassé — Sfax',
                ].map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(children: [
                    Container(
                      width: 5, height: 5,
                      decoration: const BoxDecoration(
                        color: TColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(t,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                            ? TColors.textWhite : TColors.textPrimary,
                          fontFamily: 'Poppins',
                        )),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                      size: 10, color: TColors.grey),
                  ]),
                )),
              ]),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ── Stat Card Widget ───────────────────────────────────────
  // Each card shows: icon box + number + label.
  // Color and background are passed in for per-metric theming.
  Widget _statCard(
      String num,
      String label,
      IconData icon,
      Color color,
      Color bgColor,
      bool isDark) {
    return Container(
      decoration: BoxDecoration(
        // Light color bg per metric — no all-gray cards
        color: isDark
          ? color.withValues(alpha: 0.12)
          : bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12, vertical: 8),
      child: Row(children: [

        // Icon box
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 16),
        ),

        const SizedBox(width: 8),

        // Number + label
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(num,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color,
                fontFamily: 'Poppins',
              )),
            Text(label,
              style: const TextStyle(
                fontSize: 8,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              )),
          ],
        ),
      ]),
    );
  }

  // ── Bar Chart Widget ───────────────────────────────────────
  // Simple bar chart showing signalements per category.
  // Bars use varying red opacity to show relative volumes.
  Widget _buildBarChart() {
    final data = [
      {'label': 'Voirie',    'value': 0.9},
      {'label': 'Eclairage', 'value': 0.65},
      {'label': 'Propreté',  'value': 0.5},
      {'label': 'Espaces',   'value': 0.35},
      {'label': 'Autre',     'value': 0.2},
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((d) {
        final value = d['value'] as double;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(children: [
              // Bar — height proportional to value, max 48px
              Container(
                height: 48 * value,
                decoration: BoxDecoration(
                  // Full opacity for highest bar, fades for smaller
                  color: TColors.primary.withValues(alpha: value),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4)),
                ),
              ),
              const SizedBox(height: 4),
              // Category label below bar
              Text(d['label'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 7,
                  color: TColors.textHint,
                  fontFamily: 'Poppins',
                )),
            ]),
          ),
        );
      }).toList(),
    );
  }

  // ── Logout Handler ─────────────────────────────────────────
  // Clears entire navigation stack and returns to LoginScreen.
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}