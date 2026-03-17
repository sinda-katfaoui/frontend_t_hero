import 'package:flutter/material.dart';

class TestCheckbox extends StatefulWidget {
  const TestCheckbox({super.key});

  @override
  State<TestCheckbox> createState() => _TestCheckboxState();
}

class _TestCheckboxState extends State<TestCheckbox> {
  bool _checked1 = true;
  bool _checked2 = false;
  bool _checked3 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkbox Test')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CheckboxListTile(
              title: const Text('Option 1 — checked'),
              value: _checked1,
              onChanged: (v) => setState(() => _checked1 = v!),
            ),
            CheckboxListTile(
              title: const Text('Option 2 — unchecked'),
              value: _checked2,
              onChanged: (v) => setState(() => _checked2 = v!),
            ),
            CheckboxListTile(
              title: const Text('Option 3 — checked'),
              subtitle: const Text('With subtitle'),
              value: _checked3,
              onChanged: (v) => setState(() => _checked3 = v!),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Checkbox(
                  value: true,
                  onChanged: (_) {},
                ),
                Checkbox(
                  value: false,
                  onChanged: (_) {},
                ),
                Checkbox(
                  value: null,
                  tristate: true,
                  onChanged: (_) {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}