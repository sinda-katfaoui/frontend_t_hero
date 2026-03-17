import 'package:flutter/material.dart';

class TestAppbar extends StatelessWidget {
  const TestAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('T Hero AppBar'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person), onPressed: () {}),
        ],
      ),
      body: const Center(child: Text('AppBar Test')),
    );
  }
}