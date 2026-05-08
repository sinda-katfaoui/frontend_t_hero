import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';
import 'package:frontend_t_hero/utils/constants/api_constant.dart';

class AdminSignalementDetailScreen extends StatelessWidget {
  final Map<String, dynamic> signalement;

  const AdminSignalementDetailScreen({
    super.key,
    required this.signalement,
  });

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
    final isDark         = Theme.of(context).brightness == Brightness.dark;
    final statut         = signalement['statut']         ?? 'EN_ATTENTE';
    final prio           = signalement['priorite']       ?? 'FAIBLE';
    final desc           = signalement['description']    ?? '—';
    final loc            = signalement['localisation']   ?? '—';
    final photo          = signalement['photo']          ?? '';
    final photoResolution = signalement['photoResolution'] ?? '';
    final catNom         = _catName(signalement['categorie']);
    final citoyen        = signalement['citoyen'];
    final agent          = _getAgent();
    final analyseIA      = _getAnalyseIA();
    final time           = _timeAgo(signalement['createdAt']);
    final dateStr        = _formatDate(signalement['createdAt']);
    final isResolu       = statut == 'RESOLU';

    final photoUrl           = photo.isNotEmpty
      ? '${ApiConstants.baseUrl}/images/$photo' : '';
    final photoResolutionUrl = photoResolution.isNotEmpty
      ? '${ApiConstants.baseUrl}/images/$photoResolution' : '';

    // Extract AI data properly
    double aiScore        = 0.0;
    String aiCategorie    = '—';
    String aiPriorite     = '—';

    if (analyseIA != null) {
      final raw = analyseIA['scoreConfiance']
        ?? analyseIA['confidence']
        ?? analyseIA['score'] ?? 0;
      final rawScore = (raw is num) ? raw.toDouble() : 0.0;
      aiScore     = rawScore > 1 ? rawScore / 100 : rawScore;
      aiCategorie = analyseIA['resultatCategorie']
        ?? analyseIA['categorie'] ?? '—';
      aiPriorite  = analyseIA['resultatPriorite']
        ?? analyseIA['priorite']  ?? '—';
    }

