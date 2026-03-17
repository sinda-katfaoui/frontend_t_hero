import 'package:flutter/material.dart';
import 'package:frontend_t_hero/screens/admin/admin_users_screen.dart';
import 'package:frontend_t_hero/screens/admin/admin_signalements_screen.dart';
import 'package:frontend_t_hero/screens/admin/admin_categories_screen.dart';
import 'package:frontend_t_hero/screens/auth/login_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: [
        _dashboardTab(),
        const AdminUsersScreen(),
        const AdminSignalementsScreen(),
        const AdminCategoriesScreen(),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        selectedItemColor: TColors.primary,
        unselectedItemColor: TColors.grey,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Utilisateurs'),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            label: 'Signalements'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: 'Catégories'),
        ],
      ),
    );
  }

  Widget _dashboardTab() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(children: [
          Container(
            color: TColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dashboard', style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8))),
                    const Text('Admin Principal', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500,
                      color: Colors.white)),
                  ]),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10)),
                    child: const Text('Admin',
                      style: TextStyle(
                        fontSize: 10, color: Colors.white))),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.logout,
                      color: Colors.white, size: 20),
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                      (route) => false)),
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: [
                _statCard('14', 'Utilisateurs',
                  Icons.people_outline, TColors.primary),
                _statCard('4', 'Signalements',
                  Icons.flag_outlined, TColors.info),
                _statCard('1', 'Résolus',
                  Icons.check_circle_outline, TColors.success),
                _statCard('3', 'Agents',
                  Icons.engineering_outlined, TColors.warning),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Signalements par catégorie',
                      style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 16),
                    _barChart(),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Récents',
                          style:
                            Theme.of(context).textTheme.titleSmall),
                        TextButton(
                          onPressed: () =>
                            setState(() => _index = 2),
                          child: const Text('Voir tout')),
                      ],
                    ),
                    ...[
                      'Nid de poule — Bourguiba',
                      'Lampadaire cassé — Sfax',
                      'Déchets — Sousse',
                    ].map((t) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.circle,
                        size: 8, color: TColors.primary),
                      title: Text(t,
                        style: const TextStyle(fontSize: 13)),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 12, color: TColors.grey),
                    )),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _statCard(String num, String label,
      IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TColors.borderLight, width: 0.5)),
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(num, style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600,
              color: color)),
            Text(label, style: const TextStyle(
              fontSize: 10, color: TColors.textHint)),
          ]),
      ]),
    );
  }

  Widget _barChart() {
    final data = [
      {'label': 'Voirie',    'value': 0.9},
      {'label': 'Eclairage', 'value': 0.65},
      {'label': 'Propreté',  'value': 0.5},
      {'label': 'Espaces',   'value': 0.35},
      {'label': 'Autre',     'value': 0.2},
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((d) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(children: [
              Container(
                height: 80 * (d['value'] as double),
                decoration: BoxDecoration(
                  color: TColors.primary.withValues(
                    alpha: d['value'] as double),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4))),
              ),
              const SizedBox(height: 4),
              Text(d['label'] as String,
                style: const TextStyle(
                  fontSize: 9, color: TColors.textHint),
                textAlign: TextAlign.center),
            ]),
          ),
        );
      }).toList(),
    );
  }
}