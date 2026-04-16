import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_t_hero/screens/admin/admin_users_screen.dart';
import 'package:frontend_t_hero/screens/admin/admin_signalements_screen.dart';
import 'package:frontend_t_hero/screens/admin/admin_categories_screen.dart';
import 'package:frontend_t_hero/screens/auth/login_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';
import 'package:frontend_t_hero/utils/constants/api_constant.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _index = 0;

  // ── Real stats ─────────────────────────────────────────────
  int _totalUsers        = 0;
  int _totalSignalements = 0;
  int _totalResolus      = 0;
  int _totalAgents       = 0;
  List<Map<String, dynamic>> _recentSignalements = [];
  List<Map<String, dynamic>> _categories         = [];
  bool _loadingStats = true;
  String _adminName  = 'Admin';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _loadAdminName();
    _fetchStats();
  }

  Future<void> _loadAdminName() async {
    final prefs   = await SharedPreferences.getInstance();
    final userRaw = prefs.getString('user') ?? '{}';
    final user    = jsonDecode(userRaw);
    setState(() => _adminName = user['nom'] ?? 'Admin');
  }

  Future<void> _fetchStats() async {
    setState(() => _loadingStats = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final headers = {
        'Content-Type':  'application/json',
        'Authorization': 'Bearer $token',
      };

      // Fetch all in parallel
      final results = await Future.wait([
        http.get(Uri.parse(ApiConstants.getAllUsers),
          headers: headers),
        http.get(Uri.parse(ApiConstants.getAllSignalements),
          headers: headers),
        http.get(Uri.parse(ApiConstants.getAllAgents),
          headers: headers),
        http.get(Uri.parse(ApiConstants.getAllCategories),
          headers: headers),
      ]);

      // Users
      if (results[0].statusCode == 200) {
        final data = jsonDecode(results[0].body);
        _totalUsers = (data['data'] as List).length;
      }

      // Signalements
      if (results[1].statusCode == 200) {
        final data = jsonDecode(results[1].body);
        final list = data['data'] as List;
        _totalSignalements = list.length;
        _totalResolus = list
          .where((s) => s['statut'] == 'RESOLU').length;
        _recentSignalements = list
          .take(3)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      }

      // Agents
      if (results[2].statusCode == 200) {
        final data = jsonDecode(results[2].body);
        _totalAgents = (data['data'] as List).length;
      }

      // Categories
      if (results[3].statusCode == 200) {
        final data = jsonDecode(results[3].body);
        _categories = (data['data'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      }

      setState(() => _loadingStats = false);
    } catch (e) {
      setState(() => _loadingStats = false);
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    if (!mounted) return;
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
      child: RefreshIndicator(
        onRefresh: _fetchStats,
        color: TColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Header ──────────────────────────────────────
              Container(
                color: isDark ? TColors.cardDark : TColors.cardLight,
                padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dashboard Admin',
                          style: TextStyle(
                            fontSize: 13,
                            color: TColors.textHint,
                            fontFamily: 'Poppins',
                          )),
                        Text(_adminName,
                          style: const TextStyle(
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
                      const SizedBox(width: 8),
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

              // ── Stat Cards ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: _loadingStats
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: TColors.primary)))
                  : GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.2,
                      children: [
                        _statCard('$_totalUsers', 'Utilisateurs',
                          Icons.people_outline, TColors.primary,
                          TColors.primaryLight, isDark),
                        _statCard('$_totalSignalements',
                          'Signalements',
                          Icons.flag_outlined, TColors.info,
                          TColors.infoLight, isDark),
                        _statCard('$_totalResolus', 'Résolus',
                          Icons.check_circle_outline,
                          TColors.success,
                          TColors.successLight, isDark),
                        _statCard('$_totalAgents', 'Agents',
                          Icons.engineering_outlined,
                          TColors.warning,
                          TColors.warningLight, isDark),
                      ],
                    ),
              ),

              // ── Bar Chart — real categories ──────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                      ? TColors.cardDark : TColors.cardLight,
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
                      _buildBarChart(isDark),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Recent Signalements ──────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                      ? TColors.cardDark : TColors.cardLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: TColors.borderLight, width: 0.5),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Récents',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: TColors.textSecondary,
                            fontFamily: 'Poppins',
                          )),
                        GestureDetector(
                          onTap: () =>
                            setState(() => _index = 2),
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
                    if (_loadingStats)
                      const CircularProgressIndicator(
                        color: TColors.primary)
                    else if (_recentSignalements.isEmpty)
                      const Text('Aucun signalement',
                        style: TextStyle(
                          fontSize: 14,
                          color: TColors.textHint,
                          fontFamily: 'Poppins',
                        ))
                    else
                      ..._recentSignalements.map((s) {
                        final desc = s['description'] ?? '—';
                        final citoyen = s['citoyen'];
                        final citoyenNom = citoyen is Map
                          ? citoyen['nom'] ?? '—' : '—';
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 10),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () =>
                                setState(() => _index = 2),
                              borderRadius:
                                BorderRadius.circular(10),
                              child: Padding(
                                padding:
                                  const EdgeInsets.symmetric(
                                    vertical: 4),
                                child: Row(children: [
                                  Container(
                                    width: 8, height: 8,
                                    decoration:
                                      const BoxDecoration(
                                        color: TColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                      children: [
                                        Text(desc,
                                          overflow:
                                            TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark
                                              ? TColors.textWhite
                                              : TColors.textPrimary,
                                            fontFamily: 'Poppins',
                                          )),
                                        Text(citoyenNom,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: TColors.textHint,
                                            fontFamily: 'Poppins',
                                          )),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: TColors.grey),
                                ]),
                              ),
                            ),
                          ),
                        );
                      }),
                  ]),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
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

  Widget _buildBarChart(bool isDark) {
    if (_categories.isEmpty) {
      return const Text('Aucune donnée',
        style: TextStyle(
          fontSize: 13,
          color: TColors.textHint,
          fontFamily: 'Poppins',
        ));
    }

    // Show max 5 categories
    final cats = _categories.take(5).toList();
    cats.length.toDouble();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: cats.asMap().entries.map((entry) {
        final i    = entry.key;
        final cat  = entry.value;
        final nom  = cat['nom'] ?? '';
        // Proportional height based on position
        final value = (cats.length - i) / cats.length;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(children: [
              Container(
                height: 56 * value,
                decoration: BoxDecoration(
                  color: TColors.primary
                    .withValues(alpha: 0.4 + (value * 0.6)),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6)),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                nom.length > 6
                  ? '${nom.substring(0, 6)}.' : nom,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9,
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