    final aiPct = '${(aiScore * 100).toStringAsFixed(0)}%';

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : const Color(0xFFF5F5F5),
      body: Column(children: [

        // ── Header ──────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [TColors.primary, Color(0xFFE53935)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
            borderRadius: BorderRadius.only(
              bottomLeft:  Radius.circular(28),
              bottomRight: Radius.circular(28))),
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
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Détail du signalement',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                      color: Colors.white, fontFamily: 'Poppins')),
                  Text(time,
                    style: const TextStyle(fontSize: 12, color: Colors.white70,
                      fontFamily: 'Poppins')),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
              child: Text(_statusLabel(statut),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
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

                // ── Photo du problème (avant) ─────────────────
                if (photoUrl.isNotEmpty) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? TColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: TColors.borderLight, width: 0.5),
                      boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8, offset: const Offset(0, 2))]),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.camera_alt_outlined, size: 15, color: TColors.primary),
                          SizedBox(width: 6),
                          Text('📸 Photo du problème signalé',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                              color: TColors.textPrimary, fontFamily: 'Poppins')),
                        ]),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            photoUrl,
                            width: double.infinity, height: 200,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) => progress == null
                              ? child
                              : Container(height: 200, alignment: Alignment.center,
                                  child: const CircularProgressIndicator(
                                    color: TColors.primary, strokeWidth: 2)),
                            errorBuilder: (_, __, ___) => Container(
                              height: 80, alignment: Alignment.center,
                              child: const Text('Photo non disponible',
                                style: TextStyle(fontSize: 12, color: TColors.textHint,
                                  fontFamily: 'Poppins'))))),
                        const SizedBox(height: 6),
                        const Text('Photo soumise par le citoyen',
                          style: TextStyle(fontSize: 11, color: TColors.textHint, fontFamily: 'Poppins')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Photo de résolution (après) — only when RESOLU ─
                if (isResolu && photoResolutionUrl.isNotEmpty) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: TColors.successLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: TColors.success.withValues(alpha: 0.3), width: 1),
                      boxShadow: [BoxShadow(
                        color: TColors.success.withValues(alpha: 0.06),
                        blurRadius: 8, offset: const Offset(0, 2))]),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.check_circle_outline, size: 15, color: TColors.success),
                          SizedBox(width: 6),
                          Text('✅ Photo de résolution',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                              color: TColors.success, fontFamily: 'Poppins')),
                        ]),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            photoResolutionUrl,
                            width: double.infinity, height: 200,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) => progress == null
                              ? child
                              : Container(height: 200, alignment: Alignment.center,
                                  child: const CircularProgressIndicator(
                                    color: TColors.success, strokeWidth: 2)),
                            errorBuilder: (_, __, ___) => Container(
                              height: 80, alignment: Alignment.center,
                              child: const Text('Photo non disponible',
                                style: TextStyle(fontSize: 12, color: TColors.textHint,
                                  fontFamily: 'Poppins'))))),
                        const SizedBox(height: 6),
                        const Text('Problème traité par notre équipe municipale.',
                          style: TextStyle(fontSize: 11, color: TColors.success,
                            fontFamily: 'Poppins', height: 1.4)),
                      ],
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
                    _infoRow(Icons.description_outlined,    'Description',  desc,    isDark),
                    const SizedBox(height: 10),
                    _infoRow(Icons.location_on_outlined,    'Localisation', loc,     isDark),
                    const SizedBox(height: 10),
                    _infoRow(Icons.category_outlined,       'Catégorie',    catNom,  isDark),
                    const SizedBox(height: 10),
                    _infoRow(Icons.calendar_today_outlined, 'Date',         dateStr, isDark),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: _statChip('Priorité', _prioLabel(prio),     _prioColor(prio))),
                      const SizedBox(width: 10),
                      Expanded(child: _statChip('Statut',   _statusLabel(statut), _statusColor(statut))),
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
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                            color: TColors.success, fontFamily: 'Poppins')))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_citoyenName(citoyen),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                              color: isDark ? TColors.textWhite : TColors.textPrimary,
                              fontFamily: 'Poppins')),
                          if (_citoyenEmail(citoyen).isNotEmpty)
                            Text(_citoyenEmail(citoyen),
                              style: const TextStyle(fontSize: 12, color: TColors.textHint,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: agent == null ? TColors.warningLight : TColors.infoLight,
                          borderRadius: BorderRadius.circular(20)),
                        child: Text(agent == null ? 'Non assigné' : 'Assigné',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
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
                          border: Border.all(color: TColors.warning.withValues(alpha: 0.3))),
                        child: const Row(children: [
                          Icon(Icons.person_off_outlined, size: 16, color: TColors.warning),
                          SizedBox(width: 8),
                          Text('Aucun agent assigné',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                              color: TColors.warning, fontFamily: 'Poppins')),
                        ]))
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? TColors.darkContainer : const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: TColors.borderLight, width: 0.5)),
                        child: Row(children: [
                          Container(
                            width: 44, height: 44,
                            decoration: const BoxDecoration(
                              color: TColors.infoLight, shape: BoxShape.circle),
                            child: Center(child: Text(
                              (agent['nom'] ?? '?')[0].toUpperCase(),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                                color: TColors.info, fontFamily: 'Poppins')))),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(agent['nom'] ?? '—',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                                  color: isDark ? TColors.textWhite : TColors.textPrimary,
                                  fontFamily: 'Poppins')),
                              if ((agent['email'] ?? '').isNotEmpty)
                                Text(agent['email'],
                                  style: const TextStyle(fontSize: 12, color: TColors.textHint,
                                    fontFamily: 'Poppins')),
                            ],
                          )),
                          const Icon(Icons.engineering_outlined, size: 18, color: TColors.info),
                        ]),
                      ),
                  ],
                )),

                const SizedBox(height: 12),

                // ── AI Analysis — with percentage ─────────────
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [TColors.primary, Color(0xFFE53935)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(
                      color: TColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8, offset: const Offset(0, 3))]),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(children: [
                            Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                            SizedBox(width: 8),
                            Text('🤖 Analyse IA T HERO',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                                color: Colors.white, fontFamily: 'Poppins')),
                          ]),
                          // [KEY] Show percentage prominently
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              analyseIA != null && aiScore > 0 ? aiPct : 'N/A',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                                color: Colors.white, fontFamily: 'Poppins'))),
                        ],
                      ),

                      if (analyseIA == null || aiScore == 0) ...[
                        const SizedBox(height: 10),
                        Text('Aucune analyse IA disponible pour ce signalement',
                          style: TextStyle(fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8), fontFamily: 'Poppins')),
                      ] else ...[
                        const SizedBox(height: 12),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: aiScore.clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.25),
                            valueColor: const AlwaysStoppedAnimation(Colors.white))),
                        const SizedBox(height: 12),
                        // Categorie + Priorite
                        Row(children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Catégorie détectée',
                                  style: TextStyle(fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontFamily: 'Poppins')),
                                const SizedBox(height: 2),
                                Text(aiCategorie,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                    color: Colors.white, fontFamily: 'Poppins')),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Priorité IA',
                                  style: TextStyle(fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontFamily: 'Poppins')),
                                const SizedBox(height: 2),
                                Text(aiPriorite,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                    color: Colors.white, fontFamily: 'Poppins')),
                              ],
                            ),
                          ),
                        ]),
                      ],
                    ],
                  ),
                ),

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
        blurRadius: 8, offset: const Offset(0, 2))]),
    child: child,
  );

  Widget _sectionTitle(String t) => Text(t,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
      color: TColors.textPrimary, fontFamily: 'Poppins'));

  Widget _infoRow(IconData icon, String label, String value, bool isDark) =>
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 15, color: TColors.textHint),
      const SizedBox(width: 8),
      SizedBox(width: 90,
        child: Text('$label :',
          style: const TextStyle(fontSize: 12, color: TColors.textHint, fontFamily: 'Poppins'))),
      Expanded(child: Text(value,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
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
        style: const TextStyle(fontSize: 10, color: TColors.textHint, fontFamily: 'Poppins')),
      const SizedBox(height: 4),
      Text(value,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
          color: color, fontFamily: 'Poppins')),
    ]),
  );
}