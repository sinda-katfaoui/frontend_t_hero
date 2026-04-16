// ============================================================
// NewSignalementScreen — CORRIGÉ + DESIGN PROFESSIONNEL
// ✅ Fix erreur Dart : classes typées pour Cat et Prio
// ✅ Couleurs sobres et professionnelles (thème T HERO)
// ✅ Zéro scroll — LayoutBuilder adaptatif
// ============================================================

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_t_hero/utils/constants/api_constant.dart';

// ── Classes typées — FIX de l'erreur Null ─────────────────
class _Cat {
  final String   label;
  final IconData icon;
  final Color    color;
  final Color    bg;
  final String   id;        // ← ADD THIS
  const _Cat(this.label, this.icon, this.color, this.bg, this.id);
}

class _Prio {
  final String   key;
  final String   label;
  final IconData icon;
  final Color    color;
  final Color    bg;
  final Color    border;
  const _Prio(this.key, this.label, this.icon,
    this.color, this.bg, this.border);
}

// ── Palette professionnelle T HERO ─────────────────────────
// Rouge T HERO  : #C0392B
// Beige fond    : #F0EDE8
// Gris slate    : #475569
// Bleu nuit     : #1E3A5F  (autorité, sécurité)
// Vert olive    : #4A6741  (naturel, Tunisia)
// Ambre chaud   : #B45309  (attention)

class NewSignalementScreen extends StatefulWidget {
  const NewSignalementScreen({super.key});
  @override
  State<NewSignalementScreen> createState() =>
      _NewSignalementScreenState();
}

class _NewSignalementScreenState extends State<NewSignalementScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();

  File?   _photo;
  int     _catIndex   = 0;
  String? _priorite;
  bool    _loading    = false;
  bool    _gpsLoading = false;
  double? _lat;
  String  _locLabel  = 'Localisation...';
  String  _cityLabel = 'Détection en cours';

  // ── Catégories with real MongoDB IDs ──────────────────────
