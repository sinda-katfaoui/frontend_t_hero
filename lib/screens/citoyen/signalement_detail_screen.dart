// ============================================================
// SignalementDetailScreen — Citoyen Signalement Detail View
// ============================================================
// Shows full details of a single signalement for the citoyen.
// Opened as a new route when tapping a signalement card.
//
// Displays:
//   - Map placeholder with location name
//   - Info card: category, location, citoyen, date, priority
//   - Description text
//   - AI analysis score + progress bar (if available)
//   - Status timeline: created → assigned → resolved
//
// Design decisions:
// - Red AppBar with status pill badge in actions
// - Compact map at 80px — fits without scrolling
// - Info rows in a white card with thin dividers
// - Timeline uses colored dots + connecting lines
// - ScrollView kept for safety on small devices
//
// TODO: Connect to real data:
//   - GET /signalements/GetSignalementById/:id
//   - GET /analyseAI/GetAnalyseBySignalement/:id
// ============================================================

import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class SignalementDetailScreen extends StatelessWidget {
  final Map<String, String> signalement;

  const SignalementDetailScreen({
    super.key,
    required this.signalement,
  });

  // ── Status Helpers ─────────────────────────────────────────
  String _statusLabel(String s) {
    switch (s) {
      case 'EN_COURS': return 'En cours';
      case 'RESOLU':   return 'Résolu';
      default:         return 'En attente';
    }
  }

  // ── Priority Helpers ───────────────────────────────────────
  Color _priorityColor(String p) {
    switch (p) {
      case 'ELEVEE':  return TColors.error;
      case 'MOYENNE': return TColors.warning;
      default:        return TColors.success;
    }
  }

  Color _priorityBg(String p) {
    switch (p) {
      case 'ELEVEE':  return TColors.errorLight;
      case 'MOYENNE': return TColors.warningLight;
      default:        return TColors.successLight;
    }
  }

  // ── AI Score Parser ────────────────────────────────────────
  double _parseScore(String? score) {
    if (score == null) return 0.5;
    return (double.tryParse(
      score.replaceAll('%', '')) ?? 50) / 100;
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final s        = signalement;
    final status   = s['status']   ?? 'EN_ATTENTE';
    final priority = s['priority'] ?? 'FAIBLE';

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.light,
      appBar: AppBar(
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          onPressed: () => Navigator.pop(context)),
        title: const Text('Détail signalement',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          )),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_statusLabel(status),
              style: const TextStyle(
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          _buildMap(s['localisation'], isDark),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s['title'] ?? 'Signalement',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                      ? TColors.textWhite : TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
                const SizedBox(height: 8),
                _buildInfoCard(s, priority, isDark),
                const SizedBox(height: 8),
                _buildDescriptionCard(s, isDark),
                if (s['aiScore'] != null) ...[
                  const SizedBox(height: 8),
                  _buildAICard(s),
                ],
                const SizedBox(height: 8),
                _buildTimelineCard(s, status, isDark),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // ── Map Placeholder ────────────────────────────────────────
  Widget _buildMap(String? location, bool isDark) {
    return Container(
      height: 80,
      color: isDark
        ? const Color(0xFF1A2A1A)
        : const Color(0xFFE8F0E8),
      child: Stack(children: [
        CustomPaint(
          size: const Size(double.infinity, 80),
          painter: _GridPainter(isDark: isDark),
        ),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on,
                size: 18, color: TColors.primary),
              const SizedBox(width: 5),
              Text(location ?? 'Localisation non définie',
                style: const TextStyle(
                  fontSize: 10,
                  color: TColors.textHint,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                )),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Info Card ──────────────────────────────────────────────
  Widget _buildInfoCard(
      Map<String, String> s, String priority, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12, vertical: 10),
      child: Column(children: [
        _infoRow('Catégorie',
          s['cat'] ?? '—', Icons.category_outlined, isDark),
        _thinDivider(),
        _infoRow('Localisation',
          s['localisation'] ?? '—', Icons.place_outlined, isDark),
        _thinDivider(),
        _infoRow('Citoyen',
          s['citoyen'] ?? 'Amira Bouazizi',
          Icons.person_outline, isDark),
        _thinDivider(),
        _infoRow('Date',
          s['time'] ?? '—',
          Icons.calendar_today_outlined, isDark),
        _thinDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Icon(Icons.flag_outlined,
                size: 14, color: TColors.grey),
              const SizedBox(width: 7),
              const Text('Priorité',
                style: TextStyle(
                  fontSize: 10,
                  color: TColors.textSecondary,
                  fontFamily: 'Poppins',
                )),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: _priorityBg(priority),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(priority,
                style: TextStyle(
                  fontSize: 8,
                  color: _priorityColor(priority),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                )),
            ),
          ],
        ),
        if (s['agent'] != null &&
            s['agent']!.isNotEmpty &&
            s['agent'] != '—') ...[
          _thinDivider(),
          _infoRow('Agent assigné',
            s['agent']!, Icons.engineering_outlined, isDark),
        ],
      ]),
    );
  }

  // ── Description Card ───────────────────────────────────────
  Widget _buildDescriptionCard(
      Map<String, String> s, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Description',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: TColors.textSecondary,
              fontFamily: 'Poppins',
            )),
          const SizedBox(height: 5),
          Text(s['description'] ?? 'Aucune description disponible.',
            style: TextStyle(
              fontSize: 10,
              color: isDark
                ? TColors.textWhite : TColors.textPrimary,
              fontFamily: 'Poppins',
              height: 1.5,
            )),
        ],
      ),
    );
  }

  // ── AI Analysis Card ───────────────────────────────────────
  Widget _buildAICard(Map<String, String> s) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TColors.primary.withValues(alpha: 0.2),
          width: 0.5),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(children: [
              Icon(Icons.auto_awesome,
                size: 13, color: TColors.primary),
              SizedBox(width: 5),
              Text('Analyse IA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: TColors.primary,
                  fontFamily: 'Poppins',
                )),
            ]),
            Text(s['aiScore'] ?? '—',
              style: const TextStyle(
                fontSize: 11,
                color: TColors.primary,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              )),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _parseScore(s['aiScore']),
            backgroundColor: TColors.borderLight,
            valueColor: const AlwaysStoppedAnimation(TColors.primary),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Catégorie suggérée',
              style: TextStyle(
                fontSize: 9,
                color: TColors.textSecondary,
                fontFamily: 'Poppins',
              )),
            Text(s['aiCategorie'] ?? '—',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: TColors.primary,
                fontFamily: 'Poppins',
              )),
          ],
        ),
      ]),
    );
  }

  // ── Timeline Card ──────────────────────────────────────────
  Widget _buildTimelineCard(
      Map<String, String> s, String status, bool isDark) {
    final hasAgent = s['agent'] != null &&
      s['agent']!.isNotEmpty && s['agent'] != '—';
    final isResolved = status == 'RESOLU';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Suivi',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: TColors.textSecondary,
              fontFamily: 'Poppins',
            )),
          const SizedBox(height: 10),
          _timelineItem('Signalement créé',
            s['time'] ?? '—', done: true, isLast: false),
          _timelineItem('Pris en charge',
            hasAgent
              ? 'Par ${s['agent']}'
              : 'En attente d\'un agent',
            done: hasAgent, isLast: false),
          _timelineItem('Résolu',
            isResolved
              ? 'Problème résolu avec succès'
              : 'En cours de traitement',
            done: isResolved, isLast: true),
        ],
      ),
    );
  }

  // ── Info Row ───────────────────────────────────────────────
  Widget _infoRow(
      String label, String value, IconData icon, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(icon, size: 14, color: TColors.grey),
          const SizedBox(width: 7),
          Text(label,
            style: const TextStyle(
              fontSize: 10,
              color: TColors.textSecondary,
              fontFamily: 'Poppins',
            )),
        ]),
        Flexible(
          child: Text(value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
              color: isDark
                ? TColors.textWhite : TColors.textPrimary,
            )),
        ),
      ],
    );
  }

  // ── Thin Divider ───────────────────────────────────────────
  Widget _thinDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Divider(
        height: 0,
        thickness: 0.5,
        color: TColors.borderLight,
      ),
    );
  }

  // ── Timeline Item ──────────────────────────────────────────
  Widget _timelineItem(
      String title, String subtitle, {
      required bool done,
      required bool isLast,
    }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Container(
            width: 18, height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? TColors.primary : TColors.borderLight,
            ),
            child: done
              ? const Icon(Icons.check,
                  size: 10, color: Colors.white)
              : null,
          ),
          if (!isLast)
            Container(
              width: 1.5, height: 28,
              color: done
                ? TColors.primary.withValues(alpha: 0.3)
                : TColors.borderLight,
            ),
        ]),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: done
                      ? TColors.textPrimary : TColors.textHint,
                  )),
                const SizedBox(height: 1),
                Text(subtitle,
                  style: const TextStyle(
                    fontSize: 9,
                    color: TColors.textHint,
                    fontFamily: 'Poppins',
                  )),
                if (!isLast) const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Grid Painter ───────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black)
          .withValues(alpha: 0.06)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 18) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.isDark != isDark;
}