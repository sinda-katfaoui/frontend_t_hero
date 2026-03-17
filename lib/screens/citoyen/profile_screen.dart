import 'package:flutter/material.dart';
import 'package:frontend_t_hero/screens/auth/login_screen.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Container(
          color: TColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 24),
          width: double.infinity,
          child: Column(children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              child: const Text('AB',
                style: TextStyle(color: Colors.white,
                  fontSize: 20, fontWeight: FontWeight.w500))),
            const SizedBox(height: 8),
            const Text('Amira Bouazizi',
              style: TextStyle(color: Colors.white,
                fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10)),
              child: const Text('Citoyen',
                style: TextStyle(
                  color: Colors.white, fontSize: 11))),
          ]),
        ),
        const SizedBox(height: 8),
        _menuItem(context, Icons.person_outline, 'Mon profil', () {}),
        _menuItem(context, Icons.flag_outlined,
          'Mes signalements', () {}),
        _menuItem(context, Icons.history, 'Historique', () {}),
        _menuItem(context, Icons.settings_outlined,
          'Paramètres', () {}),
        const Divider(),
        _menuItem(context, Icons.logout, 'Déconnexion', () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen()),
            (route) => false);
        }, isRed: true),
      ]),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon,
      String label, VoidCallback onTap, {bool isRed = false}) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: isRed ? TColors.errorLight : TColors.primaryLight,
          borderRadius: BorderRadius.circular(9)),
        child: Icon(icon,
          color: isRed ? TColors.error : TColors.primary,
          size: 18)),
      title: Text(label,
        style: TextStyle(
          fontSize: 14,
          color: isRed ? TColors.error : null)),
      trailing: isRed
        ? null
        : const Icon(Icons.arrow_forward_ios,
            size: 14, color: TColors.grey),
      onTap: onTap,
    );
  }
}