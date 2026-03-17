import 'package:flutter/material.dart';

class TestButton extends StatelessWidget {
  const TestButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buttons Test')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Elevated Button'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined Button'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text('Text Button'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.send),
              label: const Text('Button with Icon'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: null,
              child: const Text('Disabled Button'),
            ),
          ],
        ),
      ),
    );
  }
}