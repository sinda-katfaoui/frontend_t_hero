import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class AdminSignalementDetailScreen extends StatelessWidget {
  final Map<String, dynamic> signalement;

  const AdminSignalementDetailScreen({
    super.key,
    required this.signalement,
  });

  // ✅ FIXED: photos are at /images/FILENAME
  static const String _baseUrl = 'http://10.0.2.2:5000';

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

  Color _statusColor(String s) {
    switch (s) {
      case 'EN_COURS': return TColors.info;
      case 'RESOLU':   return TColors.success;
      default:         return TColors.warning;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'EN_COURS': return 'En cours';
      case 'RESOLU':   return 'Résolu';
      default:         return 'En attente';
    }
  }

  String _catName(dynamic c) {
    if (c == null) return 'Autre';
    if (c is Map) return c['nom'] ?? 'Autre';
    return 'Autre';
  }

  String _citoyenName(dynamic c) {
    if (c == null) return '—';
    if (c is Map) {
      final nom    = c['nom']    ?? '';
      final prenom = c['prenom'] ?? '';
      final full   = '$nom $prenom'.trim();
      return full.isEmpty ? '—' : full;
    }
    return '—';
  }

  String _citoyenEmail(dynamic c) {
    if (c == null) return '';
    if (c is Map) return c['email'] ?? '';
    return '';
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
      if (diff.inHours < 24)   return 'Il y a ${diff.inHours}h';
      return 'Il y a ${diff.inDays} jour(s)';
    } catch (_) { return '—'; }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/'
             '${date.month.toString().padLeft(2, '0')}/'
             '${date.year}  '
             '${date.hour.toString().padLeft(2, '0')}:'
             '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) { return '—'; }
  }

  Map<String, dynamic>? _getAgent() {
    final a = signalement['agent'];
    if (a is Map<String, dynamic>) return a;
    return null;
  }

  Map<String, dynamic>? _getAnalyseIA() {
    final ai = signalement['analyseIA'];
    if (ai is Map<String, dynamic>) return ai;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final statut    = signalement['statut']       ?? 'EN_ATTENTE';
    final prio      = signalement['priorite']     ?? 'FAIBLE';
    final desc      = signalement['description']  ?? '—';
    final loc       = signalement['localisation'] ?? '—';
    final photo     = signalement['photo']        ?? '';
    final catNom    = _catName(signalement['categorie']);
    final citoyen   = signalement['citoyen'];
    final agent     = _getAgent();
    final analyseIA = _getAnalyseIA();
    final time      = _timeAgo(signalement['createdAt']);
    final dateStr   = _formatDate(signalement['createdAt']);

    // ✅ Correct photo URL: baseUrl + /images/ + filename
    final photoUrl  = photo.isNotEmpty ? '$_baseUrl/images/$photo' : '';

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : const Color(0xFFF5F5F5),
      body: Column(children: [

        // ── Header ──────────────────────────────────────────
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
          padding: EdgeInsets.fromLTRB(
            16, MediaQuery.of(context).padding.top + 12, 16, 20),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Détail du signalement',
                    style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: Colors.white, fontFamily: 'Poppins')),
                  Text(time,
                    style: const TextStyle(
                      fontSize: 12, color: Colors.white70,
                      fontFamily: 'Poppins')),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3))),
              child: Text(_statusLabel(statut),
                style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: Colors.white, fontFamily: 'Poppins'))),
          ]),
        ),

        // ── Content ─────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Photo ────────────────────────────────────
                if (photoUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      photoUrl,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 220,
                          decoration: BoxDecoration(
                            color: TColors.borderLight,
                            borderRadius: BorderRadius.circular(16)),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                                : null,
                              color: TColors.primary)));
                      },
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        decoration: BoxDecoration(
                          color: TColors.borderLight.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16)),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported_outlined,
                                size: 40, color: TColors.textHint),
                              SizedBox(height: 8),
                              Text('Photo non disponible',
                                style: TextStyle(
                                  fontSize: 12, color: TColors.textHint,
                                  fontFamily: 'Poppins')),
                            ],
                          ))),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── General Info ─────────────────────────────
                _card(isDark, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('📋 Informations générales'),
                    const SizedBox(height: 12),
                    _infoRow(Icons.description_outlined,   'Description',  desc,    isDark),
                    const SizedBox(height: 10),
                    _infoRow(Icons.location_on_outlined,   'Localisation', loc,     isDark),
                    const SizedBox(height: 10),
                    _infoRow(Icons.category_outlined,      'Catégorie',    catNom,  isDark),
                    const SizedBox(height: 10),
                    _infoRow(Icons.calendar_today_outlined,'Date',         dateStr, isDark),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: _statChip('Priorité', _prioLabel(prio),       _prioColor(prio))),
                      const SizedBox(width: 10),
                      Expanded(child: _statChip('Statut',   _statusLabel(statut),   _statusColor(statut))),
                    ]),
                  ],
                )),

                const SizedBox(height: 12),

                // ── Citoyen ──────────────────────────────────
                _card(isDark, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('👤 Citoyen'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: const BoxDecoration(
                          color: TColors.successLight, shape: BoxShape.circle),
                        child: Center(child: Text(
                          _citoyenName(citoyen).isNotEmpty
                            ? _citoyenName(citoyen)[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700,
                            color: TColors.success, fontFamily: 'Poppins')))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_citoyenName(citoyen),
                            style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: isDark ? TColors.textWhite : TColors.textPrimary,
                              fontFamily: 'Poppins')),
                          if (_citoyenEmail(citoyen).isNotEmpty)
                            Text(_citoyenEmail(citoyen),
                              style: const TextStyle(
                                fontSize: 12, color: TColors.textHint,
                                fontFamily: 'Poppins')),
                        ],
                      )),
                    ]),
                  ],
                )),

                const SizedBox(height: 12),

                // ── Agent ────────────────────────────────────
                _card(isDark, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: _sectionTitle('👷 Agent assigné')),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: agent == null
                            ? TColors.warningLight : TColors.infoLight,
                          borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          agent == null ? 'Non assigné' : 'Assigné',
                          style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: agent == null ? TColors.warning : TColors.info,
                            fontFamily: 'Poppins'))),
                    ]),
                    const SizedBox(height: 12),
                    if (agent == null)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: TColors.warningLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: TColors.warning.withValues(alpha: 0.3))),
                        child: const Row(children: [
                          Icon(Icons.person_off_outlined,
                            size: 16, color: TColors.warning),
                          SizedBox(width: 8),
                          Text('Aucun agent assigné',
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: TColors.warning, fontFamily: 'Poppins')),
                        ]))
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark
                            ? TColors.darkContainer
                            : const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: TColors.borderLight, width: 0.5)),
                        child: Row(children: [
                          Container(
                            width: 44, height: 44,
                            decoration: const BoxDecoration(
                              color: TColors.infoLight, shape: BoxShape.circle),
                            child: Center(child: Text(
                              (agent['nom'] ?? '?')[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700,
                                color: TColors.info, fontFamily: 'Poppins')))),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(agent['nom'] ?? '—',
                                style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600,
                                  color: isDark
                                    ? TColors.textWhite : TColors.textPrimary,
                                  fontFamily: 'Poppins')),
                              if ((agent['email'] ?? '').isNotEmpty)
                                Text(agent['email'],
                                  style: const TextStyle(
                                    fontSize: 12, color: TColors.textHint,
                                    fontFamily: 'Poppins')),
                            ],
                          )),
                          const Icon(Icons.engineering_outlined,
                            size: 18, color: TColors.info),
                        ]),
                      ),
                  ],
                )),

                const SizedBox(height: 12),

                // ── AI Analysis ──────────────────────────────
                _card(isDark, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('🤖 Analyse IA'),
                    const SizedBox(height: 12),
                    if (analyseIA == null)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: TColors.borderLight.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12)),
                        child: const Row(children: [
                          Icon(Icons.info_outline,
                            size: 16, color: TColors.textHint),
                          SizedBox(width: 8),
                          Text('Aucune analyse IA disponible',
                            style: TextStyle(
                              fontSize: 13, color: TColors.textHint,
                              fontFamily: 'Poppins')),
                        ]))
                    else ...[
                      _aiRow('Catégorie détectée',
                        analyseIA['categorie'] ?? '—',
                        Icons.label_outline, TColors.info),
                      const SizedBox(height: 10),
                      _aiRow('Priorité détectée',
                        analyseIA['priorite'] ?? '—',
                        Icons.priority_high_rounded,
                        _prioColor(analyseIA['priorite'] ?? 'FAIBLE')),
                      const SizedBox(height: 14),

                      // Confidence bar
                      Builder(builder: (_) {
                        final raw = analyseIA['scoreConfiance']
                          ?? analyseIA['confidence']
                          ?? analyseIA['score'] ?? 0;
                        final score      = (raw is num) ? raw.toDouble() : 0.0;
                        final normalized = score > 1 ? score / 100 : score;
                        final pct        = (normalized * 100).toStringAsFixed(0);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Score de confiance',
                                  style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600,
                                    color: TColors.textPrimary,
                                    fontFamily: 'Poppins')),
                                Text('$pct%',
                                  style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w700,
                                    color: TColors.primary, fontFamily: 'Poppins')),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: normalized.clamp(0.0, 1.0),
                                minHeight: 10,
                                backgroundColor: TColors.borderLight,
                                valueColor: const AlwaysStoppedAnimation(
                                  TColors.primary))),
                          ],
                        );
                      }),

                      if (analyseIA['scoreIA'] != null ||
                          analyseIA['aiScore']  != null) ...[
                        const SizedBox(height: 10),
                        _aiRow('Score IA',
                          '${analyseIA['scoreIA'] ?? analyseIA['aiScore']}',
                          Icons.analytics_outlined, TColors.primary),
                      ],

                      if (analyseIA['labels'] is List &&
                          (analyseIA['labels'] as List).isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text('Labels Vision API',
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: TColors.textPrimary, fontFamily: 'Poppins')),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6, runSpacing: 6,
                          children: (analyseIA['labels'] as List)
                            .take(6).map((l) {
                              final label = l is Map
                                ? (l['description'] ?? l.toString())
                                : l.toString();
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: TColors.infoLight,
                                  borderRadius: BorderRadius.circular(20)),
                                child: Text(label,
                                  style: const TextStyle(
                                    fontSize: 11, color: TColors.info,
                                    fontFamily: 'Poppins')));
                            }).toList(),
                        ),
                      ],
                    ],
                  ],
                )),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _card(bool isDark, {required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? TColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: TColors.borderLight, width: 0.5),
      boxShadow: [BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: child,
  );

  Widget _sectionTitle(String t) => Text(t,
    style: const TextStyle(
      fontSize: 14, fontWeight: FontWeight.w700,
      color: TColors.textPrimary, fontFamily: 'Poppins'));

  Widget _infoRow(IconData icon, String label, String value, bool isDark) =>
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 15, color: TColors.textHint),
      const SizedBox(width: 8),
      SizedBox(width: 90,
        child: Text('$label :',
          style: const TextStyle(
            fontSize: 12, color: TColors.textHint, fontFamily: 'Poppins'))),
      Expanded(child: Text(value,
        style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: isDark ? TColors.textWhite : TColors.textPrimary,
          fontFamily: 'Poppins'))),
    ]);

  Widget _statChip(String label, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.3))),
    child: Column(children: [
      Text(label,
        style: const TextStyle(
          fontSize: 10, color: TColors.textHint, fontFamily: 'Poppins')),
      const SizedBox(height: 4),
      Text(value,
        style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700,
          color: color, fontFamily: 'Poppins')),
    ]),
  );

  Widget _aiRow(String label, String value, IconData icon, Color color) =>
    Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 15, color: color)),
      const SizedBox(width: 10),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
            style: const TextStyle(
              fontSize: 11, color: TColors.textHint, fontFamily: 'Poppins')),
          Text(value,
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: color, fontFamily: 'Poppins')),
        ],
      )),
    ]);
}