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
  int _index = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.light,
      body: IndexedStack(
        index: _index,
        children: [
          _dashboardTab(isDark),
          const AdminUsersScreen(),
          const AdminSignalementsScreen(),
          const AdminCategoriesScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        selectedItemColor: TColors.primary,
        unselectedItemColor: TColors.grey,
        backgroundColor: isDark ? TColors.cardDark : TColors.cardLight,
        elevation: 4,
        selectedLabelStyle: const TextStyle(
          fontSize: 11, fontFamily: 'Poppins',
          fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11, fontFamily: 'Poppins'),
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded, size: 24),
            label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline, size: 24),
            label: 'Utilisateurs'),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined, size: 24),
            label: 'Signalements'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined, size: 24),
            label: 'Catégories'),
        ],
      ),
    );
  }

  Widget _dashboardTab(bool isDark) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── White Header ──────────────────────────────────
          Container(
            color: isDark ? TColors.cardDark : TColors.cardLight,
            padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dashboard Admin',
                      style: TextStyle(
                        fontSize: 13,
                        color: TColors.textHint,
                        fontFamily: 'Poppins',
                      )),
                    const Text('Admin Principal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TColors.textPrimary,
                        fontFamily: 'Poppins',
                      )),
                  ],
                ),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: TColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Admin',
                      style: TextStyle(
                        fontSize: 12,
                        color: TColors.primary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      )),
                  ),
                  // Logout button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _logout,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: TColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: TColors.primary, size: 20),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),

          // ── 2x2 Stat Cards Grid ───────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
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

          // ── Bar Chart ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? TColors.cardDark : TColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: TColors.borderLight, width: 0.5),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Par catégorie',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: TColors.textSecondary,
                      fontFamily: 'Poppins',
                    )),
                  const SizedBox(height: 12),
                  _buildBarChart(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Recent Signalements ───────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? TColors.cardDark : TColors.cardLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: TColors.borderLight, width: 0.5),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Récents',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: TColors.textSecondary,
                          fontFamily: 'Poppins',
                        )),
                      GestureDetector(
                        onTap: () => setState(() => _index = 2),
                        child: const Text('Voir tout →',
                          style: TextStyle(
                            fontSize: 13,
                            color: TColors.primary,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...[
                    'Nid de poule — Bourguiba',
                    'Lampadaire cassé — Sfax',
                  ].map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _index = 2),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4),
                          child: Row(children: [
                            Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(
                                color: TColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(t,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                    ? TColors.textWhite
                                    : TColors.textPrimary,
                                  fontFamily: 'Poppins',
                                ))),
                            const Icon(Icons.arrow_forward_ios,
                              size: 14, color: TColors.grey),
                          ]),
                        ),
                      ),
                    ),
                  )),
                ]),
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _statCard(String num, String label, IconData icon,
      Color color, Color bgColor, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Ink(
          decoration: BoxDecoration(
            color: isDark
              ? color.withValues(alpha: 0.12) : bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2), width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 10),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(num,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontFamily: 'Poppins',
                    )),
                  Text(label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: TColors.textHint,
                      fontFamily: 'Poppins',
                    )),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }

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
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(children: [
              Container(
                height: 56 * value,
                decoration: BoxDecoration(
                  color: TColors.primary.withValues(alpha: value),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6)),
                ),
              ),
              const SizedBox(height: 6),
              Text(d['label'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: TColors.textHint,
                  fontFamily: 'Poppins',
                )),
            ]),
          ),
        );
      }).toList(),
    );
  }
}