import 'package:flutter/material.dart';
import 'package:frontend_t_hero/screens/citoyen/new_signalement_screen.dart';
import 'package:frontend_t_hero/screens/citoyen/notifications_screen.dart';
import 'package:frontend_t_hero/screens/citoyen/profile_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class CitoyenHomeScreen extends StatefulWidget {
  const CitoyenHomeScreen({super.key});

  @override
  State<CitoyenHomeScreen> createState() => _CitoyenHomeScreenState();
}

class _CitoyenHomeScreenState extends State<CitoyenHomeScreen> {
  int _currentIndex = 0;

  final _signalements = [
    {'title': 'Nid de poule — Bourguiba', 'cat': 'Voirie',
     'status': 'EN_COURS', 'time': 'Il y a 2h'},
    {'title': 'Lampadaire cassé — Sfax', 'cat': 'Eclairage',
     'status': 'EN_ATTENTE', 'time': 'Il y a 1j'},
    {'title': 'Déchets — Sousse', 'cat': 'Propreté',
     'status': 'RESOLU', 'time': 'Il y a 3j'},
    {'title': 'Arbres — El Mourouj', 'cat': 'Espaces Verts',
     'status': 'EN_ATTENTE', 'time': 'Il y a 5j'},
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _homeTab(),
          _historyTab(),
          const SizedBox(),
          const NotificationsScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => const NewSignalementScreen())),
        backgroundColor: TColors.primary,
        child: const Icon(Icons.add, color: Colors.white)),
      floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(children: [
          _navItem(Icons.grid_view_rounded, 'Accueil', 0),
          _navItem(Icons.history, 'Historique', 1),
          const SizedBox(width: 40),
          _navItem(Icons.notifications_outlined, 'Notifs', 3),
          _navItem(Icons.person_outline, 'Profil', 4),
        ]),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final active = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon,
              color: active ? TColors.primary : TColors.grey,
              size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(
              fontSize: 10,
              color: active ? TColors.primary : TColors.grey)),
          ]),
        ),
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
                  Text('Bonjour,', style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8))),
                  const Text('Amira Bouazizi', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500,
                    color: Colors.white)),
                ]),
              Row(children: [
                Stack(children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
                    onPressed: () =>
                      setState(() => _currentIndex = 3)),
                  Positioned(top: 8, right: 8,
                    child: Container(width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle))),
                ]),
                CircleAvatar(radius: 16,
                  backgroundColor:
                    Colors.white.withValues(alpha: 0.25),
                  child: const Text('AB', style: TextStyle(
                    color: Colors.white,
                    fontSize: 11, fontWeight: FontWeight.w500))),
              ]),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            _statCard('4', 'Total', TColors.primary),
            const SizedBox(width: 8),
            _statCard('2', 'En cours', TColors.warning),
            const SizedBox(width: 8),
            _statCard('1', 'Résolus', TColors.success),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mes signalements',
                style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: () {},
                child: const Text('Voir tout')),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _signalements.length,
            itemBuilder: (context, i) {
              final s = _signalements[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 5,
                    backgroundColor: _statusColor(s['status']!)),
                  title: Text(s['title']!, style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
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
                      style: TextStyle(fontSize: 10,
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

  Widget _historyTab() {
    return SafeArea(
      child: Column(children: [
        AppBar(
          title: const Text('Historique'),
          automaticallyImplyLeading: false),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _signalements.length,
            itemBuilder: (context, i) {
              final s = _signalements[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(s['title']!, style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
                  subtitle: Text('${s['cat']} · ${s['time']}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusBg(s['status']!),
                      borderRadius: BorderRadius.circular(8)),
                    child: Text(_statusLabel(s['status']!),
                      style: TextStyle(fontSize: 10,
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

  Widget _statCard(String num, String label, Color color) {
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