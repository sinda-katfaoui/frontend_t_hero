// ============================================================
// AdminCategoriesScreen — Category Management for Admin
// ============================================================
// Displays and manages all signalement categories.
// Embedded in AdminHomeScreen's IndexedStack at tab index 3.
//
// Features:
//   - View all categories with description + signalement count
//   - Add new category via dialog
//   - Edit existing category name/description via dialog
//   - Delete category — blocked if it has linked signalements
//
// Design decisions:
// - White card header with title + "Ajouter" button
// - Each category card: icon box + name + desc + count badge
// - Edit (blue) and delete (red) icon buttons on each card
// - Delete dialog shows warning if category has signalements
// - Count badge shows how many signalements use this category
// - No scrolling for 5 items — fits on screen perfectly
//
// TODO: Connect to real API:
//   - GET /categories/GetAllCategories
//   - POST /categories/CreateCategorie
//   - PUT /categories/UpdateCategorie/:id
//   - DELETE /categories/DeleteCategorie/:id
//     (backend already blocks delete if signalements exist)
// ============================================================

import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() =>
      _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState
    extends State<AdminCategoriesScreen> {

  // Mock categories — replace with API response
  // count = number of signalements using this category
  final List<Map<String, String>> _categories = [
    {
      'nom':   'Voirie',
      'desc':  'Routes et trottoirs',
      'count': '1',
    },
    {
      'nom':   'Eclairage',
      'desc':  'Lampadaires publics',
      'count': '1',
    },
    {
      'nom':   'Propreté',
      'desc':  'Déchets et nettoyage',
      'count': '1',
    },
    {
      'nom':   'Espaces Verts',
      'desc':  'Parcs et jardins',
      'count': '1',
    },
    {
      'nom':   'Autre',
      'desc':  'Divers',
      'count': '0',
    },
  ];

  // ── Add Dialog ─────────────────────────────────────────────
  // Opens a dialog to create a new category.
  // Adds to local list on confirm.
  // TODO: Call POST /categories/CreateCategorie
  void _showAddDialog() {
    final nomCtrl  = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle catégorie',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(
              controller: nomCtrl,
              hint: 'Nom de la catégorie',
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 10),
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
            child: const Text('Annuler',
              style: TextStyle(
                color: TColors.textHint,
                fontFamily: 'Poppins',
              )),
          ),
          ElevatedButton(
            onPressed: () {
              if (nomCtrl.text.isNotEmpty) {
                setState(() => _categories.add({
                  'nom':   nomCtrl.text,
                  'desc':  descCtrl.text,
                  'count': '0',
                }));
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Ajouter',
              style: TextStyle(
                fontSize: 11, fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  // ── Edit Dialog ────────────────────────────────────────────
  // Opens a dialog pre-filled with existing category data.
  // Updates local list on confirm.
  // TODO: Call PUT /categories/UpdateCategorie/:id
  void _showEditDialog(int index) {
    final nomCtrl  = TextEditingController(
      text: _categories[index]['nom']);
    final descCtrl = TextEditingController(
      text: _categories[index]['desc']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier catégorie',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(
              controller: nomCtrl,
              hint: 'Nom de la catégorie',
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 10),
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
            child: const Text('Annuler',
              style: TextStyle(
                color: TColors.textHint,
                fontFamily: 'Poppins',
              )),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _categories[index] = {
                  'nom':   nomCtrl.text,
                  'desc':  descCtrl.text,
                  // Preserve existing count — not changed on edit
                  'count': _categories[index]['count']!,
                };
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Enregistrer',
              style: TextStyle(
                fontSize: 11, fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  // ── Delete Dialog ──────────────────────────────────────────
  // Shows warning if category has linked signalements.
  // Only shows delete button if count is 0 — safe to delete.
  // TODO: Call DELETE /categories/DeleteCategorie/:id
  void _showDeleteDialog(int index) {
    final count = int.parse(_categories[index]['count']!);
    final name  = _categories[index]['nom']!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer catégorie',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          )),
        content: count > 0
          // Warning — cannot delete if signalements are linked
          ? RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  color: TColors.textSecondary,
                  fontFamily: 'Poppins',
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text: 'Impossible de supprimer '),
                  TextSpan(
                    text: '"$name"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: TColors.textPrimary,
                    )),
                  TextSpan(
                    text: ' car elle contient '
                      '$count signalement(s) liés.'),
                ],
              ),
            )
          // Confirmation — safe to delete
          : RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  color: TColors.textSecondary,
                  fontFamily: 'Poppins',
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text: 'Voulez-vous vraiment supprimer '),
                  TextSpan(
                    text: '"$name"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: TColors.textPrimary,
                    )),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
              style: TextStyle(
                color: TColors.textHint,
                fontFamily: 'Poppins',
              )),
          ),
          // Delete button only shown when no linked signalements
          if (count == 0)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () {
                setState(() => _categories.removeAt(index));
                Navigator.pop(context);
              },
              child: const Text('Supprimer',
                style: TextStyle(
                  fontSize: 11, fontFamily: 'Poppins')),
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

          // ── Header ──────────────────────────────────────
          // White card with title + add button
          Container(
            color: isDark ? TColors.cardDark : TColors.cardLight,
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Catégories',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
                // Add category button
                GestureDetector(
                  onTap: _showAddDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: TColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(children: [
                      Icon(Icons.add,
                        color: Colors.white, size: 13),
                      SizedBox(width: 4),
                      Text('Ajouter',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        )),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // ── Category Cards List ───────────────────────────
          // 5 categories fit on screen without scrolling.
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _categories.length,
              itemBuilder: (context, i) =>
                _categoryCard(_categories[i], i, isDark),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category Card ──────────────────────────────────────────
  // White card with:
  // - Red tinted icon box (category icon)
  // - Category name + description + signalement count
  // - Edit (blue) and delete (red) icon buttons
  Widget _categoryCard(
      Map<String, String> c, int index, bool isDark) {
    final count = int.parse(c['count']!);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10, vertical: 8),
      child: Row(children: [

        // Category icon box — red tint
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: TColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.category_outlined,
            color: TColors.primary, size: 17),
        ),

        const SizedBox(width: 10),

        // Name + description + count
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(c['nom']!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                      ? TColors.textWhite : TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
                const SizedBox(width: 6),
                // Signalement count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    // Red if has signalements, gray if empty
                    color: count > 0
                      ? TColors.primaryLight
                      : (isDark
                          ? TColors.darkContainer
                          : TColors.lightContainer),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$count',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: count > 0
                        ? TColors.primary : TColors.textHint,
                      fontFamily: 'Poppins',
                    )),
                ),
              ]),
              const SizedBox(height: 2),
              Text(c['desc']!,
                style: const TextStyle(
                  fontSize: 9,
                  color: TColors.textHint,
                  fontFamily: 'Poppins',
                )),
            ],
          ),
        ),

        // Edit + Delete action buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit button — blue icon
            GestureDetector(
              onTap: () => _showEditDialog(index),
              child: Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: TColors.infoLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 14, color: TColors.info),
              ),
            ),
            const SizedBox(width: 6),
            // Delete button — red icon
            // Grayed out if category has signalements
            GestureDetector(
              onTap: () => _showDeleteDialog(index),
              child: Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: count > 0
                    ? TColors.lightContainer
                    : TColors.errorLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 14,
                  // Grayed out when deletion is blocked
                  color: count > 0
                    ? TColors.textHint : TColors.error),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  // ── Dialog Input Field ─────────────────────────────────────
  // Reusable compact text field for add/edit dialogs.
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
      padding: const EdgeInsets.symmetric(
        horizontal: 12, vertical: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: TColors.textHint),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(
              fontSize: 11,
              color: TColors.textPrimary,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 11,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ]),
    );
  }
}