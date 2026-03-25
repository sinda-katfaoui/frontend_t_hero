// ============================================================
// AdminUsersScreen — User Management for Admin Role
// ============================================================
// Displays all users with filter tabs to view by role.
// Embedded in AdminHomeScreen's IndexedStack at tab index 1.
//
// Filter tabs:
//   0 → Tous        (all users)
//   1 → Citoyens    (role = CITOYEN)
//   2 → Agents      (role = AGENT_MUNICIPAL)
//
// Each user card shows:
//   - Colored circle avatar with initials
//   - Full name + email
//   - Role pill badge (color coded per role)
//
// Design decisions:
// - White card header with title + "Ajouter" button
// - Animated filter selector tabs (same style as RegisterScreen)
// - User cards are compact white cards — no scroll on short lists
// - Role colors: red=Admin, blue=Agent, green=Citoyen
// - No scrolling for short filtered lists — fits on screen
//
// TODO: Replace mock data with real API calls:
//   - GET /users/GetAllUsers
//   - GET /users/GetAllAgents
//   - POST /users/CreateAgent
//   - DELETE /users/DeleteUser/:id
// ============================================================

import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {

  // Active filter tab: 0=Tous, 1=Citoyens, 2=Agents
  int _filter = 0;
  final _filters = ['Tous', 'Citoyens', 'Agents'];

  // Mock user list — replace with API response
  // Matches the User model: nom, email, role, initials
  final _users = [
    {
      'nom':      'Admin Principal',
      'email':    'admin@thero.com',
      'role':     'ADMIN',
      'initials': 'AP',
    },
    {
      'nom':      'Agent Habib',
      'email':    'habib@thero.com',
      'role':     'AGENT_MUNICIPAL',
      'initials': 'AH',
    },
    {
      'nom':      'Agent Sonia',
      'email':    'sonia@thero.com',
      'role':     'AGENT_MUNICIPAL',
      'initials': 'AS',
    },
    {
      'nom':      'Amira Bouazizi',
      'email':    'amira@test.com',
      'role':     'CITOYEN',
      'initials': 'AB',
    },
    {
      'nom':      'Mohamed Ben Ali',
      'email':    'mohamed@test.com',
      'role':     'CITOYEN',
      'initials': 'MB',
    },
    {
      'nom':      'Sara Jouini',
      'email':    'sara@test.com',
      'role':     'CITOYEN',
      'initials': 'SJ',
    },
    {
      'nom':      'Yassine Trabelsi',
      'email':    'yassine@test.com',
      'role':     'CITOYEN',
      'initials': 'YT',
    },
  ];

  // ── Role Helpers ───────────────────────────────────────────
  // Color-code roles consistently: red=Admin, blue=Agent, green=Citoyen
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

  // ── Filtered Users ─────────────────────────────────────────
  // Returns subset of users based on active filter tab.
  List<Map<String, String>> get _filtered {
    if (_filter == 0) return _users;
    if (_filter == 1) return _users
      .where((u) => u['role'] == 'CITOYEN').toList();
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

          // ── Header ──────────────────────────────────────
          // White card with title + add button
          Container(
            color: isDark ? TColors.cardDark : TColors.cardLight,
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Utilisateurs',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
                // Add user button
                GestureDetector(
                  onTap: () {
                    // TODO: Open add user dialog
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: TColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(children: [
                      Icon(Icons.add,
                        color: Colors.white, size: 13),
                      SizedBox(width: 4),
                      Text('Ajouter',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        )),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // ── Filter Tabs ──────────────────────────────────
          // Animated pill selector — active tab slides white card
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

          // ── User List ─────────────────────────────────────
          // Scrollable list of filtered users.
          // Each card: avatar circle + name + email + role pill.
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final u = _filtered[i];
                return _userCard(u, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── User Card ──────────────────────────────────────────────
  // White card with:
  // - Circle avatar with initials (colored per role)
  // - Full name (bold) + email (muted)
  // - Role pill badge on the right
  Widget _userCard(Map<String, String> u, bool isDark) {
    return Container(
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

        // Circle avatar with role-colored initials
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: _roleBg(u['role']!),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(u['initials']!,
              style: TextStyle(
                fontSize: 11,
                color: _roleColor(u['role']!),
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              )),
          ),
        ),

        const SizedBox(width: 10),

        // Name and email
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(u['nom']!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                    ? TColors.textWhite : TColors.textPrimary,
                  fontFamily: 'Poppins',
                )),
              const SizedBox(height: 1),
              Text(u['email']!,
                style: const TextStyle(
                  fontSize: 9,
                  color: TColors.textHint,
                  fontFamily: 'Poppins',
                )),
            ],
          ),
        ),

        // Role pill badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _roleBg(u['role']!),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(_roleLabel(u['role']!),
            style: TextStyle(
              fontSize: 8,
              color: _roleColor(u['role']!),
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            )),
        ),
      ]),
    );
  }
}