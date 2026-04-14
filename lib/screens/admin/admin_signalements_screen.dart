import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

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

  final List<Map<String, String>> _signalements = [
    {'title': 'Nid de poule — Bourguiba', 'citoyen': 'Amira',
     'cat': 'Voirie', 'status': 'RESOLU', 'agent': 'Agent Habib'},
    {'title': 'Lampadaire cassé — Sfax', 'citoyen': 'Mohamed',
     'cat': 'Eclairage', 'status': 'EN_ATTENTE', 'agent': '—'},
    {'title': 'Déchets — Sousse', 'citoyen': 'Sara',
     'cat': 'Propreté', 'status': 'EN_ATTENTE', 'agent': '—'},
    {'title': 'Arbres — El Mourouj', 'citoyen': 'Yassine',
     'cat': 'Espaces Verts', 'status': 'EN_ATTENTE', 'agent': '—'},
  ];

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

  List<Map<String, String>> get _filtered {
    if (_filter == 0) return _signalements;
    if (_filter == 1)
      return _signalements
        .where((s) => s['status'] == 'EN_ATTENTE').toList();
    return _signalements
      .where((s) => s['status'] == 'RESOLU').toList();
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

          // ── Signalement List ──────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 4),
              itemCount: _filtered.length,
              itemBuilder: (_, i) =>
                _card(_filtered[i], isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Map<String, String> s, bool isDark) {
    final isUnassigned = s['status'] == 'EN_ATTENTE' &&
      (s['agent'] == '—' || s['agent']!.isEmpty);

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
                child: Text(s['title']!,
                  overflow: TextOverflow.ellipsis,
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
                  color: _statusBg(s['status']!),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_statusLabel(s['status']!),
                  style: TextStyle(
                    fontSize: 11,
                    color: _statusColor(s['status']!),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ))),
            ],
          ),
          const SizedBox(height: 6),
          // Citoyen + category
          Text('${s['citoyen']} · ${s['cat']}',
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
                Text(s['agent']!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: TColors.textSecondary,
                    fontFamily: 'Poppins',
                  )),
              ]),
              if (isUnassigned)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showAssignDialog(),
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: TColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                        child: Text('Assigner',
                          style: TextStyle(
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

  void _showAssignDialog() {
    final agents = ['Agent Habib', 'Agent Sonia', 'Agent Bilel'];
    String? selected;

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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: agents.map((agent) =>
              RadioListTile<String>(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(agent,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  )),
                value: agent,
                groupValue: selected,
                activeColor: TColors.primary,
                onChanged: (v) =>
                  setDialogState(() => selected = v),
              ),
            ).toList(),
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
              onPressed: selected != null
                ? () => Navigator.pop(context) : null,
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