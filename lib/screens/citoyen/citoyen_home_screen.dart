import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_t_hero/screens/citoyen/new_signalement_screen.dart';
import 'package:frontend_t_hero/screens/citoyen/notifications_screen.dart';
import 'package:frontend_t_hero/screens/citoyen/profile_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';
import 'package:frontend_t_hero/utils/constants/api_constant.dart';

class CitoyenHomeScreen extends StatefulWidget {
  const CitoyenHomeScreen({super.key});
  @override
  State<CitoyenHomeScreen> createState() => _CitoyenHomeScreenState();
}

class _CitoyenHomeScreenState extends State<CitoyenHomeScreen> {
  int _currentIndex = 0;

  // ── Real data from backend ─────────────────────────────────
  List<Map<String, dynamic>> _signalements = [];
  bool   _loadingData = true;
  String _userName    = '';
  String _userInitials= '';
  String _userId      = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _loadUserAndSignalements();
  }

  // ── Load user from SharedPreferences + fetch signalements ──
Future<void> _loadUserAndSignalements() async {
  try {
    final prefs   = await SharedPreferences.getInstance();
    final token   = prefs.getString('token');
    final userRaw = prefs.getString('user');

    print('TOKEN: $token');
    print('USER RAW: $userRaw');

    if (userRaw == null || userRaw == '{}') {
      print('NO USER IN PREFS');
      setState(() => _loadingData = false);
      return;
    }

    final user = jsonDecode(userRaw);
    final nom  = user['nom'] ?? '';
    final parts = nom.trim().split(' ');
    final initials = parts.length >= 2
      ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
      : nom.length >= 2
        ? nom.substring(0, 2).toUpperCase()
        : nom.toUpperCase();

    setState(() {
      _userName     = nom;
      _userInitials = initials;
      _userId       = user['_id'] ?? '';
    });

    print('USER ID SET TO: $_userId');
    await _fetchSignalements();
  } catch (e) {
    print('ERROR IN LOAD: $e');
    setState(() => _loadingData = false);
  }
}

  // ── GET signalements by citoyen ────────────────────────────
  Future<void> _fetchSignalements() async {
    if (_userId.isEmpty) return;
    setState(() => _loadingData = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/signalements/GetSignalementsByCitoyen/$_userId'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List;
        setState(() {
          _signalements = list
            .map((e) => e as Map<String, dynamic>)
            .toList();
          _loadingData = false;
        });
      } else {
        setState(() => _loadingData = false);
      }
    } catch (_) {
      setState(() => _loadingData = false);
    }
  }

  // ── Helpers ────────────────────────────────────────────────
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
    if (cat.contains('Voirie'))   return Icons.warning_amber_rounded;
    if (cat.contains('Eclairage')) return Icons.lightbulb_outline;
    if (cat.contains('Propret'))  return Icons.delete_outline;
    if (cat.contains('Espaces'))  return Icons.park_outlined;
    return Icons.help_outline;
  }

  String _catName(dynamic cat) {
    if (cat == null) return 'Autre';
    if (cat is Map) return cat['nom'] ?? 'Autre';
    return cat.toString();
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
      if (diff.inHours < 24)   return 'Il y a ${diff.inHours}h';
      return 'Il y a ${diff.inDays}j';
    } catch (_) { return ''; }
  }

  // ── Stats ──────────────────────────────────────────────────
  int get _total    => _signalements.length;
  int get _enCours  => _signalements
    .where((s) => s['statut'] == 'EN_COURS' ||
                  s['statut'] == 'EN_ATTENTE').length;
  int get _resolus  => _signalements
    .where((s) => s['statut'] == 'RESOLU').length;

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
        onPressed: () async {
          await Navigator.push(context,
            MaterialPageRoute(
              builder: (_) => const NewSignalementScreen()));
          // ── Refresh after new signalement ────────────────
          _fetchSignalements();
        },
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
    final recent = _signalements.take(3).toList();
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchSignalements,
        color: TColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── White header ────────────────────────────────
            Container(
              color: isDark ? TColors.cardDark : TColors.cardLight,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bonjour 👋',
                        style: TextStyle(
                          fontSize: 13,
                          color: TColors.textHint,
                          fontFamily: 'Poppins',
                        )),
                      Text(_userName.isEmpty ? 'Citoyen' : _userName,
                        style: const TextStyle(
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
                      child: Text(_userInitials.isEmpty
                        ? 'U' : _userInitials,
                        style: const TextStyle(
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

            // ── Red stats card ──────────────────────────────
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
                  _statItem('$_total',   'Total'),
                  _vDivider(),
                  _statItem('$_enCours', 'En cours'),
                  _vDivider(),
                  _statItem('$_resolus', 'Résolus'),
                ]),
              ),
            ),

            // ── Section header ──────────────────────────────
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

            // ── Signalement cards ───────────────────────────
            Expanded(
              child: _loadingData
                ? const Center(
                    child: CircularProgressIndicator(
                      color: TColors.primary))
                : recent.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              color: TColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.flag_outlined,
                              size: 36, color: TColors.primary)),
                          const SizedBox(height: 16),
                          const Text('Aucun signalement',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: TColors.textPrimary,
                              fontFamily: 'Poppins',
                            )),
                          const SizedBox(height: 6),
                          const Text('Appuyez sur + pour créer',
                            style: TextStyle(
                              fontSize: 13,
                              color: TColors.textHint,
                              fontFamily: 'Poppins',
                            )),
                        ],
                      ))
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16),
                      child: Column(
                        children: recent.map((s) =>
                          _card(s, isDark)).toList(),
                      ),
                    ),
            ),
          ],
        ),
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
          child: _loadingData
            ? const Center(
                child: CircularProgressIndicator(
                  color: TColors.primary))
            : _signalements.isEmpty
              ? const Center(
                  child: Text('Aucun signalement',
                    style: TextStyle(
                      fontSize: 16,
                      color: TColors.textHint,
                      fontFamily: 'Poppins',
                    )))
              : RefreshIndicator(
                  onRefresh: _fetchSignalements,
                  color: TColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _signalements.length,
                    itemBuilder: (_, i) =>
                      _card(_signalements[i], isDark),
                  ),
                ),
        ),
      ]),
    );
  }

  Widget _card(Map<String, dynamic> s, bool isDark) {
    final statut  = s['statut'] ?? 'EN_ATTENTE';
    final cat     = _catName(s['categorie']);
    final title   = s['description'] ?? 'Sans titre';
    final time    = _timeAgo(s['createdAt']);

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
            color: _statusBg(statut),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_catIcon(cat),
            size: 20, color: _statusColor(statut)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                    ? TColors.textWhite : TColors.textPrimary,
                  fontFamily: 'Poppins',
                )),
              const SizedBox(height: 3),
              Text('$cat · $time',
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
            color: _statusBg(statut),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(_statusLabel(statut),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _statusColor(statut),
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