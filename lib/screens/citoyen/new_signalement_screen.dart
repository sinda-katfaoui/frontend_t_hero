import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_t_hero/utils/constants/api_constant.dart';

class _Cat {
  final String   label;
  final IconData icon;
  final String   id;
  const _Cat(this.label, this.icon, this.id);
}

class _Prio {
  final String key;
  final String label;
  final String emoji;
  final Color  color;
  final Color  bg;
  const _Prio(this.key, this.label, this.emoji, this.color, this.bg);
}

const _primary   = Color(0xFFC1272D);
const _white     = Color(0xFFFFFFFF);
const _textMain  = Color(0xFF1E1E1E);
const _textSub   = Color(0xFF6B6B6B);
const _border    = Color(0xFFE5E5E5);
const _success   = Color(0xFF2E7D32);
const _warning   = Color(0xFFED6C02);
const _info      = Color(0xFF1565C0);
const _redBorder = Color(0xFFC1272D);

class NewSignalementScreen extends StatefulWidget {
  const NewSignalementScreen({super.key});
  @override
  State<NewSignalementScreen> createState() => _NewSignalementScreenState();
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
  String  _locLabel   = 'Localisation en cours...';
  String  _cityLabel  = 'Détection GPS';
  bool    _aiDone     = false;
  bool    _aiLoading  = false;

  static const _cats = [
    _Cat('Voirie',    Icons.warning_amber_rounded, '69b5f22c1a712fbb5e43b63e'),
    _Cat('Eclairage', Icons.lightbulb_outline,     '69b5f25e1a712fbb5e43b642'),
    _Cat('Propreté',  Icons.delete_outline,        '69b5f26e1a712fbb5e43b646'),
    _Cat('Espaces',   Icons.park_outlined,         '69b5f27d1a712fbb5e43b64a'),
    _Cat('Autre',     Icons.help_outline,          '69b5f28a1a712fbb5e43b64e'),
  ];

  static const _prios = [
    _Prio('FAIBLE',  'Faible',  '↓', Color(0xFF757575), Color(0xFFF5F5F5)),
    _Prio('MOYENNE', 'Moyenne', '→', _warning,           Color(0xFFFFF3E0)),
    _Prio('ELEVEE',  'Élevée',  '↑', _primary,           Color(0xFFFDECEC)),
  ];

