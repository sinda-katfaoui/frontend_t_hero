import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';
import 'package:frontend_t_hero/utils/constants/api_constant.dart';

class AdminSignalementsScreen extends StatefulWidget {
  const AdminSignalementsScreen({super.key});
  @override
  State<AdminSignalementsScreen> createState() =>
      _AdminSignalementsScreenState();
}

class _AdminSignalementsScreenState
    extends State<AdminSignalementsScreen> {

  int _filter = 0;
  final _filters = ['Tous', 'En attente', 'Résolus'];

  List<Map<String, dynamic>> _signalements = [];
  List<Map<String, dynamic>> _agents       = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // ── Fetch signalements + agents ────────────────────────────
  Future<void> _fetchData() async {
    setState(() => _loading = true);
    await Future.wait([
      _fetchSignalements(),
      _fetchAgents(),
    ]);
    setState(() => _loading = false);
  }

  Future<void> _fetchSignalements() async {
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
        final list = data['data'] as List;
        setState(() {
          _signalements = list
            .map((e) => e as Map<String, dynamic>)
            .toList();
        });
      }
    } catch (e) {
      print('Error fetching signalements: $e');
    }
  }

  Future<void> _fetchAgents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse(ApiConstants.getAllAgents),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List;
        setState(() {
          _agents = list
            .map((e) => e as Map<String, dynamic>)
            .toList();
        });
      }
    } catch (e) {
      print('Error fetching agents: $e');
    }
  }

  // ── Assign agent to signalement ────────────────────────────
  Future<void> _assignAgent(String signalementId,
      String agentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.put(
        Uri.parse(
          '${ApiConstants.baseUrl}/signalements/TraiterSignalement/$signalementId'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'agent': agentId}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _showSnack('Agent assigné avec succès ✓', TColors.success);
        await _fetchSignalements();
      } else {
        final data = jsonDecode(response.body);
        _showSnack(
          data['message'] ?? 'Erreur assignation', TColors.error);
      }
    } catch (e) {
      _showSnack('Erreur serveur', TColors.error);
    }
  }

  void _showSnack(String msg, Color color) {
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

  // ── Helpers ────────────────────────────────────────────────
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

  String _citoyenName(dynamic citoyen) {
    if (citoyen == null) return '—';
    if (citoyen is Map) return citoyen['nom'] ?? '—';
    return '—';
  }

  String _agentName(dynamic agent) {
    if (agent == null) return '—';
    if (agent is Map) return agent['nom'] ?? '—';
    return '—';
  }

  String _catName(dynamic cat) {
    if (cat == null) return 'Autre';
    if (cat is Map) return cat['nom'] ?? 'Autre';
    return 'Autre';
  }

  // ── Filtered list ──────────────────────────────────────────
  List<Map<String, dynamic>> get _filtered {
    if (_filter == 0) return _signalements;
    if (_filter == 1) return _signalements
      .where((s) => s['statut'] == 'EN_ATTENTE').toList();
    return _signalements
      .where((s) => s['statut'] == 'RESOLU').toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── Header ────────────────────────────────────────
          Container(
            color: isDark ? TColors.cardDark : TColors.cardLight,
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Signalements',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: TColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${_signalements.length} total',
                      style: const TextStyle(
                        fontSize: 12,
                        color: TColors.primary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      )),
                  ),
                  const SizedBox(width: 8),
                  // Refresh button
                  GestureDetector(
                    onTap: _fetchData,
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: TColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.refresh,
                        color: TColors.primary, size: 20)),
                  ),
                ]),
              ],
            ),
          ),

          // ── Filter Tabs ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                  ? TColors.darkContainer
                  : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: List.generate(3, (i) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        vertical: 9),
                      decoration: BoxDecoration(
                        color: _filter == i
                          ? (isDark
                              ? TColors.cardDark
                              : TColors.cardLight)
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: _filter == i
                          ? Border.all(
                              color: TColors.borderLight,
                              width: 0.5)
                          : null,
                      ),
                      child: Text(_filters[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: _filter == i
                            ? FontWeight.w600 : FontWeight.w400,
                          color: _filter == i
                            ? TColors.primary : TColors.textHint,
                        )),
                    ),
                  ),
                )),
              ),
            ),
          ),

          // ── List ─────────────────────────────────────────
          Expanded(
            child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: TColors.primary))
              : _filtered.isEmpty
                ? Center(
                    child: Text(
                      _filter == 0
                        ? 'Aucun signalement'
                        : 'Aucun signalement dans cette catégorie',
                      style: const TextStyle(
                        fontSize: 15,
                        color: TColors.textHint,
                        fontFamily: 'Poppins',
                      )))
                : RefreshIndicator(
                    onRefresh: _fetchData,
                    color: TColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) =>
                        _card(_filtered[i], isDark),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _card(Map<String, dynamic> s, bool isDark) {
    final statut  = s['statut'] ?? 'EN_ATTENTE';
    final agentObj = s['agent'];
    final isUnassigned = agentObj == null;
    final agentNom = _agentName(agentObj);
    final citoyenNom = _citoyenName(s['citoyen']);
    final catNom = _catName(s['categorie']);
    final signalementId = s['_id'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Title + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  s['description'] ?? 'Sans description',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                      ? TColors.textWhite : TColors.textPrimary,
                    fontFamily: 'Poppins',
                  ))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusBg(statut),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_statusLabel(statut),
                  style: TextStyle(
                    fontSize: 11,
                    color: _statusColor(statut),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ))),
            ],
          ),

          const SizedBox(height: 6),

          // Citoyen + category
          Text('$citoyenNom · $catNom',
            style: const TextStyle(
              fontSize: 13,
              color: TColors.textHint,
              fontFamily: 'Poppins',
            )),

          const SizedBox(height: 8),

          // Agent + assign button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.engineering_outlined,
                  size: 16, color: TColors.textSecondary),
                const SizedBox(width: 6),
                Text(isUnassigned ? 'Non assigné' : agentNom,
                  style: TextStyle(
                    fontSize: 13,
                    color: isUnassigned
                      ? TColors.warning : TColors.textSecondary,
                    fontWeight: isUnassigned
                      ? FontWeight.w600 : FontWeight.w400,
                    fontFamily: 'Poppins',
                  )),
              ]),

              if (statut != 'RESOLU')
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showAssignDialog(signalementId),
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: isUnassigned
                          ? TColors.primary : TColors.info,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                        child: Text(
                          isUnassigned ? 'Assigner' : 'Réassigner',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          )),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Assign dialog with real agents ────────────────────────
  void _showAssignDialog(String signalementId) {
    String? selectedAgentId;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
          title: const Text('Assigner un agent',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            )),
          content: _agents.isEmpty
            ? const Text(
                'Aucun agent disponible',
                style: TextStyle(
                  fontSize: 14,
                  color: TColors.textHint,
                  fontFamily: 'Poppins',
                ))
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: _agents.map((agent) {
                  final agentId  = agent['_id'] ?? '';
                  final agentNom = agent['nom'] ?? '—';
                  return RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(agentNom,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      )),
                    value: agentId,
                    groupValue: selectedAgentId,
                    activeColor: TColors.primary,
                    onChanged: (v) =>
                      setDialogState(() => selectedAgentId = v),
                  );
                }).toList(),
              ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler',
                style: TextStyle(
                  fontSize: 14,
                  color: TColors.textHint,
                  fontFamily: 'Poppins',
                ))),
            ElevatedButton(
              onPressed: selectedAgentId != null
                ? () {
                    Navigator.pop(context);
                    _assignAgent(signalementId, selectedAgentId!);
                  }
                : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Confirmer',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ))),
          ],
        ),
      ),
    );
  }
}