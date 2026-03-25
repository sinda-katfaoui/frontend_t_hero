// ============================================================
// NotificationsScreen — Citoyen Notifications Tab
// ============================================================
// Displays all notifications for the logged-in citoyen.
// This screen is embedded inside CitoyenHomeScreen's
// IndexedStack at tab index 3 — not a separate route.
//
// Notification types:
//   - 'update' → signalement assigned to an agent
//   - 'done'   → signalement marked as resolved
//   - 'info'   → general info (signalement registered, etc.)
//
// Design decisions:
// - White card per notification with red left border for unread
// - Colored circle avatar icon per notification type
// - Unread notifications have red tinted background
// - "Tout marquer comme lu" clears all unread states locally
// - No scrolling — 4 items fit perfectly on screen
// - Everything fits in one screen without scrolling
//
// TODO: Replace mock data with real API call:
//   - GET /notifications/GetNotificationsByUser/:userId
//   - PUT /notifications/MarquerCommeLu/:id
//   - PUT /notifications/MarquerToutesCommeLues/:userId
// ============================================================

import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  // Mock notification data — replace with API response
  // 'read' is mutable so we can toggle it locally
  final List<Map<String, dynamic>> _notifs = [
    {
      'msg':  'Votre signalement a été pris en charge par Agent Habib',
      'time': 'Il y a 5 min',
      'read': false,
      'type': 'update', // assigned to agent
    },
    {
      'msg':  'Nid de poule marqué Résolu',
      'time': 'Il y a 1h',
      'read': false,
      'type': 'done', // resolved
    },
    {
      'msg':  'Signalement Lampadaire enregistré',
      'time': 'Hier 18:30',
      'read': true,
      'type': 'info', // general info
    },
    {
      'msg':  'Déchets Sousse résolu avec succès',
      'time': 'Il y a 3j',
      'read': true,
      'type': 'done',
    },
  ];

  // Count of unread notifications for the badge
  int get _unreadCount =>
    _notifs.where((n) => !(n['read'] as bool)).length;

  // ── Mark All as Read ───────────────────────────────────────
  // Sets all notifications to read locally.
  // TODO: Call PUT /notifications/MarquerToutesCommeLues/:userId
  void _markAllRead() {
    setState(() {
      for (final n in _notifs) {
        n['read'] = true;
      }
    });
  }

  // ── Mark Single as Read ────────────────────────────────────
  // Tapping a notification marks it as read.
  // TODO: Call PUT /notifications/MarquerCommeLu/:id
  void _markRead(int index) {
    setState(() => _notifs[index]['read'] = true);
  }

  // ── Icon per notification type ─────────────────────────────
  IconData _typeIcon(String type) {
    switch (type) {
      case 'done':   return Icons.check_circle_outline;
      case 'update': return Icons.update_rounded;
      default:       return Icons.info_outline;
    }
  }

  // ── Icon color per type ────────────────────────────────────
  Color _typeColor(String type) {
    switch (type) {
      case 'done':   return TColors.success;
      case 'update': return TColors.primary;
      default:       return TColors.info;
    }
  }

  // ── Icon background per type ───────────────────────────────
  Color _typeBg(String type) {
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

          // ── Header ──────────────────────────────────────────
          // White card header with title + unread count badge.
          Container(
            color: isDark ? TColors.cardDark : TColors.cardLight,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Notifications',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TColors.textPrimary,
                    fontFamily: 'Poppins',
                  )),
                Row(children: [
                  // Unread count badge — only show if > 0
                  if (_unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: TColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$_unreadCount nouveau',
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        )),
                    ),
                  const SizedBox(width: 8),
                  // Mark all as read — only show if unread exist
                  if (_unreadCount > 0)
                    GestureDetector(
                      onTap: _markAllRead,
                      child: const Text('Tout lire',
                        style: TextStyle(
                          fontSize: 9,
                          color: TColors.primary,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        )),
                    ),
                ]),
              ],
            ),
          ),

          // ── Notifications List ───────────────────────────────
          // Fixed list — no scroll needed for 4 items.
          // Each item is a card with left border accent for unread.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: List.generate(_notifs.length, (i) {
                  final n = _notifs[i];
                  final unread = !(n['read'] as bool);
                  return _buildNotifCard(
                    n, i, unread, isDark);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Notification Card ──────────────────────────────────────
  // White card with:
  // - Red left border accent for unread items
  // - Colored circle avatar with type icon
  // - Message text (bold if unread, regular if read)
  // - Timestamp below message
  // - Red dot indicator top right for unread
  Widget _buildNotifCard(
      Map<String, dynamic> n,
      int index,
      bool unread,
      bool isDark) {

    final type = n['type'] as String;

    return GestureDetector(
      onTap: () => _markRead(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        decoration: BoxDecoration(
          // Red tinted background for unread, plain card for read
          color: unread
            ? TColors.primaryLight
            : (isDark ? TColors.cardDark : TColors.cardLight),
          borderRadius: BorderRadius.circular(14),
          // Red left border accent on unread notifications
          border: unread
            ? Border(
                left: const BorderSide(
                  color: TColors.primary, width: 3),
                top: BorderSide(
                  color: TColors.borderLight, width: 0.5),
                right: BorderSide(
                  color: TColors.borderLight, width: 0.5),
                bottom: BorderSide(
                  color: TColors.borderLight, width: 0.5),
              )
            : Border.all(
                color: TColors.borderLight, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Circle avatar with type icon
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                // Use type color for read, red for unread
                color: unread
                  ? TColors.primaryLight
                  : _typeBg(type),
                shape: BoxShape.circle,
                border: Border.all(
                  color: unread
                    ? TColors.primary
                    : _typeColor(type).withValues(alpha: 0.3),
                  width: 1),
              ),
              child: Icon(
                _typeIcon(type),
                size: 14,
                color: unread
                  ? TColors.primary
                  : _typeColor(type),
              ),
            ),

            const SizedBox(width: 10),

            // Message and timestamp
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n['msg'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Poppins',
                      // Bold for unread — draws attention
                      fontWeight: unread
                        ? FontWeight.w500 : FontWeight.w400,
                      color: isDark
                        ? TColors.textWhite : TColors.textPrimary,
                      height: 1.4,
                    )),
                  const SizedBox(height: 3),
                  Text(n['time'] as String,
                    style: const TextStyle(
                      fontSize: 8,
                      color: TColors.textHint,
                      fontFamily: 'Poppins',
                    )),
                ],
              ),
            ),

            // Unread indicator dot — top right corner
            if (unread) ...[
              const SizedBox(width: 6),
              Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                  color: TColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}