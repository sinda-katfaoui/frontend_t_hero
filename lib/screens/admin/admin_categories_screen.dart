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
    {'nom': 'Voirie',        'desc': 'Routes et trottoirs',  'count': '1'},
    {'nom': 'Eclairage',     'desc': 'Lampadaires publics',  'count': '1'},
    {'nom': 'Propreté',      'desc': 'Déchets et nettoyage', 'count': '1'},
    {'nom': 'Espaces Verts', 'desc': 'Parcs et jardins',     'count': '1'},
    {'nom': 'Autre',         'desc': 'Divers',               'count': '0'},
  ];

  void _showAddDialog() {
    final nomCtrl  = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle catégorie'),
        content: Column(mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom',
                prefixIcon: Icon(Icons.category_outlined))),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined))),
          ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler')),
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
            child: const Text('Ajouter')),
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
      builder: (context) => AlertDialog(
        title: const Text('Modifier catégorie'),
        content: Column(mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom',
                prefixIcon: Icon(Icons.category_outlined))),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined))),
          ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _categories[index] = {
                  'nom':   nomCtrl.text,
                  'desc':  descCtrl.text,
                  'count': _categories[index]['count']!,
                };
              });
              Navigator.pop(context);
            },
            child: const Text('Enregistrer')),
        ],
      ),
    );
  }

  void _showDeleteDialog(int index) {
    final count = int.parse(_categories[index]['count']!);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer catégorie'),
        content: count > 0
          ? Text(
              'Impossible de supprimer "${_categories[index]['nom']}" '
              'car elle contient $count signalement(s).',
              style: const TextStyle(fontSize: 13))
          : Text(
              'Voulez-vous vraiment supprimer '
              '"${_categories[index]['nom']}"?',
              style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler')),
          if (count == 0)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.error),
              onPressed: () {
                setState(() => _categories.removeAt(index));
                Navigator.pop(context);
              },
              child: const Text('Supprimer')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        AppBar(
          title: const Text('Catégories'),
          automaticallyImplyLeading: false,
          actions: [
            TextButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Ajouter',
                style: TextStyle(color: Colors.white))),
          ],
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _categories.length,
            itemBuilder: (context, i) {
              final c = _categories[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: TColors.primaryLight,
                      borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.category_outlined,
                      color: TColors.primary, size: 20)),
                  title: Text(c['nom']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    '${c['desc']} · ${c['count']} signalement(s)',
                    style: const TextStyle(fontSize: 11)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                          size: 18, color: TColors.info),
                        onPressed: () => _showEditDialog(i)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                          size: 18, color: TColors.error),
                        onPressed: () => _showDeleteDialog(i)),
                    ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}