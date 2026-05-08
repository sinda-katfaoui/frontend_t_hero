import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';
import 'package:frontend_t_hero/utils/constants/api_constant.dart';

class AgentDetailScreen extends StatefulWidget {
  final Map<String, String> signalement;
  const AgentDetailScreen({super.key, required this.signalement});

  @override
  State<AgentDetailScreen> createState() => _AgentDetailScreenState();
}

class _AgentDetailScreenState extends State<AgentDetailScreen> {
  String? _selectedStatus;
  final _statuts = ['EN_ATTENTE', 'EN_COURS', 'RESOLU'];

  File? _photoResolution;
  bool  _submitting = false;
  bool  _validating = false;

  // ── Strict label lists per category ─────────────────────────
  // These are the EXACT labels Google Vision returns for each type

  static const List<String> _lightingLabels = [
    'street light', 'street lamp', 'lamp post', 'light pole',
    'light fixture', 'lighting', 'lantern', 'lamp', 'light bulb',
    'sconce', 'street lighting', 'outdoor lighting', 'public lighting',
    'electric light', 'night light', 'security lighting', 'flood light',
    'spotlight', 'luminaire', 'lampadaire', 'eclairage', 'chandelier',
    'pendant light', 'wall light', 'neon', 'fluorescent',
  ];

  static const List<String> _voirieLabels = [
    'road', 'asphalt', 'pavement', 'pothole', 'tarmac',
    'sidewalk', 'curb', 'footpath', 'road surface', 'road damage',
    'crack', 'gravel', 'highway', 'lane', 'driveway',
    'road marking', 'crosswalk', 'zebra crossing', 'manhole',
    'speed bump', 'trottoir', 'chaussee', 'asphalte', 'nid de poule',
    'infrastructure', 'urban road', 'concrete', 'cobblestone',
    'paving', 'paved', 'macadam',
  ];

  static const List<String> _wasteLabels = [
    'waste', 'garbage', 'trash', 'litter', 'rubbish', 'dump',
    'landfill', 'sewage', 'refuse', 'littering', 'dumping',
    'debris', 'junk', 'scrap', 'pollution', 'contamination',
    'bin', 'dumpster', 'container', 'bag', 'plastic bag',
    'plastic bottle', 'can', 'cardboard', 'filth', 'dirt',
    'dechet', 'poubelle', 'ordure', 'saleté', 'immondice',
    'compost', 'recycling', 'waste management',
  ];

  static const List<String> _espacesLabels = [
    'tree', 'grass', 'park', 'garden', 'plant', 'vegetation',
    'bench', 'playground', 'shrub', 'bush', 'flower', 'lawn',
    'green space', 'nature', 'leaf', 'branch', 'trunk', 'root',
    'hedge', 'fence', 'path', 'walkway', 'alley', 'square',
    'fountain', 'statue', 'monument', 'parc', 'jardin', 'arbre',
    'pelouse', 'fleur', 'buisson', 'haie', 'verdure',
  ];

  // ── Category detection from raw Vision labels ────────────────
  bool _hasLighting(List<String> labels) =>
    labels.any((l) => _lightingLabels.any((kw) =>
      l == kw || l.contains(kw) || kw.contains(l)));

  bool _hasVoirie(List<String> labels) =>
    labels.any((l) => _voirieLabels.any((kw) =>
      l == kw || l.contains(kw) || kw.contains(l)));

  bool _hasWaste(List<String> labels) =>
    labels.any((l) => _wasteLabels.any((kw) =>
      l == kw || l.contains(kw) || kw.contains(l)));

  bool _hasEspaces(List<String> labels) =>
    labels.any((l) => _espacesLabels.any((kw) =>
      l == kw || l.contains(kw) || kw.contains(l)));

