import 'package:flutter/material.dart';
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

  final _assigned = [
    {'title': 'Nid de poule — Bourguiba', 'cat': 'Voirie',
     'status': 'EN_COURS', 'priority': 'ELEVEE',
     'citoyen': 'Amira Bouazizi', 'localisation': 'Av. Bourguiba, Tunis',
     'description': 'Grand nid de poule dangereux sur la route principale.',
     'time': 'Il y a 2h', 'agent': 'Agent Habib', 'aiScore': '80%',
     'aiCategorie': 'VOIRIE'},
    {'title': 'Lampadaire cassé — Sfax', 'cat': 'Eclairage',
     'status': 'EN_ATTENTE', 'priority': 'MOYENNE',
     'citoyen': 'Mohamed Ben Ali', 'localisation': 'Rue de la Liberté, Sfax',
     'description': 'Lampadaire cassé depuis 3 jours, zone sombre la nuit.',
     'time': 'Il y a 1j', 'agent': '—', 'aiScore': '75%',
     'aiCategorie': 'ECLAIRAGE'},
    {'title': 'Déchets marché — Sousse', 'cat': 'Propreté',
     'status': 'RESOLU', 'priority': 'FAIBLE',
     'citoyen': 'Sara Jouini', 'localisation': 'Marché Central, Sousse',
     'description': 'Dépôt sauvage de déchets près du marché central.',
     'time': 'Il y a 3j', 'agent': 'Agent Habib', 'aiScore': '70%',
     'aiCategorie': 'PROPRETE'},
  ];

  final _newSignalements = [
    {'title': 'Arbre bloque trottoir', 'cat': 'Espaces Verts',
     'priority': 'FAIBLE', 'citoyen': 'Yassine Trabelsi',
     'localisation': 'Parc El Mourouj, Tunis',
     'description': 'Arbre non entretenu bloquant le passage piéton.',
     'time': 'Il y a 5j', 'status': 'EN_ATTENTE',
     'agent': '—', 'aiScore': '65%', 'aiCategorie': 'ESPACES_VERTS'},
    {'title': 'Route endommagée — Bizerte', 'cat': 'Voirie',
     'priority': 'ELEVEE', 'citoyen': 'Karim Nasri',
     'localisation': 'Route Nationale, Bizerte',
     'description': 'Route très endommagée, dangereux pour les véhicules.',
     'time': 'Il y a 6h', 'status': 'EN_ATTENTE',
     'agent': '—', 'aiScore': '85%', 'aiCategorie': 'VOIRIE'},
  ];

  Color _statusColor(String s) {
    switch (s) {
      case 'EN_COURS':  return TColors.info;
      case 'RESOLU':    return TColors.success;
      default:          return TColors.warning;
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'EN_COURS':  return TColors.infoLight;
      case 'RESOLU':    return TColors.successLight;
      default:          return TColors.warningLight;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'EN_COURS':  return 'En cours';
      case 'RESOLU':    return 'Résolu';
      default:          return 'En attente';
    }
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'ELEVEE':  return TColors.error;
      case 'MOYENNE': return TColors.warning;
      default:        return TColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _navIndex, children: [
        _homeTab(),
        _historyTab(),
        const AgentProfileScreen(),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _navIndex,
        selectedItemColor: TColors.primary,
        unselectedItemColor: TColors.grey,
        onTap: (i) => setState(() => _navIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Tableau'),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil'),
        ],
      ),
    );
  }

  Widget _homeTab() {
    return SafeArea(
      child: Column(children: [
        Container(
          color: TColors.primary,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tableau de bord', style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8))),
                  const Text('Agent Habib', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500,
                    color: Colors.white)),
                ]),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10)),
                child: const Text('Agent Municipal',
                  style: TextStyle(
                    fontSize: 10, color: Colors.white))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            _stat('5', 'Assignés',  TColors.primary),
            const SizedBox(width: 8),
            _stat('3', 'En cours',  TColors.warning),
            const SizedBox(width: 8),
            _stat('2', 'Résolus',   TColors.success),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            _tabBtn('Mes signalements', 0),
            const SizedBox(width: 8),
            _tabBtn('Nouveaux', 1),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _tab == 0
            ? _assignedList()
            : _newList()),
      ]),
    );
  }

  Widget _historyTab() {
    return SafeArea(
      child: Column(children: [
        AppBar(
          title: const Text('Historique'),
          automaticallyImplyLeading: false),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _assigned.length,
            itemBuilder: (context, i) {
              final s = _assigned[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 5,
                    backgroundColor:
                      _priorityColor(s['priority']!)),
                  title: Text(s['title']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    '${s['cat']} · ${s['time']}',
                    style: const TextStyle(fontSize: 11)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusBg(s['status']!),
                      borderRadius: BorderRadius.circular(8)),
                    child: Text(_statusLabel(s['status']!),
                      style: TextStyle(
                        fontSize: 10,
                        color: _statusColor(s['status']!),
                        fontWeight: FontWeight.w500))),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _assignedList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _assigned.length,
      itemBuilder: (context, i) {
        final s = _assigned[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            onTap: () => Navigator.push(context,
              MaterialPageRoute(
                builder: (context) =>
                  AgentDetailScreen(signalement: s))),
            leading: CircleAvatar(
              radius: 5,
              backgroundColor: _priorityColor(s['priority']!)),
            title: Text(s['title']!,
              style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500)),
            subtitle: Text(s['cat']!,
              style: const TextStyle(fontSize: 11)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusBg(s['status']!),
                borderRadius: BorderRadius.circular(8)),
              child: Text(_statusLabel(s['status']!),
                style: TextStyle(
                  fontSize: 10,
                  color: _statusColor(s['status']!),
                  fontWeight: FontWeight.w500))),
          ),
        );
      },
    );
  }

  Widget _newList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _newSignalements.length,
      itemBuilder: (context, i) {
        final s = _newSignalements[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            onTap: () => Navigator.push(context,
              MaterialPageRoute(
                builder: (context) =>
                  AgentDetailScreen(signalement: s))),
            title: Text(s['title']!,
              style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500)),
            subtitle: Text(
              '${s['cat']} · ${s['localisation']}',
              style: const TextStyle(fontSize: 11)),
            trailing: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10),
                textStyle: const TextStyle(fontSize: 11)),
              child: const Text('Prendre en charge')),
          ),
        );
      },
    );
  }

  Widget _tabBtn(String label, int index) {
    final active = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? TColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? TColors.primary : TColors.borderLight)),
        child: Text(label,
          style: TextStyle(
            fontSize: 12,
            color: active ? Colors.white : TColors.textHint,
            fontWeight: active
              ? FontWeight.w500 : FontWeight.w400)),
      ),
    );
  }

  Widget _stat(String num, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: TColors.borderLight, width: 0.5)),
        child: Column(children: [
          Text(num, style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600,
            color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(
            fontSize: 10, color: TColors.textHint)),
        ]),
      ),
    );
  }
}