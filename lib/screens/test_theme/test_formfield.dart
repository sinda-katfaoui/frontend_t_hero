import 'package:flutter/material.dart';

class TestFormfield extends StatefulWidget {
  const TestFormfield({super.key});

  @override
  State<TestFormfield> createState() => _TestFormfieldState();
}

class _TestFormfieldState extends State<TestFormfield> {
  bool _obscure = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Fields Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  hintText: 'Votre nom complet',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'votre@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? 'Email requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => v!.length < 6 ? 'Min 6 caractères' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Décrivez le problème...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Formulaire valide ✓')),
                    );
                  }
                },
                child: const Text('Valider'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}