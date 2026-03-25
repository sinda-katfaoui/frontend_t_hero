// ============================================================
// AdminSignalementsScreen — Signalement Management for Admin
// ============================================================
// Displays all signalements with filter tabs by status.
// Embedded in AdminHomeScreen's IndexedStack at tab index 2.
//
// Filter tabs:
//   0 → Tous        (all signalements)
//   1 → En attente  (status = EN_ATTENTE)
//   2 → Résolus     (status = RESOLU)
//
// Each signalement card shows:
//   - Title + status pill
//   - Citoyen name + category
//   - Assigned agent name
//   - "Assigner" button for unassigned signalements
//
// Assign dialog:
//   - Radio list of available agents
//   - Confirm button only enabled when agent selected
//
// Design decisions:
// - White card header with title + signalement count
// - Animated filter tabs matching AdminUsersScreen style
// - Compact cards — title + subtitle + agent + button
// - "Assigner" is a small red pill button — not full width
// - Dialog uses radio buttons for agent selection
// - No scrolling on short filtered lists
//
// TODO: Connect to real API:
//   - GET /signalements/GetAllSignalements
//   - PUT /signalements/TraiterSignalement/:id (assign agent)
//   - GET /users/GetAllAgents (populate agent list)
// ============================================================

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

  // Active filter tab: 0=Tous, 1=En attente, 2=Résolus
  int _filter = 0;
  final _filters = ['Tous', 'En attente', 'Résolus'];

  // Mock signalement data — replace with API response
  final _signalements = [
    {
      'title':   'Nid de poule — Bourguiba',
      'citoyen': 'Amira',
      'cat':     'Voirie',
      'status':  'RESOLU',
      'agent':   'Agent Habib',
    },
    {
      'title':   'Lampadaire cassé — Sfax',
      'citoyen': 'Mohamed',
      'cat':     'Eclairage',
      'status':  'EN_ATTENTE',
      'agent':   '—',
    },
    {
      'title':   'Déchets — Sousse',
      'citoyen': 'Sara',
      'cat':     'Propreté',
      'status':  'EN_ATTENTE',
      'agent':   '—',
    },
    {
      'title':   'Arbres — El Mourouj',
      'citoyen': 'Yassine',
      'cat':     'Espaces Verts',
      'status':  'EN_ATTENTE',
      'agent':   '—',
    },
  ];

  // ── Status Helpers ─────────────────────────────────────────
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

  // ── Filtered Signalements ──────────────────────────────────
  List<Map<String, String>> get _filtered {
    if (_filter == 0) return _signalements;
    if (_filter == 1) return _signalements
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

          // ── Header ──────────────────────────────────────
          // White card with title + total count badge
          Container(
            color: isDark ? TColors.cardDark : TColors.cardLight,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Signalements',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
                // Total count pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: TColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${_signalements.length} total',
                    style: const TextStyle(
                      fontSize: 9,
                      color: TColors.primary,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    )),
                ),
              ],
            ),
          ),

          // ── Filter Tabs ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                  ? TColors.darkContainer
                  : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                children: List.generate(3, (i) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        vertical: 7),
                      decoration: BoxDecoration(
                        color: _filter == i
                          ? (isDark
                              ? TColors.cardDark
                              : TColors.cardLight)
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        border: _filter == i
                          ? Border.all(
                              color: TColors.borderLight,
                              width: 0.5)
                          : null,
                      ),
                      child: Text(_filters[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: _filter == i
                            ? FontWeight.w500 : FontWeight.w400,
                          color: _filter == i
                            ? TColors.primary : TColors.textHint,
                        )),
                    ),
                  ),
                )),
              ),
            ),
          ),

          // ── Signalement Cards List ────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _filtered.length,
              itemBuilder: (context, i) =>
                _signalementCard(_filtered[i], isDark),
            ),
          ),
        ],
      ),
    );
  }

  // ── Signalement Card ───────────────────────────────────────
  // Compact card with title, status pill, citoyen,
  // category, agent info, and assign button if unassigned.
  Widget _signalementCard(
      Map<String, String> s, bool isDark) {
    final isUnassigned = s['status'] == 'EN_ATTENTE' &&
      (s['agent'] == '—' || s['agent']!.isEmpty);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Title row + status pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(s['title']!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                      ? TColors.textWhite : TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusBg(s['status']!),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_statusLabel(s['status']!),
                  style: TextStyle(
                    fontSize: 8,
                    color: _statusColor(s['status']!),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  )),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Citoyen + category subtitle
          Text('${s['citoyen']} · ${s['cat']}',
            style: const TextStyle(
              fontSize: 9,
              color: TColors.textHint,
              fontFamily: 'Poppins',
            )),

          const SizedBox(height: 6),

          // Agent info + assign button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.engineering_outlined,
                  size: 12, color: TColors.textSecondary),
                const SizedBox(width: 4),
                Text(s['agent']!,
                  style: const TextStyle(
                    fontSize: 9,
                    color: TColors.textSecondary,
                    fontFamily: 'Poppins',
                  )),
              ]),

              // Assign button — only shown for unassigned ones
              if (isUnassigned)
                GestureDetector(
                  onTap: () => _showAssignDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: TColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Assigner',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      )),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Assign Agent Dialog ────────────────────────────────────
  // Shows a list of agents as radio buttons.
  // Confirm button only enabled when an agent is selected.
  // TODO: Replace agent list with GET /users/GetAllAgents
  // TODO: On confirm call PUT /signalements/TraiterSignalement/:id
  void _showAssignDialog(BuildContext context) {
    // Available agents — replace with real API data
    final agents = ['Agent Habib', 'Agent Sonia', 'Agent Bilel'];
    String? selected;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Assigner un agent',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
                    fontSize: 12,
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
                  color: TColors.textHint,
                  fontFamily: 'Poppins',
                )),
            ),
            ElevatedButton(
              // Disabled until an agent is selected
              onPressed: selected != null
                ? () => Navigator.pop(context)
                : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('Confirmer',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Poppins',
                )),
            ),
          ],
        ),
      ),
    );
  }
}