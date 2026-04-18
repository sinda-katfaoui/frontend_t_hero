import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {

  final List<Map<String, dynamic>> _notifs = [
    {'msg': 'Signalement pris en charge',
     'sub': 'Agent Habib · Il y a 5 min',
     'read': false, 'type': 'update'},
    {'msg': 'Nid de poule Résolu ✓',
     'sub': 'Il y a 1h',
     'read': false, 'type': 'done'},
    {'msg': 'Signalement Lampadaire enregistré',
     'sub': 'Hier 18:30',
     'read': true, 'type': 'info'},
    {'msg': 'Déchets Sousse résolu avec succès',
     'sub': 'Il y a 3j',
     'read': true, 'type': 'done'},
  ];

  int get _unreadCount =>
    _notifs.where((n) => !(n['read'] as bool)).length;

  void _markAllRead() =>
    setState(() { for (final n in _notifs) n['read'] = true; });

  void _markRead(int i) =>
    setState(() => _notifs[i]['read'] = true);


  Color _iconColor(String type) {
    switch (type) {
      case 'done':   return TColors.success;
      case 'update': return TColors.primary;
      default:       return TColors.info;
    }
  }

  Color _iconBg(String type) {
    switch (type) {
      case 'done':   return TColors.successLight;
      case 'update': return TColors.primaryLight;
      default:       return TColors.infoLight;
    }
  }

  String _emoji(String type) {
    switch (type) {
      case 'done':   return '✅';
      case 'update': return '⚡';
      default:       return 'ℹ️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
      Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── Gradient Header ──────────────────────────────
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
                  color: TColors.primary
                    .withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(
              16, 16, 16, 20),
            child: Column(children: [

              Row(
                mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment:
                      CrossAxisAlignment.start,
                    children: [
                      Text('🔔 Notifications',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        )),
                      Text('Restez informé de vos signalements',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontFamily: 'Poppins',
                        )),
                    ],
                  ),
                  if (_unreadCount > 0)
                    GestureDetector(
                      onTap: _markAllRead,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white
                            .withValues(alpha: 0.2),
                          borderRadius:
                            BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white
                              .withValues(alpha: 0.3))),
                        child: const Text('Tout lire ✓',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          )),
                      ),
                    ),
                ],
              ),

              if (_unreadCount > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white
                      .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white
                        .withValues(alpha: 0.2))),
                  child: Row(children: [
                    const Text('📬',
                      style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Vous avez $_unreadCount nouvelle(s) '
                        'notification(s) non lue(s)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ))),
                  ]),
                ),
              ],
            ]),
          ),

          const SizedBox(height: 8),

          // ── List ─────────────────────────────────────────
          Expanded(
            child: _notifs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                      MainAxisAlignment.center,
                    children: [
                      const Text('🔔',
                        style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      const Text('Aucune notification',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: TColors.textPrimary,
                          fontFamily: 'Poppins',
                        )),
                      const SizedBox(height: 6),
                      const Text(
                        'Vos alertes apparaîtront ici',
                        style: TextStyle(
                          fontSize: 13,
                          color: TColors.textHint,
                          fontFamily: 'Poppins',
                        )),
                    ],
                  ))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                  itemCount: _notifs.length,
                  itemBuilder: (_, i) {
                    final n      = _notifs[i];
                    final unread = !(n['read'] as bool);
                    final type   = n['type'] as String;
                    return GestureDetector(
                      onTap: () => _markRead(i),
                      child: Container(
                        margin: const EdgeInsets.only(
                          bottom: 10),
                        decoration: BoxDecoration(
                          color: unread
                            ? TColors.primaryLight
                            : (isDark
                                ? TColors.cardDark
                                : Colors.white),
                          borderRadius:
                            BorderRadius.circular(16),
                          border: Border.all(
                            color: unread
                              ? TColors.primary
                                  .withValues(alpha: 0.4)
                              : TColors.borderLight,
                            width: unread ? 1.5 : 0.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                .withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                          ],
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment:
                            CrossAxisAlignment.start,
                          children: [

                            // Icon
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: unread
                                  ? TColors.primaryLight
                                  : _iconBg(type),
                                borderRadius:
                                  BorderRadius.circular(13),
                                border: Border.all(
                                  color: unread
                                    ? TColors.primary
                                        .withValues(alpha: 0.3)
                                    : _iconColor(type)
                                        .withValues(alpha: 0.2),
                                  width: 1)),
                              child: Center(
                                child: Text(
                                  _emoji(type),
                                  style: const TextStyle(
                                    fontSize: 20)))),

                            const SizedBox(width: 12),

                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                children: [
                                  Text(n['msg'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      fontWeight: unread
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                      color: isDark
                                        ? TColors.textWhite
                                        : TColors.textPrimary,
                                    )),
                                  const SizedBox(height: 4),
                                  Text(n['sub'] as String,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: TColors.textHint,
                                      fontFamily: 'Poppins',
                                    )),
                                ],
                              ),
                            ),

                            // Unread dot
                            if (unread)
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 4),
                                width: 10, height: 10,
                                decoration: BoxDecoration(
                                  color: TColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: TColors.primary
                                        .withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      offset:
                                        const Offset(0, 1)),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),

          // ── Bottom mark all ──────────────────────────────
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16, 0, 16, 16),
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _markAllRead,
                  icon: const Icon(
                    Icons.done_all_rounded, size: 18),
                  label: const Text(
                    'Tout marquer comme lu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}