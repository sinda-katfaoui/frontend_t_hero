// agent_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class AgentDetailScreen extends StatefulWidget {
  final Map<String, String> signalement;

  const AgentDetailScreen({
    super.key,
    required this.signalement,
  });

  @override
  State<AgentDetailScreen> createState() => _AgentDetailScreenState();
}

class _AgentDetailScreenState extends State<AgentDetailScreen> {
  String? _selectedStatus;
  final _statuts = ['EN_ATTENTE', 'EN_COURS', 'RESOLU'];

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

  double _parseScore(String? score) {
    if (score == null) return 0.5;
    return (double.tryParse(
      score.replaceAll('%', '')) ?? 50) / 100;
  }

  @override
  void initState() {
    super.initState();
    _selectedStatus =
      widget.signalement['status'] ?? 'EN_ATTENTE';
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final s        = widget.signalement;
    final status   = s['status']   ?? 'EN_ATTENTE';
    final priority = s['priority'] ?? 'FAIBLE';

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.light,
      appBar: AppBar(
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context)),
        title: const Text('Détail signalement',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          )),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_statusLabel(status),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          _buildMap(s['localisation'], isDark),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s['title'] ?? '—',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                      ? TColors.textWhite : TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
                const SizedBox(height: 12),
                _buildInfoCard(s, priority, isDark),
                const SizedBox(height: 12),
                _buildDescriptionCard(s, isDark),
                const SizedBox(height: 12),
                _buildAICard(s),
                const SizedBox(height: 12),
                _buildStatusCard(isDark),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildMap(String? location, bool isDark) {
    return Container(
      height: 160,
      color: isDark
        ? const Color(0xFF1A2A1A)
        : const Color(0xFFE8F0E8),
      child: Stack(children: [
        CustomPaint(
          size: const Size(double.infinity, 160),
          painter: _GridPainter(isDark: isDark),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52, height: 52,
                decoration: const BoxDecoration(
                  color: TColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on,
                  color: Colors.white, size: 28),
              ),
              const SizedBox(height: 8),
              Text(location ?? 'Localisation non définie',
                style: const TextStyle(
                  fontSize: 13,
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

  Widget _buildInfoCard(
      Map<String, String> s, String priority, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 12),
      child: Column(children: [
        _row('Citoyen', s['citoyen'] ?? '—',
          Icons.person_outline, isDark),
        _div(),
        _row('Catégorie', s['cat'] ?? '—',
          Icons.category_outlined, isDark),
        _div(),
        _row('Localisation', s['localisation'] ?? '—',
          Icons.place_outlined, isDark),
        _div(),
        _row('Date', s['time'] ?? '—',
          Icons.calendar_today_outlined, isDark),
        _div(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Icon(Icons.flag_outlined,
                size: 18, color: TColors.grey),
              const SizedBox(width: 10),
              const Text('Priorité',
                style: TextStyle(
                  fontSize: 14,
                  color: TColors.textSecondary,
                  fontFamily: 'Poppins',
                )),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _priorityBg(priority),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(priority,
                style: TextStyle(
                  fontSize: 12,
                  color: _priorityColor(priority),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                )),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildDescriptionCard(
      Map<String, String> s, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: TColors.textSecondary,
              fontFamily: 'Poppins',
            )),
          const SizedBox(height: 8),
          Text(s['description'] ?? '—',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark
                ? TColors.textWhite : TColors.textPrimary,
              fontFamily: 'Poppins',
            )),
        ],
      ),
    );
  }

  Widget _buildAICard(Map<String, String> s) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TColors.primary.withValues(alpha: 0.2),
          width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(children: [
              Icon(Icons.auto_awesome,
                size: 18, color: TColors.primary),
              SizedBox(width: 8),
              Text('Analyse IA',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: TColors.primary,
                  fontFamily: 'Poppins',
                )),
            ]),
            Text(s['aiScore'] ?? '—',
              style: const TextStyle(
                fontSize: 15,
                color: TColors.primary,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              )),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: _parseScore(s['aiScore']),
            backgroundColor: TColors.borderLight,
            valueColor: const AlwaysStoppedAnimation(TColors.primary),
            minHeight: 7,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Catégorie suggérée',
              style: TextStyle(
                fontSize: 13,
                color: TColors.textSecondary,
                fontFamily: 'Poppins',
              )),
            Text(s['aiCategorie'] ?? '—',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TColors.primary,
                fontFamily: 'Poppins',
              )),
          ],
        ),
      ]),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Changer le statut',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: TColors.textSecondary,
              fontFamily: 'Poppins',
            )),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? TColors.dark : TColors.light,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TColors.borderLight, width: 0.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              icon: const Icon(Icons.keyboard_arrow_down,
                size: 20, color: TColors.textHint),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.swap_horiz,
                  size: 18, color: TColors.textHint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: isDark
                  ? TColors.textWhite : TColors.textPrimary,
              ),
              dropdownColor: isDark
                ? TColors.darkContainer : TColors.cardLight,
              items: _statuts.map((st) => DropdownMenuItem(
                value: st,
                child: Text(st,
                  style: const TextStyle(
                    fontSize: 14, fontFamily: 'Poppins')))).toList(),
              onChanged: (v) =>
                setState(() => _selectedStatus = v),
            ),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Statut mis à jour ✓',
                          style: TextStyle(
                            fontSize: 14, fontFamily: 'Poppins')),
                        backgroundColor: TColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Mettre à jour',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    )),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _selectedStatus = 'RESOLU');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Signalement résolu ✓',
                          style: TextStyle(
                            fontSize: 14, fontFamily: 'Poppins')),
                        backgroundColor: TColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TColors.primary,
                    side: const BorderSide(
                      color: TColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Résoudre',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    )),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      IconData icon, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(icon, size: 18, color: TColors.grey),
          const SizedBox(width: 10),
          Text(label,
            style: const TextStyle(
              fontSize: 14,
              color: TColors.textSecondary,
              fontFamily: 'Poppins',
            )),
        ]),
        Flexible(
          child: Text(value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: isDark
                ? TColors.textWhite : TColors.textPrimary,
            )),
        ),
      ],
    );
  }

  Widget _div() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 0, thickness: 0.5,
        color: TColors.borderLight),
    );
  }
}

class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black)
          .withValues(alpha: 0.06)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 22) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.isDark != isDark;
}