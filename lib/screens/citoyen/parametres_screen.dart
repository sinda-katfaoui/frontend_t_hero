import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});
  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  bool _notifications    = true;
  bool _notifSignalement = true;
  bool _notifEmail       = false;

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
        style: const TextStyle(
          fontSize: 13, fontFamily: 'Poppins',
          color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.light,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Header ──────────────────────────────────────
            Container(
              color: isDark ? TColors.cardDark : TColors.cardLight,
              padding: const EdgeInsets.fromLTRB(6, 8, 16, 8),
              child: Row(children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new,
                    size: 20,
                    color: isDark
                      ? TColors.textWhite : TColors.textPrimary),
                  onPressed: () => Navigator.pop(context)),
                Text('Paramètres',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark
                      ? TColors.textWhite : TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
              ]),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  // ── Notifications ─────────────────────────
                  _sectionTitle('Notifications', isDark),
                  const SizedBox(height: 8),

                  _toggle(
                    icon: Icons.notifications_outlined,
                    label: 'Activer les notifications',
                    subtitle: 'Recevoir des alertes sur vos signalements',
                    value: _notifications,
                    isDark: isDark,
                    onChanged: (v) {
                      setState(() {
                        _notifications = v;
                        if (!v) {
                          _notifSignalement = false;
                          _notifEmail = false;
                        }
                      });
                      _showSnack(
                        v ? 'Notifications activées ✓'
                          : 'Notifications désactivées',
                        v ? TColors.success : TColors.warning);
                    },
                  ),
                  const SizedBox(height: 8),

                  _toggle(
                    icon: Icons.flag_outlined,
                    label: 'Notifications signalements',
                    subtitle: 'Mises à jour de statut en temps réel',
                    value: _notifSignalement,
                    enabled: _notifications,
                    isDark: isDark,
                    onChanged: _notifications
                      ? (v) => setState(() => _notifSignalement = v)
                      : null,
                  ),
                  const SizedBox(height: 8),

                  _toggle(
                    icon: Icons.email_outlined,
                    label: 'Notifications par email',
                    subtitle: 'Recevoir un email à chaque mise à jour',
                    value: _notifEmail,
                    enabled: _notifications,
                    isDark: isDark,
                    onChanged: _notifications
                      ? (v) => setState(() => _notifEmail = v)
                      : null,
                  ),

                  const SizedBox(height: 24),

                  // ── À propos ──────────────────────────────
                  _sectionTitle('À propos', isDark),
                  const SizedBox(height: 8),

                  _infoTile(
                    icon: Icons.info_outline,
                    label: 'Version de l\'application',
                    value: '1.0.0',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),

                  _infoTile(
                    icon: Icons.shield_outlined,
                    label: 'Politique de confidentialité',
                    isDark: isDark,
                    showArrow: true,
                    onTap: () => _showDialog(
                      'Politique de confidentialité',
                      'T HERO respecte votre vie privée. '
                      'Vos données personnelles sont utilisées '
                      'uniquement pour améliorer les services '
                      'de la ville intelligente. Aucune donnée '
                      'n\'est partagée avec des tiers sans '
                      'votre consentement.'),
                  ),
                  const SizedBox(height: 8),

                  _infoTile(
                    icon: Icons.description_outlined,
                    label: 'Conditions d\'utilisation',
                    isDark: isDark,
                    showArrow: true,
                    onTap: () => _showDialog(
                      'Conditions d\'utilisation',
                      'En utilisant T HERO, vous acceptez '
                      'de signaler uniquement des problèmes '
                      'réels et pertinents. L\'utilisation '
                      'abusive de la plateforme peut entraîner '
                      'la suspension de votre compte. '
                      'T HERO est un service public numérique '
                      'de la ville intelligente de Tunisie.'),
                  ),

                  const SizedBox(height: 32),

                  // ── Branding ──────────────────────────────
                  Center(
                    child: Column(children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          color: TColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text('T',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            )))),
                      const SizedBox(height: 12),
                      Text('T HERO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                            ? TColors.textWhite : TColors.textPrimary,
                          letterSpacing: 3,
                          fontFamily: 'Poppins',
                        )),
                      const SizedBox(height: 4),
                      const Text('Smart City Guardian',
                        style: TextStyle(
                          fontSize: 13,
                          color: TColors.textHint,
                          fontFamily: 'Poppins',
                        )),
                      const SizedBox(height: 4),
                      const Text('© 2025 T HERO Tunisia',
                        style: TextStyle(
                          fontSize: 11,
                          color: TColors.textHint,
                          fontFamily: 'Poppins',
                        )),
                    ]),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
        title: Text(title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          )),
        content: Text(content,
          style: const TextStyle(
            fontSize: 14,
            color: TColors.textSecondary,
            fontFamily: 'Poppins',
            height: 1.6,
          )),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Fermer',
              style: TextStyle(
                fontSize: 14, fontFamily: 'Poppins'))),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark ? TColors.grey : TColors.textHint,
          letterSpacing: 0.8,
          fontFamily: 'Poppins',
        )),
    );
  }

  Widget _toggle({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required bool isDark,
    required void Function(bool)? onChanged,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.cardDark : TColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
            ? const Color(0xFF2A2A2A) : TColors.borderLight,
          width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 12),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: isDark
              ? const Color(0xFF1A1A1A) : TColors.light,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon,
            size: 20,
            color: enabled ? TColors.primary : TColors.grey)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: enabled
                    ? (isDark
                        ? TColors.textWhite : TColors.textPrimary)
                    : TColors.textHint,
                  fontFamily: 'Poppins',
                )),
              const SizedBox(height: 2),
              Text(subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? TColors.grey : TColors.textHint,
                  fontFamily: 'Poppins',
                )),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: Colors.white,
          activeTrackColor: TColors.primary,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: TColors.grey.withValues(alpha: 0.3),
        ),
      ]),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    String? value,
    required bool isDark,
    VoidCallback? onTap,
    bool showArrow = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? TColors.cardDark : TColors.cardLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                ? const Color(0xFF2A2A2A) : TColors.borderLight,
              width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 14),
            child: Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: isDark
                    ? const Color(0xFF1A1A1A) : TColors.light,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon,
                  size: 20, color: TColors.primary)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                      ? TColors.textWhite : TColors.textPrimary,
                    fontFamily: 'Poppins',
                  ))),
              if (value != null && value.isNotEmpty)
                Text(value,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? TColors.grey : TColors.textHint,
                    fontFamily: 'Poppins',
                  )),
              if (showArrow) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios,
                  size: 14, color: TColors.grey),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}