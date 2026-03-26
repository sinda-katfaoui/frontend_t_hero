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
  int _currentIndex = 0;

  final _signalements = [
    {'title': 'Nid de poule — Bourguiba', 'cat': 'Voirie',
     'status': 'EN_COURS', 'time': 'Il y a 2h'},
    {'title': 'Lampadaire cassé — Sfax', 'cat': 'Eclairage',
     'status': 'EN_ATTENTE', 'time': 'Il y a 1j'},
    {'title': 'Déchets — Sousse', 'cat': 'Propreté',
     'status': 'RESOLU', 'time': 'Il y a 3j'},
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
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _homeTab(isDark),
          _historyTab(isDark),
          const SizedBox(),
          const NotificationsScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(
            builder: (_) => const NewSignalementScreen())),
        backgroundColor: TColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
      floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        elevation: 4,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Row(children: [
          _navItem(Icons.grid_view_rounded, 'Accueil',    0, isDark),
          _navItem(Icons.history,           'Historique', 1, isDark),
          const SizedBox(width: 56),
          _navItem(Icons.notifications_outlined, 'Notifs', 3, isDark),
          _navItem(Icons.person_outline,    'Profil',     4, isDark),
        ]),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, bool isDark) {
    final active = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22,
                color: active ? TColors.primary : TColors.grey),
              const SizedBox(height: 2),
              Text(label,
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Poppins',
                  color: active ? TColors.primary : TColors.grey,
                  fontWeight: active
                    ? FontWeight.w600 : FontWeight.w400,
                )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _homeTab(bool isDark) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── White header ──────────────────────────────────
          Container(
            color: isDark ? TColors.cardDark : TColors.cardLight,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bonjour 👋',
                      style: TextStyle(
                        fontSize: 13,
                        color: TColors.textHint,
                        fontFamily: 'Poppins',
                      )),
                    const Text('Amira Bouazizi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TColors.textPrimary,
                        fontFamily: 'Poppins',
                      )),
                  ],
                ),
                Row(children: [
                  Stack(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                          ? TColors.darkContainer : TColors.light,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.notifications_outlined,
                          size: 20,
                          color: isDark
                            ? TColors.textWhite : TColors.textPrimary),
                        padding: EdgeInsets.zero,
                        onPressed: () =>
                          setState(() => _currentIndex = 3)),
                    ),
                    Positioned(top: 6, right: 6,
                      child: Container(
                        width: 9, height: 9,
                        decoration: BoxDecoration(
                          color: TColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white, width: 1.5),
                        ),
                      )),
                  ]),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: TColors.primary,
                    child: const Text('AB',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      )),
                  ),
                ]),
              ],
            ),
          ),

          // ── Red stats card ────────────────────────────────
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
                _statItem('4', 'Total'),
                _vDivider(),
                _statItem('2', 'En cours'),
                _vDivider(),
                _statItem('1', 'Résolus'),
              ]),
            ),
          ),

          // ── Section header ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Récents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 1),
                  child: const Text('Voir tout →',
                    style: TextStyle(
                      fontSize: 13,
                      color: TColors.primary,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    )),
                ),
              ],
            ),
          ),

          // ── Signalement cards ─────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: _signalements.map((s) =>
                  _card(s, isDark)).toList(),
              ),
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
            itemCount: _signalements.length,
            itemBuilder: (_, i) => _card(_signalements[i], isDark),
          ),
        ),
      ]),
    );
  }

  Widget _card(Map<String, String> s, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 12),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _statusBg(s['status']!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_catIcon(s['cat']!),
            size: 20, color: _statusColor(s['status']!)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s['title']!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                    ? TColors.textWhite : TColors.textPrimary,
                  fontFamily: 'Poppins',
                )),
              const SizedBox(height: 3),
              Text('${s['cat']} · ${s['time']}',
                style: const TextStyle(
                  fontSize: 12,
                  color: TColors.textHint,
                  fontFamily: 'Poppins',
                )),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _statusBg(s['status']!),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(_statusLabel(s['status']!),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _statusColor(s['status']!),
              fontFamily: 'Poppins',
            )),
        ),
      ]),
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