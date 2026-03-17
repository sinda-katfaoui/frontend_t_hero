import 'package:flutter/material.dart';
import 'package:frontend_t_hero/screens/auth/register_screen.dart';
import 'package:frontend_t_hero/screens/citoyen/citoyen_home_screen.dart';
import 'package:frontend_t_hero/screens/agent/agent_home_screen.dart';
import 'package:frontend_t_hero/screens/admin/admin_home_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;
  bool _loading    = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _loading = false);
      final email = _emailCtrl.text.trim();
      Widget screen;
      if (email.contains('admin')) {
        screen = const AdminHomeScreen();
      } else if (email.contains('agent')) {
        screen = const AgentHomeScreen();
      } else {
        screen = const CitoyenHomeScreen();
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                // Logo
                Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: TColors.primary,
                      borderRadius: BorderRadius.circular(10)),
                    child: const Center(
                      child: Text('T',
                        style: TextStyle(color: Colors.white,
                          fontSize: 18, fontWeight: FontWeight.w700)))),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('T HERO',
                        style: TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2)),
                      Text('بطل تونس',
                        style: TextStyle(
                          fontSize: 10, color: TColors.primary)),
                    ]),
                ]),
                const SizedBox(height: 40),
                Text('Bon retour',
                  style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text('Connectez-vous à votre compte',
                  style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'votre@email.com',
                    prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) =>
                    v!.isEmpty ? 'Email requis' : null,
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Mot de passe oublié?'))),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                    : const Text('Se connecter'),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('ou',
                      style: TextStyle(color: TColors.textHint))),
                  const Expanded(child: Divider()),
                ]),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen())),
                  child: const Text('Créer un compte'),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text('Citoyen · Agent · Admin',
                    style: TextStyle(
                      fontSize: 12, color: TColors.textHint))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}