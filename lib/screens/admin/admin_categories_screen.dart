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

  final List<Map<String, String>> _categories = [
    {'nom': 'Voirie', 'desc': 'Routes et trottoirs', 'count': '1'},
    {'nom': 'Eclairage', 'desc': 'Lampadaires publics', 'count': '1'},
    {'nom': 'Propreté', 'desc': 'Déchets et nettoyage', 'count': '1'},
    {'nom': 'Espaces Verts', 'desc': 'Parcs et jardins', 'count': '1'},
    {'nom': 'Autre', 'desc': 'Divers', 'count': '0'},
  ];

  void _showAddDialog() {
    final nomCtrl  = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
        title: const Text('Nouvelle catégorie',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(
              controller: nomCtrl,
              hint: 'Nom de la catégorie',
              icon: Icons.category_outlined),
            const SizedBox(height: 12),
            _dialogField(
              controller: descCtrl,
              hint: 'Description',
              icon: Icons.description_outlined),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
              style: TextStyle(
                fontSize: 14,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              ))),
          ElevatedButton(
            onPressed: () {
              if (nomCtrl.text.isNotEmpty) {
                setState(() => _categories.add({
                  'nom': nomCtrl.text,
                  'desc': descCtrl.text,
                  'count': '0',
                }));
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Ajouter',
              style: TextStyle(
                fontSize: 14, fontFamily: 'Poppins'))),
        ],
      ),
    );
  }

  void _showEditDialog(int index) {
    final nomCtrl  = TextEditingController(
      text: _categories[index]['nom']);
    final descCtrl = TextEditingController(
      text: _categories[index]['desc']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
        title: const Text('Modifier catégorie',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(
              controller: nomCtrl,
              hint: 'Nom de la catégorie',
              icon: Icons.category_outlined),
            const SizedBox(height: 12),
            _dialogField(
              controller: descCtrl,
              hint: 'Description',
              icon: Icons.description_outlined),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
              style: TextStyle(
                fontSize: 14,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              ))),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _categories[index] = {
                  'nom': nomCtrl.text,
                  'desc': descCtrl.text,
                  'count': _categories[index]['count']!,
                };
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Enregistrer',
              style: TextStyle(
                fontSize: 14, fontFamily: 'Poppins'))),
        ],
      ),
    );
  }

  void _showDeleteDialog(int index) {
    final count = int.parse(_categories[index]['count']!);
    final name  = _categories[index]['nom']!;

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
        content: count > 0
          ? RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: TColors.textSecondary,
                  fontFamily: 'Poppins',
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Impossible de supprimer '),
                  TextSpan(text: '"$name"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: TColors.textPrimary)),
                  TextSpan(text:
                    ' car elle contient $count signalement(s).'),
                ],
              ))
          : RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: TColors.textSecondary,
                  fontFamily: 'Poppins',
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text: 'Voulez-vous supprimer '),
                  TextSpan(text: '"$name"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: TColors.textPrimary)),
                  const TextSpan(text: ' ?'),
                ],
              )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
              style: TextStyle(
                fontSize: 14,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              ))),
          if (count == 0)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                setState(() => _categories.removeAt(index));
                Navigator.pop(context);
              },
              child: const Text('Supprimer',
                style: TextStyle(
                  fontSize: 14, fontFamily: 'Poppins'))),
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
                const Text('Catégories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
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
                          horizontal: 14, vertical: 8),
                        child: Row(children: [
                          Icon(Icons.add,
                            color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text('Ajouter',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            )),
                        ]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Category List ─────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (_, i) =>
                _categoryCard(_categories[i], i, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard(
      Map<String, String> c, int index, bool isDark) {
    final count = int.parse(c['count']!);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 12),
      child: Row(children: [
        // Icon box
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: TColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.category_outlined,
            color: TColors.primary, size: 22)),
        const SizedBox(width: 12),
        // Name + desc + count
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(c['nom']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                      ? TColors.textWhite : TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: count > 0
                      ? TColors.primaryLight
                      : (isDark
                          ? TColors.darkContainer
                          : TColors.lightContainer),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: count > 0
                        ? TColors.primary : TColors.textHint,
                      fontFamily: 'Poppins',
                    ))),
              ]),
              const SizedBox(height: 3),
              Text(c['desc']!,
                style: const TextStyle(
                  fontSize: 12,
                  color: TColors.textHint,
                  fontFamily: 'Poppins',
                )),
            ],
          ),
        ),
        // Edit + Delete buttons
        Row(mainAxisSize: MainAxisSize.min, children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showEditDialog(index),
              borderRadius: BorderRadius.circular(10),
              child: Ink(
                decoration: BoxDecoration(
                  color: TColors.infoLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(Icons.edit_outlined,
                    size: 18, color: TColors.info)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showDeleteDialog(index),
              borderRadius: BorderRadius.circular(10),
              child: Ink(
                decoration: BoxDecoration(
                  color: count > 0
                    ? TColors.lightContainer : TColors.errorLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(9),
                  child: Icon(Icons.delete_outline,
                    size: 18,
                    color: count > 0
                      ? TColors.textHint : TColors.error)),
              ),
            ),
          ),
        ]),
      ]),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 4),
      child: Row(children: [
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
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12),
            ),
          ),
        ),
      ]),
    );
  }
}