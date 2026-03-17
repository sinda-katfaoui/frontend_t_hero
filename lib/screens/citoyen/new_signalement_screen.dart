import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class NewSignalementScreen extends StatefulWidget {
  const NewSignalementScreen({super.key});

  @override
  State<NewSignalementScreen> createState() => _NewSignalementScreenState();
}

class _NewSignalementScreenState extends State<NewSignalementScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _locCtrl  = TextEditingController();
  String? _categorie;
  String? _priorite;
  bool _loading = false;

  final _categories = ['Voirie', 'Eclairage', 'Propreté',
                       'Espaces Verts', 'Autre'];
  final _priorites  = ['FAIBLE', 'MOYENNE', 'ELEVEE'];

  @override
  void dispose() {
    _descCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau signalement')),
      body: SingleChildScrollView(
        child: Column(children: [
          // Map placeholder
          Container(
            height: 180,
            color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A2A1A)
              : const Color(0xFFE8F0E8),
            child: Stack(children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on,
                      size: 40, color: TColors.primary),
                    const SizedBox(height: 4),
                    Text(
                      'Appuyez pour définir la localisation',
                      style: TextStyle(
                        fontSize: 12, color: TColors.textHint)),
                  ],
                ),
              ),
              Positioned(
                right: 12, bottom: 12,
                child: FloatingActionButton.small(
                  onPressed: () {},
                  backgroundColor: TColors.primary,
                  child: const Icon(Icons.my_location,
                    color: Colors.white, size: 18))),
            ]),
          ),
          // Form
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Décrivez le problème...',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.description_outlined)),
                  validator: (v) =>
                    v!.isEmpty ? 'Description requise' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Localisation',
                    hintText: 'Adresse du problème',
                    prefixIcon: Icon(Icons.place_outlined)),
                  validator: (v) =>
                    v!.isEmpty ? 'Localisation requise' : null,
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _categorie,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie',
                        prefixIcon: Icon(Icons.category_outlined)),
                      items: _categories.map((c) =>
                        DropdownMenuItem(value: c,
                          child: Text(c, style:
                            const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (v) => setState(() => _categorie = v),
                      validator: (v) => v == null ? 'Requis' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priorite,
                      decoration: const InputDecoration(
                        labelText: 'Priorité',
                        prefixIcon: Icon(Icons.flag_outlined)),
                      items: _priorites.map((p) =>
                        DropdownMenuItem(value: p,
                          child: Text(p, style:
                            const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (v) => setState(() => _priorite = v),
                      validator: (v) => v == null ? 'Requis' : null,
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(
                      color: TColors.primary.withValues(alpha: 0.5)),
                    foregroundColor: TColors.primary),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Ajouter une photo'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : () {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _loading = true);
                      Future.delayed(const Duration(seconds: 1), () {
                        setState(() => _loading = false);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Signalement envoyé avec succès ✓'),
                            backgroundColor: TColors.success));
                      });
                    }
                  },
                  child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                    : const Text('Envoyer le signalement'),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}