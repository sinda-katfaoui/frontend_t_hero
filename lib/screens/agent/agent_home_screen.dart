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
  int _navIndex = 0;
  int _tab      = 0;

  final List<Map<String, String>> _assigned = [
    {
      'title':        'Nid de poule — Bourguiba',
      'cat':          'Voirie',
      'status':       'EN_COURS',
      'priority':     'ELEVEE',
      'citoyen':      'Amira Bouazizi',
      'localisation': 'Av. Bourguiba, Tunis',
      'description':  'Grand nid de poule dangereux sur la route principale.',
      'time':         'Il y a 2h',
      'agent':        'Agent Habib',
      'aiScore':      '80%',
      'aiCategorie':  'VOIRIE',
    },
    {
      'title':        'Lampadaire cassé — Sfax',
      'cat':          'Eclairage',
      'status':       'EN_ATTENTE',
      'priority':     'MOYENNE',
      'citoyen':      'Mohamed Ben Ali',
      'localisation': 'Rue de la Liberté, Sfax',
      'description':  'Lampadaire cassé depuis 3 jours, zone sombre la nuit.',
      'time':         'Il y a 1j',
      'agent':        '—',
      'aiScore':      '75%',
      'aiCategorie':  'ECLAIRAGE',
    },
    {
      'title':        'Déchets marché — Sousse',
      'cat':          'Propreté',
      'status':       'RESOLU',
      'priority':     'FAIBLE',
      'citoyen':      'Sara Jouini',
      'localisation': 'Marché Central, Sousse',
      'description':  'Dépôt sauvage de déchets près du marché central.',
      'time':         'Il y a 3j',
      'agent':        'Agent Habib',
      'aiScore':      '70%',
      'aiCategorie':  'PROPRETE',
    },
  ];

  final List<Map<String, String>> _nouveaux = [
    {
      'title':        'Arbre bloque trottoir',
      'cat':          'Espaces Verts',
      'priority':     'FAIBLE',
      'citoyen':      'Yassine Trabelsi',
      'localisation': 'Parc El Mourouj, Tunis',
      'description':  'Arbre non entretenu bloquant le passage piéton.',
      'time':         'Il y a 5j',
      'status':       'EN_ATTENTE',
      'agent':        '—',
      'aiScore':      '65%',
      'aiCategorie':  'ESPACES_VERTS',
    },
    {
      'title':        'Route endommagée — Bizerte',
      'cat':          'Voirie',
      'priority':     'ELEVEE',
      'citoyen':      'Karim Nasri',
      'localisation': 'Route Nationale, Bizerte',
      'description':  'Route très endommagée, dangereux pour les véhicules.',
      'time':         'Il y a 6h',
      'status':       'EN_ATTENTE',
      'agent':        '—',
      'aiScore':      '85%',
      'aiCategorie':  'VOIRIE',
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

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'Voirie':        return Icons.warning_amber_rounded;
      case 'Eclairage':     return Icons.lightbulb_outline;
      case 'Propreté':      return Icons.delete_outline;
      case 'Espaces Verts': return Icons.park_outlined;
      default:              return Icons.help_outline;
    }
  }

  // ── Navigate safely ────────────────────────────────────────
  // Uses the mounted check before navigating to avoid
  // the "context is no longer valid" assertion error.
  void _goToDetail(Map<String, String> s) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgentDetailScreen(signalement: s)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.light,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _homeTab(isDark),
          _historyTab(isDark),
          const AgentProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _navIndex,
        selectedItemColor: TColors.primary,
        unselectedItemColor: TColors.grey,
        backgroundColor:
          isDark ? TColors.cardDark : TColors.cardLight,
        elevation: 4,
        selectedLabelStyle: const TextStyle(
          fontSize: 11, fontFamily: 'Poppins',
          fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11, fontFamily: 'Poppins'),
        onTap: (i) => setState(() => _navIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded, size: 24),
            label: 'Tableau'),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, size: 24),
            label: 'Historique'),
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
          // White Header
          Container(
            color: isDark ? TColors.cardDark : TColors.cardLight,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tableau de bord',
                      style: TextStyle(
                        fontSize: 13,
                        color: TColors.textHint,
                        fontFamily: 'Poppins',
                      )),
                    const Text('Agent Habib',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TColors.textPrimary,
                        fontFamily: 'Poppins',
                      )),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: TColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Agent Municipal',
                    style: TextStyle(
                      fontSize: 12,
                      color: TColors.primary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    )),
                ),
              ],
            ),
          ),

          // Red Stats Card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: TColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 16, horizontal: 8),
              child: Row(children: [
                _statItem('5', 'Assignés'),
                _vDivider(),
                _statItem('3', 'En cours'),
                _vDivider(),
                _statItem('2', 'Résolus'),
              ]),
            ),
          ),

          // Sub-tab Pills
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(children: [
              _tabBtn('Mes signalements', 0),
              const SizedBox(width: 10),
              _tabBtn('Nouveaux', 1),
            ]),
          ),

          // ── Tab content ────────────────────────────────
          Expanded(
            child: _tab == 0
              ? ListView.builder(
                  key: const PageStorageKey('assigned'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                  itemCount: _assigned.length,
                  itemBuilder: (_, i) =>
                    _assignedCard(_assigned[i], isDark),
                )
              : ListView.builder(
                  key: const PageStorageKey('nouveaux'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                  itemCount: _nouveaux.length,
                  itemBuilder: (_, i) =>
                    _newCard(_nouveaux[i], isDark),
                ),
          ),
        ],
      ),
    );
  }

  Widget _historyTab(bool isDark) {
    return SafeArea(
      child: Column(children: [
        Container(
          color: isDark ? TColors.cardDark : TColors.cardLight,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: const Row(children: [
            Text('Historique',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
                fontFamily: 'Poppins',
              )),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _assigned.length,
            itemBuilder: (_, i) =>
              _assignedCard(_assigned[i], isDark),
          ),
        ),
      ]),
    );
  }

  Widget _assignedCard(Map<String, String> s, bool isDark) {
    return GestureDetector(
      onTap: () => _goToDetail(s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? TColors.cardDark : TColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TColors.borderLight, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 14),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: _statusBg(s['status'] ?? 'EN_ATTENTE'),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              _catIcon(s['cat'] ?? ''),
              size: 22,
              color: _statusColor(s['status'] ?? 'EN_ATTENTE')),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['title'] ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                      ? TColors.textWhite : TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                      color: _priorityColor(
                        s['priority'] ?? 'FAIBLE'),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text('${s['cat'] ?? ''} · ${s['time'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: TColors.textHint,
                      fontFamily: 'Poppins',
                    )),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _statusBg(s['status'] ?? 'EN_ATTENTE'),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel(s['status'] ?? 'EN_ATTENTE'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _statusColor(s['status'] ?? 'EN_ATTENTE'),
                fontFamily: 'Poppins',
              )),
          ),
        ]),
      ),
    );
  }

  Widget _newCard(Map<String, String> s, bool isDark) {
    return GestureDetector(
      onTap: () => _goToDetail(s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? TColors.cardDark : TColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TColors.borderLight, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 14),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: TColors.warningLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              _catIcon(s['cat'] ?? ''),
              size: 22, color: TColors.warning),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['title'] ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                      ? TColors.textWhite : TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
                const SizedBox(height: 4),
                Text(s['localisation'] ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TColors.textHint,
                    fontFamily: 'Poppins',
                  )),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _goToDetail(s),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins'),
            ),
            child: const Text('Prendre'),
          ),
        ]),
      ),
    );
  }

  Widget _tabBtn(String label, int index) {
    final active = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: active ? TColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
              ? TColors.primary : TColors.borderLight,
            width: active ? 0 : 0.5),
        ),
        child: Text(label,
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Poppins',
            color: active ? Colors.white : TColors.textHint,
            fontWeight: active
              ? FontWeight.w600 : FontWeight.w400,
          )),
      ),
    );
  }

  Widget _statItem(String num, String label) {
    return Expanded(
      child: Column(children: [
        Text(num,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Poppins',
          )),
        const SizedBox(height: 2),
        Text(label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
            fontFamily: 'Poppins',
          )),
      ]),
    );
  }

  Widget _vDivider() {
    return Container(
      width: 1, height: 36,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}