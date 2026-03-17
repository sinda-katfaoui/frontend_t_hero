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
  void initState() {
    super.initState();
    _selectedStatus = widget.signalement['status'] ?? 'EN_ATTENTE';
  }

  @override
  Widget build(BuildContext context) {
    final s        = widget.signalement;
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
            child: Text(status,
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
            height: 160,
            color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A2A1A)
              : const Color(0xFFE8F0E8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on,
                    size: 36, color: TColors.primary),
                  const SizedBox(height: 4),
                  Text(s['localisation'] ?? '—',
                    style: const TextStyle(
                      fontSize: 12,
                      color: TColors.textHint)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(s['title'] ?? '—',
                  style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                // Info card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      _infoRow('Citoyen',
                        s['citoyen'] ?? '—',
                        Icons.person_outline),
                      const Divider(height: 20),
                      _infoRow('Catégorie',
                        s['cat'] ?? '—',
                        Icons.category_outlined),
                      const Divider(height: 20),
                      _infoRow('Localisation',
                        s['localisation'] ?? '—',
                        Icons.place_outlined),
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
                            const Icon(Icons.flag_outlined,
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
                      s['description'] ?? '—',
                      style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ),
                const SizedBox(height: 16),
                // AI Analysis
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
                          Text(s['aiScore'] ?? '—',
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
                          value: double.tryParse(
                            (s['aiScore'] ?? '0%')
                              .replaceAll('%', '')) != null
                            ? double.parse(
                                (s['aiScore'] ?? '0%')
                                  .replaceAll('%', '')) / 100
                            : 0.5,
                          backgroundColor: TColors.borderLight,
                          color: TColors.primary,
                          minHeight: 6)),
                      const SizedBox(height: 12),
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
                // Change status
                Text('Changer le statut',
                  style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(children: [
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Nouveau statut',
                          prefixIcon: Icon(Icons.swap_horiz)),
                        items: _statuts.map((s) =>
                          DropdownMenuItem(value: s,
                            child: Text(s, style:
                              const TextStyle(fontSize: 13))
                          )).toList(),
                        onChanged: (v) =>
                          setState(() => _selectedStatus = v),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                  content: Text(
                                    'Statut mis à jour ✓'),
                                  backgroundColor:
                                    TColors.success));
                              Navigator.pop(context);
                            },
                            child: const Text('Mettre à jour'))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() =>
                                _selectedStatus = 'RESOLU');
                              ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                  content: Text(
                                    'Signalement résolu ✓'),
                                  backgroundColor:
                                    TColors.success));
                              Navigator.pop(context);
                            },
                            child: const Text('Résoudre'))),
                      ]),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
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
        Flexible(
          child: Text(value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500))),
      ],
    );
  }
}