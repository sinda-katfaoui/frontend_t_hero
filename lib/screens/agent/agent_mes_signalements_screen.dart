import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class AgentMesSignalementsScreen extends StatefulWidget {
  final String? highlightTitle;
  const AgentMesSignalementsScreen({super.key, this.highlightTitle});
  @override
  State<AgentMesSignalementsScreen> createState() =>
      _AgentMesSignalementsScreenState();
}

class _AgentMesSignalementsScreenState
    extends State<AgentMesSignalementsScreen> {

  int _filter    = 0;
  int _sortIndex = 0;
  final _filters = ['Tous', 'En cours', 'Résolus'];

  // ── Auto-open detail if coming from Analyses IA ────────────
  @override
  void initState() {
    super.initState();
    if (widget.highlightTitle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final index = _signalements.indexWhere(
          (s) => s['title'] == widget.highlightTitle);
        if (index != -1) {
          _showDetail(_signalements[index], index);
        }
      });
    }
  }

  // ── Mutable signalements — agent can update status ─────────
  final List<Map<String, dynamic>> _signalements = [
    {
      'title':       'Nid de poule — Bourguiba',
      'cat':         'Voirie',
      'status':      'EN_COURS',
      'priority':    'ELEVEE',
      'loc':         'Av. Bourguiba, Tunis',
      'time':        'Il y a 2h',
      'desc':        'Grand nid de poule dangereux sur la route principale.',
      'citoyen':     'Amira Bouazizi',
      'aiScore':     0.80,
      'aiScoreLabel':'80%',
      'aiCat':       'Voirie',
    },
    {
      'title':       'Lampadaire cassé — Sfax',
      'cat':         'Eclairage',
      'status':      'EN_ATTENTE',
      'priority':    'MOYENNE',
      'loc':         'Rue de la Liberté, Sfax',
      'time':        'Il y a 1j',
      'desc':        'Lampadaire cassé depuis 3 jours.',
      'citoyen':     'Mohamed Ben Ali',
      'aiScore':     0.75,
      'aiScoreLabel':'75%',
      'aiCat':       'Eclairage',
    },
    {
      'title':       'Déchets — Sousse',
      'cat':         'Propreté',
      'status':      'RESOLU',
      'priority':    'FAIBLE',
      'loc':         'Marché Central, Sousse',
      'time':        'Il y a 3j',
      'desc':        'Dépôt sauvage de déchets près du marché.',
      'citoyen':     'Sara Jouini',
      'aiScore':     0.70,
      'aiScoreLabel':'70%',
      'aiCat':       'Propreté',
    },
    {
      'title':       'Route endommagée — Bizerte',
      'cat':         'Voirie',
      'status':      'RESOLU',
      'priority':    'ELEVEE',
      'loc':         'Route Nationale, Bizerte',
      'time':        'Il y a 5j',
      'desc':        'Route très endommagée après les pluies.',
      'citoyen':     'Yassine Trabelsi',
      'aiScore':     0.85,
      'aiScoreLabel':'85%',
      'aiCat':       'Voirie',
    },
  ];

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

  int _priorityOrder(String p) {
    switch (p) {
      case 'ELEVEE':  return 0;
      case 'MOYENNE': return 1;
      default:        return 2;
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

  // ── Filtered + sorted list ─────────────────────────────────
  List<Map<String, dynamic>> get _filtered {
    List<Map<String, dynamic>> list;
    if (_filter == 0) {
      list = List.from(_signalements);
    } else if (_filter == 1) {
      list = _signalements
        .where((s) => s['status'] == 'EN_COURS' ||
                      s['status'] == 'EN_ATTENTE')
        .toList();
    } else {
      list = _signalements
        .where((s) => s['status'] == 'RESOLU')
        .toList();
    }

    if (_sortIndex == 1) {
      list.sort((a, b) =>
        _priorityOrder(a['priority'])
          .compareTo(_priorityOrder(b['priority'])));
    }
    return list;
  }

  // ── Change status dialog ───────────────────────────────────
  void _showChangeStatus(int realIndex) {
    final s = _signalements[realIndex];
    String selected = s['status'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: TColors.borderLight,
                  borderRadius: BorderRadius.circular(2)),
              )),
              const SizedBox(height: 16),
              const Text('Modifier le statut',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TColors.textPrimary,
                  fontFamily: 'Poppins',
                )),
              const SizedBox(height: 6),
              Text('Signalement : ${s['title']}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: TColors.textHint,
                  fontFamily: 'Poppins',
                )),
              const SizedBox(height: 20),

              // Status options
              ...['EN_ATTENTE', 'EN_COURS', 'RESOLU'].map((status) {
                final isSelected = selected == status;
                return GestureDetector(
                  onTap: () =>
                    setSheet(() => selected = status),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                        ? _statusBg(status) : TColors.light,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                          ? _statusColor(status)
                          : TColors.borderLight,
                        width: isSelected ? 1.5 : 0.5),
                    ),
                    child: Row(children: [
                      Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: _statusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(_statusLabel(status),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                            ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                            ? _statusColor(status)
                            : TColors.textPrimary,
                          fontFamily: 'Poppins',
                        )),
                      const Spacer(),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded,
                          color: _statusColor(status), size: 20),
                    ]),
                  ),
                );
              }),

              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() =>
                      _signalements[realIndex]['status'] = selected);
                    Navigator.pop(context);
                    _showSnack(
                      'Statut mis à jour : ${_statusLabel(selected)} ✓',
                      TColors.success);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Confirmer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Detail bottom sheet ────────────────────────────────────
  void _showDetail(Map<String, dynamic> s, int realIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28)),
        ),
        child: Column(
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
                          child: Text(s['title'],
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
                            color: _statusBg(s['status']),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _statusLabel(s['status']),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _statusColor(s['status']),
                              fontFamily: 'Poppins',
                            ))),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Info rows
                    _detailRow(Icons.person_outline,
                      'Citoyen', s['citoyen']),
                    _detailRow(Icons.category_outlined,
                      'Catégorie', s['cat']),
                    _detailRow(Icons.place_outlined,
                      'Localisation', s['loc']),
                    _detailRow(Icons.access_time_outlined,
                      'Soumis', s['time']),

                    // Priority
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: TColors.light,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.flag_outlined,
                            size: 18, color: TColors.primary)),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Priorité',
                              style: TextStyle(
                                fontSize: 11,
                                color: TColors.textHint,
                                fontFamily: 'Poppins',
                              )),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _priorityBg(s['priority']),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_priorityLabel(s['priority']),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _priorityColor(s['priority']),
                              fontFamily: 'Poppins',
                            ))),
                      ]),
                    ),

                    const SizedBox(height: 4),

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
                      child: Text(s['desc'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: TColors.textPrimary,
                          fontFamily: 'Poppins',
                          height: 1.5,
                        ))),

                    const SizedBox(height: 16),

                    // AI Card
                    Container(
                      decoration: BoxDecoration(
                        color: TColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: TColors.primary
                            .withValues(alpha: 0.2),
                          width: 0.5),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(children: [
                              Icon(Icons.auto_awesome,
                                size: 16, color: TColors.primary),
                              SizedBox(width: 6),
                              Text('Analyse IA',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: TColors.primary,
                                  fontFamily: 'Poppins',
                                )),
                            ]),
                            Text(s['aiScoreLabel'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: TColors.primary,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: s['aiScore'],
                            backgroundColor: TColors.borderLight,
                            valueColor:
                              const AlwaysStoppedAnimation(
                                TColors.primary),
                            minHeight: 7,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Catégorie suggérée',
                              style: TextStyle(
                                fontSize: 12,
                                color: TColors.textSecondary,
                                fontFamily: 'Poppins',
                              )),
                            Text(s['aiCat'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: TColors.primary,
                                fontFamily: 'Poppins',
                              )),
                          ],
                        ),
                      ]),
                    ),

                    const SizedBox(height: 20),

                    // ── Action buttons ─────────────────────
                    // Prendre en charge button
                    if (s['status'] == 'EN_ATTENTE') ...[
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() =>
                              _signalements[realIndex]
                                ['status'] = 'EN_COURS');
                            Navigator.pop(context);
                            _showSnack(
                              'Signalement pris en charge ✓',
                              TColors.info);
                          },
                          icon: const Icon(
                            Icons.play_circle_outline,
                            size: 20),
                          label: const Text(
                            'Prendre en charge',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            )),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.info,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Marquer résolu button
                    if (s['status'] == 'EN_COURS') ...[
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() =>
                              _signalements[realIndex]
                                ['status'] = 'RESOLU');
                            Navigator.pop(context);
                            _showSnack(
                              'Signalement marqué résolu ✓',
                              TColors.success);
                          },
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 20),
                          label: const Text(
                            'Marquer comme résolu',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            )),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.success,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Modifier statut button — always visible
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Future.delayed(
                            const Duration(milliseconds: 300),
                            () => _showChangeStatus(realIndex));
                        },
                        icon: const Icon(Icons.swap_horiz,
                          size: 20),
                        label: const Text(
                          'Modifier le statut',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          )),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: TColors.primary,
                          side: const BorderSide(
                            color: TColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
        style: const TextStyle(
          fontSize: 13, fontFamily: 'Poppins')),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered;

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
                      Text(
                        '${_signalements.length} signalements assignés',
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

            // ── Stats card ───────────────────────────────────
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

            // ── Sort + Filter ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(children: [
                // Sort by priority toggle
                GestureDetector(
                  onTap: () => setState(() =>
                    _sortIndex = _sortIndex == 0 ? 1 : 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _sortIndex == 1
                        ? TColors.primaryLight : (isDark
                            ? TColors.darkContainer : TColors.light),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _sortIndex == 1
                          ? TColors.primary : TColors.borderLight,
                        width: _sortIndex == 1 ? 1.5 : 0.5),
                    ),
                    child: Row(children: [
                      Icon(Icons.sort,
                        size: 16,
                        color: _sortIndex == 1
                          ? TColors.primary : TColors.textHint),
                      const SizedBox(width: 6),
                      Text(
                        _sortIndex == 1 ? 'Priorité ✓' : 'Trier',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: _sortIndex == 1
                            ? FontWeight.w600 : FontWeight.w400,
                          color: _sortIndex == 1
                            ? TColors.primary : TColors.textHint,
                        )),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                // Filter tabs
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                        ? TColors.darkContainer
                        : const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: List.generate(3, (i) => Expanded(
                        child: GestureDetector(
                          onTap: () =>
                            setState(() => _filter = i),
                          child: AnimatedContainer(
                            duration:
                              const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8),
                            decoration: BoxDecoration(
                              color: _filter == i
                                ? (isDark
                                    ? TColors.cardDark
                                    : TColors.cardLight)
                                : Colors.transparent,
                              borderRadius:
                                BorderRadius.circular(9),
                              border: _filter == i
                                ? Border.all(
                                    color: TColors.borderLight,
                                    width: 0.5)
                                : null,
                            ),
                            child: Text(_filters[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: _filter == i
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                                color: _filter == i
                                  ? TColors.primary
                                  : TColors.textHint,
                              )),
                          ),
                        ),
                      )),
                    ),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 6),

            // ── List ─────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
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
                      ],
                    ))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final s = filtered[i];
                      final realIndex = _signalements.indexOf(s);
                      return _card(s, realIndex, isDark);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Map<String, dynamic> s, int realIndex, bool isDark) {
    return GestureDetector(
      onTap: () => _showDetail(s, realIndex),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? TColors.cardDark : TColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TColors.borderLight, width: 0.5),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              // Category icon
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: _statusBg(s['status']),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(_catIcon(s['cat']),
                  size: 22,
                  color: _statusColor(s['status']))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['title'],
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
                        child: Text(s['loc'],
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: TColors.textHint,
                            fontFamily: 'Poppins',
                          ))),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusBg(s['status']),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_statusLabel(s['status']),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(s['status']),
                    fontFamily: 'Poppins',
                  ))),
            ]),

            const SizedBox(height: 10),

            // Bottom row: priority + quick action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Priority badge
                Row(children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: _priorityColor(s['priority']),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Priorité ${_priorityLabel(s['priority'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _priorityColor(s['priority']),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    )),
                  const SizedBox(width: 10),
                  Text('· ${s['time']}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: TColors.textHint,
                      fontFamily: 'Poppins',
                    )),
                ]),

                // Quick action button
                if (s['status'] == 'EN_ATTENTE')
                  GestureDetector(
                    onTap: () {
                      setState(() =>
                        _signalements[realIndex]
                          ['status'] = 'EN_COURS');
                      _showSnack(
                        'Pris en charge ✓', TColors.info);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: TColors.info,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Prendre',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ))),
                  )
                else if (s['status'] == 'EN_COURS')
                  GestureDetector(
                    onTap: () {
                      setState(() =>
                        _signalements[realIndex]
                          ['status'] = 'RESOLU');
                      _showSnack(
                        'Marqué résolu ✓', TColors.success);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: TColors.success,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Résoudre',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ))),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: TColors.successLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('✓ Traité',
                      style: TextStyle(
                        fontSize: 12,
                        color: TColors.success,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ))),
              ],
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
            fontSize: 22,
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
} //new version of signalement qui a tous pour l'agent