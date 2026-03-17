import 'package:flutter/material.dart';

class TestShowdialog extends StatelessWidget {
  const TestShowdialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dialog Test')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Confirmer'),
                  content: const Text(
                    'Voulez-vous vraiment supprimer ce signalement?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Confirmer'),
                    ),
                  ],
                ),
              ),
              child: const Text('Show Alert Dialog'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Succès'),
                  content: const Text('Signalement créé avec succès!'),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
              child: const Text('Show Success Dialog'),
            ),
          ],
        ),
      ),
    );
  }
}