import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_t_hero/screens/agent/agent_detail_screen.dart';
import 'package:frontend_t_hero/screens/agent/agent_profile_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';
import 'package:frontend_t_hero/utils/constants/api_constant.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({super.key});
  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
  int _navIndex = 0;
  final _profileKey = GlobalKey<AgentProfileScreenState>();

  List<Map<String, dynamic>> _assigned = [];
  List<Map<String, dynamic>> _resolved = [];
  bool   _loading   = true;
  String _agentName = 'Agent';
  String _agentId   = '';
  String _search    = '';
  final  _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _loadAgentAndData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAgentAndData() async {
    final prefs   = await SharedPreferences.getInstance();
    final userRaw = prefs.getString('user') ?? '{}';
    final user    = jsonDecode(userRaw);
    setState(() {
      _agentName = user['nom'] ?? 'Agent';
      _agentId   = user['_id'] ?? '';
    });
    await _fetchSignalements();
  }

  Future<void> _fetchSignalements() async {
    setState(() => _loading = true);
    try {
      final prefs    = await SharedPreferences.getInstance();
      final token    = prefs.getString('token') ?? '';
      final response = await http.get(
        Uri.parse(ApiConstants.getAllSignalements),
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer $token' },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['data'] as List).map((e) => e as Map<String, dynamic>).toList();

        final allMine = list.where((s) {
          final agent = s['agent'];
          if (agent == null) return false;
          if (agent is Map) return agent['_id'] == _agentId;
          return agent.toString() == _agentId;
        }).toList();

        final active   = allMine.where((s) => s['statut'] != 'RESOLU').toList();
        final resolved = allMine.where((s) => s['statut'] == 'RESOLU').toList();

        double _getScore(Map<String, dynamic> s) {
          final ai = s['analyseIA'];
          if (ai is Map) return ((ai['scoreConfiance'] ?? 0) as num).toDouble();
          return 0.0;
        }

        int sortFn(a, b) {
          final pA = _prioOrder(a['priorite'] ?? 'FAIBLE');
          final pB = _prioOrder(b['priorite'] ?? 'FAIBLE');
          if (pA != pB) return pA.compareTo(pB);
          return _getScore(b).compareTo(_getScore(a));
        }

        active.sort(sortFn);
        resolved.sort(sortFn);

        setState(() { _assigned = active; _resolved = resolved; _loading = false; });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  int _prioOrder(String p) { switch (p) { case 'ELEVEE': return 0; case 'MOYENNE': return 1; default: return 2; } }

  List<Map<String, dynamic>> get _filteredAssigned {
    if (_search.isEmpty) return _assigned;
    final q = _search.toLowerCase();
    return _assigned.where((s) {
      final desc = (s['description'] ?? '').toString().toLowerCase();
      final cat  = _catName(s['categorie']).toLowerCase();
      final loc  = (s['localisation'] ?? '').toString().toLowerCase();
      return desc.contains(q) || cat.contains(q) || loc.contains(q);
    }).toList();
  }

  void _openDetail(Map<String, dynamic> s) async {
    final cat       = _catName(s['categorie']);
    final analyseIA = s['analyseIA'];
    String aiScore  = 'N/A';
    String aiCat    = cat;
    String aiPrio   = '—';
    String photo    = '';

    if (analyseIA is Map) {
      final score = analyseIA['scoreConfiance'];
      if (score != null) aiScore = '${((score as num).toDouble() * 100).toStringAsFixed(0)}%';
      aiCat  = analyseIA['resultatCategorie'] ?? cat;
      aiPrio = analyseIA['resultatPriorite']  ?? '—';
    }
    if (s['photo'] != null && s['photo'].toString().isNotEmpty) photo = s['photo'].toString();

    final result = await Navigator.push(context,
      MaterialPageRoute(builder: (_) => AgentDetailScreen(
        signalement: {
          'id':          s['_id']          ?? '',
          'title':       s['description']  ?? '—',
          'description': s['description']  ?? '—',
          'status':      s['statut']        ?? 'EN_ATTENTE',
          'priority':    s['priorite']      ?? 'FAIBLE',
          'cat':         cat,
          'localisation':s['localisation'] ?? '—',
          'time':        _timeAgo(s['createdAt']),
          'citoyen':     s['citoyen'] is Map ? s['citoyen']['nom'] ?? '—' : '—',
          'aiScore':     aiScore,
          'aiCategorie': aiCat,
          'aiPriority':  aiPrio,
          'photo':       photo,
        },
      )),
    );

    if (result == true) {
      _showHeroSnack();
      await _fetchSignalements();
      _profileKey.currentState?.refreshStats();
    }
  }

  void _showHeroSnack() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 4),
      content: const Row(children: [
        Text('🦸', style: TextStyle(fontSize: 24)),
        SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bravo ! Signalement résolu ✓',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: Colors.white, fontFamily: 'Poppins')),
            SizedBox(height: 2),
            Text('Vous êtes le HÉROS de notre Tunisie, merci !',
              style: TextStyle(fontSize: 12, color: Colors.white, fontFamily: 'Poppins')),
          ],
        )),
      ]),
      backgroundColor: const Color(0xFF2D6A4F),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }

  Color  _statusColor(String s) { switch (s) { case 'EN_COURS': return TColors.info; case 'RESOLU': return TColors.success; default: return TColors.warning; } }
  Color  _statusBg(String s)    { switch (s) { case 'EN_COURS': return TColors.infoLight; case 'RESOLU': return TColors.successLight; default: return TColors.warningLight; } }
  String _statusLabel(String s) { switch (s) { case 'EN_COURS': return 'En cours'; case 'RESOLU': return 'Résolu'; default: return 'En attente'; } }
  Color  _prioColor(String p)   { switch (p) { case 'ELEVEE': return TColors.error; case 'MOYENNE': return TColors.warning; default: return TColors.success; } }
  String _prioLabel(String p)   { switch (p) { case 'ELEVEE': return 'Élevée'; case 'MOYENNE': return 'Moyenne'; default: return 'Faible'; } }
  String _catName(dynamic cat)  { if (cat == null) return 'Autre'; if (cat is Map) return cat['nom'] ?? 'Autre'; return cat.toString(); }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
      if (diff.inHours   < 24) return 'Il y a ${diff.inHours}h';
      return 'Il y a ${diff.inDays}j';
    } catch (_) { return ''; }
  }

  IconData _catIcon(String cat) {
    if (cat.contains('Voirie'))    return Icons.warning_amber_rounded;
    if (cat.contains('Eclairage')) return Icons.lightbulb_outline;
    if (cat.contains('Propret'))   return Icons.delete_outline;
    if (cat.contains('Espaces'))   return Icons.park_outlined;
    return Icons.help_outline;
  }

  int get _totalAssigned => _assigned.length + _resolved.length;
  int get _enCours => _assigned.where((s) => s['statut'] == 'EN_COURS').length;
  int get _resolus => _resolved.length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.light,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _homeTab(isDark),
          _achievementsTab(isDark),
          AgentProfileScreen(key: _profileKey),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _navIndex,
        selectedItemColor: TColors.primary,
        unselectedItemColor: TColors.grey,
        backgroundColor: isDark ? TColors.cardDark : TColors.cardLight,
        elevation: 4,
        selectedLabelStyle:   const TextStyle(fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontFamily: 'Poppins'),
        onTap: (i) {
          setState(() => _navIndex = i);
          if (i == 2) _profileKey.currentState?.refreshStats();
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded,  size: 24), label: 'Missions'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_rounded, size: 24), label: 'Succès'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline,      size: 24), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _homeTab(bool isDark) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            color: isDark ? TColors.cardDark : TColors.cardLight,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Text('👋  ', style: TextStyle(fontSize: 14)),
                    Text('Salut, Héros !',
                      style: TextStyle(fontSize: 13, color: TColors.primary,
                        fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                  ]),
                  Text(_agentName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                      color: TColors.textPrimary, fontFamily: 'Poppins')),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: TColors.primary, borderRadius: BorderRadius.circular(20)),
                  child: const Row(children: [
                    Text('🦸 ', style: TextStyle(fontSize: 12)),
                    Text('Agent Municipal',
                      style: TextStyle(fontSize: 11, color: Colors.white,
                        fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                  ])),
              ],
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [TColors.primary, Color(0xFFE53935)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(
                  color: TColors.primary.withValues(alpha: 0.35),
                  blurRadius: 14, offset: const Offset(0, 5))]),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              child: Row(children: [
                _statItem('$_totalAssigned', 'Missions',  Icons.shield_outlined),
                _vDivider(),
                _statItem('$_enCours',       'En cours',  Icons.bolt_outlined),
                _vDivider(),
                _statItem('$_resolus',       'Victoires', Icons.emoji_events_outlined),
              ]),
            ),
          ),

          // [ADDED] Search bar — white, red border
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TColors.primary, width: 1.5),
                boxShadow: [BoxShadow(
                  color: TColors.primary.withValues(alpha: 0.08),
                  blurRadius: 6, offset: const Offset(0, 2))]),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(fontSize: 14, fontFamily: 'Poppins', color: TColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Rechercher une mission...',
                  hintStyle: const TextStyle(fontSize: 13, color: TColors.textHint, fontFamily: 'Poppins'),
                  prefixIcon: const Icon(Icons.search, color: TColors.primary, size: 20),
                  suffixIcon: _search.isNotEmpty
                    ? GestureDetector(
                        onTap: () { _searchCtrl.clear(); setState(() => _search = ''); },
                        child: const Icon(Icons.close, color: TColors.primary, size: 18))
                    : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(children: [
                  Text('⚡ ', style: TextStyle(fontSize: 16)),
                  Text('Mes Missions',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                      color: TColors.textPrimary, fontFamily: 'Poppins')),
                ]),
                if (!_loading)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: TColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      _search.isNotEmpty
                        ? '${_filteredAssigned.length} résultat(s)'
                        : '${_assigned.length} actives',
                      style: const TextStyle(fontSize: 11, color: TColors.primary,
                        fontWeight: FontWeight.w600, fontFamily: 'Poppins'))),
              ],
            ),
          ),

          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator(color: TColors.primary))
              : _filteredAssigned.isEmpty
                ? _emptyState(
                    _search.isNotEmpty ? '🔍 Aucun résultat' : '🦸 Pas de missions actives',
                    _search.isNotEmpty
                      ? 'Essayez un autre terme de recherche'
                      : 'Toutes vos missions sont accomplies !\nVos succès sont dans l\'onglet Succès 🏆')
                : RefreshIndicator(
                    onRefresh: _fetchSignalements,
                    color: TColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: _filteredAssigned.length,
                      itemBuilder: (_, i) => _card(_filteredAssigned[i], isDark),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _achievementsTab(bool isDark) {
    return SafeArea(
      child: Column(children: [
        Container(
          color: isDark ? TColors.cardDark : TColors.cardLight,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(children: [
                Text('🏆  ', style: TextStyle(fontSize: 20)),
                Text('Mes Succès',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                    color: TColors.textPrimary, fontFamily: 'Poppins')),
              ]),
              if (_resolved.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: TColors.successLight, borderRadius: BorderRadius.circular(20)),
                  child: Text('${_resolved.length} 🏅',
                    style: const TextStyle(fontSize: 12, color: TColors.success,
                      fontWeight: FontWeight.w700, fontFamily: 'Poppins'))),
            ],
          ),
        ),

        if (_resolved.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2D6A4F), Color(0xFF40916C)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Text('🦸', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vous êtes un vrai Héros !',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: Colors.white, fontFamily: 'Poppins')),
                  Text('${_resolved.length} mission(s) accomplie(s) pour la Tunisie 🇹🇳',
                    style: TextStyle(fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.9), fontFamily: 'Poppins')),
                ],
              )),
            ]),
          ),

        const SizedBox(height: 4),

        Expanded(
          child: _loading
            ? const Center(child: CircularProgressIndicator(color: TColors.primary))
            : _resolved.isEmpty
              ? _emptyState('🎯 Pas encore de succès',
                  'Résolvez vos missions pour\ndécrocher vos premiers succès ! 💪')
              : RefreshIndicator(
                  onRefresh: _fetchSignalements,
                  color: TColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _resolved.length,
                    itemBuilder: (_, i) => _resolvedCard(_resolved[i], isDark),
                  ),
                ),
        ),
      ]),
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🦸', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
              color: TColors.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: TColors.textHint,
              fontFamily: 'Poppins', height: 1.5)),
        ],
      ),
    );
  }

  Widget _card(Map<String, dynamic> s, bool isDark) {
    final statut    = s['statut']      ?? 'EN_ATTENTE';
    final cat       = _catName(s['categorie']);
    final desc      = s['description'] ?? '—';
    final time      = _timeAgo(s['createdAt']);
    final prio      = s['priorite']    ?? 'FAIBLE';
    final analyseIA = s['analyseIA'];
    final aiScore   = analyseIA is Map
      ? ((analyseIA['scoreConfiance'] ?? 0) as num).toDouble() : 0.0;

    return GestureDetector(
      onTap: () => _openDetail(s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? TColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.borderLight, width: 0.5),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8, offset: const Offset(0, 2))]),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: _prioColor(prio),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16), bottomLeft: Radius.circular(16))),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: _statusBg(statut), borderRadius: BorderRadius.circular(12)),
                          child: Icon(_catIcon(cat), size: 20, color: _statusColor(statut))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(desc, overflow: TextOverflow.ellipsis, maxLines: 1,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                                color: isDark ? TColors.textWhite : TColors.textPrimary,
                                fontFamily: 'Poppins')),
                            const SizedBox(height: 3),
                            Text('$cat · $time',
                              style: const TextStyle(fontSize: 11, color: TColors.textHint, fontFamily: 'Poppins')),
                          ],
                        )),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusBg(statut), borderRadius: BorderRadius.circular(20)),
                          child: Text(_statusLabel(statut),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                              color: _statusColor(statut), fontFamily: 'Poppins'))),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Container(width: 8, height: 8,
                          decoration: BoxDecoration(color: _prioColor(prio), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('Priorité ${_prioLabel(prio)}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: _prioColor(prio), fontFamily: 'Poppins')),
                        if (aiScore > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: TColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10)),
                            child: Text('🤖 ${(aiScore * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                                color: TColors.primary, fontFamily: 'Poppins'))),
                        ],
                        const Spacer(),
                        const Row(children: [
                          Text('Voir mission',
                            style: TextStyle(fontSize: 11, color: TColors.primary,
                              fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                          SizedBox(width: 3),
                          Icon(Icons.arrow_forward_ios, size: 10, color: TColors.primary),
                        ]),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resolvedCard(Map<String, dynamic> s, bool isDark) {
    final cat       = _catName(s['categorie']);
    final desc      = s['description'] ?? '—';
    final time      = _timeAgo(s['updatedAt'] ?? s['createdAt']);
    final prio      = s['priorite'] ?? 'FAIBLE';
    final analyseIA = s['analyseIA'];
    final aiScore   = analyseIA is Map
      ? ((analyseIA['scoreConfiance'] ?? 0) as num).toDouble() : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.success.withValues(alpha: 0.3), width: 1),
        boxShadow: [BoxShadow(
          color: TColors.success.withValues(alpha: 0.06),
          blurRadius: 8, offset: const Offset(0, 2))]),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: TColors.success,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16), bottomLeft: Radius.circular(16))),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: TColors.successLight, borderRadius: BorderRadius.circular(12)),
                    child: const Text('🏅', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(desc, overflow: TextOverflow.ellipsis, maxLines: 1,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                          color: isDark ? TColors.textWhite : TColors.textPrimary,
                          fontFamily: 'Poppins')),
                      const SizedBox(height: 3),
                      Text('$cat · $time',
                        style: const TextStyle(fontSize: 11, color: TColors.textHint, fontFamily: 'Poppins')),
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(width: 7, height: 7,
                          decoration: BoxDecoration(color: _prioColor(prio), shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Text('Priorité ${_prioLabel(prio)}',
                          style: TextStyle(fontSize: 10, color: _prioColor(prio),
                            fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                        if (aiScore > 0) ...[
                          const SizedBox(width: 6),
                          Text('· 🤖 ${(aiScore * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 10, color: TColors.primary,
                              fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                        ],
                      ]),
                    ],
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: TColors.successLight, borderRadius: BorderRadius.circular(20)),
                    child: const Text('✓ Succès',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: TColors.success, fontFamily: 'Poppins'))),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String num, String label, IconData icon) {
    return Expanded(
      child: Column(children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
        const SizedBox(height: 4),
        Text(num, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
          color: Colors.white, fontFamily: 'Poppins')),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11,
          color: Colors.white.withValues(alpha: 0.8), fontFamily: 'Poppins')),
      ]),
    );
  }

  Widget _vDivider() => Container(
    width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3));
}