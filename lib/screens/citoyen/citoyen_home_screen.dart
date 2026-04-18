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
  State<CitoyenHomeScreen> createState() =>
      _CitoyenHomeScreenState();
}

class _CitoyenHomeScreenState extends State<CitoyenHomeScreen>
    with TickerProviderStateMixin {

  int _currentIndex = 0;
  int _filterIndex  = 0; // 0=Tous 1=En cours 2=Résolus

  List<Map<String, dynamic>> _signalements = [];
  bool   _loadingData  = true;
  String _userName     = '';
  String _userInitials = '';
  String _userId       = '';

  late AnimationController _bannerCtrl;
  late Animation<double>   _bannerAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _bannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800));
    _bannerAnim = CurvedAnimation(
      parent: _bannerCtrl, curve: Curves.easeOut);
    _bannerCtrl.forward();
    _loadUserAndSignalements();
  }

  @override
  void dispose() {
    _bannerCtrl.dispose();
    super.dispose();
  }

  // ── Extract ID from JWT ────────────────────────────────────
  String _extractIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return '';
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded =
        utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded);
      return map['id'] ?? '';
    } catch (_) { return ''; }
  }

  Future<void> _loadUserAndSignalements() async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final userRaw = prefs.getString('user');
      final token   = prefs.getString('token') ?? '';

      if (userRaw == null || userRaw == '{}') {
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

      _userId = user['_id'] ?? user['id'] ?? '';
      if (_userId.isEmpty && token.isNotEmpty) {
        _userId = _extractIdFromToken(token);
      }

      setState(() {
        _userName     = nom;
        _userInitials = initials;
      });
      await _fetchSignalements();
    } catch (e) {
      setState(() => _loadingData = false);
    }
  }

  Future<void> _fetchSignalements() async {
    if (_userId.isEmpty) {
      setState(() => _loadingData = false);
      return;
    }
    setState(() => _loadingData = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/signalements'
          '/GetSignalementsByCitoyen/$_userId'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _signalements = (data['data'] as List)
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
      case 'RESOLU':   return 'Résolu ✓';
      default:         return 'En attente';
    }
  }

  Color _prioColor(String p) {
    switch (p) {
      case 'ELEVEE':  return TColors.error;
      case 'MOYENNE': return TColors.warning;
      default:        return TColors.success;
    }
  }

  String _prioLabel(String p) {
    switch (p) {
      case 'ELEVEE':  return 'Élevée';
      case 'MOYENNE': return 'Moyenne';
      default:        return 'Faible';
    }
  }

  String _prioEmoji(String p) {
    switch (p) {
      case 'ELEVEE':  return '🔴';
      case 'MOYENNE': return '🟡';
      default:        return '🟢';
    }
  }

  IconData _catIcon(String cat) {
    if (cat.contains('Voirie'))    return Icons.warning_amber_rounded;
    if (cat.contains('Eclairage')) return Icons.lightbulb_outline;
    if (cat.contains('Propret'))   return Icons.delete_outline;
    if (cat.contains('Espaces'))   return Icons.park_outlined;
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
      if (diff.inMinutes < 60)
        return 'Il y a ${diff.inMinutes}min';
      if (diff.inHours < 24)
        return 'Il y a ${diff.inHours}h';
      return 'Il y a ${diff.inDays}j';
    } catch (_) { return ''; }
  }

  int get _total   => _signalements.length;
  int get _enCours => _signalements.where((s) =>
    s['statut'] == 'EN_COURS' ||
    s['statut'] == 'EN_ATTENTE').length;
  int get _resolus => _signalements
    .where((s) => s['statut'] == 'RESOLU').length;

  List<Map<String, dynamic>> get _filtered {
    if (_filterIndex == 1)
      return _signalements.where((s) =>
        s['statut'] == 'EN_COURS' ||
        s['statut'] == 'EN_ATTENTE').toList();
    if (_filterIndex == 2)
      return _signalements
        .where((s) => s['statut'] == 'RESOLU').toList();
    return _signalements;
  }

  // ── Detail sheet ───────────────────────────────────────────
  void _showDetail(Map<String, dynamic> s) {
    final statut    = s['statut'] ?? 'EN_ATTENTE';
    final cat       = _catName(s['categorie']);
    final desc      = s['description'] ?? '—';
    final loc       = s['localisation'] ?? '—';
    final time      = _timeAgo(s['createdAt']);
    final prio      = s['priorite'] ?? 'FAIBLE';
    final agent     = s['agent'];
    final agentNom  = agent is Map
      ? agent['nom'] ?? '—' : '—';
    final analyseIA = s['analyseIA'];
    double aiScore  = 0.0;
    String aiCat    = cat;
    if (analyseIA is Map) {
      aiScore = (analyseIA['scoreIA'] ?? 0).toDouble();
      aiCat   = analyseIA['categorieIA'] ?? cat;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28)),
        ),
        child: Column(children: [

          Center(child: Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: TColors.borderLight,
              borderRadius: BorderRadius.circular(2)),
          )),

          // Gradient header
          Container(
            margin: const EdgeInsets.fromLTRB(
              16, 12, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  TColors.primary,
                  Color(0xFFE53935)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: Colors.white
                    .withValues(alpha: 0.2),
                  borderRadius:
                    BorderRadius.circular(16)),
                child: Icon(_catIcon(cat),
                  color: Colors.white, size: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                    CrossAxisAlignment.start,
                  children: [
                    Text(desc,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      )),
                    const SizedBox(height: 6),
                    Row(children: [
                      Container(
                        padding:
                          const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white
                            .withValues(alpha: 0.2),
                          borderRadius:
                            BorderRadius.circular(20)),
                        child: Text(
                          _statusLabel(statut),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ))),
                      const SizedBox(width: 8),
                      Text(
                        '${_prioEmoji(prio)} $prio',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white
                            .withValues(alpha: 0.9),
                          fontFamily: 'Poppins',
                        )),
                    ]),
                  ],
                ),
              ),
            ]),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                  CrossAxisAlignment.start,
                children: [

                  // Info card
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius:
                        BorderRadius.circular(16),
                      border: Border.all(
                        color: TColors.borderLight,
                        width: 0.5)),
                    padding: const EdgeInsets.all(14),
                    child: Column(children: [
                      _infoRow(
                        Icons.category_outlined,
                        'Catégorie', cat),
                      _divLine(),
                      _infoRow(
                        Icons.place_outlined,
                        'Localisation', loc),
                      _divLine(),
                      _infoRow(
                        Icons.access_time_outlined,
                        'Soumis', time),
                      _divLine(),
                      _infoRow(
                        Icons.engineering_outlined,
                        'Agent assigné', agentNom),
                    ]),
                  ),

                  const SizedBox(height: 14),

                  // Status timeline
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius:
                        BorderRadius.circular(16),
                      border: Border.all(
                        color: TColors.borderLight,
                        width: 0.5)),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment:
                        CrossAxisAlignment.start,
                      children: [
                        const Text('Suivi du signalement',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: TColors.textPrimary,
                            fontFamily: 'Poppins',
                          )),
                        const SizedBox(height: 12),
                        _timelineStep(
                          '✅', 'Signalement soumis',
                          'Enregistré dans le système',
                          true),
                        _timelineStep(
                          statut != 'EN_ATTENTE'
                            ? '✅' : '⏳',
                          'Pris en charge',
                          agentNom != '—'
                            ? 'Agent: $agentNom'
                            : 'En attente d\'assignation',
                          statut != 'EN_ATTENTE'),
                        _timelineStep(
                          statut == 'RESOLU'
                            ? '🏆' : '⏳',
                          'Résolu',
                          statut == 'RESOLU'
                            ? 'Problème résolu ✓'
                            : 'En cours de traitement',
                          statut == 'RESOLU',
                          isLast: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Description
                  const Text('Description',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: TColors.textPrimary,
                      fontFamily: 'Poppins',
                    )),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius:
                        BorderRadius.circular(12),
                      border: Border.all(
                        color: TColors.borderLight,
                        width: 0.5)),
                    child: Text(desc,
                      style: const TextStyle(
                        fontSize: 14,
                        color: TColors.textPrimary,
                        fontFamily: 'Poppins',
                        height: 1.5,
                      ))),

                  // AI card
                  if (aiScore > 0) ...[
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            TColors.primary,
                            TColors.primary
                              .withValues(alpha: 0.75)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                          BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(children: [
                              Icon(Icons.auto_awesome,
                                size: 16,
                                color: Colors.white),
                              SizedBox(width: 6),
                              Text('Analyse IA T HERO',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                )),
                            ]),
                            Container(
                              padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white
                                  .withValues(alpha: 0.2),
                                borderRadius:
                                  BorderRadius.circular(
                                    20)),
                              child: Text(
                                '${(aiScore * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                ))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius:
                            BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: aiScore,
                            backgroundColor: Colors.white
                              .withValues(alpha: 0.25),
                            valueColor:
                              const AlwaysStoppedAnimation(
                                Colors.white),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Catégorie suggérée',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white
                                  .withValues(alpha: 0.8),
                                fontFamily: 'Poppins',
                              )),
                            Text(aiCat,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              )),
                          ],
                        ),
                      ]),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _timelineStep(String emoji, String title,
      String sub, bool done, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: done
                ? TColors.primaryLight
                : TColors.light,
              shape: BoxShape.circle,
              border: Border.all(
                color: done
                  ? TColors.primary
                  : TColors.borderLight,
                width: 1.5)),
            child: Center(
              child: Text(emoji,
                style: const TextStyle(fontSize: 14)))),
          if (!isLast)
            Container(
              width: 2, height: 28,
              color: done
                ? TColors.primary.withValues(alpha: 0.3)
                : TColors.borderLight),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment:
                CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: done
                      ? TColors.textPrimary
                      : TColors.textHint,
                    fontFamily: 'Poppins',
                  )),
                const SizedBox(height: 2),
                Text(sub,
                  style: const TextStyle(
                    fontSize: 11,
                    color: TColors.textHint,
                    fontFamily: 'Poppins',
                  )),
                if (!isLast) const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label,
      String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, size: 18, color: TColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
              style: const TextStyle(
                fontSize: 10,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              )),
            Text(value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TColors.textPrimary,
                fontFamily: 'Poppins',
              )),
          ],
        ),
      ]),
    );
  }

  Widget _divLine() => const Divider(
    height: 1, thickness: 0.5,
    color: TColors.borderLight);

  @override
  Widget build(BuildContext context) {
    final isDark =
      Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
        isDark ? TColors.dark : TColors.light,
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
      floatingActionButton: _currentIndex == 0 ||
          _currentIndex == 1
        ? FloatingActionButton(
            onPressed: () async {
              await Navigator.push(context,
                MaterialPageRoute(
                  builder: (_) =>
                    const NewSignalementScreen()));
              _fetchSignalements();
            },
            backgroundColor: TColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: const Icon(Icons.add,
              color: Colors.white, size: 28),
          )
        : null,
      floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: isDark
          ? TColors.cardDark : TColors.cardLight,
        elevation: 8,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Row(children: [
          _navItem(Icons.grid_view_rounded,
            'Accueil',    0, isDark),
          _navItem(Icons.history,
            'Historique', 1, isDark),
          const SizedBox(width: 56),
          _navItem(Icons.notifications_outlined,
            'Notifs',     3, isDark),
          _navItem(Icons.person_outline,
            'Profil',     4, isDark),
        ]),
      ),
    );
  }

  Widget _navItem(IconData icon, String label,
      int index, bool isDark) {
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
                color: active
                  ? TColors.primary : TColors.grey),
              const SizedBox(height: 2),
              Text(label,
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Poppins',
                  color: active
                    ? TColors.primary : TColors.grey,
                  fontWeight: active
                    ? FontWeight.w600 : FontWeight.w400,
                )),
            ],
          ),
        ),
      ),
    );
  }

  // ── HOME TAB ───────────────────────────────────────────────
  Widget _homeTab(bool isDark) {
    final recent = _signalements.take(3).toList();
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchSignalements,
        color: TColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment:
              CrossAxisAlignment.stretch,
            children: [

              // ── Hero Banner ────────────────────────────
              FadeTransition(
                opacity: _bannerAnim,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TColors.primary,
                        Color(0xFFE53935),
                        Color(0xFFC62828)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Stack(children: [

                    // Background decoration circles
                    Positioned(
                      top: -30, right: -20,
                      child: Container(
                        width: 140, height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white
                            .withValues(alpha: 0.05)),
                      )),
                    Positioned(
                      bottom: -20, left: -10,
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white
                            .withValues(alpha: 0.05)),
                      )),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16, 16, 16, 20),
                      child: Column(children: [

                        // Top row
                        Row(
                          mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                                CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  const Text('👋  ',
                                    style: TextStyle(
                                      fontSize: 14)),
                                  Text(
                                    'Bonjour, Citoyen !',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white
                                        .withValues(
                                          alpha: 0.85),
                                      fontFamily: 'Poppins',
                                      fontWeight:
                                        FontWeight.w500,
                                    )),
                                ]),
                                Text(
                                  _userName.isEmpty
                                    ? 'Citoyen' : _userName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  )),
                              ],
                            ),
                            Row(children: [
                              // Notif bell
                              GestureDetector(
                                onTap: () => setState(
                                  () => _currentIndex = 3),
                                child: Container(
                                  width: 42, height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                      .withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white
                                        .withValues(
                                          alpha: 0.3))),
                                  child: Stack(children: [
                                    const Center(
                                      child: Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.white,
                                        size: 20)),
                                    Positioned(
                                      top: 8, right: 8,
                                      child: Container(
                                        width: 8, height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ))),
                                  ]),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Avatar
                              GestureDetector(
                                onTap: () => setState(
                                  () => _currentIndex = 4),
                                child: Container(
                                  width: 42, height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                      .withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white
                                        .withValues(
                                          alpha: 0.5),
                                      width: 2)),
                                  child: Center(
                                    child: Text(
                                      _userInitials.isEmpty
                                        ? 'U'
                                        : _userInitials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight:
                                          FontWeight.w700,
                                        fontFamily: 'Poppins',
                                      ))),
                                ),
                              ),
                            ]),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Stats row
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white
                              .withValues(alpha: 0.15),
                            borderRadius:
                              BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white
                                .withValues(alpha: 0.2))),
                          child: Row(children: [
                            _bannerStat('$_total',
                              'Signalements',
                              Icons.flag_outlined),
                            _bannerDiv(),
                            _bannerStat('$_enCours',
                              'En cours',
                              Icons.pending_outlined),
                            _bannerDiv(),
                            _bannerStat('$_resolus',
                              'Résolus',
                              Icons.check_circle_outline),
                          ]),
                        ),

                        const SizedBox(height: 14),

                        // CTA button
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(context,
                              MaterialPageRoute(
                                builder: (_) =>
                                  const NewSignalementScreen()));
                            _fetchSignalements();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 13),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                    .withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset:
                                    const Offset(0, 3)),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment:
                                MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline,
                                  color: TColors.primary,
                                  size: 20),
                                SizedBox(width: 8),
                                Text(
                                  '+ Nouveau signalement',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: TColors.primary,
                                    fontFamily: 'Poppins',
                                  )),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 16),

              // ── Quick category pills ───────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16),
                child: Column(
                  crossAxisAlignment:
                    CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Text('⚡ ',
                        style: TextStyle(fontSize: 14)),
                      Text('Catégories',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: TColors.textPrimary,
                          fontFamily: 'Poppins',
                        )),
                    ]),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        _catPill('🛣️', 'Voirie',
                          isDark),
                        _catPill('💡', 'Eclairage',
                          isDark),
                        _catPill('🗑️', 'Propreté',
                          isDark),
                        _catPill('🌿', 'Espaces Verts',
                          isDark),
                        _catPill('❓', 'Autre',
                          isDark),
                      ]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Recent section ─────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16),
                child: Row(
                  mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(children: [
                      Text('📍 ',
                        style: TextStyle(fontSize: 14)),
                      Text('Mes récents',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: TColors.textPrimary,
                          fontFamily: 'Poppins',
                        )),
                    ]),
                    GestureDetector(
                      onTap: () => setState(
                        () => _currentIndex = 1),
                      child: Container(
                        padding:
                          const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: TColors.primaryLight,
                          borderRadius:
                            BorderRadius.circular(20)),
                        child: const Text(
                          'Voir tout →',
                          style: TextStyle(
                            fontSize: 12,
                            color: TColors.primary,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          )),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ── Cards ──────────────────────────────────
              _loadingData
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: TColors.primary)))
                : recent.isEmpty
                  ? _emptyHome()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16),
                      child: Column(
                        children: recent.map((s) =>
                          _card(s, isDark)).toList(),
                      ),
                    ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _catPill(String emoji, String label,
      bool isDark) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context,
          MaterialPageRoute(
            builder: (_) =>
              const NewSignalementScreen()));
        _fetchSignalements();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? TColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: TColors.borderLight, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                .withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2)),
          ],
        ),
        child: Row(children: [
          Text(emoji,
            style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: isDark
                ? TColors.textWhite
                : TColors.textPrimary,
            )),
        ]),
      ),
    );
  }

  Widget _emptyHome() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TColors.primaryLight,
                  TColors.primary
                    .withValues(alpha: 0.1)]),
              shape: BoxShape.circle),
            child: const Center(
              child: Text('📍',
                style: TextStyle(fontSize: 36)))),
          const SizedBox(height: 16),
          const Text('Aucun signalement',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: TColors.textPrimary,
              fontFamily: 'Poppins',
            )),
          const SizedBox(height: 6),
          const Text(
            'Signalez un problème dans votre ville\net contribuez à la améliorer 🇹🇳',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: TColors.textHint,
              fontFamily: 'Poppins',
              height: 1.5,
            )),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              await Navigator.push(context,
                MaterialPageRoute(
                  builder: (_) =>
                    const NewSignalementScreen()));
              _fetchSignalements();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    TColors.primary,
                    Color(0xFFE53935)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add,
                    color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Créer un signalement',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HISTORY TAB ────────────────────────────────────────────
  Widget _historyTab(bool isDark) {
    return SafeArea(
      child: Column(children: [

        // Gradient header
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [TColors.primary, Color(0xFFE53935)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft:  Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            16, 16, 16, 20),
          child: Column(children: [
            const Row(
              mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment:
                    CrossAxisAlignment.start,
                  children: [
                    Text('📋 Historique',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      )),
                    Text('Tous vos signalements',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontFamily: 'Poppins',
                      )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white
                  .withValues(alpha: 0.15),
                borderRadius:
                  BorderRadius.circular(16)),
              child: Row(children: [
                _bannerStat('$_total', 'Total',
                  Icons.flag_outlined),
                _bannerDiv(),
                _bannerStat('$_enCours', 'En cours',
                  Icons.pending_outlined),
                _bannerDiv(),
                _bannerStat('$_resolus', 'Résolus',
                  Icons.check_circle_outline),
              ]),
            ),
          ]),
        ),

        const SizedBox(height: 8),

        // Filter tabs
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 4),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                ? TColors.darkContainer
                : const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: List.generate(3, (i) {
                final labels = [
                  'Tous', 'En cours', 'Résolus'];
                final sel = _filterIndex == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                      setState(() => _filterIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        vertical: 9),
                      decoration: BoxDecoration(
                        color: sel
                          ? (isDark
                              ? TColors.cardDark
                              : Colors.white)
                          : Colors.transparent,
                        borderRadius:
                          BorderRadius.circular(10),
                        border: sel
                          ? Border.all(
                              color: TColors.borderLight,
                              width: 0.5)
                          : null),
                      child: Text(labels[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: sel
                            ? FontWeight.w600
                            : FontWeight.w400,
                          color: sel
                            ? TColors.primary
                            : TColors.textHint,
                        )),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        const SizedBox(height: 4),

        Expanded(
          child: _loadingData
            ? const Center(
                child: CircularProgressIndicator(
                  color: TColors.primary))
            : _filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                      MainAxisAlignment.center,
                    children: [
                      const Text('📋',
                        style: TextStyle(
                          fontSize: 48)),
                      const SizedBox(height: 12),
                      const Text('Aucun signalement',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: TColors.textPrimary,
                          fontFamily: 'Poppins',
                        )),
                      const SizedBox(height: 6),
                      const Text(
                        'Vos signalements apparaîtront ici',
                        style: TextStyle(
                          fontSize: 13,
                          color: TColors.textHint,
                          fontFamily: 'Poppins',
                        )),
                    ],
                  ))
              : RefreshIndicator(
                  onRefresh: _fetchSignalements,
                  color: TColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) =>
                      _card(_filtered[i], isDark),
                  ),
                ),
        ),
      ]),
    );
  }

  Widget _card(Map<String, dynamic> s, bool isDark) {
    final statut = s['statut'] ?? 'EN_ATTENTE';
    final cat    = _catName(s['categorie']);
    final desc   = s['description'] ?? '—';
    final time   = _timeAgo(s['createdAt']);
    final prio   = s['priorite'] ?? 'FAIBLE';

    return GestureDetector(
      onTap: () => _showDetail(s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? TColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TColors.borderLight, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                .withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _statusBg(statut),
                  borderRadius:
                    BorderRadius.circular(13)),
                child: Icon(_catIcon(cat),
                  size: 22,
                  color: _statusColor(statut))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                    CrossAxisAlignment.start,
                  children: [
                    Text(desc,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                          ? TColors.textWhite
                          : TColors.textPrimary,
                        fontFamily: 'Poppins',
                      )),
                    const SizedBox(height: 3),
                    Text('$cat · $time',
                      style: const TextStyle(
                        fontSize: 11,
                        color: TColors.textHint,
                        fontFamily: 'Poppins',
                      )),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBg(statut),
                  borderRadius:
                    BorderRadius.circular(20)),
                child: Text(_statusLabel(statut),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(statut),
                    fontFamily: 'Poppins',
                  ))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Text(_prioEmoji(prio),
                style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 5),
              Text('Priorité ${_prioLabel(prio)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _prioColor(prio),
                  fontFamily: 'Poppins',
                )),
              const Spacer(),
              const Row(children: [
                Text('Détails',
                  style: TextStyle(
                    fontSize: 11,
                    color: TColors.primary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  )),
                SizedBox(width: 3),
                Icon(Icons.arrow_forward_ios,
                  size: 10, color: TColors.primary),
              ]),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _bannerStat(String num, String label,
      IconData icon) {
    return Expanded(
      child: Column(children: [
        Icon(icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 16),
        const SizedBox(height: 3),
        Text(num,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Poppins',
          )),
        const SizedBox(height: 2),
        Text(label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.75),
            fontFamily: 'Poppins',
          )),
      ]),
    );
  }

  Widget _bannerDiv() => Container(
    width: 1, height: 32,
    color: Colors.white.withValues(alpha: 0.2));
}