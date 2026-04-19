import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_t_hero/screens/admin/admin_users_screen.dart';
import 'package:frontend_t_hero/screens/admin/admin_signalements_screen.dart';
import 'package:frontend_t_hero/screens/admin/admin_categories_screen.dart';
import 'package:frontend_t_hero/screens/admin/admin_profile_screen.dart';
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

  int _totalUsers        = 0;
  int _totalSignalements = 0;
  int _totalResolus      = 0;
  int _totalAgents       = 0;
  int _totalEnCours      = 0;
  int _totalEnAttente    = 0;
  List<Map<String, dynamic>> _recentSignalements = [];
  List<Map<String, dynamic>> _categories         = [];
  Map<String, int> _catCounts = {};
  bool   _loadingStats = true;
  String _adminName    = 'Admin';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
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

      if (results[0].statusCode == 200) {
        final data = jsonDecode(results[0].body);
        _totalUsers = (data['data'] as List).length;
      }

      if (results[1].statusCode == 200) {
        final data = jsonDecode(results[1].body);
        final list = data['data'] as List;
        _totalSignalements = list.length;
        _totalResolus   = list
          .where((s) => s['statut'] == 'RESOLU').length;
        _totalEnCours   = list
          .where((s) => s['statut'] == 'EN_COURS').length;
        _totalEnAttente = list
          .where((s) => s['statut'] == 'EN_ATTENTE').length;
        _recentSignalements = list
          .take(4)
          .map((e) => e as Map<String, dynamic>)
          .toList();

        final Map<String, int> counts = {};
        for (final s in list) {
          final cat = s['categorie'];
          String catId = '';
          if (cat is Map) catId = cat['_id'] ?? '';
          else if (cat is String) catId = cat;
          if (catId.isNotEmpty) {
            counts[catId] = (counts[catId] ?? 0) + 1;
          }
        }
        _catCounts = counts;
      }

      if (results[2].statusCode == 200) {
        final data = jsonDecode(results[2].body);
        _totalAgents = (data['data'] as List).length;
      }

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

  Color _statusColor(String s) {
    switch (s) {
      case 'EN_COURS': return TColors.info;
      case 'RESOLU':   return TColors.success;
      default:         return TColors.warning;
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'EN_COURS': return TColors.infoLight;
      case 'RESOLU':   return TColors.successLight;
      default:         return TColors.warningLight;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'EN_COURS': return 'En cours';
      case 'RESOLU':   return 'Résolu';
      default:         return 'En attente';
    }
  }

  String _catName(dynamic cat) {
    if (cat == null) return 'Autre';
    if (cat is Map) return cat['nom'] ?? 'Autre';
    return cat.toString();
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}min';
      if (diff.inHours < 24)   return '${diff.inHours}h';
      return '${diff.inDays}j';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
      Theme.of(context).brightness == Brightness.dark;
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
        backgroundColor:
          isDark ? TColors.cardDark : TColors.cardLight,
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

              // ── Gradient Header ──────────────────────────
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
                  16, 16, 16, 20),
                child: Column(children: [

                  // Top row
                  Row(
                    mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                          CrossAxisAlignment.start,
                        children: [
                          const Text('Tableau de bord',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              fontFamily: 'Poppins',
                            )),
                          Text(_adminName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            )),
                        ],
                      ),
                      Row(children: [

                        // Admin badge
                        Container(
                          padding:
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white
                              .withValues(alpha: 0.2),
                            borderRadius:
                              BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white
                                .withValues(alpha: 0.3))),
                          child: const Row(children: [
                            Icon(Icons.shield_outlined,
                              size: 13,
                              color: Colors.white),
                            SizedBox(width: 4),
                            Text('Administrateur',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              )),
                          ]),
                        ),

                        const SizedBox(width: 8),

                        // Profile button
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                const AdminProfileScreen())),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                    .withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset:
                                    const Offset(0, 2)),
                              ]),
                            child: const Icon(
                              Icons.person_outline,
                              color: TColors.primary,
                              size: 18)),
                        ),

                        const SizedBox(width: 8),

                        // Logout button
                        GestureDetector(
                          onTap: _logout,
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
                              Icons.logout_rounded,
                              color: Colors.white,
                              size: 17)),
                        ),
                      ]),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Stats strip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white
                        .withValues(alpha: 0.15),
                      borderRadius:
                        BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white
                          .withValues(alpha: 0.2))),
                    child: Row(children: [
                      _bannerStat('$_totalSignalements',
                        'Signalements',
                        Icons.flag_outlined),
                      _bannerDiv(),
                      _bannerStat('$_totalResolus',
                        'Résolus',
                        Icons.check_circle_outline),
                      _bannerDiv(),
                      _bannerStat('$_totalUsers',
                        'Citoyens',
                        Icons.people_outline),
                      _bannerDiv(),
                      _bannerStat('$_totalAgents',
                        'Agents',
                        Icons.engineering_outlined),
                    ]),
                  ),

                  const SizedBox(height: 14),

                  // Encouragement
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white
                        .withValues(alpha: 0.15),
                      borderRadius:
                        BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white
                          .withValues(alpha: 0.2))),
                    child: Row(children: [
                      const Text('🏛️',
                        style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                            CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gérez votre ville intelligente',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              )),
                            Text(
                              'T HERO — Smart City Tunisia 🇹🇳',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white
                                  .withValues(alpha: 0.85),
                                fontFamily: 'Poppins',
                              )),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),

              const SizedBox(height: 14),

              // ── Status overview ──────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16),
                child: const Row(children: [
                  Text('📊 ',
                    style: TextStyle(fontSize: 14)),
                  Text('Aperçu des statuts',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: TColors.textPrimary,
                      fontFamily: 'Poppins',
                    )),
                ]),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16),
                child: _loadingStats
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: TColors.primary))
                  : Row(children: [
                      Expanded(child: _statusCard(
                        '$_totalEnAttente',
                        'En attente',
                        Icons.hourglass_empty_rounded,
                        TColors.warning,
                        TColors.warningLight,
                        isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _statusCard(
                        '$_totalEnCours',
                        'En cours',
                        Icons.bolt_rounded,
                        TColors.info,
                        TColors.infoLight,
                        isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _statusCard(
                        '$_totalResolus',
                        'Résolus',
                        Icons.check_circle_outline,
                        TColors.success,
                        TColors.successLight,
                        isDark)),
                    ]),
              ),

              const SizedBox(height: 14),

              // ── Bar chart ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                      ? TColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: TColors.borderLight,
                      width: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                          .withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                      CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Text('📈 ',
                          style: TextStyle(fontSize: 14)),
                        Text(
                          'Signalements par catégorie',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: TColors.textPrimary,
                            fontFamily: 'Poppins',
                          )),
                      ]),
                      const SizedBox(height: 16),
                      _loadingStats
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: TColors.primary))
                        : _buildRealBarChart(isDark),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Recent signalements ──────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                      ? TColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: TColors.borderLight,
                      width: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                          .withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(children: [
                          Text('🕐 ',
                            style: TextStyle(
                              fontSize: 14)),
                          Text('Signalements récents',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: TColors.textPrimary,
                              fontFamily: 'Poppins',
                            )),
                        ]),
                        GestureDetector(
                          onTap: () =>
                            setState(() => _index = 2),
                          child: Container(
                            padding:
                              const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4),
                            decoration: BoxDecoration(
                              color: TColors.primaryLight,
                              borderRadius:
                                BorderRadius.circular(20)),
                            child: const Text(
                              'Voir tout →',
                              style: TextStyle(
                                fontSize: 12,
                                color: TColors.primary,
                                fontFamily: 'Poppins',
                                fontWeight:
                                  FontWeight.w600,
                              )),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_loadingStats)
                      const Center(
                        child: CircularProgressIndicator(
                          color: TColors.primary))
                    else if (_recentSignalements.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(children: [
                          Text('📋',
                            style: TextStyle(
                              fontSize: 36)),
                          SizedBox(height: 8),
                          Text('Aucun signalement',
                            style: TextStyle(
                              fontSize: 14,
                              color: TColors.textHint,
                              fontFamily: 'Poppins',
                            )),
                        ]),
                      )
                    else
                      ..._recentSignalements.map((s) {
                        final statut =
                          s['statut'] ?? 'EN_ATTENTE';
                        final desc =
                          s['description'] ?? '—';
                        final cat =
                          _catName(s['categorie']);
                        final time =
                          _timeAgo(s['createdAt']);
                        final citoyen = s['citoyen'];
                        final citoyenNom =
                          citoyen is Map
                            ? citoyen['nom'] ?? '—'
                            : '—';
                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: 10),
                          decoration: BoxDecoration(
                            color: isDark
                              ? TColors.dark
                              : TColors.light,
                            borderRadius:
                              BorderRadius.circular(12),
                            border: Border.all(
                              color: TColors.borderLight,
                              width: 0.5)),
                          padding:
                            const EdgeInsets.all(12),
                          child: Row(children: [
                            Container(
                              width: 42, height: 42,
                              decoration: BoxDecoration(
                                color: _statusBg(statut),
                                borderRadius:
                                  BorderRadius.circular(
                                    12)),
                              child: Icon(
                                Icons.flag_outlined,
                                size: 20,
                                color: _statusColor(
                                  statut))),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                  CrossAxisAlignment
                                    .start,
                                children: [
                                  Text(desc,
                                    overflow:
                                      TextOverflow
                                        .ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight:
                                        FontWeight.w600,
                                      color: isDark
                                        ? TColors.textWhite
                                        : TColors
                                            .textPrimary,
                                      fontFamily:
                                        'Poppins',
                                    )),
                                  const SizedBox(height: 3),
                                  Text(
                                    '$citoyenNom · '
                                    '$cat · $time',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color:
                                        TColors.textHint,
                                      fontFamily:
                                        'Poppins',
                                    )),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusBg(statut),
                                borderRadius:
                                  BorderRadius.circular(
                                    20)),
                              child: Text(
                                _statusLabel(statut),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight:
                                    FontWeight.w600,
                                  color: _statusColor(
                                    statut),
                                  fontFamily: 'Poppins',
                                ))),
                          ]),
                        );
                      }),
                  ]),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealBarChart(bool isDark) {
    if (_categories.isEmpty || _catCounts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Column(children: [
          Text('📊', style: TextStyle(fontSize: 36)),
          SizedBox(height: 8),
          Text('Aucune donnée disponible',
            style: TextStyle(
              fontSize: 13,
              color: TColors.textHint,
              fontFamily: 'Poppins',
            )),
        ]),
      );
    }

    final List<MapEntry<String, int>> entries = [];
    for (final cat in _categories) {
      final id    = cat['_id'] ?? '';
      final nom   = cat['nom'] ?? 'Autre';
      final count = _catCounts[id] ?? 0;
      entries.add(MapEntry(nom, count));
    }
    entries.sort((a, b) => b.value.compareTo(a.value));

    final maxCount = entries.isEmpty ? 1
      : entries.first.value == 0 ? 1
      : entries.first.value;
    const maxBarHeight = 80.0;

    final barColors = [
      TColors.primary,
      TColors.info,
      TColors.success,
      TColors.warning,
      const Color(0xFF6366F1),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: maxBarHeight + 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: entries.asMap().entries.map((e) {
              final i     = e.key;
              final nom   = e.value.key;
              final count = e.value.value;
              final ratio = count / maxCount;
              final barH  = ratio * maxBarHeight;
              final color =
                barColors[i % barColors.length];
              final shortNom = nom.length > 7
                ? nom.substring(0, 6) : nom;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4),
                  child: Column(
                    mainAxisAlignment:
                      MainAxisAlignment.end,
                    children: [
                      Text('$count',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                          fontFamily: 'Poppins',
                        )),
                      const SizedBox(height: 3),
                      AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 600),
                        curve: Curves.easeOut,
                        height: barH < 8 ? 8 : barH,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius:
                            const BorderRadius.vertical(
                              top: Radius.circular(6)),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(
                                alpha: 0.3),
                              blurRadius: 6,
                              offset:
                                const Offset(0, 2)),
                          ]),
                      ),
                      const SizedBox(height: 8),
                      Text(shortNom,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isDark
                            ? TColors.textWhite
                            : TColors.textSecondary,
                          fontFamily: 'Poppins',
                        )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 0.5,
          color: TColors.borderLight),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: entries.asMap().entries.map((e) {
            final i     = e.key;
            final nom   = e.value.key;
            final count = e.value.value;
            final color =
              barColors[i % barColors.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius:
                      BorderRadius.circular(3))),
                const SizedBox(width: 5),
                Text('$nom ($count)',
                  style: const TextStyle(
                    fontSize: 10,
                    color: TColors.textHint,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  )),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _statusCard(String num, String label,
      IconData icon, Color color, Color bg, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
          ? color.withValues(alpha: 0.12) : bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(num,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
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
    );
  }

  Widget _bannerStat(String num, String label,
      IconData icon) {
    return Expanded(
      child: Column(children: [
        Icon(icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 15),
        const SizedBox(height: 3),
        Text(num,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Poppins',
          )),
        const SizedBox(height: 1),
        Text(label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withValues(alpha: 0.75),
            fontFamily: 'Poppins',
          )),
      ]),
    );
  }

  Widget _bannerDiv() => Container(
    width: 1, height: 28,
    color: Colors.white.withValues(alpha: 0.2));
}