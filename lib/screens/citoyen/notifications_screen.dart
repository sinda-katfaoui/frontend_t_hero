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
    {'msg': 'Nid de poule Résolu',
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

  void _markAllRead() {
    setState(() {
      for (final n in _notifs) n['read'] = true;
    });
  }

  void _markRead(int i) =>
    setState(() => _notifs[i]['read'] = true);

  IconData _icon(String type) {
    switch (type) {
      case 'done':   return Icons.check_circle_outline;
      case 'update': return Icons.access_time_rounded;
      default:       return Icons.info_outline;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────
          Container(
            color: isDark ? TColors.cardDark : TColors.cardLight,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
                Row(children: [
                  if (_unreadCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: TColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$_unreadCount nouveau',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        )),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _markAllRead,
                      child: const Text('Tout lire',
                        style: TextStyle(
                          fontSize: 12,
                          color: TColors.primary,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        )),
                    ),
                  ],
                ]),
              ],
            ),
          ),

          // ── Notification cards ───────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(_notifs.length, (i) {
                  final n     = _notifs[i];
                  final unread= !(n['read'] as bool);
                  final type  = n['type'] as String;
                  return GestureDetector(
                    onTap: () => _markRead(i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: unread
                          ? TColors.primaryLight
                          : (isDark
                              ? TColors.cardDark
                              : TColors.cardLight),
                        borderRadius: BorderRadius.circular(16),
                        border: unread
                          ? Border(
                              left: const BorderSide(
                                color: TColors.primary,
                                width: 3),
                              top: BorderSide(
                                color: TColors.borderLight,
                                width: 0.5),
                              right: BorderSide(
                                color: TColors.borderLight,
                                width: 0.5),
                              bottom: BorderSide(
                                color: TColors.borderLight,
                                width: 0.5),
                            )
                          : Border.all(
                              color: TColors.borderLight,
                              width: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: unread
                                ? TColors.primaryLight
                                : _iconBg(type),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: unread
                                  ? TColors.primary
                                  : _iconColor(type)
                                      .withValues(alpha: 0.3),
                                width: 1.5),
                            ),
                            child: Icon(_icon(type),
                              size: 18,
                              color: unread
                                ? TColors.primary
                                : _iconColor(type)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                CrossAxisAlignment.start,
                              children: [
                                Text(n['msg'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Poppins',
                                    fontWeight: unread
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                    color: isDark
                                      ? TColors.textWhite
                                      : TColors.textPrimary,
                                  )),
                                const SizedBox(height: 3),
                                Text(n['sub'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: TColors.textHint,
                                    fontFamily: 'Poppins',
                                  )),
                              ],
                            ),
                          ),
                          if (unread)
                            Container(
                              width: 9, height: 9,
                              decoration: const BoxDecoration(
                                color: TColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // ── Mark all as read link ────────────────────────
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Center(
                child: GestureDetector(
                  onTap: _markAllRead,
                  child: const Text('Tout marquer comme lu',
                    style: TextStyle(
                      fontSize: 13,
                      color: TColors.primary,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    )),
                ),
              ),
            ),
        ],
      ),
    );
  }
}