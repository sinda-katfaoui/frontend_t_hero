import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notifs = [
    {'msg': 'Votre signalement a été pris en charge par Agent Habib',
     'time': 'Il y a 5 min', 'read': false, 'type': 'update'},
    {'msg': 'Nid de poule marqué Résolu',
     'time': 'Il y a 1h', 'read': false, 'type': 'done'},
    {'msg': 'Signalement Lampadaire enregistré',
     'time': 'Hier 18:30', 'read': true, 'type': 'info'},
    {'msg': 'Déchets Sousse résolu avec succès',
     'time': 'Il y a 3j', 'read': true, 'type': 'done'},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Container(
          color: TColors.primary,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notifications',
                style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)),
                child: const Text('2 new',
                  style: TextStyle(fontSize: 11,
                    color: TColors.primary,
                    fontWeight: FontWeight.w500))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  for (final n in _notifs) {
                    n['read'] = true;
                  }
                });
              },
              child: const Text('Tout marquer comme lu'))),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _notifs.length,
            itemBuilder: (context, i) {
              final n = _notifs[i];
              final unread = !(n['read'] as bool);
              return Container(
                color: unread
                  ? TColors.primaryLight.withValues(alpha: 0.3)
                  : Colors.transparent,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: unread
                      ? TColors.primaryLight
                      : TColors.lightContainer,
                    child: Icon(
                      n['type'] == 'done'
                        ? Icons.check_circle_outline
                        : n['type'] == 'update'
                          ? Icons.update
                          : Icons.info_outline,
                      color: unread ? TColors.primary : TColors.grey,
                      size: 18)),
                  title: Text(n['msg'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: unread
                        ? FontWeight.w500 : FontWeight.w400)),
                  subtitle: Text(n['time'] as String,
                    style: const TextStyle(fontSize: 11)),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}