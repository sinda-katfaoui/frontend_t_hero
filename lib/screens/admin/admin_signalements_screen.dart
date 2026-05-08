import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';
import 'package:frontend_t_hero/utils/constants/api_constant.dart';
import 'package:frontend_t_hero/screens/admin/admin_signalement_detail_screen.dart';

class AdminSignalementsScreen extends StatefulWidget {
  const AdminSignalementsScreen({super.key});
  @override
  State<AdminSignalementsScreen> createState() => _AdminSignalementsScreenState();
}

class _AdminSignalementsScreenState extends State<AdminSignalementsScreen> {

  int _filter = 0;
  final _filters = ['Tous', 'En attente', 'Résolus'];

  List<Map<String, dynamic>> _signalements = [];
  List<Map<String, dynamic>> _agents       = [];
  bool    _loading = true;
  String  _search  = '';
  final   _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    await Future.wait([_fetchSignalements(), _fetchAgents()]);
    setState(() => _loading = false);
  }

  Future<void> _fetchSignalements() async {
    try {
      final prefs    = await SharedPreferences.getInstance();
      final token    = prefs.getString('token') ?? '';
      final response = await http.get(
        Uri.parse(ApiConstants.getAllSignalements),
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer $token' },
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _signalements = (data['data'] as List).map((e) => e as Map<String, dynamic>).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchAgents() async {
    try {
      final prefs    = await SharedPreferences.getInstance();
      final token    = prefs.getString('token') ?? '';
      final response = await http.get(
        Uri.parse(ApiConstants.getAllAgents),
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer $token' },
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _agents = (data['data'] as List).map((e) => e as Map<String, dynamic>).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _assignAgent(String signalementId, String agentId) async {
    try {
      final prefs    = await SharedPreferences.getInstance();
      final token    = prefs.getString('token') ?? '';
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/signalements/TraiterSignalement/$signalementId'),
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer $token' },
        body: jsonEncode({'agent': agentId}),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        _snack('Agent assigné ✓', TColors.success);
        await _fetchSignalements();
      } else {
        final data = jsonDecode(response.body);
        _snack(data['message'] ?? 'Erreur', TColors.error);
      }
    } catch (_) {
      _snack('Erreur serveur', TColors.error);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontSize: 13, fontFamily: 'Poppins')),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Color  _statusColor(String s) { switch (s) { case 'EN_COURS': return TColors.info; case 'RESOLU': return TColors.success; default: return TColors.warning; } }
  Color  _statusBg(String s)    { switch (s) { case 'EN_COURS': return TColors.infoLight; case 'RESOLU': return TColors.successLight; default: return TColors.warningLight; } }
  String _statusLabel(String s) { switch (s) { case 'EN_COURS': return 'En cours'; case 'RESOLU': return 'Résolu'; default: return 'En attente'; } }
  String _statusEmoji(String s) { switch (s) { case 'EN_COURS': return '⚡'; case 'RESOLU': return '✅'; default: return '⏳'; } }
  Color  _prioColor(String p)   { switch (p) { case 'ELEVEE': return TColors.error; case 'MOYENNE': return TColors.warning; default: return TColors.success; } }
  String _prioLabel(String p)   { switch (p) { case 'ELEVEE': return 'Élevée'; case 'MOYENNE': return 'Moyenne'; default: return 'Faible'; } }

  String _citoyenName(dynamic c) { if (c == null) return '—'; if (c is Map) return c['nom'] ?? '—'; return '—'; }
  String _agentName(dynamic a)   { if (a == null) return '—'; if (a is Map) return a['nom'] ?? '—'; return '—'; }
  String _catName(dynamic c)     { if (c == null) return 'Autre'; if (c is Map) return c['nom'] ?? 'Autre'; return 'Autre'; }

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

  List<Map<String, dynamic>> get _filtered {
    var list = _signalements;
    if (_filter == 1) list = list.where((s) => s['statut'] == 'EN_ATTENTE').toList();
    if (_filter == 2) list = list.where((s) => s['statut'] == 'RESOLU').toList();
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((s) {
        final desc    = (s['description'] ?? '').toString().toLowerCase();
        final cat     = _catName(s['categorie']).toLowerCase();
        final citoyen = _citoyenName(s['citoyen']).toLowerCase();
        final loc     = (s['localisation'] ?? '').toString().toLowerCase();
        return desc.contains(q) || cat.contains(q) || citoyen.contains(q) || loc.contains(q);
      }).toList();
    }
    return list;
  }

  int get _enAttente => _signalements.where((s) => s['statut'] == 'EN_ATTENTE').length;
  int get _enCours   => _signalements.where((s) => s['statut'] == 'EN_COURS').length;
  int get _resolus   => _signalements.where((s) => s['statut'] == 'RESOLU').length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── Header ──────────────────────────────────────
          Container(
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
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('🚩 Signalements',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                        color: Colors.white, fontFamily: 'Poppins')),
                    Text('${_signalements.length} au total',
                      style: const TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'Poppins')),
                  ]),
                  GestureDetector(
                    onTap: _fetchData,
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
                      child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 17))),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
                child: Row(children: [
                  _bannerStat('${_signalements.length}', 'Total',      Icons.flag_outlined),
                  _bannerDiv(),
                  _bannerStat('$_enAttente',              'En attente', Icons.hourglass_empty_rounded),
                  _bannerDiv(),
                  _bannerStat('$_enCours',                'En cours',   Icons.bolt_outlined),
                  _bannerDiv(),
                  _bannerStat('$_resolus',                'Résolus',    Icons.check_circle_outline),
                ]),
              ),
              const SizedBox(height: 14),

              // [ADDED] Search bar — white background, red border
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TColors.primary, width: 1.5)),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _search = v),
                  style: const TextStyle(fontSize: 14, fontFamily: 'Poppins', color: TColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un signalement...',
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
            ]),
          ),

          // ── Filter Tabs ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? TColors.darkContainer : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: List.generate(3, (i) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _filter == i ? (isDark ? TColors.cardDark : Colors.white) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: _filter == i ? Border.all(color: TColors.borderLight, width: 0.5) : null),
                      child: Text(_filters[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, fontFamily: 'Poppins',
                          fontWeight: _filter == i ? FontWeight.w600 : FontWeight.w400,
                          color: _filter == i ? TColors.primary : TColors.textHint)),
                    ),
                  ),
                )),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              _search.isNotEmpty
                ? '${_filtered.length} résultat(s) pour "$_search"'
                : '${_filtered.length} signalement(s)',
              style: const TextStyle(fontSize: 12, color: TColors.textHint, fontFamily: 'Poppins')),
          ),

          // ── List ─────────────────────────────────────────
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator(color: TColors.primary))
              : _filtered.isEmpty
                ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🚩', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(_search.isNotEmpty ? 'Aucun résultat pour "$_search"' : 'Aucun signalement',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                          color: TColors.textPrimary, fontFamily: 'Poppins')),
                      const SizedBox(height: 6),
                      const Text('Essayez un autre terme de recherche',
                        style: TextStyle(fontSize: 13, color: TColors.textHint, fontFamily: 'Poppins')),
                    ],
                  ))
                : RefreshIndicator(
                    onRefresh: _fetchData,
                    color: TColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _card(_filtered[i], isDark),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _card(Map<String, dynamic> s, bool isDark) {
    final statut       = s['statut']   ?? 'EN_ATTENTE';
    final prio         = s['priorite'] ?? 'FAIBLE';
    final agentObj     = s['agent'];
    final isUnassigned = agentObj == null;
    final agentNom     = _agentName(agentObj);
    final citoyenNom   = _citoyenName(s['citoyen']);
    final catNom       = _catName(s['categorie']);
    final desc         = s['description'] ?? '—';
    final time         = _timeAgo(s['createdAt']);
    final id           = s['_id'] ?? '';

    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => AdminSignalementDetailScreen(signalement: s)),
      ).then((_) => _fetchData()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? TColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.borderLight, width: 0.5),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: _statusBg(statut),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
            child: Row(children: [
              Text(_statusEmoji(statut), style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(child: Text(desc,
                overflow: TextOverflow.ellipsis, maxLines: 1,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  color: isDark ? TColors.textWhite : TColors.textPrimary, fontFamily: 'Poppins'))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20)),
                child: Text(_statusLabel(statut),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                    color: _statusColor(statut), fontFamily: 'Poppins'))),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.person_outline, size: 13, color: TColors.textHint),
                const SizedBox(width: 4),
                Text(citoyenNom, style: const TextStyle(fontSize: 12, color: TColors.textHint, fontFamily: 'Poppins')),
                const SizedBox(width: 10),
                const Icon(Icons.category_outlined, size: 13, color: TColors.textHint),
                const SizedBox(width: 4),
                Text(catNom, style: const TextStyle(fontSize: 12, color: TColors.textHint, fontFamily: 'Poppins')),
                const Spacer(),
                Text(time, style: const TextStyle(fontSize: 11, color: TColors.textHint, fontFamily: 'Poppins')),
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Container(width: 8, height: 8,
                    decoration: BoxDecoration(color: _prioColor(prio), shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text('Priorité ${_prioLabel(prio)}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: _prioColor(prio), fontFamily: 'Poppins')),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isUnassigned ? TColors.warningLight : TColors.infoLight,
                    borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    Icon(isUnassigned ? Icons.person_off_outlined : Icons.engineering_outlined,
                      size: 11, color: isUnassigned ? TColors.warning : TColors.info),
                    const SizedBox(width: 4),
                    Text(isUnassigned ? 'Non assigné' : agentNom,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                        color: isUnassigned ? TColors.warning : TColors.info, fontFamily: 'Poppins')),
                  ])),
              ]),
              if (statut != 'RESOLU') ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => _showAssignDialog(id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: isUnassigned ? TColors.primary : TColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: isUnassigned ? null : Border.all(color: TColors.info.withValues(alpha: 0.4), width: 1)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(isUnassigned ? Icons.person_add_outlined : Icons.swap_horiz_rounded,
                          size: 15, color: isUnassigned ? Colors.white : TColors.info),
                        const SizedBox(width: 6),
                        Text(isUnassigned ? 'Assigner un agent' : 'Réassigner',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                            color: isUnassigned ? Colors.white : TColors.info, fontFamily: 'Poppins')),
                      ]),
                    ),
                  ),
                ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  void _showAssignDialog(String signalementId) {
    String? selectedAgentId;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Text('🦸 ', style: TextStyle(fontSize: 18)),
            Text('Assigner un agent',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
          ]),
          content: _agents.isEmpty
            ? const Text('Aucun agent disponible',
                style: TextStyle(fontSize: 14, color: TColors.textHint, fontFamily: 'Poppins'))
            : SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: _agents.map((agent) {
                    final agentId  = agent['_id'] ?? '';
                    final agentNom = agent['nom'] ?? '—';
                    final sel      = selectedAgentId == agentId;
                    return GestureDetector(
                      onTap: () => setD(() => selectedAgentId = agentId),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: sel ? TColors.primaryLight : TColors.light,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sel ? TColors.primary : TColors.borderLight,
                            width: sel ? 1.5 : 0.5)),
                        child: Row(children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: sel ? TColors.primaryLight : TColors.infoLight,
                              shape: BoxShape.circle),
                            child: Center(child: Text(
                              agentNom.isNotEmpty ? agentNom[0].toUpperCase() : '?',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                                color: sel ? TColors.primary : TColors.info, fontFamily: 'Poppins')))),
                          const SizedBox(width: 12),
                          Expanded(child: Text(agentNom,
                            style: TextStyle(fontSize: 14,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                              color: sel ? TColors.primary : TColors.textPrimary, fontFamily: 'Poppins'))),
                          if (sel)
                            const Icon(Icons.check_circle_rounded, color: TColors.primary, size: 20),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
              ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler',
                style: TextStyle(fontSize: 14, color: TColors.textHint, fontFamily: 'Poppins'))),
            ElevatedButton(
              onPressed: selectedAgentId != null
                ? () { Navigator.pop(context); _assignAgent(signalementId, selectedAgentId!); }
                : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary, foregroundColor: Colors.white,
                disabledBackgroundColor: TColors.borderLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0),
              child: const Text('Confirmer',
                style: TextStyle(fontSize: 14, fontFamily: 'Poppins'))),
          ],
        ),
      ),
    );
  }

  Widget _bannerStat(String num, String label, IconData icon) {
    return Expanded(
      child: Column(children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 14),
        const SizedBox(height: 3),
        Text(num, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
          color: Colors.white, fontFamily: 'Poppins')),
        const SizedBox(height: 1),
        Text(label, style: TextStyle(fontSize: 8,
          color: Colors.white.withValues(alpha: 0.75), fontFamily: 'Poppins')),
      ]),
    );
  }

  Widget _bannerDiv() => Container(
    width: 1, height: 28, color: Colors.white.withValues(alpha: 0.2));
}