static const _cats = [
  _Cat('Voirie',        Icons.warning_amber_rounded,
    Color(0xFFB45309), Color(0xFFFEF3C7),
    '69b5f22c1a712fbb5e43b63e'),
  _Cat('Eclairage',     Icons.lightbulb_outline,
    Color(0xFF1E3A5F), Color(0xFFE8EEF6),
    '69b5f25e1a712fbb5e43b642'),
  _Cat('Proprete',      Icons.delete_outline,
    Color(0xFF4A6741), Color(0xFFECF4E8),
    '69b5f26e1a712fbb5e43b646'),
  _Cat('Espaces Verts', Icons.park_outlined,
    Color(0xFF2D6A4F), Color(0xFFE8F5EE),
    '69b5f27d1a712fbb5e43b64a'),
  _Cat('Autre',         Icons.help_outline,
    Color(0xFF475569), Color(0xFFF1F5F9),
    '69b5f28a1a712fbb5e43b64e'),
];

  // ── Priorités — classes typées ──────────────────────────
  static const _prios = [
    _Prio('FAIBLE',  'Faible',  Icons.arrow_downward_rounded,
      Color(0xFF2D6A4F), Color(0xFFE8F5EE), Color(0xFF74C69D)),
    _Prio('MOYENNE', 'Moyenne', Icons.remove_rounded,
      Color(0xFFB45309), Color(0xFFFEF3C7), Color(0xFFF59E0B)),
    _Prio('ELEVEE',  'Élevée',  Icons.arrow_upward_rounded,
      Color(0xFFC0392B), Color(0xFFFFEBEB), Color(0xFFF87171)),
  ];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() { _gpsLoading = true; _locLabel = 'Localisation...'; });
    try {
      bool ok = await Geolocator.isLocationServiceEnabled();
      if (!ok) {
        setState(() {
          _locLabel = 'GPS désactivé';
          _cityLabel = 'Service indisponible';
          _gpsLoading = false;
        });
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          setState(() { _locLabel = 'Permission refusée'; _gpsLoading = false; });
          return;
        }
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() { _locLabel = 'Permission refusée'; _gpsLoading = false; });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _lat = pos.latitude;
        _locLabel  = '${pos.latitude.toStringAsFixed(4)}°N  ${pos.longitude.toStringAsFixed(4)}°E';
        _cityLabel = 'Position détectée';
        _gpsLoading = false;
      });
    } catch (_) {
      setState(() { _locLabel = 'Erreur GPS'; _gpsLoading = false; });
    }
  }

  Future<void> _pickImage(ImageSource src) async {
    try {
      final p = await ImagePicker().pickImage(source: src, imageQuality: 80);
      if (p != null) setState(() => _photo = File(p.path));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'),
          backgroundColor: const Color(0xFFC0392B)));
    }
  }

Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;
  if (_priorite == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Veuillez choisir une priorité',
        style: TextStyle(fontFamily: 'Poppins')),
      backgroundColor: const Color(0xFFC0392B),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12))));
    return;
  }
  if (_photo == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Veuillez ajouter une photo',
        style: TextStyle(fontFamily: 'Poppins')),
      backgroundColor: const Color(0xFFC0392B),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12))));
    return;
  }

  setState(() => _loading = true);

  try {
    // ── Get token + user ───────────────────────────────────
    final prefs     = await SharedPreferences.getInstance();
    final token     = prefs.getString('token') ?? '';
    final userRaw   = prefs.getString('user') ?? '{}';
    final user      = jsonDecode(userRaw);
    final citoyenId = user['_id'] ?? '';

    // ── Multipart request ──────────────────────────────────
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.createSignalement),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['description'] = _descCtrl.text.trim();
    request.fields['localisation'] = _locLabel;
    request.fields['priorite']    = _priorite!;
    request.fields['categorie']   = _cats[_catIndex].id; // real ObjectId
    request.fields['citoyen']     = citoyenId;

    request.files.add(await http.MultipartFile.fromPath(
      'photo', _photo!.path));

    final streamed  = await request.send()
      .timeout(const Duration(seconds: 15));
    final response  = await http.Response.fromStream(streamed);

    if (!mounted) return;
    setState(() => _loading = false);

    if (response.statusCode == 201) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_outline,
            color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('Signalement envoyé avec succès !',
            style: TextStyle(fontFamily: 'Poppins')),
        ]),
        backgroundColor: const Color(0xFF2D6A4F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12))));
    } else {
      final data = jsonDecode(response.body);
      final msg  = data['message'] ?? data['error'] ?? 'Erreur envoi';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg,
          style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: const Color(0xFFC0392B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12))));
    }
  } catch (e) {
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Erreur: ${e.toString()}',
        style: const TextStyle(fontFamily: 'Poppins')),
      backgroundColor: const Color(0xFFC0392B),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12))));
  }
}
  // ══════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EDE8),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(children: [
            _appBar(),
            Expanded(
              child: LayoutBuilder(builder: (ctx, constraints) {
                final h   = constraints.maxHeight;
                const gap = 6.0;
                const p   = 10.0;
                return Padding(
                  padding: const EdgeInsets.all(p),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: h * 0.13, child: _gpsCard()),
                      const SizedBox(height: gap),
                      SizedBox(height: h * 0.28, child: _photoCard()),
                      const SizedBox(height: gap),
                      SizedBox(
                        height: h * 0.24,
                        child: Row(children: [
                          Expanded(child: _catCard()),
                          const SizedBox(width: gap),
                          Expanded(child: _descCard()),
                        ]),
                      ),
                      const SizedBox(height: gap),
                      SizedBox(height: h * 0.13, child: _prioCard()),
                      const SizedBox(height: gap),
                      SizedBox(height: h * 0.08, child: _submitBtn()),
                      const SizedBox(height: gap),
                      SizedBox(height: h * 0.06, child: _aiHint()),
                    ],
                  ),
                );
              }),
            ),
          ]),
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────
  Widget _appBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new,
              size: 13, color: Color(0xFF1A1A1A)),
          ),
        ),
        const SizedBox(width: 10),
        const Text('Nouveau signalement',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
      ]),
    );
  }

  // ── GPS ────────────────────────────────────────────────
  Widget _gpsCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFC0392B),
        borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.18),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(.3))),
          child: _gpsLoading
            ? const Padding(padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.location_on, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_cityLabel,
              style: TextStyle(color: Colors.white.withOpacity(.75),
                fontSize: 9, fontWeight: FontWeight.w600,
                letterSpacing: .05, fontFamily: 'Poppins')),
            const SizedBox(height: 3),
            Text(_locLabel,
              style: const TextStyle(color: Colors.white,
                fontSize: 12, fontWeight: FontWeight.w800,
                fontFamily: 'monospace')),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.2),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withOpacity(.3))),
              child: Text(
                _lat != null ? 'GPS actif' : 'En attente...',
                style: const TextStyle(color: Colors.white,
                  fontSize: 8, fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins')),
            ),
          ],
        )),
        GestureDetector(
          onTap: _getLocation,
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(.3))),
            child: const Icon(Icons.my_location,
              color: Colors.white, size: 16),
          ),
        ),
      ]),
    );
  }

  // ── Photo ──────────────────────────────────────────────
  Widget _photoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4DE), width: .5)),
      padding: const EdgeInsets.all(9),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('PHOTO DU PROBLÈME',
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8), letterSpacing: .6,
              fontFamily: 'Poppins')),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEB),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFF87171))),
            child: const Text('Requis',
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700,
                color: Color(0xFFC0392B), fontFamily: 'Poppins')),
          ),
        ]),
        const SizedBox(height: 6),
        Expanded(
          child: GestureDetector(
            onTap: () => _pickImage(ImageSource.camera),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _photo != null
                  ? const Color(0xFFE8F5EE) : const Color(0xFFFAF9F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _photo != null
                    ? const Color(0xFF2D6A4F)
                    : const Color(0xFFCBD5E1),
                  width: 1.5)),
              child: _photo != null ? _photoPreview() : _photoEmpty(),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: _pBtn(
            icon: _photo != null
              ? Icons.refresh_rounded : Icons.camera_alt_outlined,
            label: _photo != null ? 'Reprendre' : 'Caméra',
            bg: _photo != null
              ? const Color(0xFFE8F5EE) : const Color(0xFFF8F9FA),
            border: _photo != null
              ? const Color(0xFF2D6A4F) : const Color(0xFFDDE1E7),
            color: _photo != null
              ? const Color(0xFF2D6A4F) : const Color(0xFF475569),
            onTap: () => _pickImage(ImageSource.camera))),
          const SizedBox(width: 6),
          Expanded(child: _pBtn(
            icon: Icons.photo_library_outlined,
            label: 'Galerie',
            bg: const Color(0xFFF8F9FA),
            border: const Color(0xFFDDE1E7),
            color: const Color(0xFF475569),
            onTap: () => _pickImage(ImageSource.gallery))),
        ]),
      ]),
    );
  }

  Widget _photoPreview() => Stack(fit: StackFit.expand, children: [
    ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(_photo!, fit: BoxFit.cover)),
    Positioned(top: 6, right: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF2D6A4F).withOpacity(.9),
          borderRadius: BorderRadius.circular(999)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check, color: Colors.white, size: 10),
          SizedBox(width: 3),
          Text('Photo ajoutée',
            style: TextStyle(color: Colors.white,
              fontSize: 9, fontWeight: FontWeight.w700,
              fontFamily: 'Poppins')),
        ]))),
  ]);

  Widget _photoEmpty() => Column(
    mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(
      width: 42, height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFCBD5E1))),
      child: const Icon(Icons.camera_alt_outlined,
        color: Color(0xFF475569), size: 20)),
    const SizedBox(height: 7),
    const Text('Prendre une photo',
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
        color: Color(0xFF1E3A5F), fontFamily: 'Poppins')),
    const SizedBox(height: 2),
    const Text('Caméra ou galerie photo',
      style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8),
        fontFamily: 'Poppins')),
  ]);

  Widget _pBtn({required IconData icon, required String label,
    required Color bg, required Color border, required Color color,
    required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(9),
          border: Border.all(color: border, width: 1.5)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10,
            fontWeight: FontWeight.w600, fontFamily: 'Poppins',
            color: color)),
        ]),
      ),
    );
  }

  // ── Catégorie ──────────────────────────────────────────
  Widget _catCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E4DE), width: .5)),
      padding: const EdgeInsets.all(8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const Text('CATÉGORIE',
          style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8), letterSpacing: .5,
            fontFamily: 'Poppins')),
        const SizedBox(height: 5),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.05),
            itemCount: _cats.length,
            itemBuilder: (_, i) {
              final cat = _cats[i];
              final sel = i == _catIndex;
              return GestureDetector(
                onTap: () => setState(() => _catIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: cat.bg,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: sel
                        ? cat.color : cat.color.withOpacity(.3),
                      width: sel ? 2.0 : 1.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cat.icon, color: cat.color, size: 14),
                      const SizedBox(height: 3),
                      Text(cat.label,
                        style: TextStyle(fontSize: 7,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins', color: cat.color),
                        textAlign: TextAlign.center),
                    ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  // ── Description ────────────────────────────────────────
  Widget _descCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E4DE), width: .5)),
      padding: const EdgeInsets.all(8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const Text('DESCRIPTION',
          style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8), letterSpacing: .5,
            fontFamily: 'Poppins')),
        const SizedBox(height: 5),
        Expanded(
          child: TextFormField(
            controller: _descCtrl,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(fontSize: 11,
              color: Color(0xFF1E3A5F), fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: 'Décrivez le problème...',
              hintStyle: const TextStyle(color: Color(0xFFCBD5E1),
                fontSize: 10, fontFamily: 'Poppins'),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(
                  color: Color(0xFFDDE1E7))),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(
                  color: Color(0xFFDDE1E7))),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(
                  color: Color(0xFF1E3A5F), width: 1.5)),
              contentPadding: const EdgeInsets.all(8)),
            validator: (v) =>
              v == null || v.trim().isEmpty ? 'Requis' : null,
          ),
        ),
      ]),
    );
  }

  // ── Priorité ───────────────────────────────────────────
  Widget _prioCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E4DE), width: .5)),
      padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const Text('PRIORITÉ',
          style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8), letterSpacing: .5,
            fontFamily: 'Poppins')),
        const SizedBox(height: 5),
        Expanded(
          child: Row(children: List.generate(_prios.length, (i) {
            final p   = _prios[i];
            final sel = _priorite == p.key;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _priorite = p.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(right: i < _prios.length - 1 ? 5 : 0),
                  decoration: BoxDecoration(
                    color: p.bg,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: sel ? p.color : p.border.withOpacity(.5),
                      width: sel ? 2.0 : 1.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(p.icon, color: p.color, size: 14),
                      const SizedBox(height: 3),
                      Text(p.label,
                        style: TextStyle(fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins', color: p.color)),
                    ]),
                ),
              ),
            );
          })),
        ),
      ]),
    );
  }

  // ── Submit ─────────────────────────────────────────────
  Widget _submitBtn() {
    return ElevatedButton.icon(
      onPressed: _loading ? null : _submit,
      icon: _loading
        ? const SizedBox(width: 15, height: 15,
            child: CircularProgressIndicator(
              color: Colors.white, strokeWidth: 2))
        : const Icon(Icons.send_rounded, size: 15),
      label: Text(_loading ? 'Envoi en cours...' : 'Analyser et envoyer',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
          fontFamily: 'Poppins')),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC0392B),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
        elevation: 0),
    );
  }

  // ── AI Hint ────────────────────────────────────────────
  Widget _aiHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF6),
        borderRadius: BorderRadius.circular(9)),
      child: const Row(children: [
        Icon(Icons.auto_awesome, color: Color(0xFF1E3A5F), size: 12),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            "L'IA analysera ta photo et attribuera la priorité automatiquement",
            style: TextStyle(fontSize: 9, color: Color(0xFF1E3A5F),
              fontWeight: FontWeight.w500, fontFamily: 'Poppins'))),
      ]),
    );
  }
}