import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class SignalementDetailScreen extends StatefulWidget {
  final Map<String, String> signalement;

  const SignalementDetailScreen({
    super.key,
    required this.signalement,
  });

  @override
  State<SignalementDetailScreen> createState() =>
      _SignalementDetailScreenState();
}

class _SignalementDetailScreenState
    extends State<SignalementDetailScreen> {

  Color _statusColor(String s) {
    switch (s) {
      case 'EN_COURS':  return TColors.info;
      case 'RESOLU':    return TColors.success;
      default:          return TColors.warning;
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'EN_COURS':  return TColors.infoLight;
      case 'RESOLU':    return TColors.successLight;
      default:          return TColors.warningLight;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'EN_COURS':  return 'En cours';
      case 'RESOLU':    return 'Résolu';
      default:          return 'En attente';
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final s = widget.signalement;
    final status   = s['status']   ?? 'EN_ATTENTE';
    final priority = s['priority'] ?? 'FAIBLE';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail signalement'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusBg(status),
              borderRadius: BorderRadius.circular(10)),
            child: Text(_statusLabel(status),
              style: TextStyle(
                fontSize: 11,
                color: _statusColor(status),
                fontWeight: FontWeight.w500))),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          // Map placeholder
          Container(
            height: 180,
            color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A2A1A)
              : const Color(0xFFE8F0E8),
            child: Stack(children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on,
                      size: 40, color: TColors.primary),
                    const SizedBox(height: 4),
                    Text(s['localisation'] ?? 'Localisation',
                      style: TextStyle(
                        fontSize: 12,
                        color: TColors.textHint,
                        fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ]),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(s['title'] ?? 'Signalement',
                  style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                // Info card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      _infoRow('Catégorie',
                        s['cat'] ?? '—',
                        Icons.category_outlined),
                      const Divider(height: 20),
                      _infoRow('Localisation',
                        s['localisation'] ?? '—',
                        Icons.place_outlined),
                      const Divider(height: 20),
                      _infoRow('Citoyen',
                        s['citoyen'] ?? 'Amira Bouazizi',
                        Icons.person_outline),
                      const Divider(height: 20),
                      _infoRow('Date',
                        s['time'] ?? '—',
                        Icons.calendar_today_outlined),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Icon(Icons.flag_outlined,
                              size: 18, color: TColors.grey),
                            const SizedBox(width: 8),
                            const Text('Priorité',
                              style: TextStyle(
                                fontSize: 13,
                                color: TColors.textSecondary)),
                          ]),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _priorityBg(priority),
                              borderRadius:
                                BorderRadius.circular(8)),
                            child: Text(priority,
                              style: TextStyle(
                                fontSize: 11,
                                color: _priorityColor(priority),
                                fontWeight: FontWeight.w500))),
                        ],
                      ),
                      if (s['agent'] != null &&
                          s['agent']!.isNotEmpty &&
                          s['agent'] != '—') ...[
                        const Divider(height: 20),
                        _infoRow('Agent assigné',
                          s['agent']!,
                          Icons.engineering_outlined),
                      ],
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                Text('Description',
                  style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      s['description'] ??
                        'Aucune description disponible.',
                      style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ),
                const SizedBox(height: 16),
                // AI Analysis
                if (s['aiScore'] != null) ...[
                  Text('Analyse IA',
                    style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Score de confiance',
                              style: TextStyle(fontSize: 13)),
                            Text(s['aiScore']!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: TColors.primary,
                                fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 0.8,
                            backgroundColor: TColors.borderLight,
                            color: TColors.primary,
                            minHeight: 6)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Catégorie suggérée',
                              style: TextStyle(fontSize: 13)),
                            Text(s['aiCategorie'] ?? '—',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Status timeline
                Text('Suivi',
                  style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      _timelineItem('Signalement créé',
                        s['time'] ?? '—', true),
                      _timelineItem('Pris en charge',
                        s['agent'] != null &&
                        s['agent'] != '—'
                          ? 'Par ${s['agent']}'
                          : 'En attente',
                        s['agent'] != null &&
                        s['agent'] != '—'),
                      _timelineItem('Résolu',
                        status == 'RESOLU'
                          ? 'Problème résolu'
                          : 'En cours de traitement',
                        status == 'RESOLU',
                        isLast: true),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(icon, size: 18, color: TColors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(
            fontSize: 13, color: TColors.textSecondary)),
        ]),
        Text(value, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _timelineItem(String title, String subtitle,
      bool done, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? TColors.primary : TColors.borderLight),
            child: done
              ? const Icon(Icons.check,
                  size: 12, color: Colors.white)
              : null),
          if (!isLast)
            Container(
              width: 2, height: 32,
              color: done
                ? TColors.primary.withValues(alpha: 0.3)
                : TColors.borderLight),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: done
                    ? TColors.textPrimary
                    : TColors.textHint)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(
                  fontSize: 11, color: TColors.textHint)),
                if (!isLast) const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}