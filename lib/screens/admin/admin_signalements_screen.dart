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

  final _signalements = [
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

  List<Map<String, String>> get _filtered {
    if (_filter == 0) return _signalements;
    if (_filter == 1) return _signalements
      .where((s) => s['status'] == 'EN_ATTENTE').toList();
    return _signalements
      .where((s) => s['status'] == 'RESOLU').toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        AppBar(
          title: Text('Signalements (${_signalements.length})'),
          automaticallyImplyLeading: false),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                ? TColors.cardDark
                : const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: List.generate(3, (i) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _filter = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _filter == i
                        ? Theme.of(context).cardTheme.color
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(9)),
                    child: Text(_filters[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _filter == i
                          ? FontWeight.w500 : FontWeight.w400,
                        color: _filter == i
                          ? TColors.primary : TColors.textHint)),
                  ),
                ),
              )),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _filtered.length,
            itemBuilder: (context, i) {
              final s = _filtered[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(s['title']!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500))),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusBg(s['status']!),
                              borderRadius:
                                BorderRadius.circular(8)),
                            child: Text(s['status']!,
                              style: TextStyle(
                                fontSize: 9,
                                color: _statusColor(s['status']!),
                                fontWeight: FontWeight.w500))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${s['citoyen']} · ${s['cat']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: TColors.textHint)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Agent: ${s['agent']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: TColors.textSecondary)),
                          if (s['status'] == 'EN_ATTENTE')
                            ElevatedButton(
                              onPressed: () =>
                                _showAssignDialog(context),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 28),
                                padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 10),
                                textStyle:
                                  const TextStyle(fontSize: 11)),
                              child: const Text('Assigner')),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  void _showAssignDialog(BuildContext context) {
    final agents = ['Agent Habib', 'Agent Sonia', 'Agent Bilel'];
    String? selected;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Assigner un agent'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: agents.map((a) => RadioListTile<String>(
              title: Text(a,
                style: const TextStyle(fontSize: 13)),
              value: a,
              groupValue: selected,
              activeColor: TColors.primary,
              onChanged: (v) =>
                setDialogState(() => selected = v),
            )).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
            ElevatedButton(
              onPressed: selected != null
                ? () => Navigator.pop(context)
                : null,
              child: const Text('Confirmer')),
          ],
        ),
      ),
    );
  }
}