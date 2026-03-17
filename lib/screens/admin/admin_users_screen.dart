import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  int _filter = 0;
  final _filters = ['Tous', 'Citoyens', 'Agents'];

  final _users = [
    {'nom': 'Admin Principal', 'email': 'admin@thero.com',
     'role': 'ADMIN', 'initials': 'AP'},
    {'nom': 'Agent Habib', 'email': 'habib@thero.com',
     'role': 'AGENT_MUNICIPAL', 'initials': 'AH'},
    {'nom': 'Agent Sonia', 'email': 'sonia@thero.com',
     'role': 'AGENT_MUNICIPAL', 'initials': 'AS'},
    {'nom': 'Amira Bouazizi', 'email': 'amira@test.com',
     'role': 'CITOYEN', 'initials': 'AB'},
    {'nom': 'Mohamed Ben Ali', 'email': 'mohamed@test.com',
     'role': 'CITOYEN', 'initials': 'MB'},
    {'nom': 'Sara Jouini', 'email': 'sara@test.com',
     'role': 'CITOYEN', 'initials': 'SJ'},
    {'nom': 'Yassine Trabelsi', 'email': 'yassine@test.com',
     'role': 'CITOYEN', 'initials': 'YT'},
  ];

  Color _roleColor(String r) {
    switch (r) {
      case 'ADMIN':           return TColors.primary;
      case 'AGENT_MUNICIPAL': return TColors.info;
      default:                return TColors.success;
    }
  }

  Color _roleBg(String r) {
    switch (r) {
      case 'ADMIN':           return TColors.primaryLight;
      case 'AGENT_MUNICIPAL': return TColors.infoLight;
      default:                return TColors.successLight;
    }
  }

  String _roleLabel(String r) {
    switch (r) {
      case 'ADMIN':           return 'Admin';
      case 'AGENT_MUNICIPAL': return 'Agent';
      default:                return 'Citoyen';
    }
  }

  List<Map<String, String>> get _filtered {
    if (_filter == 0) return _users;
    if (_filter == 1) return _users
      .where((u) => u['role'] == 'CITOYEN').toList();
    return _users
      .where((u) => u['role'] == 'AGENT_MUNICIPAL').toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        AppBar(
          title: const Text('Utilisateurs'),
          automaticallyImplyLeading: false,
          actions: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Ajouter',
                style: TextStyle(color: Colors.white))),
          ],
        ),
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
                      borderRadius: BorderRadius.circular(9),
                      border: _filter == i
                        ? Border.all(
                            color: TColors.borderLight,
                            width: 0.5)
                        : null),
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
              final u = _filtered[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _roleBg(u['role']!),
                    child: Text(u['initials']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: _roleColor(u['role']!),
                        fontWeight: FontWeight.w500))),
                  title: Text(u['nom']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
                  subtitle: Text(u['email']!,
                    style: const TextStyle(fontSize: 11)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _roleBg(u['role']!),
                      borderRadius: BorderRadius.circular(8)),
                    child: Text(_roleLabel(u['role']!),
                      style: TextStyle(
                        fontSize: 10,
                        color: _roleColor(u['role']!),
                        fontWeight: FontWeight.w500))),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}