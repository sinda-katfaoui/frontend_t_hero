import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';
import 'package:frontend_t_hero/utils/constants/api_constant.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});
  @override
  State<AdminCategoriesScreen> createState() =>
      _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState
    extends State<AdminCategoriesScreen> {

  List<Map<String, dynamic>> _categories = [];
  bool _loading = true;

  // Category icons mapped by name
  IconData _catIcon(String nom) {
    final n = nom.toLowerCase();
    if (n.contains('voirie'))    return Icons.warning_amber_rounded;
    if (n.contains('eclairage') ||
        n.contains('éclairage')) return Icons.lightbulb_outline;
    if (n.contains('propret'))   return Icons.delete_outline;
    if (n.contains('espaces') ||
        n.contains('vert'))      return Icons.park_outlined;
    return Icons.category_outlined;
  }

  // Category colors by index
  final List<Color> _catColors = [
    TColors.primary,
    TColors.info,
    TColors.success,
    TColors.warning,
    const Color(0xFF6366F1),
  ];

  final List<Color> _catBgs = [
    TColors.primaryLight,
    TColors.infoLight,
    TColors.successLight,
    TColors.warningLight,
    const Color(0xFFEDE9FE),
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.get(
        Uri.parse(ApiConstants.getAllCategories),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _categories = (data['data'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _createCategory(String nom, String desc) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.post(
        Uri.parse(
          '${ApiConstants.baseUrl}/categories/CreateCategorie'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'nom': nom, 'description': desc}),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 201) {
        _snack('Catégorie ajoutée ✓', TColors.success);
        await _fetchCategories();
      } else {
        final data = jsonDecode(response.body);
        _snack(data['message'] ?? 'Erreur', TColors.error);
      }
    } catch (_) {
      _snack('Erreur serveur', TColors.error);
    }
  }

  Future<void> _updateCategory(String id, String nom,
      String desc) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.put(
        Uri.parse(
          '${ApiConstants.baseUrl}/categories'
          '/UpdateCategorie/$id'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'nom': nom, 'description': desc}),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        _snack('Catégorie modifiée ✓', TColors.success);
        await _fetchCategories();
      } else {
        final data = jsonDecode(response.body);
        _snack(data['message'] ?? 'Erreur', TColors.error);
      }
    } catch (_) {
      _snack('Erreur serveur', TColors.error);
    }
  }

  Future<void> _deleteCategory(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.delete(
        Uri.parse(
          '${ApiConstants.baseUrl}/categories'
          '/DeleteCategorie/$id'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        _snack('Catégorie supprimée', TColors.success);
        await _fetchCategories();
      } else {
        final data = jsonDecode(response.body);
        _snack(data['message'] ?? 'Erreur', TColors.error);
      }
    } catch (_) {
      _snack('Erreur serveur', TColors.error);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
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

  void _showAddDialog() {
    final nomCtrl  = TextEditingController();
    final descCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28))),
        padding: EdgeInsets.fromLTRB(
          20, 12, 20,
          MediaQuery.of(context).viewInsets.bottom + 24),
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
            const Row(children: [
              Text('🏷️ ', style: TextStyle(fontSize: 18)),
              Text('Nouvelle catégorie',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TColors.textPrimary,
                  fontFamily: 'Poppins',
                )),
            ]),
            const SizedBox(height: 6),
            const Text(
              'Ajoutez une nouvelle catégorie de signalement',
              style: TextStyle(
                fontSize: 13,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              )),
            const SizedBox(height: 20),
            _sheetField(
              controller: nomCtrl,
              hint: 'Nom de la catégorie',
              icon: Icons.category_outlined),
            const SizedBox(height: 10),
            _sheetField(
              controller: descCtrl,
              hint: 'Description (optionnel)',
              icon: Icons.description_outlined),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (nomCtrl.text.trim().isNotEmpty) {
                    Navigator.pop(context);
                    _createCategory(
                      nomCtrl.text.trim(),
                      descCtrl.text.trim());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                      BorderRadius.circular(16)),
                  elevation: 0),
                child: const Text('Ajouter',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ))),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> cat) {
    final nomCtrl  =
      TextEditingController(text: cat['nom'] ?? '');
    final descCtrl =
      TextEditingController(
        text: cat['description'] ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28))),
        padding: EdgeInsets.fromLTRB(
          20, 12, 20,
          MediaQuery.of(context).viewInsets.bottom + 24),
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
            const Row(children: [
              Text('✏️ ', style: TextStyle(fontSize: 18)),
              Text('Modifier catégorie',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TColors.textPrimary,
                  fontFamily: 'Poppins',
                )),
            ]),
            const SizedBox(height: 20),
            _sheetField(
              controller: nomCtrl,
              hint: 'Nom de la catégorie',
              icon: Icons.category_outlined),
            const SizedBox(height: 10),
            _sheetField(
              controller: descCtrl,
              hint: 'Description',
              icon: Icons.description_outlined),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (nomCtrl.text.trim().isNotEmpty) {
                    Navigator.pop(context);
                    _updateCategory(
                      cat['_id'],
                      nomCtrl.text.trim(),
                      descCtrl.text.trim());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                      BorderRadius.circular(16)),
                  elevation: 0),
                child: const Text('Enregistrer',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ))),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> cat) {
    final name = cat['nom'] ?? '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer catégorie',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          )),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: TColors.textSecondary,
              fontFamily: 'Poppins',
              height: 1.5),
            children: [
              const TextSpan(text: 'Supprimer '),
              TextSpan(
                text: '"$name"',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: TColors.textPrimary)),
              const TextSpan(
                text: ' ? Action irréversible. '
                'Impossible si des signalements '
                'sont liés.'),
            ])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
              style: TextStyle(
                fontSize: 14,
                color: TColors.textHint,
                fontFamily: 'Poppins'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
              elevation: 0),
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(cat['_id']);
            },
            child: const Text('Supprimer',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins'))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
      Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── Gradient Header ──────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TColors.primary,
                  Color(0xFFE53935)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              16, 16, 16, 20),
            child: Column(children: [

              Row(
                mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment:
                      CrossAxisAlignment.start,
                    children: [
                      const Text('🏷️ Catégories',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        )),
                      Text(
                        '${_categories.length} catégorie(s)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontFamily: 'Poppins',
                        )),
                    ],
                  ),
                  Row(children: [
                    GestureDetector(
                      onTap: _fetchCategories,
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white
                            .withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white
                              .withValues(alpha: 0.3))),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 17)),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showAddDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                            BorderRadius.circular(20)),
                        child: const Row(children: [
                          Icon(Icons.add,
                            color: TColors.primary,
                            size: 16),
                          SizedBox(width: 5),
                          Text('Ajouter',
                            style: TextStyle(
                              fontSize: 13,
                              color: TColors.primary,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            )),
                        ]),
                      ),
                    ),
                  ]),
                ],
              ),

              const SizedBox(height: 14),

              // Info strip
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white
                    .withValues(alpha: 0.15),
                  borderRadius:
                    BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white
                      .withValues(alpha: 0.2))),
                child: Row(children: [
                  const Text('📋',
                    style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                        CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gérez les catégories',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          )),
                        Text(
                          'Les citoyens choisissent une '
                          'catégorie lors du signalement',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white
                              .withValues(alpha: 0.85),
                            fontFamily: 'Poppins',
                          )),
                      ],
                    ),
                  ),
                ]),
              ),
            ]),
          ),

          const SizedBox(height: 8),

          // ── List ─────────────────────────────────────────
          Expanded(
            child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: TColors.primary))
              : _categories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment:
                        MainAxisAlignment.center,
                      children: [
                        const Text('🏷️',
                          style: TextStyle(
                            fontSize: 48)),
                        const SizedBox(height: 12),
                        const Text('Aucune catégorie',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: TColors.textPrimary,
                            fontFamily: 'Poppins',
                          )),
                        const SizedBox(height: 6),
                        const Text(
                          'Ajoutez une catégorie pour commencer',
                          style: TextStyle(
                            fontSize: 13,
                            color: TColors.textHint,
                            fontFamily: 'Poppins',
                          )),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _showAddDialog,
                          child: Container(
                            padding:
                              const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  TColors.primary,
                                  Color(0xFFE53935)]),
                              borderRadius:
                                BorderRadius.circular(14)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add,
                                  color: Colors.white,
                                  size: 16),
                                SizedBox(width: 6),
                                Text('Ajouter une catégorie',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                      FontWeight.w700,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ))
                : RefreshIndicator(
                    onRefresh: _fetchCategories,
                    color: TColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                      itemCount: _categories.length,
                      itemBuilder: (_, i) =>
                        _categoryCard(
                          _categories[i], i, isDark),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard(Map<String, dynamic> cat,
      int index, bool isDark) {
    final nom  = cat['nom'] ?? '';
    final desc = cat['description'] ?? '';
    final color = _catColors[index % _catColors.length];
    final bg    = _catBgs[index % _catBgs.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TColors.borderLight, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment:
            CrossAxisAlignment.stretch,
          children: [

            // Color accent bar
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16))),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
                child: Row(children: [

                  // Icon box
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius:
                        BorderRadius.circular(13)),
                    child: Icon(
                      _catIcon(nom),
                      color: color, size: 22)),

                  const SizedBox(width: 12),

                  // Name + desc
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                        CrossAxisAlignment.start,
                      mainAxisAlignment:
                        MainAxisAlignment.center,
                      children: [
                        Text(nom,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark
                              ? TColors.textWhite
                              : TColors.textPrimary,
                            fontFamily: 'Poppins',
                          )),
                        if (desc.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(desc,
                            style: const TextStyle(
                              fontSize: 12,
                              color: TColors.textHint,
                              fontFamily: 'Poppins',
                            )),
                        ],
                        const SizedBox(height: 6),
                        Container(
                          padding:
                            const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius:
                              BorderRadius.circular(20)),
                          child: Text(
                            'Catégorie active',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: color,
                              fontFamily: 'Poppins',
                            )),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Actions
                  Column(
                    mainAxisAlignment:
                      MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () =>
                          _showEditDialog(cat),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: TColors.infoLight,
                            borderRadius:
                              BorderRadius.circular(10)),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 17,
                            color: TColors.info)),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () =>
                          _showDeleteDialog(cat),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: TColors.errorLight,
                            borderRadius:
                              BorderRadius.circular(10)),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 17,
                            color: TColors.error)),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.light,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TColors.borderLight, width: 0.5)),
      padding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 4),
      child: Row(children: [
        Icon(icon, size: 20, color: TColors.textHint),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(
              fontSize: 14,
              color: TColors.textPrimary,
              fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: TColors.textHint,
                fontFamily: 'Poppins'),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12)),
          ),
        ),
      ]),
    );
  }
}