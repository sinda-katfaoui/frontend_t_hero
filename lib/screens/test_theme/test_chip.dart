import 'package:flutter/material.dart';

class TestChip extends StatefulWidget {
  const TestChip({super.key});

  @override
  State<TestChip> createState() => _TestChipState();
}

class _TestChipState extends State<TestChip> {
  int _selected = 0;
  final List<String> _filters = ['Tous', 'Voirie', 'Eclairage', 'Propreté', 'Espaces Verts'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chip Test')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter chips:',
              style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: List.generate(_filters.length, (i) =>
                FilterChip(
                  label: Text(_filters[i]),
                  selected: _selected == i,
                  onSelected: (_) => setState(() => _selected = i),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Action chips:',
              style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('EN_ATTENTE'),
                  onPressed: () {},
                ),
                ActionChip(
                  label: const Text('EN_COURS'),
                  onPressed: () {},
                ),
                ActionChip(
                  label: const Text('RÉSOLU'),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}