  // ── Strict category matching ─────────────────────────────────
  // Uses raw Vision labels — NOT AI engine category
  // because aiEngine misclassifies "street light" as "road"
  bool _categoryMatches(String signalementCat, List<String> rawLabels) {
    final cat = signalementCat.toUpperCase()
      .replaceAll('É', 'E').replaceAll('È', 'E').replaceAll('Ê', 'E')
      .replaceAll('Ô', 'O').replaceAll('Î', 'I').replaceAll('Â', 'A');

    final hasLight   = _hasLighting(rawLabels);
    final hasVoirie  = _hasVoirie(rawLabels);
    final hasWaste   = _hasWaste(rawLabels);
    final hasEspaces = _hasEspaces(rawLabels);

    if (cat.contains('ECLAIR')) {
      // Must have lighting labels AND no strong voirie/waste signals
      return hasLight && !hasWaste;
    }

    if (cat.contains('VOIRIE')) {
      // Must have road labels AND no lighting labels
      // (street light photo has both "street" and lighting labels)
      return hasVoirie && !hasLight;
    }

    if (cat.contains('PROPRET')) {
      // Must have waste labels
      return hasWaste;
    }

    if (cat.contains('ESPACE') || cat.contains('VERT')) {
      // Must have nature/park labels AND no waste/road signals
      return hasEspaces && !hasWaste && !hasVoirie;
    }

    // AUTRE — accept anything that passed the urban check
    return true;
  }

  String _categoryLabel(String cat) {
    final c = cat.toUpperCase()
      .replaceAll('É', 'E').replaceAll('È', 'E').replaceAll('Ê', 'E');
    if (c.contains('ECLAIR'))  return 'Éclairage';
    if (c.contains('VOIRIE'))  return 'Voirie';
    if (c.contains('PROPRET')) return 'Propreté';
    if (c.contains('ESPACE'))  return 'Espaces Verts';
    return 'Autre';
  }

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.signalement['status'] ?? 'EN_ATTENTE';
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

  double _parseScore(String? score) {
    if (score == null || score == 'N/A') return 0.0;
    return (double.tryParse(score.replaceAll('%', '')) ?? 0) / 100;
  }

  Future<void> _pickResolutionPhoto(ImageSource src) async {
    try {
      final p = await ImagePicker().pickImage(source: src, imageQuality: 80);
      if (p == null) return;

      final file = File(p.path);
      setState(() => _validating = true);

      try {
        final prefs       = await SharedPreferences.getInstance();
        final token       = prefs.getString('token') ?? '';
        final bytes       = await file.readAsBytes();
        final base64Image = base64Encode(bytes);

        final response = await http.post(
          Uri.parse('${ApiConstants.baseUrl}/analyseAI/analyze'),
          headers: {
            'Content-Type':  'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'image': base64Image, 'zone': ''}),
        ).timeout(const Duration(seconds: 30));

        if (!mounted) return;

        if (response.statusCode == 400) {
          setState(() { _validating = false; _photoResolution = null; });
          _snack(
            '❌ Photo non pertinente — photographiez le problème résolu sur le terrain',
            TColors.error);
          return;
        }

        if (response.statusCode == 201) {
          final data    = jsonDecode(response.body);
          final sigCat  = widget.signalement['cat'] ?? '';

          // Extract raw Vision labels from response
          final rawLabelsList = data['ai']['labels'] as List? ?? [];
          final rawLabels = rawLabelsList
            .map((l) => l is Map
              ? (l['label'] ?? l['description'] ?? l.toString()).toString().toLowerCase()
              : l.toString().toLowerCase())
            .toList();

          final matches = _categoryMatches(sigCat, rawLabels);

          if (!matches) {
            setState(() { _validating = false; _photoResolution = null; });
            _snack(
              '❌ Photo incorrecte — la photo doit montrer une résolution de type "${_categoryLabel(sigCat)}"',
              TColors.error);
            return;
          }

          setState(() { _validating = false; _photoResolution = file; });
          _snack('✅ Photo validée — catégorie correcte', TColors.success);
        } else {
          setState(() { _validating = false; _photoResolution = file; });
        }
      } catch (e) {
        setState(() { _validating = false; _photoResolution = file; });
      }
    } catch (e) {
      setState(() => _validating = false);
      _snack('Erreur: $e', TColors.error);
    }
  }

  Future<void> _submitStatus() async {
    if (_selectedStatus == null) return;

    if (_selectedStatus == 'RESOLU' && _photoResolution == null) {
      _snack('Veuillez ajouter une photo de résolution', TColors.warning);
      return;
    }

    setState(() => _submitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final sigId = widget.signalement['id'] ?? '';

      if (sigId.isEmpty) {
        _snack('ID du signalement manquant', TColors.error);
        setState(() => _submitting = false);
        return;
      }

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConstants.baseUrl}/signalements/ChangerStatut/$sigId'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['statut'] = _selectedStatus!;

      if (_selectedStatus == 'RESOLU' && _photoResolution != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photoResolution', _photoResolution!.path),
        );
      }

      final streamed = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamed);

