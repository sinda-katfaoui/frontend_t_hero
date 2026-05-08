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
  List<Map<String, dynamic>> _allSignalements    = [];
  List<Map<String, dynamic>> _categories         = [];
  Map<String, int>           _catCounts          = {};

  bool    _loadingStats = true;
  String  _adminName    = 'Admin';
  String? _statsError;

  // ── Professional single-hue palette ─────────────────────────
  // All bars use shades of TColors.primary (red) from dark to light
  static const List<Color> _barShades = [
    Color(0xFFB71C1C), // darkest
    Color(0xFFD32F2F),
    Color(0xFFE53935),
    Color(0xFFEF5350),
    Color(0xFFEF9A9A), // lightest
  ];

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
    final prefs  = await SharedPreferences.getInstance();
    final user   = jsonDecode(prefs.getString('user') ?? '{}');
    setState(() => _adminName = user['nom'] ?? 'Admin');
  }

  Future<void> _fetchStats() async {
    setState(() { _loadingStats = true; _statsError = null; });
    try {
      final prefs   = await SharedPreferences.getInstance();
      final token   = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() { _loadingStats = false; _statsError = 'Token manquant — reconnectez-vous'; });
        return;
      }
      final headers = { 'Content-Type': 'application/json', 'Authorization': 'Bearer $token' };

      http.Response? usersRes, sigsRes, agentsRes, catsRes;

      try { usersRes  = await http.get(Uri.parse(ApiConstants.getAllUsers),       headers: headers).timeout(const Duration(seconds: 10)); } catch (_) {}
      try { sigsRes   = await http.get(Uri.parse(ApiConstants.getAllSignalements), headers: headers).timeout(const Duration(seconds: 10)); } catch (_) {}
      try { agentsRes = await http.get(Uri.parse(ApiConstants.getAllAgents),       headers: headers).timeout(const Duration(seconds: 10)); } catch (_) {}
      try { catsRes   = await http.get(Uri.parse(ApiConstants.getAllCategories),   headers: headers).timeout(const Duration(seconds: 10)); } catch (_) {}

      if (usersRes?.statusCode == 200) {
        _totalUsers = (jsonDecode(usersRes!.body)['data'] as List).length;
      }

      if (sigsRes?.statusCode == 200) {
        final list = (jsonDecode(sigsRes!.body)['data'] as List).cast<Map<String, dynamic>>();
        _allSignalements    = list;
        _totalSignalements  = list.length;
        _totalResolus       = list.where((s) => s['statut'] == 'RESOLU').length;
        _totalEnCours       = list.where((s) => s['statut'] == 'EN_COURS').length;
        _totalEnAttente     = list.where((s) => s['statut'] == 'EN_ATTENTE').length;
        _recentSignalements = list.take(4).toList();
        final Map<String, int> counts = {};
        for (final s in list) {
          final cat = s['categorie'];
          final id  = cat is Map ? (cat['_id'] ?? '') : (cat ?? '');
          if (id.toString().isNotEmpty) counts[id.toString()] = (counts[id.toString()] ?? 0) + 1;
        }
        _catCounts = counts;
      }

      if (agentsRes?.statusCode == 200) {
        final list  = (jsonDecode(agentsRes!.body)['data'] as List).cast<Map<String, dynamic>>();
        _totalAgents = list.length;
      }

      if (catsRes?.statusCode == 200) {
        _categories = (jsonDecode(catsRes!.body)['data'] as List).cast<Map<String, dynamic>>();
      }

      setState(() => _loadingStats = false);
    } catch (e) {
      setState(() { _loadingStats = false; _statsError = 'Erreur de chargement: $e'; });
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
  }

  Color  _statusColor(String s) { switch (s) { case 'EN_COURS': return TColors.info; case 'RESOLU': return TColors.success; default: return TColors.warning; } }
  Color  _statusBg(String s)    { switch (s) { case 'EN_COURS': return TColors.infoLight; case 'RESOLU': return TColors.successLight; default: return TColors.warningLight; } }
  String _statusLabel(String s) { switch (s) { case 'EN_COURS': return 'En cours'; case 'RESOLU': return 'Résolu'; default: return 'En attente'; } }

  String _catName(dynamic cat) {
    if (cat == null) return 'Autre';
    if (cat is Map) return cat['nom'] ?? 'Autre';
    return cat.toString();
  }

  String _timeAgo(String? d) {
    if (d == null) return '';
    try {
      final diff = DateTime.now().difference(DateTime.parse(d));
      if (diff.inMinutes < 60) return '${diff.inMinutes}min';
      if (diff.inHours   < 24) return '${diff.inHours}h';
      return '${diff.inDays}j';
    } catch (_) { return ''; }
  }

  // ── Computed stats for statistics page ──────────────────────
  double get _resolutionRate => _totalSignalements == 0
    ? 0 : (_totalResolus / _totalSignalements * 100);

  Map<String, int> get _sigsByAgent {
    final Map<String, int> map = {};
    for (final s in _allSignalements) {
      final agent = s['agent'];
      if (agent is Map) {
        final nom = agent['nom'] ?? '—';
        map[nom] = (map[nom] ?? 0) + 1;
      }
    }
    return map;
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
        selectedLabelStyle:   const TextStyle(fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontFamily: 'Poppins'),
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded,  size: 24), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline,     size: 24), label: 'Utilisateurs'),
          BottomNavigationBarItem(icon: Icon(Icons.flag_outlined,      size: 24), label: 'Signalements'),
          BottomNavigationBarItem(icon: Icon(Icons.category_outlined,  size: 24), label: 'Catégories'),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // DASHBOARD TAB
  // ════════════════════════════════════════════════════════════
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
              _buildHeader(),
              const SizedBox(height: 14),
              if (_statsError != null) ...[
                _buildErrorBanner(),
                const SizedBox(height: 10),
              ],
              _sectionLabel('📊', 'Aperçu des statuts'),
              const SizedBox(height: 10),
              _buildStatusRow(isDark),
              const SizedBox(height: 14),
              _buildCategoryChart(isDark),
              const SizedBox(height: 14),
              _buildStatisticsCard(isDark),
              const SizedBox(height: 14),
              _buildRecentSignalements(isDark),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [TColors.primary, Color(0xFFE53935)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28))),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Tableau de bord',
                  style: TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'Poppins')),
                Text(_adminName, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                    color: Colors.white, fontFamily: 'Poppins')),
              ]),
            ),
            const SizedBox(width: 8),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.shield_outlined, size: 13, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Admin', style: TextStyle(fontSize: 11, color: Colors.white,
                    fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                ])),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AdminProfileScreen())),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6, offset: const Offset(0, 2))]),
                  child: const Icon(Icons.person_outline, color: TColors.primary, size: 18))),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _logout,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
                  child: const Icon(Icons.logout_rounded, color: Colors.white, size: 17))),
            ]),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
          child: Row(children: [
            _bannerStat('$_totalSignalements', 'Signalements', Icons.flag_outlined),
            _bannerDiv(),
            _bannerStat('$_totalResolus',      'Résolus',      Icons.check_circle_outline),
            _bannerDiv(),
            _bannerStat('$_totalUsers',        'Utilisateurs', Icons.people_outline),
            _bannerDiv(),
            _bannerStat('$_totalAgents',       'Agents',       Icons.engineering_outlined),
          ]),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
          child: Row(children: [
            const Text('🏛️', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Gérez votre ville intelligente',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: Colors.white, fontFamily: 'Poppins')),
              Text('T HERO — Smart City Tunisia 🇹🇳',
                style: TextStyle(fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.85), fontFamily: 'Poppins')),
            ])),
          ]),
        ),
      ]),
    );
  }

  Widget _buildErrorBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFDECEC), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TColors.primary.withValues(alpha: 0.4))),
        child: Row(children: [
          const Icon(Icons.error_outline, color: TColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(_statsError!,
            style: const TextStyle(fontSize: 12, color: TColors.primary, fontFamily: 'Poppins'))),
          GestureDetector(onTap: _fetchStats,
            child: const Text('Réessayer',
              style: TextStyle(fontSize: 12, color: TColors.primary,
                fontWeight: FontWeight.w700, fontFamily: 'Poppins'))),
        ]),
      ),
    );
  }

  Widget _buildStatusRow(bool isDark) {
  if (_loadingStats) return const Center(child: CircularProgressIndicator(color: TColors.primary));
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(children: [
      Expanded(child: _statusCard('$_totalEnAttente', 'En attente',
        Icons.hourglass_empty_rounded,
        const Color(0xFF616161), const Color(0xFFF5F5F5), isDark)),
      const SizedBox(width: 10),
      Expanded(child: _statusCard('$_totalEnCours', 'En cours',
        Icons.bolt_rounded,
        const Color(0xFFB71C1C), const Color(0xFFFDECEC), isDark)),
      const SizedBox(width: 10),
      Expanded(child: _statusCard('$_totalResolus', 'Résolus',
        Icons.check_circle_outline,
        const Color(0xFF1B5E20), const Color(0xFFEDF7ED), isDark)),
    ]),
  );
}

  Widget _buildCategoryChart(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _card(isDark,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardTitle('📈', 'Signalements par catégorie'),
          const SizedBox(height: 16),
          _loadingStats
            ? const Center(child: CircularProgressIndicator(color: TColors.primary))
            : _buildBarChart(isDark),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // [NEW] STATISTICS CARD — dedicated municipality stats
  // ════════════════════════════════════════════════════════════
  Widget _buildStatisticsCard(bool isDark) {
    if (_loadingStats) return const SizedBox.shrink();

    final rate = _resolutionRate;
    final agentStats = _sigsByAgent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _card(isDark,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _cardTitle('📊', 'Statistiques de la municipalité'),
          const SizedBox(height: 16),

          // ── Taux de résolution ───────────────────────────
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Taux de résolution',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: TColors.textPrimary, fontFamily: 'Poppins')),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: TColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20)),
              child: Text('${rate.toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: TColors.primary, fontFamily: 'Poppins'))),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: rate / 100,
              minHeight: 10,
              backgroundColor: TColors.borderLight,
              valueColor: const AlwaysStoppedAnimation(TColors.primary))),
          const SizedBox(height: 6),
          Text('${_totalResolus} résolus sur ${_totalSignalements} signalements',
            style: const TextStyle(fontSize: 11, color: TColors.textHint, fontFamily: 'Poppins')),

          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 0.5, color: TColors.borderLight),
          const SizedBox(height: 14),

          // ── Répartition par statut ───────────────────────
          const Text('Répartition par statut',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: TColors.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 10),
          _statRow('En attente', _totalEnAttente, _totalSignalements, TColors.warning),
          const SizedBox(height: 8),
          _statRow('En cours',   _totalEnCours,   _totalSignalements, TColors.info),
          const SizedBox(height: 8),
          _statRow('Résolus',    _totalResolus,   _totalSignalements, TColors.success),

          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 0.5, color: TColors.borderLight),
          const SizedBox(height: 14),

          // ── Performance des agents ───────────────────────
          const Text('Performance des agents',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: TColors.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 10),

          if (agentStats.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TColors.borderLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10)),
              child: const Row(children: [
                Icon(Icons.info_outline, size: 14, color: TColors.textHint),
                SizedBox(width: 8),
                Text('Aucun agent assigné pour l\'instant',
                  style: TextStyle(fontSize: 12, color: TColors.textHint, fontFamily: 'Poppins')),
              ]))
          else
            ...agentStats.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _agentStatRow(e.key, e.value, isDark))),

          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 0.5, color: TColors.borderLight),
          const SizedBox(height: 14),

          // ── Résumé chiffres clés ─────────────────────────
          const Text('Chiffres clés',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: TColors.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _keyFigure('$_totalSignalements', 'Total signalements', Icons.flag_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _keyFigure('$_totalAgents',       'Agents actifs',      Icons.engineering_outlined)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _keyFigure('$_totalUsers',   'Citoyens',        Icons.people_outline)),
            const SizedBox(width: 10),
            Expanded(child: _keyFigure('${_categories.length}', 'Catégories', Icons.category_outlined)),
          ]),
        ]),
      ),
    );
  }

  Widget _statRow(String label, int count, int total, Color color) {
    final pct = total == 0 ? 0.0 : count / total;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label,
            style: const TextStyle(fontSize: 12, color: TColors.textSecondary, fontFamily: 'Poppins')),
        ]),
        Text('$count (${(pct * 100).toStringAsFixed(0)}%)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
            color: color, fontFamily: 'Poppins')),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: pct, minHeight: 6,
          backgroundColor: color.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation(color))),
    ]);
  }

  Widget _agentStatRow(String nom, int count, bool isDark) {
    final pct = _totalSignalements == 0 ? 0.0 : count / _totalSignalements;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? TColors.dark : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TColors.borderLight, width: 0.5)),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: TColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle),
          child: Center(child: Text(
            nom.isNotEmpty ? nom[0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
              color: TColors.primary, fontFamily: 'Poppins')))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(nom, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: isDark ? TColors.textWhite : TColors.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct, minHeight: 5,
              backgroundColor: TColors.borderLight,
              valueColor: const AlwaysStoppedAnimation(TColors.primary))),
        ])),
        const SizedBox(width: 10),
        Text('$count',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
            color: TColors.primary, fontFamily: 'Poppins')),
      ]),
    );
  }

  Widget _keyFigure(String num, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.primary.withValues(alpha: 0.15))),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: TColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: TColors.primary, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(num, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
            color: TColors.primary, fontFamily: 'Poppins')),
          Text(label, style: const TextStyle(fontSize: 10, color: TColors.textHint,
            fontFamily: 'Poppins')),
        ])),
      ]),
    );
  }

  Widget _buildRecentSignalements(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _card(isDark,
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _cardTitle('🕐', 'Signalements récents'),
            GestureDetector(
              onTap: () => setState(() => _index = 2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                child: const Text('Voir tout →',
                  style: TextStyle(fontSize: 12, color: TColors.primary,
                    fontFamily: 'Poppins', fontWeight: FontWeight.w600)))),
          ]),
          const SizedBox(height: 12),
          if (_loadingStats)
            const Center(child: CircularProgressIndicator(color: TColors.primary))
          else if (_recentSignalements.isEmpty)
            const Padding(padding: EdgeInsets.all(20),
              child: Column(children: [
                Text('📋', style: TextStyle(fontSize: 36)),
                SizedBox(height: 8),
                Text('Aucun signalement',
                  style: TextStyle(fontSize: 14, color: TColors.textHint, fontFamily: 'Poppins')),
              ]))
          else
            ..._recentSignalements.map((s) {
              final statut     = s['statut'] ?? 'EN_ATTENTE';
              final desc       = s['description'] ?? '—';
              final cat        = _catName(s['categorie']);
              final time       = _timeAgo(s['createdAt']);
              final citoyen    = s['citoyen'];
              final citoyenNom = citoyen is Map ? citoyen['nom'] ?? '—' : '—';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isDark ? TColors.dark : TColors.light,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TColors.borderLight, width: 0.5)),
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: _statusBg(statut), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.flag_outlined, size: 20, color: _statusColor(statut))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(desc, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: isDark ? TColors.textWhite : TColors.textPrimary,
                        fontFamily: 'Poppins')),
                    const SizedBox(height: 3),
                    Text('$citoyenNom · $cat · $time',
                      style: const TextStyle(fontSize: 11, color: TColors.textHint, fontFamily: 'Poppins')),
                  ])),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusBg(statut), borderRadius: BorderRadius.circular(20)),
                    child: Text(_statusLabel(statut),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                        color: _statusColor(statut), fontFamily: 'Poppins'))),
                ]),
              );
            }),
        ]),
      ),
    );
  }

  Widget _buildBarChart(bool isDark) {
    if (_categories.isEmpty || _catCounts.isEmpty) {
      return const Padding(padding: EdgeInsets.all(20),
        child: Column(children: [
          Text('📊', style: TextStyle(fontSize: 36)),
          SizedBox(height: 8),
          Text('Aucune donnée disponible',
            style: TextStyle(fontSize: 13, color: TColors.textHint, fontFamily: 'Poppins')),
        ]));
    }

    final entries = <MapEntry<String, int>>[];
    for (final cat in _categories) {
      final id    = cat['_id'] ?? '';
      final nom   = cat['nom'] ?? 'Autre';
      final count = _catCounts[id] ?? 0;
      entries.add(MapEntry(nom, count));
    }
    entries.sort((a, b) => b.value.compareTo(a.value));

    final maxCount    = entries.fold(0, (m, e) => e.value > m ? e.value : m);
    final maxVal      = maxCount == 0 ? 1 : maxCount;
    const maxBarH     = 80.0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: maxBarH + 50,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: entries.asMap().entries.map((e) {
            final i        = e.key;
            final nom      = e.value.key;
            final count    = e.value.value;
            final barH     = (count / maxVal * maxBarH).clamp(8.0, maxBarH);
            // [PROFESSIONAL] All bars use shades of red — no multicolor
            final color    = _barShades[i % _barShades.length];
            final shortNom = nom.length > 7 ? nom.substring(0, 6) : nom;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('$count',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                      color: color, fontFamily: 'Poppins')),
                  const SizedBox(height: 3),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    height: barH,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      boxShadow: [BoxShadow(
                        color: color.withValues(alpha: 0.25),
                        blurRadius: 4, offset: const Offset(0, 2))]),
                  ),
                  const SizedBox(height: 8),
                  Text(shortNom, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                      color: isDark ? TColors.textWhite : TColors.textSecondary,
                      fontFamily: 'Poppins')),
                ]),
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 12),
      const Divider(height: 1, thickness: 0.5, color: TColors.borderLight),
      const SizedBox(height: 12),
      Wrap(spacing: 12, runSpacing: 6,
        children: entries.asMap().entries.map((e) {
          final color = _barShades[e.key % _barShades.length];
          return Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 10, height: 10,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 5),
            Text('${e.value.key} (${e.value.value})',
              style: const TextStyle(fontSize: 10, color: TColors.textHint,
                fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
          ]);
        }).toList()),
    ]);
  }

  // ── Shared widgets ───────────────────────────────────────────
  Widget _card(bool isDark, {required Widget child}) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: isDark ? TColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: TColors.borderLight, width: 0.5),
      boxShadow: [BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 8, offset: const Offset(0, 2))]),
    padding: const EdgeInsets.all(16),
    child: child,
  );

  Widget _cardTitle(String emoji, String label) => Row(children: [
    Text('$emoji ', style: const TextStyle(fontSize: 14)),
    Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
      color: TColors.textPrimary, fontFamily: 'Poppins')),
  ]);

  Widget _sectionLabel(String emoji, String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(children: [
      Text('$emoji ', style: const TextStyle(fontSize: 14)),
      Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
        color: TColors.textPrimary, fontFamily: 'Poppins')),
    ]),
  );

 Widget _statusCard(String num, String label, IconData icon, Color color, Color bg, bool isDark) =>
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    decoration: BoxDecoration(
      color: isDark ? color.withValues(alpha: 0.12) : bg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withValues(alpha: 0.2), width: 1)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 8),
      Text(num, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
        color: color, fontFamily: 'Poppins')),
      Text(label, style: TextStyle(fontSize: 11,
        color: isDark ? Colors.white54 : color.withValues(alpha: 0.7),
        fontFamily: 'Poppins')),
    ]),
  );

  Widget _bannerStat(String num, String label, IconData icon) => Expanded(
    child: Column(children: [
      Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 15),
      const SizedBox(height: 3),
      Text(num, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
        color: Colors.white, fontFamily: 'Poppins')),
      const SizedBox(height: 1),
      Text(label, style: TextStyle(fontSize: 9,
        color: Colors.white.withValues(alpha: 0.75), fontFamily: 'Poppins')),
    ]),
  );

  Widget _bannerDiv() => Container(
    width: 1, height: 28, color: Colors.white.withValues(alpha: 0.2));
}