  static const _aiCatMap = {
    'road':           0,
    'lighting':       1,
    'waste':          2,
    'infrastructure': 3,
    'other':          4,
    'danger':         0,
  };

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
    setState(() { _gpsLoading = true; _locLabel = 'Localisation en cours...'; });
    try {
      bool ok = await Geolocator.isLocationServiceEnabled();
      if (!ok) {
        setState(() { _locLabel = 'GPS désactivé'; _cityLabel = 'Service indisponible'; _gpsLoading = false; });
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
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _lat       = pos.latitude;
        _locLabel  = '${pos.latitude.toStringAsFixed(4)}°N, ${pos.longitude.toStringAsFixed(4)}°E';
        _cityLabel = 'Position détectée';
        _gpsLoading = false;
      });
    } catch (_) {
      setState(() { _locLabel = 'Erreur de localisation'; _gpsLoading = false; });
    }
  }

  Future<void> _pickImage(ImageSource src) async {
    try {
      final p = await ImagePicker().pickImage(source: src, imageQuality: 80);
      if (p != null) {
        setState(() { _photo = File(p.path); _aiDone = false; _aiLoading = true; });
        await _runAiAnalysis(File(p.path));
      }
    } catch (e) {
      if (mounted) _snack('Erreur: $e', _primary);
    }
  }

  Future<void> _runAiAnalysis(File imageFile) async {
    try {
      final prefs       = await SharedPreferences.getInstance();
      final token       = prefs.getString('token') ?? '';
      final bytes       = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/analyseAI/analyze'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'image': base64Image, 'zone': _locLabel}),
      ).timeout(const Duration(seconds: 30));

      if (!mounted) return;

      if (response.statusCode == 400) {
        final data             = jsonDecode(response.body);
        final isRelevanceError = data['relevant'] == false;
        setState(() {
          _aiLoading = false;
          _aiDone    = false;
          if (isRelevanceError) _photo = null;
        });
        _snack(
          isRelevanceError
            ? '❌ Image non pertinente — photographiez un problème urbain'
            : (data['message'] ?? 'Erreur lors de l\'analyse'),
          _primary);

      } else if (response.statusCode == 201) {
        final data             = jsonDecode(response.body);
        final ai               = data['ai'] as Map<String, dynamic>;
        final detectedCategory = ai['category'] as String;
        final detectedPriority = ai['priority']  as String;

        final prioMap = {
          'critical': 'ELEVEE',
          'high':     'ELEVEE',
          'medium':   'MOYENNE',
          'low':      'FAIBLE',
        };

        setState(() {
          _aiLoading = false;
          _aiDone    = true;
          _catIndex  = _aiCatMap[detectedCategory] ?? 4;
          _priorite  = prioMap[detectedPriority]   ?? 'MOYENNE';
        });

        _snack(
          '🤖 IA: ${_categoryLabel(detectedCategory)} — ${_priorityLabel(detectedPriority)}',
          _success);
      } else {
        setState(() { _aiLoading = false; _aiDone = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _aiLoading = false; _aiDone = false; });
    }
  }

  String _categoryLabel(String cat) {
    const m = {
      'road': 'Voirie', 'waste': 'Propreté',
      'lighting': 'Éclairage', 'danger': 'Voirie',
      'infrastructure': 'Espaces', 'other': 'Autre',
    };
    return m[cat] ?? cat;
  }

  String _priorityLabel(String p) {
    const m = {
      'critical': 'Critique', 'high': 'Élevée',
      'medium': 'Moyenne',    'low':  'Faible',
    };
    return m[p] ?? p;
  }

  // ── Submit ────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_photo == null) {
      _snack('Veuillez ajouter une photo urbaine valide', _primary);
      return;
    }

    if (_aiLoading) {
      _snack('Analyse IA en cours, veuillez patienter...', _warning);
      return;
    }

    if (_priorite == null) setState(() => _priorite = 'FAIBLE');

    setState(() => _loading = true);

    try {
      final prefs   = await SharedPreferences.getInstance();
      final token   = prefs.getString('token') ?? '';
      final userRaw = prefs.getString('user') ?? '{}';
      final user    = jsonDecode(userRaw);

      String citoyenId = user['_id'] ?? user['id'] ?? '';
      if (citoyenId.isEmpty && token.isNotEmpty) {
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final norm    = base64Url.normalize(parts[1]);
            final decoded = utf8.decode(base64Url.decode(norm));
            citoyenId     = jsonDecode(decoded)['id'] ?? '';
          }
        } catch (_) {}
      }

      final request = http.MultipartRequest(
          'POST', Uri.parse(ApiConstants.createSignalement));

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['description']    = _descCtrl.text.trim();
      request.fields['localisation']   = _locLabel;
      // [FIX] Send the AI-determined priority and category from preview
      // Backend will use these directly — no second Vision API call
      request.fields['priorite']       = _priorite!;
      request.fields['categorie']      = _cats[_catIndex].id;
      request.fields['citoyen']        = citoyenId;
      request.files.add(
          await http.MultipartFile.fromPath('photo', _photo!.path));

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);

      if (!mounted) return;
      setState(() => _loading = false);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        Navigator.pop(context);
        _snack('Signalement envoyé avec succès ✓', _success);
      } else {
        final errorMsg = data['error'] ?? data['message'] ?? 'Erreur lors de l\'envoi';
        _snack(errorMsg, _primary);
      }

    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack('Erreur de connexion au serveur', _primary);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
        style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 13)),
      backgroundColor: color,
      behavior:        SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  BoxDecoration _cardBox() => BoxDecoration(
    color:        _white,
    borderRadius: BorderRadius.circular(12),
    border:       Border.all(color: _redBorder.withValues(alpha: 0.35), width: 1.2),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:          const Color(0xFFEEEEEE),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 9,  child: _gpsBar()),
                    const SizedBox(height: 6),
                    Expanded(flex: 26, child: _photoCard()),
                    const SizedBox(height: 6),
                    Expanded(flex: 14, child: _descCard()),
                    const SizedBox(height: 6),
                    Expanded(flex: 14, child: _catRow()),
                    const SizedBox(height: 6),
                    Expanded(flex: 13, child: _prioRow()),
                    const SizedBox(height: 6),
                    Expanded(flex: 9,  child: _submitBtn()),
                    const SizedBox(height: 4),
                    Expanded(flex: 4,  child: _aiHint()),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, Color(0xFFE53935)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(children: [
        Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Nouveau Signalement',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Poppins')),
              Text('Ville Intelligente — Tunisie 🇹🇳',
                style: TextStyle(fontSize: 10, color: Colors.white70, fontFamily: 'Poppins')),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
            child: const Row(children: [
              Icon(Icons.auto_awesome, size: 11, color: Colors.white),
              SizedBox(width: 4),
              Text('IA activée',
                style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
          child: Row(children: [
            const Text('🦸', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Signalez, protégez votre ville !',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins')),
              Text('Chaque signalement compte 💪',
                style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.85), fontFamily: 'Poppins')),
            ])),
          ]),
        ),
      ]),
    );
  }

  Widget _gpsBar() {
    return Container(
      decoration: _cardBox(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _lat != null ? [_success, const Color(0xFF43A047)] : [_primary, const Color(0xFFE53935)]),
            shape: BoxShape.circle),
          child: _gpsLoading
            ? const Padding(padding: EdgeInsets.all(6),
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Icon(_lat != null ? Icons.location_on : Icons.location_searching, color: Colors.white, size: 14)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_cityLabel, style: const TextStyle(fontSize: 10, color: _textSub, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
            Text(_locLabel, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: _textMain, fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _lat != null ? _success.withValues(alpha: 0.1) : const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _lat != null ? _success.withValues(alpha: 0.5) : _border)),
          child: Text(_lat != null ? '✓ GPS actif' : '⏳ Attente',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
              color: _lat != null ? _success : _textSub, fontFamily: 'Poppins')),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _getLocation,
          child: Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border)),
            child: const Icon(Icons.refresh_rounded, color: _textSub, size: 12)),
        ),
      ]),
    );
  }

  Widget _photoCard() {
    return Container(
      decoration: _cardBox(),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(children: [
                Icon(Icons.camera_alt_outlined, size: 13, color: _primary),
                SizedBox(width: 5),
                Text('Photo du problème',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textMain, fontFamily: 'Poppins')),
              ]),
              _aiLoading
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: _info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _info.withValues(alpha: 0.4))),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(width: 8, height: 8,
                        child: CircularProgressIndicator(color: _info, strokeWidth: 1.5)),
                      SizedBox(width: 4),
                      Text('Analyse IA...',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _info, fontFamily: 'Poppins')),
                    ]))
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: _photo != null ? _success.withValues(alpha: 0.1) : const Color(0xFFFDECEC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _photo != null ? _success.withValues(alpha: 0.5) : _primary.withValues(alpha: 0.4))),
                    child: Text(_photo != null ? '✓ OK' : '* Requis',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                        color: _photo != null ? _success : _primary, fontFamily: 'Poppins'))),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _pickImage(ImageSource.camera),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: _photo != null
                  ? Stack(fit: StackFit.expand, children: [
                      Image.file(_photo!, fit: BoxFit.cover),
                      if (_aiLoading)
                        Container(
                          color: Colors.black.withValues(alpha: 0.45),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              SizedBox(height: 8),
                              Text('Analyse IA en cours...',
                                style: TextStyle(color: Colors.white, fontSize: 11,
                                  fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                            ],
                          ),
                        ),
                      if (!_aiLoading)
                        Positioned(
                          bottom: 6, right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(color: _success, borderRadius: BorderRadius.circular(7)),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.check, color: Colors.white, size: 10),
                              SizedBox(width: 3),
                              Text('Photo OK',
                                style: TextStyle(fontSize: 9, color: Colors.white,
                                  fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                            ]))),
                    ])
                  : Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFDECEC), Color(0xFFFFF8F8)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: _redBorder.withValues(alpha: 0.2), width: 1.5)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: const BoxDecoration(color: _white, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt_outlined, color: _primary, size: 20)),
                          const SizedBox(height: 6),
                          const Text('Photographiez le problème',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textMain, fontFamily: 'Poppins')),
                          const SizedBox(height: 2),
                          const Text('Appuyez pour la caméra',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10, color: _textSub, fontFamily: 'Poppins')),
                        ],
                      )),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
          child: Row(children: [
            Expanded(child: _imgBtn(
              icon:  _photo != null ? Icons.refresh_rounded : Icons.camera_alt_outlined,
              label: _photo != null ? 'Reprendre' : 'Caméra',
              onTap: () => _pickImage(ImageSource.camera))),
            const SizedBox(width: 6),
            Expanded(child: _imgBtn(
              icon: Icons.photo_library_outlined, label: 'Galerie',
              onTap: () => _pickImage(ImageSource.gallery))),
          ]),
        ),
      ]),
    );
  }

  Widget _imgBtn({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFDECEC), borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _redBorder.withValues(alpha: 0.3), width: 1.2)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: _primary, size: 13),
          const SizedBox(width: 5),
          Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _primary, fontFamily: 'Poppins')),
        ]),
      ),
    );
  }

  Widget _descCard() {
    return Container(
      decoration: _cardBox(),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.edit_note_rounded, size: 14, color: _primary),
          SizedBox(width: 5),
          Text('Description',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textMain, fontFamily: 'Poppins')),
        ]),
        const SizedBox(height: 4),
        Expanded(
          child: TextFormField(
            controller: _descCtrl, maxLines: null, expands: true,
            textAlignVertical: TextAlignVertical.top, keyboardType: TextInputType.multiline,
            style: const TextStyle(fontSize: 12, color: _textMain, fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: 'Décrivez le problème...',
              hintStyle: TextStyle(color: _textSub.withValues(alpha: 0.6), fontSize: 11, fontFamily: 'Poppins'),
              filled: true, fillColor: const Color(0xFFFAFAFA),
              contentPadding: const EdgeInsets.all(8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _redBorder.withValues(alpha: 0.25), width: 1)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _redBorder.withValues(alpha: 0.25), width: 1)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _primary, width: 2)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _primary, width: 1)),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'La description est obligatoire';
              if (v.trim().length < 10)           return 'Minimum 10 caractères requis';
              if (RegExp(r'^\d+$').hasMatch(v.trim()))
                return 'La description ne peut pas être uniquement des chiffres';
              if (!RegExp(r'[a-zA-ZÀ-ÿ]{3,}').hasMatch(v.trim()))
                return 'Veuillez écrire une description réelle';
              return null;
            },
          ),
        ),
      ]),
    );
  }

  Widget _catRow() {
    return Container(
      decoration: _cardBox(),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.category_outlined, size: 13, color: _primary),
          const SizedBox(width: 5),
          const Text('Catégorie',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textMain, fontFamily: 'Poppins')),
          if (_aiDone) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: _success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Text('auto IA',
                style: TextStyle(fontSize: 8, color: _success, fontWeight: FontWeight.w700, fontFamily: 'Poppins'))),
          ],
        ]),
        const SizedBox(height: 5),
        Expanded(
          child: Row(
            children: List.generate(_cats.length, (i) {
              final cat = _cats[i];
              final sel = i == _catIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _catIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.only(right: i < _cats.length - 1 ? 4 : 0),
                    decoration: BoxDecoration(
                      gradient: sel ? const LinearGradient(
                        colors: [_primary, Color(0xFFE53935)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                      color: sel ? null : const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel ? _primary : _redBorder.withValues(alpha: 0.25),
                        width: sel ? 0 : 1),
                      boxShadow: sel ? [
                        BoxShadow(color: _primary.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))
                      ] : null),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(cat.icon, size: 15, color: sel ? Colors.white : _primary),
                      const SizedBox(height: 3),
                      FittedBox(fit: BoxFit.scaleDown,
                        child: Text(cat.label, textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins', color: sel ? Colors.white : _textMain))),
                    ]),
                  ),
                ),
              );
            }),
          ),
        ),
      ]),
    );
  }

  Widget _prioRow() {
    return Container(
      decoration: _cardBox(),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.flag_outlined, size: 13, color: _primary),
          const SizedBox(width: 5),
          const Text('Priorité',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textMain, fontFamily: 'Poppins')),
          if (_aiDone) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: _success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Text('auto IA',
                style: TextStyle(fontSize: 8, color: _success, fontWeight: FontWeight.w700, fontFamily: 'Poppins'))),
          ],
        ]),
        const SizedBox(height: 5),
        Expanded(
          child: Row(
            children: List.generate(_prios.length, (i) {
              final p   = _prios[i];
              final sel = _priorite == p.key;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _priorite = p.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.only(right: i < _prios.length - 1 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: sel ? p.bg : const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel ? p.color : _redBorder.withValues(alpha: 0.25),
                        width: sel ? 2 : 1),
                      boxShadow: sel ? [
                        BoxShadow(color: p.color.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2))
                      ] : null),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      FittedBox(fit: BoxFit.scaleDown,
                        child: Text(p.emoji,
                          style: TextStyle(fontSize: 16, color: p.color, fontWeight: FontWeight.w900))),
                      const SizedBox(height: 2),
                      FittedBox(fit: BoxFit.scaleDown,
                        child: Text(p.label,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins', color: sel ? p.color : _textMain))),
                    ]),
                  ),
                ),
              );
            }),
          ),
        ),
      ]),
    );
  }

  Widget _submitBtn() {
    final bool blocked = _loading || _aiLoading;
    return GestureDetector(
      onTap: blocked ? null : _submit,
      child: Container(
        decoration: BoxDecoration(
          gradient: blocked ? null : const LinearGradient(
            colors: [_primary, Color(0xFFE53935)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          color: blocked ? const Color(0xFFE0E0E0) : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: blocked ? [] : [
            BoxShadow(color: _primary.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Center(
          child: blocked
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(width: 14, height: 14,
                  child: CircularProgressIndicator(color: Color(0xFF9E9E9E), strokeWidth: 2)),
                const SizedBox(width: 8),
                Text(_aiLoading ? 'Analyse IA...' : 'Envoi en cours...',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: Color(0xFF9E9E9E), fontFamily: 'Poppins')),
              ])
            : const Row(mainAxisSize: MainAxisSize.min, children: [
                Text('🚀', style: TextStyle(fontSize: 15)),
                SizedBox(width: 8),
                Text('Envoyer le signalement',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: Colors.white, fontFamily: 'Poppins')),
              ]),
        ),
      ),
    );
  }

  Widget _aiHint() {
    return Container(
      decoration: BoxDecoration(
        color: _info.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _info.withValues(alpha: 0.2), width: 1)),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(children: [
        const Icon(Icons.auto_awesome, color: _info, size: 11),
        const SizedBox(width: 6),
        const Expanded(
          child: Text('🤖 T HERO IA — Signalement traité en priorité',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9, color: _info, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
        ),
      ]),
    );
  }
}