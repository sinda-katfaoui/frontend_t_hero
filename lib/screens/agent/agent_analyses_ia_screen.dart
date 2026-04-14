import 'package:flutter/material.dart';
import 'package:frontend_t_hero/screens/agent/agent_mes_signalements_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class AgentAnalysesIAScreen extends StatelessWidget {
  const AgentAnalysesIAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> _analyses = [
      {
        'title':    'Route endommagée — Bizerte',
        'cat':      'Voirie',
        'score':    0.85,
        'label':    '85%',
        'priority': 'ELEVEE',
        'time':     'Il y a 6h',
      },
      {
        'title':    'Nid de poule — Bourguiba',
        'cat':      'Voirie',
        'score':    0.80,
        'label':    '80%',
        'priority': 'ELEVEE',
        'time':     'Il y a 2h',
      },
      {
        'title':    'Lampadaire cassé — Sfax',
        'cat':      'Eclairage',
        'score':    0.75,
        'label':    '75%',
        'priority': 'MOYENNE',
        'time':     'Il y a 1j',
      },
      {
        'title':    'Déchets marché — Sousse',
        'cat':      'Propreté',
        'score':    0.70,
        'label':    '70%',
        'priority': 'FAIBLE',
        'time':     'Il y a 3j',
      },
    ];

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

    String _priorityLabel(String p) {
      switch (p) {
        case 'ELEVEE':  return 'Élevée';
        case 'MOYENNE': return 'Moyenne';
        default:        return 'Faible';
      }
    }

    Color _scoreColor(double score) {
      if (score >= 0.80) return TColors.error;
      if (score >= 0.70) return TColors.warning;
      return TColors.success;
    }

    Widget rankBadge(int rank) {
      final colors = [
        TColors.error,
        TColors.error,
        TColors.warning,
        TColors.success,
      ];
      final color = colors[rank < colors.length ? rank : colors.length - 1];
      return Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Text('${rank + 1}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'Poppins',
            ))),
      );
    }

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Analyses IA',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark
                          ? TColors.textWhite : TColors.textPrimary,
                        fontFamily: 'Poppins',
                      )),
                    const Text('Classés par score décroissant',
                      style: TextStyle(
                        fontSize: 12,
                        color: TColors.textHint,
                        fontFamily: 'Poppins',
                      )),
                  ],
                ),
              ]),
            ),

            // ── AI summary card ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: TColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('IA T HERO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          )),
                        const SizedBox(height: 4),
                        Text(
                          '${_analyses.length} signalements analysés',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                            fontFamily: 'Poppins',
                          )),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Précision moyenne : 77.5%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            )),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),

            // ── List sorted DESC ─────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4),
                itemCount: _analyses.length,
                itemBuilder: (_, i) {
                  final a = _analyses[i];
                  return GestureDetector(
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                        builder: (_) => AgentMesSignalementsScreen(
                          highlightTitle: a['title']))),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark
                          ? TColors.cardDark : TColors.cardLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: TColors.borderLight, width: 0.5),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rank + title + priority
                          Row(children: [
                            rankBadge(i),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(a['title'],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                    ? TColors.textWhite
                                    : TColors.textPrimary,
                                  fontFamily: 'Poppins',
                                ))),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _priorityBg(a['priority']),
                                borderRadius:
                                  BorderRadius.circular(20),
                              ),
                              child: Text(
                                _priorityLabel(a['priority']),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _priorityColor(a['priority']),
                                  fontFamily: 'Poppins',
                                ))),
                          ]),

                          const SizedBox(height: 8),

                          // Category + time
                          Text('${a['cat']} · ${a['time']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: TColors.textHint,
                              fontFamily: 'Poppins',
                            )),

                          const SizedBox(height: 10),

                          // Score bar
                          Row(children: [
                            Icon(Icons.auto_awesome,
                              size: 14,
                              color: _scoreColor(a['score'])),
                            const SizedBox(width: 6),
                            const Text('Score IA',
                              style: TextStyle(
                                fontSize: 12,
                                color: TColors.textSecondary,
                                fontFamily: 'Poppins',
                              )),
                            const Spacer(),
                            Text(a['label'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _scoreColor(a['score']),
                                fontFamily: 'Poppins',
                              )),
                          ]),

                          const SizedBox(height: 6),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: a['score'],
                              backgroundColor: isDark
                                ? const Color(0xFF2A2A2A)
                                : TColors.borderLight,
                              valueColor: AlwaysStoppedAnimation(
                                _scoreColor(a['score'])),
                              minHeight: 7,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Tap hint
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('Voir le signalement',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: TColors.primary,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                )),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios,
                                size: 11, color: TColors.primary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}