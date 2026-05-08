import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_t_hero/screens/agent/agent_detail_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';
import 'package:frontend_t_hero/utils/constants/api_constant.dart';

class AgentMesSignalementsScreen extends StatefulWidget {
  const AgentMesSignalementsScreen({super.key});
  @override
  State<AgentMesSignalementsScreen> createState() => _AgentMesSignalementsScreenState();
}

class _AgentMesSignalementsScreenState extends State<AgentMesSignalementsScreen> {

  int _filter    = 0;
  int _sortIndex = 0;
  final _filters = ['Tous', 'En cours', 'Résolus'];

  List<Map<String, dynamic>> _signalements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchSignalements();
  }

  Future<void> _fetchSignalements() async {
    setState(() => _loading = true);
    try {
      final prefs    = await SharedPreferences.getInstance();
      final token    = prefs.getString('token') ?? '';
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/signalements/GetAllSignalements'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _signalements = (data['data'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
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
      if (diff.inHours   < 24) return 'Il y a ${diff.inHours}h';
      return 'Il y a ${diff.inDays}j';
    } catch (_) { return ''; }
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

  Color _priorityColor(String p) {
    switch (p) {
      case 'ELEVEE':  return TColors.error;
      case 'MOYENNE': return TColors.warning;
      default:        return TColors.success;
    }
  }


  String _priorityLabel(String p) {
    switch (p) {
      case 'ELEVEE':  return 'Élevée';
      case 'MOYENNE': return 'Moyenne';
      default:        return 'Faible';
    }
  }

  int _priorityOrder(String p) {
    switch (p) { case 'ELEVEE': return 0; case 'MOYENNE': return 1; default: return 2; }
  }

  IconData _catIcon(String cat) {
    if (cat.contains('Voirie'))    return Icons.warning_amber_rounded;
    if (cat.contains('Eclairage')) return Icons.lightbulb_outline;
    if (cat.contains('Propret'))   return Icons.delete_outline;
    if (cat.contains('Espaces'))   return Icons.park_outlined;
    return Icons.help_outline;
  }

  List<Map<String, dynamic>> get _filtered {
    List<Map<String, dynamic>> list;
    if (_filter == 1)
      list = _signalements.where((s) =>
        s['statut'] == 'EN_COURS' || s['statut'] == 'EN_ATTENTE').toList();
    else if (_filter == 2)
      list = _signalements.where((s) => s['statut'] == 'RESOLU').toList();
    else
      list = List.from(_signalements);

    if (_sortIndex == 1) {
      list.sort((a, b) =>
        _priorityOrder(a['priorite'] ?? 'FAIBLE')
          .compareTo(_priorityOrder(b['priorite'] ?? 'FAIBLE')));
    }
    return list;
  }

  // [KEY FIX] Navigate to AgentDetailScreen with correct key names
  void _openDetail(Map<String, dynamic> s) async {
    final cat      = _catName(s['categorie']);
    final analyseIA = s['analyseIA'];
    String aiScore = 'N/A';
    String aiCat   = cat;
    String aiPrio  = '—';
    if (analyseIA is Map) {
      final score = analyseIA['scoreConfiance'];
      if (score != null) aiScore = '${(score * 100).toStringAsFixed(0)}%';
      aiCat  = analyseIA['resultatCategorie'] ?? cat;
      aiPrio = analyseIA['resultatPriorite']  ?? '—';
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgentDetailScreen(
          signalement: {
            'id':          s['_id']           ?? '',
            'title':       s['description']   ?? '—',
            'description': s['description']   ?? '—',
            'status':      s['statut']         ?? 'EN_ATTENTE',  // [FIX] key is 'status'
            'priority':    s['priorite']       ?? 'FAIBLE',
            'cat':         cat,
            'localisation':s['localisation']  ?? '—',
            'time':        _timeAgo(s['createdAt']),
            'citoyen':     s['citoyen'] is Map
              ? s['citoyen']['nom'] ?? '—' : '—',
            'aiScore':     aiScore,
            'aiCategorie': aiCat,
            'aiPriority':  aiPrio,
          },
        ),
      ),
    );

    // Refresh list when agent comes back from detail screen
    if (result == true) _fetchSignalements();
  }


  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.light,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Header ──────────────────────────────────────
            Container(
              color: isDark ? TColors.cardDark : TColors.cardLight,
              padding: const EdgeInsets.fromLTRB(6, 8, 16, 8),
              child: Row(children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, size: 20,
                    color: isDark ? TColors.textWhite : TColors.textPrimary),
                  onPressed: () => Navigator.pop(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mes signalements',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                          color: isDark ? TColors.textWhite : TColors.textPrimary,
                          fontFamily: 'Poppins')),
                      Text('${_signalements.length} signalements assignés',
                        style: const TextStyle(fontSize: 12, color: TColors.textHint, fontFamily: 'Poppins')),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _fetchSignalements,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: TColors.primaryLight, shape: BoxShape.circle),
                    child: const Icon(Icons.refresh_rounded, color: TColors.primary, size: 18))),
              ]),
            ),

            // ── Stats card ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Container(
                decoration: BoxDecoration(
                  color: TColors.primary, borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                child: Row(children: [
                  _stat('${_signalements.length}', 'Total'),
                  _divStat(),
                  _stat('${_signalements.where((s) => s['statut'] == 'EN_COURS' || s['statut'] == 'EN_ATTENTE').length}', 'En cours'),
                  _divStat(),
                  _stat('${_signalements.where((s) => s['statut'] == 'RESOLU').length}', 'Résolus'),
                ]),
              ),
            ),

            // ── Sort + Filter ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => setState(() => _sortIndex = _sortIndex == 0 ? 1 : 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _sortIndex == 1 ? TColors.primaryLight : (isDark ? TColors.darkContainer : TColors.light),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _sortIndex == 1 ? TColors.primary : TColors.borderLight,
                        width: _sortIndex == 1 ? 1.5 : 0.5)),
                    child: Row(children: [
                      Icon(Icons.sort, size: 16, color: _sortIndex == 1 ? TColors.primary : TColors.textHint),
                      const SizedBox(width: 6),
                      Text(_sortIndex == 1 ? 'Priorité ✓' : 'Trier',
                        style: TextStyle(fontSize: 12, fontFamily: 'Poppins',
                          fontWeight: _sortIndex == 1 ? FontWeight.w600 : FontWeight.w400,
                          color: _sortIndex == 1 ? TColors.primary : TColors.textHint)),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? TColors.darkContainer : const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: List.generate(3, (i) => Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _filter = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _filter == i ? (isDark ? TColors.cardDark : TColors.cardLight) : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              border: _filter == i ? Border.all(color: TColors.borderLight, width: 0.5) : null),
                            child: Text(_filters[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, fontFamily: 'Poppins',
                                fontWeight: _filter == i ? FontWeight.w600 : FontWeight.w400,
                                color: _filter == i ? TColors.primary : TColors.textHint)),
                          ),
                        ),
                      )),
                    ),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 6),

            // ── List ─────────────────────────────────────────
            Expanded(
              child: _loading
                ? const Center(child: CircularProgressIndicator(color: TColors.primary))
                : filtered.isEmpty
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 72, height: 72,
                          decoration: BoxDecoration(color: TColors.primaryLight, shape: BoxShape.circle),
                          child: const Icon(Icons.flag_outlined, size: 36, color: TColors.primary)),
                        const SizedBox(height: 16),
                        const Text('Aucun signalement',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                            color: TColors.textPrimary, fontFamily: 'Poppins')),
                      ],
                    ))
                  : RefreshIndicator(
                      onRefresh: _fetchSignalements,
                      color: TColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _card(filtered[i], isDark),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Map<String, dynamic> s, bool isDark) {
    final statut = s['statut']   ?? 'EN_ATTENTE';
    final cat    = _catName(s['categorie']);
    final desc   = s['description'] ?? '—';
    final time   = _timeAgo(s['createdAt']);
    final prio   = s['priorite'] ?? 'FAIBLE';

    return GestureDetector(
      onTap: () => _openDetail(s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? TColors.cardDark : TColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.borderLight, width: 0.5)),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: _statusBg(statut), borderRadius: BorderRadius.circular(13)),
                child: Icon(_catIcon(cat), size: 22, color: _statusColor(statut))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(desc, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        color: isDark ? TColors.textWhite : TColors.textPrimary,
                        fontFamily: 'Poppins')),
                    const SizedBox(height: 3),
                    Text('$cat · $time',
                      style: const TextStyle(fontSize: 11, color: TColors.textHint, fontFamily: 'Poppins')),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusBg(statut), borderRadius: BorderRadius.circular(20)),
                child: Text(_statusLabel(statut),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: _statusColor(statut), fontFamily: 'Poppins'))),
            ]),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(width: 8, height: 8,
                    decoration: BoxDecoration(color: _priorityColor(prio), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('Priorité ${_priorityLabel(prio)}',
                    style: TextStyle(fontSize: 12, color: _priorityColor(prio),
                      fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                  const SizedBox(width: 10),
                  Text('· $time',
                    style: const TextStyle(fontSize: 11, color: TColors.textHint, fontFamily: 'Poppins')),
                ]),
                const Row(children: [
                  Text('Voir mission',
                    style: TextStyle(fontSize: 11, color: TColors.primary,
                      fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                  SizedBox(width: 3),
                  Icon(Icons.arrow_forward_ios, size: 10, color: TColors.primary),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String num, String label) {
    return Expanded(
      child: Column(children: [
        Text(num, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
          color: Colors.white, fontFamily: 'Poppins')),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11,
          color: Colors.white.withValues(alpha: 0.7), fontFamily: 'Poppins')),
      ]),
    );
  }

  Widget _divStat() => Container(
    width: 1, height: 32, color: Colors.white.withValues(alpha: 0.2));
}