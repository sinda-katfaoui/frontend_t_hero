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
  const _Prio(this.key, this.label, this.emoji,
    this.color, this.bg);
}

const _primary   = Color(0xFFC1272D);
const _bgPage    = Color(0xFFF8F6F3);
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
  State<NewSignalementScreen> createState() =>
      _NewSignalementScreenState();
}

class _NewSignalementScreenState
    extends State<NewSignalementScreen> {

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

  static const _cats = [
    _Cat('Voirie',    Icons.warning_amber_rounded,
      '69b5f22c1a712fbb5e43b63e'),
    _Cat('Eclairage', Icons.lightbulb_outline,
      '69b5f25e1a712fbb5e43b642'),
    _Cat('Propreté',  Icons.delete_outline,
      '69b5f26e1a712fbb5e43b646'),
    _Cat('Espaces',   Icons.park_outlined,
      '69b5f27d1a712fbb5e43b64a'),
    _Cat('Autre',     Icons.help_outline,
      '69b5f28a1a712fbb5e43b64e'),
  ];

  static const _prios = [
    _Prio('FAIBLE',  'Faible',  '↓',
      Color(0xFF757575), Color(0xFFF5F5F5)),
    _Prio('MOYENNE', 'Moyenne', '→',
      _warning,          Color(0xFFFFF3E0)),
    _Prio('ELEVEE',  'Élevée',  '↑',
      _primary,          Color(0xFFFDECEC)),
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
    setState(() {
      _gpsLoading = true;
      _locLabel   = 'Localisation en cours...';
    });
    try {
      bool ok = await Geolocator.isLocationServiceEnabled();
      if (!ok) {
        setState(() {
          _locLabel   = 'GPS désactivé';
          _cityLabel  = 'Service indisponible';
          _gpsLoading = false;
        });
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          setState(() {
            _locLabel   = 'Permission refusée';
            _gpsLoading = false;
          });
          return;
        }
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() {
          _locLabel   = 'Permission refusée';
          _gpsLoading = false;
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _lat      = pos.latitude;
        _locLabel =
          '${pos.latitude.toStringAsFixed(4)}°N, '
          '${pos.longitude.toStringAsFixed(4)}°E';
        _cityLabel  = 'Position détectée';
        _gpsLoading = false;
      });
    } catch (_) {
      setState(() {
        _locLabel   = 'Erreur de localisation';
        _gpsLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource src) async {
    try {
      final p = await ImagePicker()
        .pickImage(source: src, imageQuality: 80);
      if (p != null)
        setState(() => _photo = File(p.path));
    } catch (e) {
      if (mounted) _snack('Erreur: $e', _primary);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_priorite == null) {
      _snack('Veuillez sélectionner une priorité', _primary);
      return;
    }
    if (_photo == null) {
      _snack('Veuillez ajouter une photo', _primary);
      return;
    }
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
            final payload = parts[1];
            final norm    = base64Url.normalize(payload);
            final decoded =
              utf8.decode(base64Url.decode(norm));
            final map = jsonDecode(decoded);
            citoyenId = map['id'] ?? '';
          }
        } catch (_) {}
      }
      final request = http.MultipartRequest(
        'POST', Uri.parse(ApiConstants.createSignalement));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['description']  = _descCtrl.text.trim();
      request.fields['localisation'] = _locLabel;
      request.fields['priorite']     = _priorite!;
      request.fields['categorie']    = _cats[_catIndex].id;
      request.fields['citoyen']      = citoyenId;
      request.files.add(await http.MultipartFile.fromPath(
        'photo', _photo!.path));
      final streamed = await request.send()
        .timeout(const Duration(seconds: 15));
      final response =
        await http.Response.fromStream(streamed);
      if (!mounted) return;
      setState(() => _loading = false);
      if (response.statusCode == 201) {
        Navigator.pop(context);
        _snack('Signalement envoyé avec succès', _success);
      } else {
        final data = jsonDecode(response.body);
        _snack(data['message'] ?? 'Erreur lors de l\'envoi',
          _primary);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack('Erreur de connexion', _primary);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 13)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)),
    ));
  }

  BoxDecoration _cardBox() => BoxDecoration(
    color: _white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: _redBorder.withValues(alpha: 0.45),
      width: 1.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 4,
        offset: const Offset(0, 2)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(children: [
            _appBar(),
            Expanded(
              child: LayoutBuilder(
                builder: (ctx, box) {
                  final h     = box.maxHeight;
                  final avail = h - 66;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                      12, 10, 12, 8),
                    child: Column(
                      crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                      children: [

                        // 1. GPS — 8%
                        SizedBox(
                          height: avail * 0.08,
                          child: _gpsBar()),
                        const SizedBox(height: 8),

                        // 2. Photo — 29%
                        SizedBox(
                          height: avail * 0.29,
                          child: _photoCard()),
                        const SizedBox(height: 8),

                        // 3. Description — 12%
                        SizedBox(
                          height: avail * 0.12,
                          child: _descCard()),
                        const SizedBox(height: 8),

                        // 4. Categories — 15%
                        SizedBox(
                          height: avail * 0.15,
                          child: _catRow()),
                        const SizedBox(height: 8),

                        // 5. Priority — 14%
                        SizedBox(
                          height: avail * 0.14,
                          child: _prioRow()),
                        const SizedBox(height: 8),

                        // 6. Submit — 8%
                        SizedBox(
                          height: avail * 0.08,
                          child: _submitBtn()),
                        const SizedBox(height: 8),

                        // 7. AI hint — remaining
                        Expanded(child: _aiHint()),
                      ],
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────
  Widget _appBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 16, 11),
      decoration: const BoxDecoration(
        color: _white,
        border: Border(
          bottom: BorderSide(color: _primary, width: 2))),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border, width: 1)),
            child: const Icon(Icons.arrow_back_ios_new,
              size: 13, color: _textMain),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nouveau Signalement',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                  fontFamily: 'Poppins',
                  letterSpacing: -0.3,
                )),
              Text('Ville Intelligente — Tunisie',
                style: TextStyle(
                  fontSize: 10,
                  color: _textSub,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                )),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFDECEC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _primary.withValues(alpha: 0.4))),
          child: const Row(children: [
            Icon(Icons.auto_awesome,
              size: 11, color: _primary),
            SizedBox(width: 4),
            Text('IA activée',
              style: TextStyle(
                fontSize: 10,
                color: _primary,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              )),
          ]),
        ),
      ]),
    );
  }

  // ── 1. GPS ─────────────────────────────────────────────
  Widget _gpsBar() {
    return Container(
      decoration: _cardBox(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: _lat != null ? _success : _primary,
            shape: BoxShape.circle),
          child: _gpsLoading
            ? const Padding(
                padding: EdgeInsets.all(6),
                child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
            : Icon(
                _lat != null
                  ? Icons.location_on
                  : Icons.location_searching,
                color: Colors.white, size: 14)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_cityLabel,
                style: const TextStyle(
                  fontSize: 10,
                  color: _textSub,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                )),
              Text(_locLabel,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: _textMain,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                )),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _lat != null
              ? _success.withValues(alpha: 0.1)
              : const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _lat != null
                ? _success.withValues(alpha: 0.5)
                : _border)),
          child: Text(
            _lat != null ? '✓ GPS actif' : '⏳ Attente',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: _lat != null ? _success : _textSub,
              fontFamily: 'Poppins',
            )),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _getLocation,
          child: Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border)),
            child: const Icon(Icons.refresh_rounded,
              color: _textSub, size: 12)),
        ),
      ]),
    );
  }

  // ── 2. Photo ───────────────────────────────────────────
  Widget _photoCard() {
    return Container(
      decoration: _cardBox(),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Photo du problème',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textMain,
                  fontFamily: 'Poppins',
                )),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _photo != null
                    ? _success.withValues(alpha: 0.1)
                    : const Color(0xFFFDECEC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _photo != null
                      ? _success.withValues(alpha: 0.5)
                      : _primary.withValues(alpha: 0.4))),
                child: Text(
                  _photo != null
                    ? '✓ Photo ajoutée' : 'Obligatoire',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _photo != null
                      ? _success : _primary,
                    fontFamily: 'Poppins',
                  ))),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _pickImage(ImageSource.camera),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _photo != null
                  ? Stack(fit: StackFit.expand, children: [
                      Image.file(_photo!, fit: BoxFit.cover),
                      Positioned(
                        bottom: 7, right: 7,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _success,
                            borderRadius:
                              BorderRadius.circular(7)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check,
                                color: Colors.white,
                                size: 11),
                              SizedBox(width: 4),
                              Text('Photo OK',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins')),
                            ]))),
                    ])
                  : Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius:
                          BorderRadius.circular(10),
                        border: Border.all(
                          color: _redBorder
                            .withValues(alpha: 0.25),
                          width: 1.5)),
                      child: Column(
                        mainAxisAlignment:
                          MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 46, height: 46,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFDECEC),
                              shape: BoxShape.circle),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: _primary, size: 22)),
                          const SizedBox(height: 8),
                          const Text(
                            'Photographiez le problème',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _textMain,
                              fontFamily: 'Poppins',
                            )),
                          const SizedBox(height: 3),
                          const Text(
                            'Appuyez pour ouvrir la caméra',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: _textSub,
                              fontFamily: 'Poppins',
                            )),
                        ],
                      )),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(7, 0, 7, 7),
          child: Row(children: [
            Expanded(child: _imgBtn(
              icon: _photo != null
                ? Icons.refresh_rounded
                : Icons.camera_alt_outlined,
              label: _photo != null
                ? 'Reprendre' : 'Caméra',
              onTap: () =>
                _pickImage(ImageSource.camera))),
            const SizedBox(width: 6),
            Expanded(child: _imgBtn(
              icon: Icons.photo_library_outlined,
              label: 'Galerie',
              onTap: () =>
                _pickImage(ImageSource.gallery))),
          ]),
        ),
      ]),
    );
  }

  Widget _imgBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _redBorder.withValues(alpha: 0.35),
            width: 1.2)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _primary, size: 13),
            const SizedBox(width: 5),
            Text(label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _textMain,
                fontFamily: 'Poppins',
              )),
          ],
        ),
      ),
    );
  }

  // ── 3. Description ─────────────────────────────────────
  Widget _descCard() {
    return Container(
      decoration: _cardBox(),
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Description',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textMain,
              fontFamily: 'Poppins',
            )),
          const SizedBox(height: 4),
          Expanded(
            child: TextFormField(
              controller: _descCtrl,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(
                fontSize: 12,
                color: _textMain,
                fontFamily: 'Poppins'),
              decoration: InputDecoration(
                hintText:
                  'Décrivez le problème observé...',
                hintStyle: const TextStyle(
                  color: Color(0xFFBBBBBB),
                  fontSize: 11,
                  fontFamily: 'Poppins'),
                filled: true,
                fillColor: const Color(0xFFFAFAFA),
                contentPadding: const EdgeInsets.all(9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _redBorder
                      .withValues(alpha: 0.3),
                    width: 1)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _redBorder
                      .withValues(alpha: 0.3),
                    width: 1)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: _primary, width: 1.8)),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: _primary, width: 1)),
              ),
              validator: (v) =>
                v == null || v.trim().isEmpty
                  ? 'Champ requis' : null,
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Categories — bigger height, clear labels ─────────
  Widget _catRow() {
    return Container(
      decoration: _cardBox(),
      padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Catégorie',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textMain,
              fontFamily: 'Poppins',
            )),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              children: List.generate(_cats.length, (i) {
                final cat = _cats[i];
                final sel = i == _catIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                      setState(() => _catIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 150),
                      margin: EdgeInsets.only(
                        right: i < _cats.length - 1
                          ? 5 : 0),
                      decoration: BoxDecoration(
                        color: sel
                          ? _primary
                          : const Color(0xFFF7F7F7),
                        borderRadius:
                          BorderRadius.circular(8),
                        border: Border.all(
                          color: sel
                            ? _primary
                            : _redBorder.withValues(
                                alpha: 0.3),
                          width: sel ? 1.5 : 1)),
                      child: Column(
                        mainAxisAlignment:
                          MainAxisAlignment.center,
                        children: [
                          Icon(cat.icon,
                            size: 18,
                            color: sel
                              ? Colors.white
                              : _primary),
                          const SizedBox(height: 4),
                          Text(cat.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                              color: sel
                                ? Colors.white
                                : _textMain,
                            )),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. Priority ────────────────────────────────────────
  Widget _prioRow() {
    return Container(
      decoration: _cardBox(),
      padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Priorité',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textMain,
              fontFamily: 'Poppins',
            )),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              children: List.generate(_prios.length, (i) {
                final p   = _prios[i];
                final sel = _priorite == p.key;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                      setState(() => _priorite = p.key),
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 150),
                      margin: EdgeInsets.only(
                        right: i < _prios.length - 1
                          ? 6 : 0),
                      decoration: BoxDecoration(
                        color: sel
                          ? p.bg
                          : const Color(0xFFF7F7F7),
                        borderRadius:
                          BorderRadius.circular(8),
                        border: Border.all(
                          color: sel
                            ? p.color
                            : _redBorder.withValues(
                                alpha: 0.3),
                          width: sel ? 1.8 : 1)),
                      child: Column(
                        mainAxisAlignment:
                          MainAxisAlignment.center,
                        children: [
                          Text(p.emoji,
                            style: TextStyle(
                              fontSize: 18,
                              color: p.color,
                              fontWeight:
                                FontWeight.w900)),
                          const SizedBox(height: 3),
                          Text(p.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                              color: sel
                                ? p.color : _textMain,
                            )),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── 6. Submit — compact ────────────────────────────────
  Widget _submitBtn() {
    return GestureDetector(
      onTap: _loading ? null : _submit,
      child: Container(
        decoration: BoxDecoration(
          color: _loading
            ? const Color(0xFFE0E0E0) : _primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: _loading
            ? []
            : [
                BoxShadow(
                  color: _primary
                    .withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3)),
              ],
        ),
        child: Center(
          child: _loading
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14, height: 14,
                    child: CircularProgressIndicator(
                      color: Color(0xFF9E9E9E),
                      strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('Envoi...',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9E9E9E),
                      fontFamily: 'Poppins',
                    )),
                ])
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.send_rounded,
                    color: Colors.white, size: 15),
                  SizedBox(width: 7),
                  Text('Envoyer le signalement',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    )),
                ]),
        ),
      ),
    );
  }

  // ── 7. AI Hint — minimal ───────────────────────────────
  Widget _aiHint() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _info.withValues(alpha: 0.25),
          width: 1)),
      padding: const EdgeInsets.symmetric(
        horizontal: 10, vertical: 4),
      child: Row(children: [
        const Icon(Icons.auto_awesome,
          color: _info, size: 11),
        const SizedBox(width: 6),
        const Expanded(
          child: Text(
            'L\'IA T HERO accélèrera la prise en charge '
            'de votre signalement.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              color: _info,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            )),
        ),
      ]),
    );
  }
}