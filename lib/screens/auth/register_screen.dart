import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nomCtrl   = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _codeCtrl  = TextEditingController();
  bool _obscure    = true;
  int  _role       = 0;

  final _roles = ['Citoyen', 'Agent', 'Admin'];

  @override
  void dispose() {
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white : TColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Créer un compte',
                  style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text('Choisissez votre rôle',
                  style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                // Role selector
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                      ? TColors.cardDark
                      : const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: List.generate(3, (i) => Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _role = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _role == i
                              ? Theme.of(context).cardTheme.color
                              : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            border: _role == i
                              ? Border.all(
                                  color: TColors.borderLight,
                                  width: 0.5)
                              : null),
                          child: Text(_roles[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _role == i
                                ? FontWeight.w500 : FontWeight.w400,
                              color: _role == i
                                ? TColors.primary : TColors.textHint)),
                        ),
                      ),
                    )),
                  ),
                ),
                const SizedBox(height: 24),
                // Nom
                TextFormField(
                  controller: _nomCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    hintText: 'Votre nom',
                    prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'votre@email.com',
                    prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                // Password
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                      onPressed: () =>
                        setState(() => _obscure = !_obscure))),
                  validator: (v) =>
                    v!.length < 6 ? 'Min 6 caractères' : null,
                ),
                // Code field for Agent or Admin
                if (_role == 1 || _role == 2) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: _role == 1 ? 'Code Agent' : 'Code Admin',
                      hintText: 'Fourni par l\'administrateur',
                      prefixIcon: const Icon(Icons.shield_outlined),
                      filled: true,
                      fillColor: TColors.primaryLight),
                    validator: (v) =>
                      v!.isEmpty ? 'Code requis' : null,
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Compte créé avec succès ✓'),
                          backgroundColor: TColors.success));
                    }
                  },
                  child: const Text('S\'inscrire'),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        text: 'Déjà un compte? ',
                        style: TextStyle(
                          color: TColors.textHint, fontSize: 13),
                        children: [
                          TextSpan(
                            text: 'Se connecter',
                            style: TextStyle(
                              color: TColors.primary,
                              fontWeight: FontWeight.w500)),
                        ])))),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}