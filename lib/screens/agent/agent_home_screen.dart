// ============================================================
// AgentHomeScreen — Main Dashboard for Agent Municipal Role
// ============================================================
// Main screen for municipal agents after login.
// Uses IndexedStack with BottomNavigationBar for 3 tabs:
//   0 → Home (assigned signalements + new ones to pick up)
//   1 → History (all past signalements)
//   2 → Profile
//
// Home tab has 2 sub-tabs (pill buttons):
//   - "Mes signalements" → list assigned to this agent
//   - "Nouveaux"         → unassigned signalements to claim
//
// Design decisions:
// - White card header with greeting + role badge
// - Red stats card (same style as CitoyenHomeScreen)
// - Pill tab buttons instead of full tab bar
// - Priority dot on left of each card (red=high, orange=medium)
// - "Prendre en charge" button on new signalements
// - No scrolling — 3 items fit perfectly on screen
// - Tapping any card navigates to AgentDetailScreen
//
// TODO: Replace mock data with real API calls:
//   - GET /signalements/GetSignalementsByCitoyen → filter by agent
//   - GET /signalements/GetAllSignalements → for new ones
//   - PUT /signalements/TraiterSignalement/:id → claim signalement
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_t_hero/screens/agent/agent_detail_screen.dart';
import 'package:frontend_t_hero/screens/agent/agent_profile_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {

  // Bottom nav index: 0=Home, 1=History, 2=Profile
  int _navIndex = 0;

  // Sub-tab inside home: 0=Assigned, 1=New
  int _tab = 0;

  // Mock assigned signalements — replace with API data
  // These are signalements already assigned to this agent
  final _assigned = [
    {
      'title':       'Nid de poule — Bourguiba',
      'cat':         'Voirie',
      'status':      'EN_COURS',
      'priority':    'ELEVEE',
      'citoyen':     'Amira Bouazizi',
      'localisation':'Av. Bourguiba, Tunis',
      'description': 'Grand nid de poule dangereux sur la route principale.',
      'time':        'Il y a 2h',
      'agent':       'Agent Habib',
      'aiScore':     '80%',
      'aiCategorie': 'VOIRIE',
    },
    {
      'title':       'Lampadaire cassé — Sfax',
      'cat':         'Eclairage',
      'status':      'EN_ATTENTE',
      'priority':    'MOYENNE',
      'citoyen':     'Mohamed Ben Ali',
      'localisation':'Rue de la Liberté, Sfax',
      'description': 'Lampadaire cassé depuis 3 jours, zone sombre la nuit.',
      'time':        'Il y a 1j',
      'agent':       '—',
      'aiScore':     '75%',
      'aiCategorie': 'ECLAIRAGE',
    },
    {
      'title':       'Déchets marché — Sousse',
      'cat':         'Propreté',
      'status':      'RESOLU',
      'priority':    'FAIBLE',
      'citoyen':     'Sara Jouini',
      'localisation':'Marché Central, Sousse',
      'description': 'Dépôt sauvage de déchets près du marché central.',
      'time':        'Il y a 3j',
      'agent':       'Agent Habib',
      'aiScore':     '70%',
      'aiCategorie': 'PROPRETE',
    },
  ];

  // Mock new unassigned signalements — agent can claim these
  final _newSignalements = [
    {
      'title':       'Arbre bloque trottoir',
      'cat':         'Espaces Verts',
      'priority':    'FAIBLE',
      'citoyen':     'Yassine Trabelsi',
      'localisation':'Parc El Mourouj, Tunis',
      'description': 'Arbre non entretenu bloquant le passage piéton.',
      'time':        'Il y a 5j',
      'status':      'EN_ATTENTE',
      'agent':       '—',
      'aiScore':     '65%',
      'aiCategorie': 'ESPACES_VERTS',
    },
    {
      'title':       'Route endommagée — Bizerte',
      'cat':         'Voirie',
      'priority':    'ELEVEE',
      'citoyen':     'Karim Nasri',
      'localisation':'Route Nationale, Bizerte',
      'description': 'Route très endommagée, dangereux pour les véhicules.',
      'time':        'Il y a 6h',
      'status':      'EN_ATTENTE',
      'agent':       '—',
      'aiScore':     '85%',
      'aiCategorie': 'VOIRIE',
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

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

  // ── Priority Helpers ───────────────────────────────────────
  // Priority dot color on left of each card
  Color _priorityColor(String p) {
    switch (p) {
      case 'ELEVEE':  return TColors.error;
      case 'MOYENNE': return TColors.warning;
      default:        return TColors.success;
    }
  }

  // ── Category Icon ──────────────────────────────────────────
  IconData _catIcon(String cat) {
    switch (cat) {
      case 'Voirie':        return Icons.warning_amber_rounded;
      case 'Eclairage':     return Icons.lightbulb_outline;
      case 'Propreté':      return Icons.delete_outline;
      case 'Espaces Verts': return Icons.park_outlined;
      default:              return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.light,

      // IndexedStack keeps all tabs alive — no rebuild on switch
      body: IndexedStack(
        index: _navIndex,
        children: [
          _homeTab(isDark),
          _historyTab(isDark),
          const AgentProfileScreen(),
        ],
      ),

      // ── Bottom Navigation Bar ──────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _navIndex,
        selectedItemColor: TColors.primary,
        unselectedItemColor: TColors.grey,
        backgroundColor: isDark ? TColors.cardDark : TColors.cardLight,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 7, fontFamily: 'Poppins',
          fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(
          fontSize: 7, fontFamily: 'Poppins'),
        onTap: (i) => setState(() => _navIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded, size: 19),
            label: 'Tableau'),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, size: 19),
            label: 'Historique'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 19),
            label: 'Profil'),
        ],
      ),
    );
  }

  // ── Home Tab ───────────────────────────────────────────────
  // White header + red stats card + sub-tab pills + list.
  Widget _homeTab(bool isDark) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── White Header ────────────────────────────────
          Container(
            color: isDark ? TColors.cardDark : TColors.cardLight,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tableau de bord',
                      style: TextStyle(
                        fontSize: 9,
                        color: TColors.textHint,
                        fontFamily: 'Poppins',
                      )),
                    const Text('Agent Habib',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TColors.textPrimary,
                        fontFamily: 'Poppins',
                      )),
                  ],
                ),
                // Role badge pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: TColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Agent Municipal',
                    style: TextStyle(
                      fontSize: 8,
                      color: TColors.primary,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    )),
                ),
              ],
            ),
          ),

          // ── Red Stats Card ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Container(
              decoration: BoxDecoration(
                color: TColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 12, horizontal: 8),
              child: Row(children: [
                _statItem('5', 'Assignés'),
                _divider(),
                _statItem('3', 'En cours'),
                _divider(),
                _statItem('2', 'Résolus'),
              ]),
            ),
          ),

          // ── Sub-tab Pills ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 6),
            child: Row(children: [
              _tabBtn('Mes signalements', 0),
              const SizedBox(width: 7),
              _tabBtn('Nouveaux', 1),
            ]),
          ),

          // ── Signalement List ────────────────────────────
          // Switches between assigned and new lists
          Expanded(
            child: _tab == 0
              ? _assignedList(isDark)
              : _newList(isDark),
          ),
        ],
      ),
    );
  }

  // ── History Tab ────────────────────────────────────────────
  // All past signalements in a scrollable list.
  Widget _historyTab(bool isDark) {
    return SafeArea(
      child: Column(children: [
        Container(
          color: isDark ? TColors.cardDark : TColors.cardLight,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: const Row(children: [
            Text('Historique',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TColors.textPrimary,
                fontFamily: 'Poppins',
              )),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: _assigned.length,
            itemBuilder: (context, i) =>
              _signalementCard(_assigned[i], isDark,
                showPriority: true),
          ),
        ),
      ]),
    );
  }

  // ── Assigned List ──────────────────────────────────────────
  // Compact column — 3 items fit without scroll.
  Widget _assignedList(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: _assigned.map((s) =>
          _signalementCard(s, isDark,
            showPriority: true)).toList(),
      ),
    );
  }

  // ── New Signalements List ──────────────────────────────────
  // Shows unassigned signalements with "Prendre en charge" button.
  Widget _newList(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: _newSignalements.map((s) =>
          _newCard(s, isDark)).toList(),
      ),
    );
  }

  // ── Signalement Card ───────────────────────────────────────
  // Reused in assigned list and history tab.
  // Tapping opens AgentDetailScreen for full details.
  Widget _signalementCard(
      Map<String, String> s, bool isDark,
      {bool showPriority = false}) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
            AgentDetailScreen(signalement: s))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isDark ? TColors.cardDark : TColors.cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: TColors.borderLight, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 8),
        child: Row(children: [

          // Category icon box
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: _statusBg(s['status']!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _catIcon(s['cat']!),
              size: 15,
              color: _statusColor(s['status']!),
            ),
          ),

          const SizedBox(width: 9),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['title']!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                      ? TColors.textWhite : TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
                const SizedBox(height: 2),
                Row(children: [
                  // Priority dot
                  if (showPriority) ...[
                    Container(
                      width: 5, height: 5,
                      decoration: BoxDecoration(
                        color: _priorityColor(s['priority']!),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text('${s['cat']} · ${s['time']}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: TColors.textHint,
                      fontFamily: 'Poppins',
                    )),
                ]),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // Status pill
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
        ]),
      ),
    );
  }

  // ── New Signalement Card ───────────────────────────────────
  // Shows unassigned signalement with "Prendre en charge" button.
  Widget _newCard(Map<String, String> s, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
            AgentDetailScreen(signalement: s))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isDark ? TColors.cardDark : TColors.cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: TColors.borderLight, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 8),
        child: Row(children: [

          // Category icon
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: TColors.warningLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _catIcon(s['cat']!),
              size: 15, color: TColors.warning),
          ),

          const SizedBox(width: 9),

          // Title + location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['title']!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                      ? TColors.textWhite : TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
                const SizedBox(height: 2),
                Text(s['localisation']!,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: TColors.textHint,
                    fontFamily: 'Poppins',
                  )),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // Claim button — compact red pill
          GestureDetector(
            onTap: () {
              // TODO: Call PUT /signalements/TraiterSignalement/:id
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: TColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Prendre',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                )),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Sub-tab Pill Button ────────────────────────────────────
  // Active = red filled | Inactive = transparent with border
  Widget _tabBtn(String label, int index) {
    final active = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? TColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? TColors.primary : TColors.borderLight,
            width: 0.5),
        ),
        child: Text(label,
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'Poppins',
            color: active ? Colors.white : TColors.textHint,
            fontWeight: active
              ? FontWeight.w500 : FontWeight.w400,
          )),
      ),
    );
  }

  // ── Stat Item ──────────────────────────────────────────────
  // Single stat inside the red stats card.
  Widget _statItem(String num, String label) {
    return Expanded(
      child: Column(children: [
        Text(num,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Poppins',
          )),
        const SizedBox(height: 2),
        Text(label,
          style: TextStyle(
            fontSize: 8,
            color: Colors.white.withValues(alpha: 0.65),
            fontFamily: 'Poppins',
          )),
      ]),
    );
  }

  // ── Vertical Divider ───────────────────────────────────────
  // Thin white separator between stat items in red card.
  Widget _divider() {
    return Container(
      width: 0.5, height: 28,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}