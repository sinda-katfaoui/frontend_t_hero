import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';
import 'package:frontend_t_hero/utils/constants/api_constant.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});
  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // ── GET all categories ─────────────────────────────────────
  Future<void> _fetchCategories() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http
          .get(
            Uri.parse(ApiConstants.getAllCategories),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List;
        setState(() {
          _categories = list.map((e) => e as Map<String, dynamic>).toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  // ── POST create category ───────────────────────────────────
  Future<void> _createCategory(String nom, String desc) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/categories/CreateCategorie'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'nom': nom, 'description': desc}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        _showSnack('Catégorie ajoutée ✓', TColors.success);
        await _fetchCategories();
      } else {
        final data = jsonDecode(response.body);
        _showSnack(data['message'] ?? 'Erreur création', TColors.error);
      }
    } catch (e) {
      _showSnack('Erreur serveur', TColors.error);
    }
  }

  // ── PUT update category ────────────────────────────────────
  Future<void> _updateCategory(String id, String nom, String desc) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http
          .put(
            Uri.parse('${ApiConstants.baseUrl}/categories/UpdateCategorie/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'nom': nom, 'description': desc}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _showSnack('Catégorie modifiée ✓', TColors.success);
        await _fetchCategories();
      } else {
        final data = jsonDecode(response.body);
        _showSnack(data['message'] ?? 'Erreur modification', TColors.error);
      }
    } catch (e) {
      _showSnack('Erreur serveur', TColors.error);
    }
  }

  // ── DELETE category ────────────────────────────────────────
  Future<void> _deleteCategory(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http
          .delete(
            Uri.parse('${ApiConstants.baseUrl}/categories/DeleteCategorie/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _showSnack('Catégorie supprimée', TColors.success);
        await _fetchCategories();
      } else {
        final data = jsonDecode(response.body);
        _showSnack(data['message'] ?? 'Erreur suppression', TColors.error);
      }
    } catch (e) {
      _showSnack('Erreur serveur', TColors.error);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Add dialog ─────────────────────────────────────────────
  void _showAddDialog() {
    final nomCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Nouvelle catégorie',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(
              controller: nomCtrl,
              hint: 'Nom de la catégorie',
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 12),
            _dialogField(
              controller: descCtrl,
              hint: 'Description',
              icon: Icons.description_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(
                fontSize: 14,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nomCtrl.text.isNotEmpty) {
                Navigator.pop(context);
                _createCategory(nomCtrl.text.trim(), descCtrl.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Ajouter',
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Edit dialog ────────────────────────────────────────────
  void _showEditDialog(Map<String, dynamic> cat) {
    final nomCtrl = TextEditingController(text: cat['nom'] ?? '');
    final descCtrl = TextEditingController(text: cat['description'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Modifier catégorie',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(
              controller: nomCtrl,
              hint: 'Nom de la catégorie',
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 12),
            _dialogField(
              controller: descCtrl,
              hint: 'Description',
              icon: Icons.description_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(
                fontSize: 14,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nomCtrl.text.isNotEmpty) {
                Navigator.pop(context);
                _updateCategory(
                  cat['_id'],
                  nomCtrl.text.trim(),
                  descCtrl.text.trim(),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Enregistrer',
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Delete dialog ──────────────────────────────────────────
  void _showDeleteDialog(Map<String, dynamic> cat) {
    final name = cat['nom'] ?? '';
    // We can't know signalement count from category alone
    // Backend will reject if signalements exist

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Supprimer catégorie',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: TColors.textSecondary,
              fontFamily: 'Poppins',
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'Supprimer '),
              TextSpan(
                text: '"$name"',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: TColors.textPrimary,
                ),
              ),
              const TextSpan(text: ' ? Cette action est irréversible.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(
                fontSize: 14,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(cat['_id']);
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ────────────────────────────────────────
          Container(
            color: isDark ? TColors.cardDark : TColors.cardLight,
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Catégories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TColors.textPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      '${_categories.length} catégories',
                      style: const TextStyle(
                        fontSize: 12,
                        color: TColors.textHint,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Refresh
                    GestureDetector(
                      onTap: _fetchCategories,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: TColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.refresh,
                          color: TColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Add button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showAddDialog,
                        borderRadius: BorderRadius.circular(12),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: TColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.add, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Ajouter',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Category List ─────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: TColors.primary),
                  )
                : _categories.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune catégorie',
                      style: TextStyle(
                        fontSize: 15,
                        color: TColors.textHint,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchCategories,
                    color: TColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (_, i) =>
                          _categoryCard(_categories[i], isDark),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard(Map<String, dynamic> cat, bool isDark) {
    final nom = cat['nom'] ?? '';
    final desc = cat['description'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Icon box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: TColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.category_outlined,
              color: TColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Name + desc
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? TColors.textWhite : TColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc.isEmpty ? 'Aucune description' : desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TColors.textHint,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),

          // Edit + Delete
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showEditDialog(cat),
                  borderRadius: BorderRadius.circular(10),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: TColors.infoLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(9),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: TColors.info,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showDeleteDialog(cat),
                  borderRadius: BorderRadius.circular(10),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: TColors.errorLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(9),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: TColors.error,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.light,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: TColors.textHint),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                fontSize: 14,
                color: TColors.textPrimary,
                fontFamily: 'Poppins',
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: TColors.textHint,
                  fontFamily: 'Poppins',
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
