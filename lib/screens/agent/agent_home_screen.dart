import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _loadAgentAndData();
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse(ApiConstants.getAllSignalements),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['data'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();

        final allMine = list.where((s) {
          final agent = s['agent'];
          if (agent == null) return false;
          if (agent is Map) return agent['_id'] == _agentId;
          return agent.toString() == _agentId;
        }).toList();

        final active   = allMine
          .where((s) => s['statut'] != 'RESOLU').toList();
        final resolved = allMine
          .where((s) => s['statut'] == 'RESOLU').toList();

        // ── UPDATED: sort by priority first, then by AI score descending ──
        int sortByPrioAndScore(a, b) {
          final prioA = _prioOrder(a['priorite'] ?? 'FAIBLE');
          final prioB = _prioOrder(b['priorite'] ?? 'FAIBLE');

          // First sort by priority level (ELEVEE → MOYENNE → FAIBLE)
          if (prioA != prioB) return prioA.compareTo(prioB);

          // Same priority → sort by AI score descending
          final analyseA = a['analyseIA'];
          final analyseB = b['analyseIA'];

          final scoreA = analyseA is Map
            ? ((analyseA['scoreConfiance'] ?? 0) as num).toDouble()
            : 0.0;
          final scoreB = analyseB is Map
            ? ((analyseB['scoreConfiance'] ?? 0) as num).toDouble()
            : 0.0;

          return scoreB.compareTo(scoreA); // descending score
        }

        active.sort(sortByPrioAndScore);
        resolved.sort(sortByPrioAndScore);

        setState(() {
          _assigned = active;
          _resolved = resolved;
          _loading  = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  int _prioOrder(String p) {
    switch (p) {
      case 'ELEVEE':  return 0;
      case 'MOYENNE': return 1;
      default:        return 2;
    }
  }

  Future<void> _changerStatut(String id, String statut,
      {bool fromDetail = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.put(
        Uri.parse(
          '${ApiConstants.baseUrl}/signalements/ChangerStatut/$id'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'statut': statut}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (fromDetail && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        if (statut == 'RESOLU') {
          _showHeroSnack();
        } else {
          _showSnack('Statut mis à jour ✓', TColors.success);
        }
        await _fetchSignalements();
        _profileKey.currentState?.refreshStats();
      } else {
        _showSnack('Erreur lors de la mise à jour', TColors.error);
      }
    } catch (e) {
      _showSnack('Erreur serveur', TColors.error);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
        style: const TextStyle(
          fontSize: 13, fontFamily: 'Poppins')),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showHeroSnack() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 4),
      content: const Row(children: [
        Text('🦸', style: TextStyle(fontSize: 24)),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Bravo ! Signalement résolu ✓',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                )),
              SizedBox(height: 2),
              Text(
                'Vous êtes le HÉROS de notre Tunisie, merci !',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                )),
            ],
          ),
        ),
      ]),
      backgroundColor: const Color(0xFF2D6A4F),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)),
    ));
  }

  void _showDetail(Map<String, dynamic> s) {
    final statut     = s['statut'] ?? 'EN_ATTENTE';
    final cat        = _catName(s['categorie']);
    final desc       = s['description'] ?? '—';
    final loc        = s['localisation'] ?? '—';
    final time       = _timeAgo(s['createdAt']);
    final id         = s['_id'] ?? '';
    final prio       = s['priorite'] ?? 'FAIBLE';
    final citoyen    = s['citoyen'];
    final citoyenNom = citoyen is Map
      ? citoyen['nom'] ?? '—' : '—';

    // ── FIXED: read real AI data from MongoDB ──
    final analyseIA  = s['analyseIA'];
    double aiScore   = 0.0;
    String aiCat     = cat;
    String aiPriority = '';

    if (analyseIA is Map) {
      aiScore    = ((analyseIA['scoreConfiance'] ?? 0) as num).toDouble();
      aiCat      = analyseIA['resultatCategorie'] ?? cat;
      aiPriority = analyseIA['resultatPriorite']  ?? '';
    }

    double prioScore = aiScore > 0
      ? aiScore
      : (prio == 'ELEVEE' ? 1.0 : prio == 'MOYENNE' ? 0.6 : 0.3);

    String aiCatLabel(String c) {
      const m = {
        'VOIRIE':        'Voirie',
        'ECLAIRAGE':     'Éclairage',
        'PROPRETE':      'Propreté',
        'ESPACES_VERTS': 'Espaces Verts',
        'AUTRE':         'Autre',
      };
      return m[c] ?? c;
    }

    String selectedStatut = statut;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          height: MediaQuery.of(context).size.height * 0.92,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28)),
          ),
          child: Column(children: [

            Center(child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: TColors.borderLight,
                borderRadius: BorderRadius.circular(2)),
            )),

            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [TColors.primary, Color(0xFFE53935)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14)),
                  child: Icon(_catIcon(cat),
                    color: Colors.white, size: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(desc,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        )),
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            _statusLabel(selectedStatut),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ))),
                        const SizedBox(width: 8),
                        const Text('🦸',
                          style: TextStyle(fontSize: 16)),
                      ]),
                    ],
                  ),
                ),
              ]),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: TColors.borderLight, width: 0.5)),
                      padding: const EdgeInsets.all(14),
                      child: Column(children: [
                        _infoRow(Icons.person_outline,
                          'Citoyen', citoyenNom),
                        _dividerLine(),
                        _infoRow(Icons.category_outlined,
                          'Catégorie', cat),
                        _dividerLine(),
                        _infoRow(Icons.place_outlined,
                          'Localisation', loc),
                        _dividerLine(),
                        _infoRow(Icons.access_time_outlined,
                          'Soumis', time),
                      ]),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _prioColor(prio).withValues(alpha: 0.3),
                          width: 1)),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Icon(Icons.speed_rounded,
                                  size: 18, color: _prioColor(prio)),
                                const SizedBox(width: 8),
                                Text('Niveau de priorité',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _prioColor(prio),
                                    fontFamily: 'Poppins',
                                  )),
                              ]),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _prioColor(prio),
                                  borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  aiScore > 0
                                    ? '${(aiScore * 100).toStringAsFixed(1)}%'
                                    : '${(prioScore * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                  ))),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: prioScore,
                              backgroundColor: _prioColor(prio)
                                .withValues(alpha: 0.15),
                              valueColor: AlwaysStoppedAnimation(
                                _prioColor(prio)),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prio == 'ELEVEE'
                                  ? '⚠️ Intervention urgente !'
                                  : prio == 'MOYENNE'
                                    ? '⏳ Traitement modéré'
                                    : '✅ Pas urgent',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _prioColor(prio),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                )),
                              Text(_prioLabel(prio),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _prioColor(prio),
                                  fontFamily: 'Poppins',
                                )),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            TColors.primary,
                            TColors.primary.withValues(alpha: 0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(children: [
                              Icon(Icons.auto_awesome,
                                size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Analyse IA T HERO',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                )),
                            ]),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                aiScore > 0
                                  ? '${(aiScore * 100).toStringAsFixed(0)}%'
                                  : 'N/A',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                ))),
                          ],
                        ),
                        if (aiScore > 0) ...[
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: aiScore,
                                  backgroundColor: Colors.white
                                    .withValues(alpha: 0.25),
                                  valueColor:
                                    const AlwaysStoppedAnimation(
                                      Colors.white),
                                  minHeight: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${(aiScore * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              )),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                children: [
                                  Text('Catégorie détectée',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white
                                        .withValues(alpha: 0.75),
                                      fontFamily: 'Poppins',
                                    )),
                                  const SizedBox(height: 2),
                                  Text(aiCatLabel(aiCat),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                    )),
                                ],
                              ),
                            ),
                            if (aiPriority.isNotEmpty)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                  children: [
                                    Text('Priorité IA',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white
                                          .withValues(alpha: 0.75),
                                        fontFamily: 'Poppins',
                                      )),
                                    const SizedBox(height: 2),
                                    Text(aiPriority,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                      )),
                                  ],
                                ),
                              ),
                          ]),
                        ] else ...[
                          const SizedBox(height: 10),
                          Text(
                            'Aucune analyse IA disponible pour ce signalement',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontFamily: 'Poppins',
                            )),
                        ],
                      ]),
                    ),

                    const SizedBox(height: 14),

                    Row(children: [
                      const Text('⚡ ',
                        style: TextStyle(fontSize: 16)),
                      const Text('Modifier le statut',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: TColors.textPrimary,
                          fontFamily: 'Poppins',
                        )),
                    ]),
                    const SizedBox(height: 10),

                    ...['EN_ATTENTE', 'EN_COURS', 'RESOLU'].map((st) {
                      final isSel = selectedStatut == st;
                      return GestureDetector(
                        onTap: () =>
                          setSheet(() => selectedStatut = st),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSel
                              ? _statusBg(st)
                              : const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSel
                                ? _statusColor(st)
                                : TColors.borderLight,
                              width: isSel ? 2 : 0.5)),
                          child: Row(children: [
                            Container(
                              width: 14, height: 14,
                              decoration: BoxDecoration(
                                color: _statusColor(st),
                                shape: BoxShape.circle)),
                            const SizedBox(width: 12),
                            Text(_statusLabel(st),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSel
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                                color: isSel
                                  ? _statusColor(st)
                                  : TColors.textPrimary,
                                fontFamily: 'Poppins',
                              )),
                            const Spacer(),
                            if (st == 'RESOLU' && isSel)
                              const Text('🏆',
                                style: TextStyle(fontSize: 16)),
                            if (isSel && st != 'RESOLU')
                              Icon(Icons.check_circle_rounded,
                                color: _statusColor(st), size: 22),
                          ]),
                        ),
                      );
                    }),

                    const SizedBox(height: 6),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: selectedStatut == statut
                          ? null
                          : () => _changerStatut(
                              id, selectedStatut, fromDetail: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedStatut == 'RESOLU'
                            ? const Color(0xFF2D6A4F)
                            : TColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: TColors.borderLight,
                          disabledForegroundColor: TColors.textHint,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          selectedStatut == 'RESOLU'
                            ? '🏆  Marquer comme résolu !'
                            : 'Confirmer le statut',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          )),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
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

  Color _prioColor(String p) {
    switch (p) {
      case 'ELEVEE':  return TColors.error;
      case 'MOYENNE': return TColors.warning;
      default:        return TColors.success;
    }
  }

  String _prioLabel(String p) {
    switch (p) {
      case 'ELEVEE':  return 'Élevée';
      case 'MOYENNE': return 'Moyenne';
      default:        return 'Faible';
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
      if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
      if (diff.inHours < 24)   return 'Il y a ${diff.inHours}h';
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
  int get _enCours => _assigned
    .where((s) => s['statut'] == 'EN_COURS').length;
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
        selectedLabelStyle: const TextStyle(
          fontSize: 11, fontFamily: 'Poppins',
          fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11, fontFamily: 'Poppins'),
        onTap: (i) {
          setState(() => _navIndex = i);
          if (i == 2) _profileKey.currentState?.refreshStats();
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded, size: 24),
            label: 'Missions'),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_rounded, size: 24),
            label: 'Succès'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 24),
            label: 'Profil'),
        ],
      ),
    );
  }

  Widget _homeTab(bool isDark) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: isDark ? TColors.cardDark : TColors.cardLight,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text('👋  ', style: TextStyle(fontSize: 14)),
                      Text('Salut, Héros !',
                        style: TextStyle(
                          fontSize: 13,
                          color: TColors.primary,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        )),
                    ]),
                    Text(_agentName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TColors.textPrimary,
                        fontFamily: 'Poppins',
                      )),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: TColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(children: [
                    Text('🦸 ', style: TextStyle(fontSize: 12)),
                    Text('Agent Municipal',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      )),
                  ]),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [TColors.primary, Color(0xFFE53935)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: TColors.primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5)),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 18, horizontal: 8),
              child: Row(children: [
                _statItem('$_totalAssigned', 'Missions',
                  Icons.shield_outlined),
                _vDivider(),
                _statItem('$_enCours', 'En cours',
                  Icons.bolt_outlined),
                _vDivider(),
                _statItem('$_resolus', 'Victoires',
                  Icons.emoji_events_outlined),
              ]),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(children: [
                  Text('⚡ ', style: TextStyle(fontSize: 16)),
                  Text('Mes Missions',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: TColors.textPrimary,
                      fontFamily: 'Poppins',
                    )),
                ]),
                if (!_loading && _assigned.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: TColors.primaryLight,
                      borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '${_assigned.length} actives',
                      style: const TextStyle(
                        fontSize: 11,
                        color: TColors.primary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ))),
              ],
            ),
          ),

          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator(
                  color: TColors.primary))
              : _assigned.isEmpty
                ? _emptyState(
                    '🦸 Pas de missions actives',
                    'Toutes vos missions sont accomplies !\nVos succès sont dans l\'onglet Succès 🏆')
                : RefreshIndicator(
                    onRefresh: _fetchSignalements,
                    color: TColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                      itemCount: _assigned.length,
                      itemBuilder: (_, i) =>
                        _card(_assigned[i], isDark),
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
              ]),
              if (_resolved.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: TColors.successLight,
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '${_resolved.length} 🏅',
                    style: const TextStyle(
                      fontSize: 12,
                      color: TColors.success,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ))),
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              const Text('🦸', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vous êtes un vrai Héros !',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      )),
                    Text(
                      '${_resolved.length} mission(s) accomplie(s) '
                      'pour la Tunisie 🇹🇳',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontFamily: 'Poppins',
                      )),
                  ],
                ),
              ),
            ]),
          ),

        const SizedBox(height: 4),

        Expanded(
          child: _loading
            ? const Center(child: CircularProgressIndicator(
                color: TColors.primary))
            : _resolved.isEmpty
              ? _emptyState(
                  '🎯 Pas encore de succès',
                  'Résolvez vos missions pour\ndécrocher vos premiers succès ! 💪')
              : RefreshIndicator(
                  onRefresh: _fetchSignalements,
                  color: TColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _resolved.length,
                    itemBuilder: (_, i) =>
                      _resolvedCard(_resolved[i], isDark),
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
          Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: TColors.textPrimary,
              fontFamily: 'Poppins',
            )),
          const SizedBox(height: 8),
          Text(subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: TColors.textHint,
              fontFamily: 'Poppins',
              height: 1.5,
            )),
        ],
      ),
    );
  }

  Widget _card(Map<String, dynamic> s, bool isDark) {
    final statut = s['statut'] ?? 'EN_ATTENTE';
    final cat    = _catName(s['categorie']);
    final desc   = s['description'] ?? '—';
    final time   = _timeAgo(s['createdAt']);
    final prio   = s['priorite'] ?? 'FAIBLE';

    // Show AI score in card if available
    final analyseIA = s['analyseIA'];
    final aiScore = analyseIA is Map
      ? ((analyseIA['scoreConfiance'] ?? 0) as num).toDouble()
      : 0.0;

    return GestureDetector(
      onTap: () => _showDetail(s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? TColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.borderLight, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: _prioColor(prio),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16)),
                ),
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
                            color: _statusBg(statut),
                            borderRadius: BorderRadius.circular(12)),
                          child: Icon(_catIcon(cat),
                            size: 20, color: _statusColor(statut))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(desc,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                    ? TColors.textWhite
                                    : TColors.textPrimary,
                                  fontFamily: 'Poppins',
                                )),
                              const SizedBox(height: 3),
                              Text('$cat · $time',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: TColors.textHint,
                                  fontFamily: 'Poppins',
                                )),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusBg(statut),
                            borderRadius: BorderRadius.circular(20)),
                          child: Text(_statusLabel(statut),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _statusColor(statut),
                              fontFamily: 'Poppins',
                            ))),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: _prioColor(prio),
                            shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('Priorité ${_prioLabel(prio)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _prioColor(prio),
                            fontFamily: 'Poppins',
                          )),
                        // ── UPDATED: show AI score in card ──
                        if (aiScore > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: TColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              '🤖 ${(aiScore * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: TColors.primary,
                                fontFamily: 'Poppins',
                              ))),
                        ],
                        const Spacer(),
                        const Row(children: [
                          Text('Voir mission',
                            style: TextStyle(
                              fontSize: 11,
                              color: TColors.primary,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            )),
                          SizedBox(width: 3),
                          Icon(Icons.arrow_forward_ios,
                            size: 10, color: TColors.primary),
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
    final cat  = _catName(s['categorie']);
    final desc = s['description'] ?? '—';
    final time = _timeAgo(s['updatedAt'] ?? s['createdAt']);
    final prio = s['priorite'] ?? 'FAIBLE';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TColors.success.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: TColors.success.withValues(alpha: 0.06),
            blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: TColors.success,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: TColors.successLight,
                      borderRadius: BorderRadius.circular(12)),
                    child: const Text('🏅',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(desc,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                              ? TColors.textWhite
                              : TColors.textPrimary,
                            fontFamily: 'Poppins',
                          )),
                        const SizedBox(height: 3),
                        Text('$cat · $time',
                          style: const TextStyle(
                            fontSize: 11,
                            color: TColors.textHint,
                            fontFamily: 'Poppins',
                          )),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(
                            width: 7, height: 7,
                            decoration: BoxDecoration(
                              color: _prioColor(prio),
                              shape: BoxShape.circle)),
                          const SizedBox(width: 5),
                          Text('Priorité ${_prioLabel(prio)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: _prioColor(prio),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            )),
                        ]),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: TColors.successLight,
                      borderRadius: BorderRadius.circular(20)),
                    child: const Text('✓ Succès',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: TColors.success,
                        fontFamily: 'Poppins',
                      ))),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, size: 18, color: TColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
              style: const TextStyle(
                fontSize: 10,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              )),
            Text(value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TColors.textPrimary,
                fontFamily: 'Poppins',
              )),
          ],
        ),
      ]),
    );
  }

  Widget _dividerLine() => const Divider(
    height: 1, thickness: 0.5, color: TColors.borderLight);

  Widget _statItem(String num, String label, IconData icon) {
    return Expanded(
      child: Column(children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
        const SizedBox(height: 4),
        Text(num,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Poppins',
          )),
        const SizedBox(height: 2),
        Text(label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
            fontFamily: 'Poppins',
          )),
      ]),
    );
  }

  Widget _vDivider() => Container(
    width: 1, height: 40,
    color: Colors.white.withValues(alpha: 0.3));
}