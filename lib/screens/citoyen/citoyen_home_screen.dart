// ============================================================
// CitoyenHomeScreen — Main Dashboard for Citoyen Role
// ============================================================
// This is the main screen for citizens (Citoyen) after login.
// It uses an IndexedStack with a bottom navigation bar to
// switch between 4 tabs without rebuilding them each time.
//
// Tab structure:
//   0 → Home (signalements list + stats)
//   1 → History (all past signalements)
//   2 → Empty (FAB opens NewSignalementScreen as new route)
//   3 → Notifications
//   4 → Profile
//
// Design decisions:
// - White card header with greeting + red stats panel below
// - Stats are inside a red rounded card — no separate gray boxes
// - Only 3 signalements shown on home — "Voir tout" for rest
// - FAB is a square-ish rounded button (12px radius) centered
// - No scrolling on home tab — everything fits in one screen
// - BottomAppBar with CircularNotchedRectangle for FAB notch
//
// TODO: Replace mock data with real API calls:
//   - GET /signalements/GetSignalementsByCitoyen/:id
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Tracks which bottom nav tab is active
  int _currentIndex = 0;

  // Mock signalement data — replace with API response
  // Each map matches the Signalement model fields
  final _signalements = [
    {
      'title': 'Nid de poule — Bourguiba',
      'cat': 'Voirie',
      'status': 'EN_COURS',
      'time': 'Il y a 2h',
    },
    {
      'title': 'Lampadaire cassé — Sfax',
      'cat': 'Eclairage',
      'status': 'EN_ATTENTE',
      'time': 'Il y a 1j',
    },
    {
      'title': 'Déchets — Sousse',
      'cat': 'Propreté',
      'status': 'RESOLU',
      'time': 'Il y a 3j',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Light status bar icons on white header background
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  // ── Status Helpers ─────────────────────────────────────────
  // Map status string to display color, background, and label.
  // Used for pill badges on each signalement card.

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

  // ── Icon per category ──────────────────────────────────────
  // Visual indicator in the card icon box on the left.
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
        index: _currentIndex,
        children: [
          _homeTab(isDark),
          _historyTab(isDark),
          const SizedBox(), // Placeholder — FAB opens new screen
          const NotificationsScreen(),
          const ProfileScreen(),
        ],
      ),

      // ── FAB — opens new signalement form ──────────────────
      // Square-ish shape (12px radius) for modern look.
      // Centered in the BottomAppBar notch.
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NewSignalementScreen())),
        backgroundColor: TColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 22),
      ),
      floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,

      // ── Bottom Navigation Bar ──────────────────────────────
      // BottomAppBar with notch for the FAB.
      // 4 nav items with gap in middle for FAB.
      bottomNavigationBar: BottomAppBar(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        elevation: 0,
        notchMargin: 6,
        shape: const CircularNotchedRectangle(),
        child: Row(children: [
          _navItem(Icons.grid_view_rounded, 'Accueil',   0, isDark),
          _navItem(Icons.history,           'Historique',1, isDark),
          const SizedBox(width: 48), // Space for FAB
          _navItem(Icons.notifications_outlined, 'Notifs', 3, isDark),
          _navItem(Icons.person_outline,    'Profil',    4, isDark),
        ]),
      ),
    );
  }

  // ── Nav Item Widget ────────────────────────────────────────
  // Each bottom nav tab with icon + label + active dot indicator.
  Widget _navItem(IconData icon, String label, int index, bool isDark) {
    final active = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                size: 19,
                color: active ? TColors.primary : TColors.grey),
              const SizedBox(height: 2),
              Text(label,
                style: TextStyle(
                  fontSize: 7,
                  fontFamily: 'Poppins',
                  color: active ? TColors.primary : TColors.grey,
                  fontWeight: active
                    ? FontWeight.w500 : FontWeight.w400,
                )),
              // Active indicator dot below label
              if (active) ...[
                const SizedBox(height: 2),
                Container(
                  width: 3, height: 3,
                  decoration: const BoxDecoration(
                    color: TColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Home Tab ───────────────────────────────────────────────
  // Contains: white header, red stats card, signalement list.
  // Everything fits on screen — no vertical scroll.
  Widget _homeTab(bool isDark) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── White Top Header ────────────────────────────
          // Greeting + notification bell + avatar
          Container(
            color: isDark ? TColors.cardDark : TColors.cardLight,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bonjour 👋',
                      style: TextStyle(
                        fontSize: 9,
                        color: TColors.textHint,
                        fontFamily: 'Poppins',
                      )),
                    const Text('Amira Bouazizi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TColors.textPrimary,
                        fontFamily: 'Poppins',
                      )),
                  ],
                ),
                Row(children: [
                  // Notification bell with unread red dot
                  Stack(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: isDark
                          ? TColors.darkContainer : TColors.light,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          size: 16,
                          color: isDark
                            ? TColors.textWhite : TColors.textPrimary),
                        padding: EdgeInsets.zero,
                        onPressed: () =>
                          setState(() => _currentIndex = 3)),
                    ),
                    // Unread notification dot
                    Positioned(
                      top: 4, right: 4,
                      child: Container(
                        width: 7, height: 7,
                        decoration: const BoxDecoration(
                          color: TColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(width: 8),
                  // User avatar with initials
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: TColors.primary,
                    child: const Text('AB',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      )),
                  ),
                ]),
              ],
            ),
          ),

          // ── Red Stats Card ──────────────────────────────
          // Shows total, en cours, résolus counts.
          // Full-width red rounded card — premium look.
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
                _statItem('4', 'Total'),
                _divider(),
                _statItem('2', 'En cours'),
                _divider(),
                _statItem('1', 'Résolus'),
              ]),
            ),
          ),

          // ── Section Header ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Récents',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 1),
                  child: const Text('Voir tout →',
                    style: TextStyle(
                      fontSize: 9,
                      color: TColors.primary,
                      fontFamily: 'Poppins',
                    )),
                ),
              ],
            ),
          ),

          // ── Signalement Cards ───────────────────────────
          // Shows max 3 items — no scrolling needed.
          // Each card has a category icon, title, and status pill.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: _signalements.map((s) =>
                  _signalementCard(s, isDark)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── History Tab ────────────────────────────────────────────
  // Shows all signalements in a scrollable list.
  Widget _historyTab(bool isDark) {
    return SafeArea(
      child: Column(children: [
        // Simple header
        Container(
          color: isDark ? TColors.cardDark : TColors.cardLight,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: const Row(
            children: [
              Text('Historique',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TColors.textPrimary,
                  fontFamily: 'Poppins',
                )),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: _signalements.length,
            itemBuilder: (context, i) =>
              _signalementCard(_signalements[i], isDark),
          ),
        ),
      ]),
    );
  }

  // ── Signalement Card ───────────────────────────────────────
  // Reused in both home tab and history tab.
  // Shows: category icon box, title, subtitle, status pill.
  Widget _signalementCard(
      Map<String, String> s, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10, vertical: 8),
      child: Row(children: [

        // Category icon box — color matches status
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: _statusBg(s['status']!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _catIcon(s['cat']!),
            size: 16,
            color: _statusColor(s['status']!),
          ),
        ),

        const SizedBox(width: 10),

        // Title and subtitle
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
              Text('${s['cat']} · ${s['time']}',
                style: const TextStyle(
                  fontSize: 9,
                  color: TColors.textHint,
                  fontFamily: 'Poppins',
                )),
            ],
          ),
        ),

        const SizedBox(width: 6),

        // Status pill badge
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
              fontWeight: FontWeight.w500,
              color: _statusColor(s['status']!),
              fontFamily: 'Poppins',
            )),
        ),
      ]),
    );
  }

  // ── Stat Item ──────────────────────────────────────────────
  // Single stat inside the red stats card.
  // Number is large white, label is small faded white below.
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
  // Thin white separator between stat items.
  Widget _divider() {
    return Container(
      width: 0.5,
      height: 28,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}