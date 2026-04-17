import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class AgentParametresScreen extends StatefulWidget {
  const AgentParametresScreen({super.key});
  @override
  State<AgentParametresScreen> createState() =>
      _AgentParametresScreenState();
}

class _AgentParametresScreenState
    extends State<AgentParametresScreen> {
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

            // ── Hero Header ──────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [TColors.primary, Color(0xFFE53935)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft:  Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: TColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4)),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(6, 8, 16, 20),
              child: Column(children: [
                // Back + title
                Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                      size: 20, color: Colors.white),
                    onPressed: () => Navigator.pop(context)),
                  const Text('Paramètres',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    )),
                ]),
                const SizedBox(height: 8),
                // Hero encouragement strip
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2))),
                  child: Row(children: [
                    const Text('⚙️',
                      style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                          CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Configurez votre expérience',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            )),
                          Text(
                            'Héros bien configuré = mission réussie 🦸',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white
                                .withValues(alpha: 0.85),
                              fontFamily: 'Poppins',
                            )),
                        ],
                      ),
                    ),
                  ]),
                ),
              ]),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  // ── Notifications ─────────────────────────
                  _sectionTitle('🔔  Notifications', isDark),
                  const SizedBox(height: 10),

                  _toggle(
                    icon: Icons.notifications_outlined,
                    label: 'Activer les notifications',
                    subtitle:
                      'Recevoir des alertes sur vos missions',
                    value: _notifications,
                    isDark: isDark,
                    onChanged: (v) {
                      setState(() {
                        _notifications = v;
                        if (!v) {
                          _notifSignalement = false;
                          _notifEmail       = false;
                        }
                      });
                      _showSnack(
                        v ? '🔔 Notifications activées ✓'
                          : 'Notifications désactivées',
                        v ? TColors.success : TColors.warning);
                    },
                  ),
                  const SizedBox(height: 10),

                  _toggle(
                    icon: Icons.flag_outlined,
                    label: 'Alertes missions',
                    subtitle:
                      'Mises à jour de statut en temps réel',
                    value: _notifSignalement,
                    enabled: _notifications,
                    isDark: isDark,
                    onChanged: _notifications
                      ? (v) {
                          setState(() => _notifSignalement = v);
                          _showSnack(
                            v ? '⚡ Alertes missions activées ✓'
                              : 'Alertes missions désactivées',
                            v ? TColors.success : TColors.warning);
                        }
                      : null,
                  ),
                  const SizedBox(height: 10),

                  _toggle(
                    icon: Icons.email_outlined,
                    label: 'Notifications par email',
                    subtitle:
                      'Recevoir un email à chaque mise à jour',
                    value: _notifEmail,
                    enabled: _notifications,
                    isDark: isDark,
                    onChanged: _notifications
                      ? (v) {
                          setState(() => _notifEmail = v);
                          _showSnack(
                            v ? '📧 Notifications email activées ✓'
                              : 'Notifications email désactivées',
                            v ? TColors.success : TColors.warning);
                        }
                      : null,
                  ),

                  const SizedBox(height: 24),

                  // ── À propos ──────────────────────────────
                  _sectionTitle('ℹ️  À propos', isDark),
                  const SizedBox(height: 10),

                  _infoTile(
                    icon: Icons.info_outline,
                    label: 'Version de l\'application',
                    value: '1.0.0',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),

                  _infoTile(
                    icon: Icons.shield_outlined,
                    label: 'Politique de confidentialité',
                    isDark: isDark,
                    showArrow: true,
                    onTap: () => _showDialog(
                      '🔒 Politique de confidentialité',
                      'T HERO respecte votre vie privée. '
                      'Vos données personnelles sont utilisées '
                      'uniquement pour améliorer les services '
                      'de la ville intelligente. Aucune donnée '
                      'n\'est partagée avec des tiers sans '
                      'votre consentement.'),
                  ),
                  const SizedBox(height: 10),

                  _infoTile(
                    icon: Icons.star_outline_rounded,
                    label: 'Conditions d\'utilisation',
                    isDark: isDark,
                    showArrow: true,
                    onTap: () => _showDialog(
                      '🦸 Sois un Héros de Tunisie !',
                      'En tant qu\'Agent Municipal T HERO, '
                      'tu es bien plus qu\'un simple employé — '
                      'tu es un gardien de ta ville et un héros '
                      'du quotidien pour tes concitoyens.\n\n'
                      '🇹🇳 Ta mission :\n'
                      'Chaque signalement que tu traites améliore '
                      'la vie de tes voisins et contribue à '
                      'construire une Tunisie plus propre, plus '
                      'sûre et plus moderne.\n\n'
                      '⚡ Tes engagements :\n'
                      '• Traiter les signalements avec rapidité '
                      'et professionnalisme\n'
                      '• Respecter les citoyens et leurs '
                      'préoccupations\n'
                      '• Mettre à jour les statuts en temps réel\n'
                      '• Agir avec intégrité et transparence\n\n'
                      '🏆 Ensemble, faisons de nos villes '
                      'des endroits dont nous sommes fiers. '
                      'T HERO compte sur toi !'),
                  ),

                  const SizedBox(height: 32),

                  // ── Branding ──────────────────────────────
                  Center(
                    child: Column(children: [
                      Container(
                        width: 70, height: 70,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              TColors.primary,
                              Color(0xFFE53935)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: TColors.primary
                                .withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4)),
                          ],
                        ),
                        child: const Center(
                          child: Text('T',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            )))),
                      const SizedBox(height: 12),
                      Text('T HERO',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark
                            ? TColors.textWhite
                            : TColors.textPrimary,
                          letterSpacing: 4,
                          fontFamily: 'Poppins',
                        )),
                      const SizedBox(height: 4),
                      const Text('🦸 Smart City Guardian',
                        style: TextStyle(
                          fontSize: 13,
                          color: TColors.primary,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        )),
                      const SizedBox(height: 6),
                      const Text('© 2025 T HERO Tunisia 🇹🇳',
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
        content: SingleChildScrollView(
          child: Text(content,
            style: const TextStyle(
              fontSize: 14,
              color: TColors.textSecondary,
              fontFamily: 'Poppins',
              height: 1.7,
            )),
        ),
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
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark ? TColors.grey : TColors.textSecondary,
          letterSpacing: 0.5,
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
        color: isDark ? TColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled && value
            ? TColors.primary.withValues(alpha: 0.3)
            : TColors.borderLight,
          width: enabled && value ? 1.5 : 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 12),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: enabled && value
              ? TColors.primaryLight
              : (isDark ? TColors.dark : TColors.light),
            borderRadius: BorderRadius.circular(13)),
          child: Icon(icon,
            size: 20,
            color: enabled && value
              ? TColors.primary : TColors.grey)),
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
                        ? TColors.textWhite
                        : TColors.textPrimary)
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
          inactiveTrackColor:
            TColors.grey.withValues(alpha: 0.3),
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
            color: isDark ? TColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: TColors.borderLight, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 14),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: TColors.primaryLight,
                  borderRadius: BorderRadius.circular(13)),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: TColors.primaryLight,
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TColors.primary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ))),
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