      if (!mounted) return;
      setState(() => _submitting = false);

      if (response.statusCode == 200) {
        _snack(
          _selectedStatus == 'RESOLU'
            ? '🏆 Signalement résolu avec photo ✓'
            : 'Statut mis à jour ✓',
          TColors.success);
        Navigator.pop(context, true);
      } else {
        _snack('Erreur lors de la mise à jour', TColors.error);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _snack('Erreur de connexion', TColors.error);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
        style: const TextStyle(fontSize: 13, fontFamily: 'Poppins')),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 4),
    ));
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
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20)),
            child: Text(_statusLabel(status),
              style: const TextStyle(fontSize: 12, color: Colors.white,
                fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                    color: isDark ? TColors.textWhite : TColors.textPrimary,
                    fontFamily: 'Poppins')),
                const SizedBox(height: 12),
                _buildInfoCard(s, priority, isDark),
                const SizedBox(height: 12),
                _buildSignalementPhoto(s),
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

  Widget _buildSignalementPhoto(Map<String, String> s) {
    final photo = s['photo'] ?? '';
    if (photo.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.borderLight, width: 0.5)),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.camera_alt_outlined, size: 16, color: TColors.primary),
            SizedBox(width: 8),
            Text('📸 Photo du problème signalé',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: TColors.textPrimary, fontFamily: 'Poppins')),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              '${ApiConstants.baseUrl}/images/$photo',
              height: 180, width: double.infinity, fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Container(height: 180, alignment: Alignment.center,
                    child: const CircularProgressIndicator(color: TColors.primary, strokeWidth: 2)),
              errorBuilder: (_, __, ___) => Container(
                height: 60, alignment: Alignment.center,
                child: const Text('Photo non disponible',
                  style: TextStyle(fontSize: 12, color: TColors.textHint, fontFamily: 'Poppins'))),
            ),
          ),
          const SizedBox(height: 6),
          const Text('Photo prise par le citoyen lors du signalement',
            style: TextStyle(fontSize: 11, color: TColors.textHint, fontFamily: 'Poppins')),
        ],
      ),
    );
  }

  Widget _buildMap(String? location, bool isDark) {
    return Container(
      height: 160,
      color: isDark ? const Color(0xFF1A2A1A) : const Color(0xFFE8F0E8),
      child: Stack(children: [
        CustomPaint(
          size: const Size(double.infinity, 160),
          painter: _GridPainter(isDark: isDark)),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52, height: 52,
                decoration: const BoxDecoration(color: TColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.location_on, color: Colors.white, size: 28)),
              const SizedBox(height: 8),
              Text(location ?? 'Localisation non définie',
                style: const TextStyle(fontSize: 13, color: TColors.textHint,
                  fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildInfoCard(Map<String, String> s, String priority, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.borderLight, width: 0.5)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(children: [
        _row('Citoyen',      s['citoyen']      ?? '—', Icons.person_outline,         isDark),
        _div(),
        _row('Catégorie',    s['cat']          ?? '—', Icons.category_outlined,       isDark),
        _div(),
        _row('Localisation', s['localisation'] ?? '—', Icons.place_outlined,         isDark),
        _div(),
        _row('Date',         s['time']         ?? '—', Icons.calendar_today_outlined, isDark),
        _div(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(children: [
              Icon(Icons.flag_outlined, size: 18, color: TColors.grey),
              SizedBox(width: 10),
              Text('Priorité',
                style: TextStyle(fontSize: 14, color: TColors.textSecondary, fontFamily: 'Poppins')),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _priorityBg(priority), borderRadius: BorderRadius.circular(20)),
              child: Text(priority,
                style: TextStyle(fontSize: 12, color: _priorityColor(priority),
                  fontWeight: FontWeight.w600, fontFamily: 'Poppins'))),
          ],
        ),
      ]),
    );
  }

  Widget _buildDescriptionCard(Map<String, String> s, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.borderLight, width: 0.5)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Description',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
              color: TColors.textSecondary, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          Text(s['description'] ?? '—',
            style: TextStyle(fontSize: 14, height: 1.5,
              color: isDark ? TColors.textWhite : TColors.textPrimary,
              fontFamily: 'Poppins')),
        ],
      ),
    );
  }

  Widget _buildAICard(Map<String, String> s) {
    final scoreVal = _parseScore(s['aiScore']);
    final hasScore = scoreVal > 0;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TColors.primary, Color(0xFFE53935)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(children: [
              Icon(Icons.auto_awesome, size: 18, color: Colors.white),
              SizedBox(width: 8),
              Text('Analyse IA T HERO',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                  color: Colors.white, fontFamily: 'Poppins')),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20)),
              child: Text(
                hasScore ? s['aiScore']! : 'N/A',
                style: const TextStyle(fontSize: 15, color: Colors.white,
                  fontWeight: FontWeight.w700, fontFamily: 'Poppins'))),
          ],
        ),
        if (hasScore) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: scoreVal,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 8)),
        ] else ...[
          const SizedBox(height: 10),
          Text('Aucune analyse IA disponible',
            style: TextStyle(fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8), fontFamily: 'Poppins')),
        ],
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Catégorie détectée',
              style: TextStyle(fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8), fontFamily: 'Poppins')),
            Text(s['aiCategorie'] ?? '—',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: Colors.white, fontFamily: 'Poppins')),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Priorité IA',
              style: TextStyle(fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8), fontFamily: 'Poppins')),
            Text(s['aiPriority'] ?? '—',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: Colors.white, fontFamily: 'Poppins')),
          ],
        ),
      ]),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    final isResolu = _selectedStatus == 'RESOLU';
    final sigCat   = widget.signalement['cat'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.borderLight, width: 0.5)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚡ Modifier le statut',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
              color: TColors.textSecondary, fontFamily: 'Poppins')),
          const SizedBox(height: 12),

          ..._statuts.map((st) {
            final sel = _selectedStatus == st;
            Color color;
            String emoji;
            switch (st) {
              case 'EN_COURS': color = TColors.info;    emoji = '⚡'; break;
              case 'RESOLU':   color = TColors.success; emoji = '🏆'; break;
              default:         color = TColors.warning; emoji = '⏳'; break;
            }
            return GestureDetector(
              onTap: () => setState(() => _selectedStatus = st),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? color.withValues(alpha: 0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? color : TColors.borderLight,
                    width: sel ? 1.5 : 0.5)),
                child: Row(children: [
                  Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: sel ? color : TColors.borderLight, width: 2),
                      color: sel ? color : Colors.transparent),
                    child: sel
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null),
                  const SizedBox(width: 12),
                  Text('$emoji  ${_statusLabel(st)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                      color: sel ? color : TColors.textSecondary,
                      fontFamily: 'Poppins')),
                ]),
              ),
            );
          }),

          if (isResolu) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: TColors.successLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TColors.success.withValues(alpha: 0.4), width: 1)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.camera_alt_outlined, size: 16, color: TColors.success),
                    SizedBox(width: 8),
                    Text('Photo de résolution',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                        color: TColors.success, fontFamily: 'Poppins')),
                    SizedBox(width: 6),
                    Text('* Obligatoire',
                      style: TextStyle(fontSize: 11, color: TColors.success, fontFamily: 'Poppins')),
                  ]),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: TColors.info.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      const Icon(Icons.info_outline, size: 13, color: TColors.info),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'La photo doit montrer une résolution de type "${_categoryLabel(sigCat)}" — validée par notre IA',
                          style: const TextStyle(fontSize: 10, color: TColors.info,
                            fontFamily: 'Poppins', height: 1.4))),
                    ]),
                  ),
                  const SizedBox(height: 10),

                  if (_validating)
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: TColors.success.withValues(alpha: 0.3), width: 1.5)),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: TColors.primary, strokeWidth: 2),
                            SizedBox(height: 8),
                            Text('Validation IA en cours...',
                              style: TextStyle(fontSize: 11, color: TColors.textHint, fontFamily: 'Poppins')),
                          ],
                        ),
                      ),
                    )
                  else if (_photoResolution != null)
                    Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_photoResolution!,
                          height: 160, width: double.infinity, fit: BoxFit.cover)),
                      Positioned(
                        top: 8, right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _photoResolution = null),
                          child: Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(
                              color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 16)))),
                      Positioned(
                        bottom: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: TColors.success, borderRadius: BorderRadius.circular(8)),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.check, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text('Photo validée par IA',
                              style: TextStyle(fontSize: 10, color: Colors.white,
                                fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                          ]))),
                    ])
                  else
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: TColors.success.withValues(alpha: 0.3), width: 1.5)),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 32, color: TColors.success),
                            SizedBox(height: 4),
                            Text('Photographiez la résolution',
                              style: TextStyle(fontSize: 12, color: TColors.success, fontFamily: 'Poppins')),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _photoBtn(
                      icon:  Icons.camera_alt_outlined,
                      label: 'Caméra',
                      onTap: _validating ? null : () => _pickResolutionPhoto(ImageSource.camera))),
                    const SizedBox(width: 8),
                    Expanded(child: _photoBtn(
                      icon:  Icons.photo_library_outlined,
                      label: 'Galerie',
                      onTap: _validating ? null : () => _pickResolutionPhoto(ImageSource.gallery))),
                  ]),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (_submitting || _validating) ? null : _submitStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: isResolu ? TColors.success : TColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0),
              child: (_submitting || _validating)
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(isResolu ? '🏆' : '⚡', style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        isResolu ? 'Marquer comme résolu !' : 'Mettre à jour le statut',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins')),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoBtn({required IconData icon, required String label, VoidCallback? onTap}) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: disabled ? TColors.light : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: disabled ? TColors.borderLight : TColors.success.withValues(alpha: 0.4),
            width: 1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: disabled ? TColors.textHint : TColors.success, size: 14),
            const SizedBox(width: 6),
            Text(label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: disabled ? TColors.textHint : TColors.success, fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, IconData icon, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(icon, size: 18, color: TColors.grey),
          const SizedBox(width: 10),
          Text(label,
            style: const TextStyle(fontSize: 14, color: TColors.textSecondary, fontFamily: 'Poppins')),
        ]),
        Flexible(
          child: Text(value,
            textAlign: TextAlign.right, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: isDark ? TColors.textWhite : TColors.textPrimary))),
      ],
    );
  }

  Widget _div() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Divider(height: 0, thickness: 0.5, color: TColors.borderLight));
}

class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 22)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += 22)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.isDark != isDark;
}