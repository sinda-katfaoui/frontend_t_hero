import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';
import 'package:frontend_t_hero/utils/constants/api_constant.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  NotificationsScreenState createState() =>
      NotificationsScreenState();
}

class NotificationsScreenState
    extends State<NotificationsScreen> {

  List<Map<String, dynamic>> _notifs = [];
  bool _loading = true;
  String _userId = '';
  String _token  = '';

  @override
  void initState() {
    super.initState();
    _loadAndFetch();
  }

  // ✅ Fixed: reload everything if token not ready yet
  void refresh() {
    if (_token.isEmpty || _userId.isEmpty) {
      _loadAndFetch();
    } else {
      _fetchNotifs(_token, _userId);
    }
  }

  Future<void> _loadAndFetch() async {
    final prefs   = await SharedPreferences.getInstance();
    final token   = prefs.getString('token') ?? '';
    final userRaw = prefs.getString('user') ?? '{}';
    final user    = jsonDecode(userRaw);

    String uid = user['_id'] ?? user['id'] ?? '';
    if (uid.isEmpty && token.isNotEmpty) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final norm    = base64Url.normalize(parts[1]);
          final decoded =
            utf8.decode(base64Url.decode(norm));
          uid = jsonDecode(decoded)['id'] ?? '';
        }
      } catch (_) {}
    }

    setState(() {
      _userId = uid;
      _token  = token;
    });
    await _fetchNotifs(token, uid);
  }

  Future<void> _fetchNotifs(String token, String uid) async {
    if (uid.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/notifications'
          '/GetNotificationsByCitoyen/$uid'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('Notif status: ${response.statusCode}');
      debugPrint('Notif body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List? ?? [];
        setState(() {
          _notifs = list
            .map((e) => e as Map<String, dynamic>)
            .toList()
            ..sort((a, b) {
              final da = DateTime.tryParse(
                a['createdAt'] ?? '') ?? DateTime(0);
              final db = DateTime.tryParse(
                b['createdAt'] ?? '') ?? DateTime(0);
              return db.compareTo(da);
            });
          _loading = false;
        });
      } else {
        setState(() { _notifs = []; _loading = false; });
      }
    } catch (e) {
      debugPrint('Notif fetch error: $e');
      setState(() { _notifs = []; _loading = false; });
    }
  }

  Future<void> _markRead(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      await http.put(
        Uri.parse(
          '${ApiConstants.baseUrl}/notifications'
          '/UpdateNotification/$id'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'lu': true}),
      ).timeout(const Duration(seconds: 10));
      setState(() {
        final i = _notifs.indexWhere(
          (n) => n['_id'] == id);
        if (i != -1) _notifs[i]['lu'] = true;
      });
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    for (final n in _notifs) {
      if (!(n['lu'] as bool? ?? false)) {
        await _markRead(n['_id'] ?? '');
      }
    }
  }

  int get _unreadCount =>
    _notifs.where((n) =>
      !(n['lu'] as bool? ?? false)).length;

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1)  return 'À l\'instant';
      if (diff.inMinutes < 60)
        return 'Il y a ${diff.inMinutes}min';
      if (diff.inHours < 24)
        return 'Il y a ${diff.inHours}h';
      if (diff.inDays == 1) return 'Hier';
      return 'Il y a ${diff.inDays}j';
    } catch (_) { return ''; }
  }

  String _emoji(String? type) {
    switch (type) {
      case 'RESOLU':   return '✅';
      case 'EN_COURS': return '⚡';
      default:         return 'ℹ️';
    }
  }

  Color _iconColor(String? type) {
    switch (type) {
      case 'RESOLU':   return TColors.success;
      case 'EN_COURS': return TColors.primary;
      default:         return TColors.info;
    }
  }

  Color _iconBg(String? type) {
    switch (type) {
      case 'RESOLU':   return TColors.successLight;
      case 'EN_COURS': return TColors.primaryLight;
      default:         return TColors.infoLight;
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
                      Text(
                        'Restez informé de vos signalements',
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
                        'Vous avez $_unreadCount '
                        'nouvelle(s) non lue(s)',
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

          Expanded(
            child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: TColors.primary))
              : _notifs.isEmpty
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
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () =>
                            _fetchNotifs(_token, _userId),
                          child: Container(
                            padding:
                              const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10),
                            decoration: BoxDecoration(
                              color: TColors.primaryLight,
                              borderRadius:
                                BorderRadius.circular(14)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.refresh_rounded,
                                  color: TColors.primary,
                                  size: 16),
                                SizedBox(width: 6),
                                Text('Actualiser',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: TColors.primary,
                                    fontWeight:
                                      FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  )),
                              ]),
                          ),
                        ),
                      ],
                    ))
                : RefreshIndicator(
                    onRefresh: () async =>
                      _fetchNotifs(_token, _userId),
                    color: TColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                      itemCount: _notifs.length,
                      itemBuilder: (_, i) {
                        final n      = _notifs[i];
                        final unread =
                          !(n['lu'] as bool? ?? false);
                        final type = n['type'] as String?;
                        final msg  =
                          n['message'] ?? 'Notification';
                        final time =
                          _timeAgo(n['createdAt']);
                        final id = n['_id'] ?? '';

                        return GestureDetector(
                          onTap: () => _markRead(id),
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
                                  offset:
                                    const Offset(0, 2)),
                              ]),
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment:
                                CrossAxisAlignment.start,
                              children: [

                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color: unread
                                      ? TColors.primaryLight
                                      : _iconBg(type),
                                    borderRadius:
                                      BorderRadius.circular(
                                        13),
                                    border: Border.all(
                                      color: unread
                                        ? TColors.primary
                                            .withValues(
                                              alpha: 0.3)
                                        : _iconColor(type)
                                            .withValues(
                                              alpha: 0.2),
                                      width: 1)),
                                  child: Center(
                                    child: Text(
                                      _emoji(type),
                                      style: const TextStyle(
                                        fontSize: 20)))),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                      CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(msg,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                          fontWeight: unread
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                          color: isDark
                                            ? TColors.textWhite
                                            : TColors
                                                .textPrimary,
                                        )),
                                      const SizedBox(height: 4),
                                      Text(time,
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
                                    margin:
                                      const EdgeInsets.only(
                                        top: 4),
                                    width: 10, height: 10,
                                    decoration: BoxDecoration(
                                      color: TColors.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: TColors.primary
                                            .withValues(
                                              alpha: 0.4),
                                          blurRadius: 4,
                                          offset: const Offset(
                                            0, 1)),
                                      ])),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),

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
                      borderRadius:
                        BorderRadius.circular(14)),
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