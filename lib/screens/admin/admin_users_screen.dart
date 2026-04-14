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
    if (_filter == 1)
      return _users.where((u) => u['role'] == 'CITOYEN').toList();
    return _users
      .where((u) => u['role'] == 'AGENT_MUNICIPAL').toList();
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
                const Text('Utilisateurs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: TColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                        child: Row(children: [
                          Icon(Icons.add,
                            color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text('Ajouter',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            )),
                        ]),
                      ),
                    ),
                  ),
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

          // ── User List ─────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 4),
              itemCount: _filtered.length,
              itemBuilder: (_, i) =>
                _userCard(_filtered[i], isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userCard(Map<String, String> u, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 12),
      child: Row(children: [
        // Avatar
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _roleBg(u['role']!),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(u['initials']!,
              style: TextStyle(
                fontSize: 14,
                color: _roleColor(u['role']!),
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              )),
          ),
        ),
        const SizedBox(width: 12),
        // Name + email
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(u['nom']!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                    ? TColors.textWhite : TColors.textPrimary,
                  fontFamily: 'Poppins',
                )),
              const SizedBox(height: 2),
              Text(u['email']!,
                style: const TextStyle(
                  fontSize: 12,
                  color: TColors.textHint,
                  fontFamily: 'Poppins',
                )),
            ],
          ),
        ),
        // Role pill
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: _roleBg(u['role']!),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(_roleLabel(u['role']!),
            style: TextStyle(
              fontSize: 12,
              color: _roleColor(u['role']!),
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            )),
        ),
      ]),
    );
  }
}