import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class MesSignalementsScreen extends StatefulWidget {
  const MesSignalementsScreen({super.key});
  @override
  State<MesSignalementsScreen> createState() =>
      _MesSignalementsScreenState();
}

class _MesSignalementsScreenState
    extends State<MesSignalementsScreen> {

  int _filter = 0;
  final _filters = ['Tous', 'En cours', 'Résolus'];

  final List<Map<String, String>> _signalements = [
    {
      'title':  'Nid de poule — Bourguiba',
      'cat':    'Voirie',
      'status': 'EN_COURS',
      'time':   'Il y a 2h',
      'desc':   'Grand nid de poule dangereux sur la route principale.',
      'loc':    'Av. Bourguiba, Tunis',
    },
    {
      'title':  'Lampadaire cassé — Sfax',
      'cat':    'Eclairage',
      'status': 'EN_ATTENTE',
      'time':   'Il y a 1j',
      'desc':   'Lampadaire cassé depuis 3 jours.',
      'loc':    'Rue de la Liberté, Sfax',
    },
    {
      'title':  'Déchets — Sousse',
      'cat':    'Propreté',
      'status': 'RESOLU',
      'time':   'Il y a 3j',
      'desc':   'Dépôt sauvage de déchets près du marché.',
      'loc':    'Marché Central, Sousse',
    },
    {
      'title':  'Route endommagée — Bizerte',
      'cat':    'Voirie',
      'status': 'RESOLU',
      'time':   'Il y a 5j',
      'desc':   'Route très endommagée après les pluies.',
      'loc':    'Route Nationale, Bizerte',
    },
  ];

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

  List<Map<String, String>> get _filtered {
    if (_filter == 0) return _signalements;
    if (_filter == 1)
      return _signalements
        .where((s) => s['status'] == 'EN_COURS' ||
                      s['status'] == 'EN_ATTENTE').toList();
    return _signalements
      .where((s) => s['status'] == 'RESOLU').toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.light,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Header ──────────────────────────────────────
            Container(
              color: isDark ? TColors.cardDark : TColors.cardLight,
              padding: const EdgeInsets.fromLTRB(6, 8, 16, 8),
              child: Row(children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new,
                    size: 20,
                    color: isDark
                      ? TColors.textWhite : TColors.textPrimary),
                  onPressed: () => Navigator.pop(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mes signalements',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                            ? TColors.textWhite : TColors.textPrimary,
                          fontFamily: 'Poppins',
                        )),
                      Text('${_signalements.length} signalements',
                        style: const TextStyle(
                          fontSize: 12,
                          color: TColors.textHint,
                          fontFamily: 'Poppins',
                        )),
                    ],
                  ),
                ),
              ]),
            ),

            // ── Stats row ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Container(
                decoration: BoxDecoration(
                  color: TColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 8),
                child: Row(children: [
                  _stat('${_signalements.length}', 'Total'),
                  _div(),
                  _stat(
                    '${_signalements.where((s) =>
                      s['status'] == 'EN_COURS' ||
                      s['status'] == 'EN_ATTENTE').length}',
                    'En cours'),
                  _div(),
                  _stat(
                    '${_signalements.where((s) =>
                      s['status'] == 'RESOLU').length}',
                    'Résolus'),
                ]),
              ),
            ),

            // ── Filter tabs ──────────────────────────────────
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

            // ── List ─────────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
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
                          child: const Icon(
                            Icons.flag_outlined,
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
                        const Text(
                          'Vos signalements apparaîtront ici',
                          style: TextStyle(
                            fontSize: 13,
                            color: TColors.textHint,
                            fontFamily: 'Poppins',
                          )),
                      ],
                    ))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) =>
                      _card(_filtered[i], isDark),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Map<String, String> s, bool isDark) {
    return GestureDetector(
      onTap: () => _showDetail(s, isDark),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? TColors.cardDark : TColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.borderLight, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 14),
        child: Row(children: [
          // Category icon
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: _statusBg(s['status']!),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(_catIcon(s['cat']!),
              size: 22, color: _statusColor(s['status']!))),
          const SizedBox(width: 12),
          // Info
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
                Row(children: [
                  Icon(Icons.place_outlined,
                    size: 12, color: TColors.textHint),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(s['loc']!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: TColors.textHint,
                        fontFamily: 'Poppins',
                      ))),
                ]),
                const SizedBox(height: 3),
                Text('${s['cat']} · ${s['time']}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: TColors.textHint,
                    fontFamily: 'Poppins',
                  )),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status pill
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
              ))),
        ]),
      ),
    );
  }

  // ── Detail bottom sheet ────────────────────────────────────
  void _showDetail(Map<String, String> s, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: TColors.borderLight,
                  borderRadius: BorderRadius.circular(2)),
              )),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + status
                    Row(
                      mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(s['title']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: TColors.textPrimary,
                              fontFamily: 'Poppins',
                            ))),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusBg(s['status']!),
                            borderRadius:
                              BorderRadius.circular(20),
                          ),
                          child: Text(_statusLabel(s['status']!),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _statusColor(s['status']!),
                              fontFamily: 'Poppins',
                            ))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Info rows
                    _detailRow(Icons.category_outlined,
                      'Catégorie', s['cat']!),
                    _detailRow(Icons.place_outlined,
                      'Localisation', s['loc']!),
                    _detailRow(Icons.access_time_outlined,
                      'Soumis', s['time']!),
                    const SizedBox(height: 16),
                    // Description
                    const Text('Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: TColors.textSecondary,
                        fontFamily: 'Poppins',
                      )),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: TColors.light,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: TColors.borderLight, width: 0.5),
                      ),
                      child: Text(s['desc']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: TColors.textPrimary,
                          fontFamily: 'Poppins',
                          height: 1.5,
                        ))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: TColors.light,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: TColors.primary)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
              style: const TextStyle(
                fontSize: 11,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              )),
            Text(value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TColors.textPrimary,
                fontFamily: 'Poppins',
              )),
          ],
        ),
      ]),
    );
  }

  Widget _stat(String num, String label) {
    return Expanded(
      child: Column(children: [
        Text(num,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Poppins',
          )),
        const SizedBox(height: 2),
        Text(label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
            fontFamily: 'Poppins',
          )),
      ]),
    );
  }

  Widget _div() {
    return Container(
      width: 1, height: 32,
      color: Colors.white.withValues(alpha: 0.2));
  }
}