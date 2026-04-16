import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';
import 'package:frontend_t_hero/utils/constants/api_constant.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  int _filter = 0;
  final _filters = ['Tous', 'Citoyens', 'Agents'];

  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // ── GET all users ──────────────────────────────────────────
  Future<void> _fetchUsers() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse(ApiConstants.getAllUsers),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List;
        setState(() {
          _users = list
            .map((e) => e as Map<String, dynamic>)
            .toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  // ── POST create user ───────────────────────────────────────
  Future<void> _createUser(String nom, String email,
      String motDePasse, String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      String url = role == 'AGENT_MUNICIPAL'
        ? ApiConstants.createAgent
        : ApiConstants.createUser;

      final body = role == 'AGENT_MUNICIPAL'
        ? {
            'nom': nom, 'email': email,
            'motDePasse': motDePasse,
            'code_Agent': 1234,
          }
        : {
            'nom': nom, 'email': email,
            'motDePasse': motDePasse,
          };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        _showSnack('Utilisateur ajouté avec succès ✓',
          TColors.success);
        await _fetchUsers();
      } else {
        final data = jsonDecode(response.body);
        _showSnack(
          data['message'] ?? 'Erreur création', TColors.error);
      }
    } catch (e) {
      _showSnack('Erreur serveur', TColors.error);
    }
  }

  // ── PUT update user ────────────────────────────────────────
  Future<void> _updateUser(String id, String nom,
      String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/users/UpdateUser/$id'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'nom': nom, 'email': email}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _showSnack('Utilisateur modifié ✓', TColors.success);
        await _fetchUsers();
      } else {
        final data = jsonDecode(response.body);
        _showSnack(
          data['message'] ?? 'Erreur modification', TColors.error);
      }
    } catch (e) {
      _showSnack('Erreur serveur', TColors.error);
    }
  }

  // ── PUT toggle isBlocked ───────────────────────────────────
  Future<void> _toggleBlock(String id, bool currentlyBlocked) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/users/UpdateUser/$id'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'isBlocked': !currentlyBlocked}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _showSnack(
          currentlyBlocked ? 'Compte activé ✓' : 'Compte désactivé',
          currentlyBlocked ? TColors.success : TColors.warning);
        await _fetchUsers();
      } else {
        _showSnack('Erreur mise à jour', TColors.error);
      }
    } catch (e) {
      _showSnack('Erreur serveur', TColors.error);
    }
  }

  // ── DELETE user ────────────────────────────────────────────
  Future<void> _deleteUser(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/users/DeleteUser/$id'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _showSnack('Utilisateur supprimé', TColors.success);
        await _fetchUsers();
      } else {
        _showSnack('Erreur suppression', TColors.error);
      }
    } catch (e) {
      _showSnack('Erreur serveur', TColors.error);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
        style: const TextStyle(
          fontSize: 13, fontFamily: 'Poppins')),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── Helpers ────────────────────────────────────────────────
  Color _roleColor(String r) {
    switch (r) {
      case 'ADMIN':           return TColors.primary;
      case 'AGENT_MUNICIPAL': return TColors.info;
      default:                return TColors.success;
    }
  }

  Color _roleBg(String r) {
    switch (r) {
      case 'ADMIN':           return TColors.primaryLight;
      case 'AGENT_MUNICIPAL': return TColors.infoLight;
      default:                return TColors.successLight;
    }
  }

  String _roleLabel(String r) {
    switch (r) {
      case 'ADMIN':           return 'Admin';
      case 'AGENT_MUNICIPAL': return 'Agent';
      default:                return 'Citoyen';
    }
  }

  String _initials(String nom) {
    final parts = nom.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nom.length >= 2
      ? nom.substring(0, 2).toUpperCase() : nom.toUpperCase();
  }

  // ── Filtered list ──────────────────────────────────────────
  List<Map<String, dynamic>> get _filtered {
    if (_filter == 0) return _users;
    if (_filter == 1) return _users
      .where((u) => u['role'] == 'CITOYEN').toList();
    return _users
      .where((u) => u['role'] == 'AGENT_MUNICIPAL').toList();
  }

  // ── Add user dialog ────────────────────────────────────────
  void _showAddDialog() {
    final nomCtrl   = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl  = TextEditingController();
    String selectedRole = 'CITOYEN';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
            20, 12, 20,
            MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: TColors.borderLight,
                  borderRadius: BorderRadius.circular(2)),
              )),
              const SizedBox(height: 16),
              const Text('Ajouter un utilisateur',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TColors.textPrimary,
                  fontFamily: 'Poppins',
                )),
              const SizedBox(height: 20),

              // Role selector
              const Text('Rôle',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: TColors.textSecondary,
                  fontFamily: 'Poppins',
                )),
              const SizedBox(height: 8),
              Row(children: [
                'CITOYEN', 'AGENT_MUNICIPAL',
              ].map((role) {
                final active = selectedRole == role;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                      setSheet(() => selectedRole = role),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10),
                      decoration: BoxDecoration(
                        color: active
                          ? _roleBg(role) : TColors.light,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: active
                            ? _roleColor(role)
                            : TColors.borderLight,
                          width: active ? 1.5 : 0.5),
                      ),
                      child: Text(
                        role == 'CITOYEN'
                          ? 'Citoyen' : 'Agent Municipal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: active
                            ? FontWeight.w600 : FontWeight.w400,
                          color: active
                            ? _roleColor(role) : TColors.textHint,
                          fontFamily: 'Poppins',
                        )),
                    ),
                  ),
                );
              }).toList()),

              const SizedBox(height: 16),
              _sheetField(
                controller: nomCtrl,
                hint: 'Nom complet',
                icon: Icons.person_outline),
              const SizedBox(height: 10),
              _sheetField(
                controller: emailCtrl,
                hint: 'Email',
                icon: Icons.email_outlined,
                keyboard: TextInputType.emailAddress),
              const SizedBox(height: 10),
              _sheetField(
                controller: passCtrl,
                hint: 'Mot de passe',
                icon: Icons.lock_outline,
                obscure: true),
              const SizedBox(height: 20),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (nomCtrl.text.isNotEmpty &&
                        emailCtrl.text.isNotEmpty &&
                        passCtrl.text.isNotEmpty) {
                      Navigator.pop(context);
                      _createUser(
                        nomCtrl.text.trim(),
                        emailCtrl.text.trim(),
                        passCtrl.text.trim(),
                        selectedRole,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Ajouter',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Edit user dialog ───────────────────────────────────────
  void _showEditDialog(Map<String, dynamic> u) {
    final nomCtrl   = TextEditingController(text: u['nom'] ?? '');
    final emailCtrl = TextEditingController(text: u['email'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          20, 12, 20,
          MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: TColors.borderLight,
                borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 16),
            const Text('Modifier l\'utilisateur',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
                fontFamily: 'Poppins',
              )),
            const SizedBox(height: 20),
            _sheetField(
              controller: nomCtrl,
              hint: 'Nom complet',
              icon: Icons.person_outline),
            const SizedBox(height: 10),
            _sheetField(
              controller: emailCtrl,
              hint: 'Email',
              icon: Icons.email_outlined,
              keyboard: TextInputType.emailAddress),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (nomCtrl.text.isNotEmpty) {
                    Navigator.pop(context);
                    _updateUser(
                      u['_id'],
                      nomCtrl.text.trim(),
                      emailCtrl.text.trim(),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Enregistrer',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ))),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete confirmation ────────────────────────────────────
  void _showDeleteDialog(Map<String, dynamic> u) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer l\'utilisateur',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          )),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: TColors.textSecondary,
              fontFamily: 'Poppins',
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'Supprimer '),
              TextSpan(
                text: u['nom'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: TColors.textPrimary)),
              const TextSpan(
                text: ' ? Cette action est irréversible.'),
            ],
          )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
              style: TextStyle(
                fontSize: 14,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              ))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(u['_id']);
            },
            child: const Text('Supprimer',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
              ))),
        ],
      ),
    );
  }

  // ── Toggle block confirmation ──────────────────────────────
  void _showToggleDialog(Map<String, dynamic> u) {
    final isBlocked = u['isBlocked'] == true;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
        title: Text(
          isBlocked ? 'Activer le compte' : 'Désactiver le compte',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          )),
        content: Text(
          isBlocked
            ? 'L\'utilisateur pourra à nouveau se connecter.'
            : 'L\'utilisateur ne pourra plus se connecter.',
          style: const TextStyle(
            fontSize: 14,
            color: TColors.textSecondary,
            fontFamily: 'Poppins',
            height: 1.5,
          )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
              style: TextStyle(
                fontSize: 14,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              ))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocked
                ? TColors.success : TColors.warning,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              _toggleBlock(u['_id'], isBlocked);
            },
            child: Text(
              isBlocked ? 'Activer' : 'Désactiver',
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
              ))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── Header ────────────────────────────────────────
          Container(
            color: isDark ? TColors.cardDark : TColors.cardLight,
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Utilisateurs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TColors.textPrimary,
                        fontFamily: 'Poppins',
                      )),
                    Text('${_users.length} comptes au total',
                      style: const TextStyle(
                        fontSize: 12,
                        color: TColors.textHint,
                        fontFamily: 'Poppins',
                      )),
                  ],
                ),
                Row(children: [
                  // Refresh
                  GestureDetector(
                    onTap: _fetchUsers,
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: TColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.refresh,
                        color: TColors.primary, size: 20)),
                  ),
                  const SizedBox(width: 8),
                  // Add button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _showAddDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: TColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                          child: Row(children: [
                            Icon(Icons.add,
                              color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text('Ajouter',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              )),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),

          // ── Filter Tabs ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                  ? TColors.darkContainer
                  : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: List.generate(3, (i) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10),
                      decoration: BoxDecoration(
                        color: _filter == i
                          ? (isDark
                              ? TColors.cardDark
                              : TColors.cardLight)
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: _filter == i
                          ? Border.all(
                              color: TColors.borderLight,
                              width: 0.5)
                          : null,
                      ),
                      child: Text(_filters[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: _filter == i
                            ? FontWeight.w600 : FontWeight.w400,
                          color: _filter == i
                            ? TColors.primary : TColors.textHint,
                        )),
                    ),
                  ),
                )),
              ),
            ),
          ),

          // ── User List ─────────────────────────────────────
          Expanded(
            child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: TColors.primary))
              : filtered.isEmpty
                ? const Center(
                    child: Text('Aucun utilisateur',
                      style: TextStyle(
                        fontSize: 15,
                        color: TColors.textHint,
                        fontFamily: 'Poppins',
                      )))
                : RefreshIndicator(
                    onRefresh: _fetchUsers,
                    color: TColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) =>
                        _userCard(filtered[i], isDark),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _userCard(Map<String, dynamic> u, bool isDark) {
    final isBlocked = u['isBlocked'] == true;
    final isAdmin   = u['role'] == 'ADMIN';
    final nom       = u['nom'] ?? '';
    final email     = u['email'] ?? '';
    final role      = u['role'] ?? 'CITOYEN';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isBlocked
          ? (isDark
              ? TColors.darkContainer
              : const Color(0xFFF5F5F5))
          : (isDark ? TColors.cardDark : TColors.cardLight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 12),
      child: Row(children: [

        // Avatar with active dot
        Stack(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: isBlocked
                ? TColors.lightContainer : _roleBg(role),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(_initials(nom),
                style: TextStyle(
                  fontSize: 14,
                  color: isBlocked
                    ? TColors.textHint : _roleColor(role),
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                )),
            ),
          ),
          Positioned(
            bottom: 1, right: 1,
            child: Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                color: isBlocked
                  ? TColors.grey : TColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ]),

        const SizedBox(width: 12),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nom,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isBlocked
                    ? TColors.textHint
                    : (isDark
                        ? TColors.textWhite : TColors.textPrimary),
                  fontFamily: 'Poppins',
                )),
              const SizedBox(height: 2),
              Text(email,
                style: const TextStyle(
                  fontSize: 12,
                  color: TColors.textHint,
                  fontFamily: 'Poppins',
                )),
              if (isBlocked) ...[
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: TColors.warningLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Désactivé',
                    style: TextStyle(
                      fontSize: 10,
                      color: TColors.warning,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ))),
              ],
            ],
          ),
        ),

        // Role pill
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isBlocked
              ? TColors.lightContainer : _roleBg(role),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(_roleLabel(role),
            style: TextStyle(
              fontSize: 11,
              color: isBlocked
                ? TColors.textHint : _roleColor(role),
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            )),
        ),

        const SizedBox(width: 8),

        // Action menu
        if (!isAdmin)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
              size: 20, color: TColors.grey),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
            elevation: 2,
            onSelected: (value) {
              if (value == 'edit')   _showEditDialog(u);
              if (value == 'toggle') _showToggleDialog(u);
              if (value == 'delete') _showDeleteDialog(u);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit_outlined,
                    size: 18, color: TColors.info),
                  SizedBox(width: 10),
                  Text('Modifier',
                    style: TextStyle(
                      fontSize: 14, fontFamily: 'Poppins')),
                ])),
              PopupMenuItem(
                value: 'toggle',
                child: Row(children: [
                  Icon(
                    isBlocked
                      ? Icons.check_circle_outline
                      : Icons.block_outlined,
                    size: 18,
                    color: isBlocked
                      ? TColors.success : TColors.warning),
                  const SizedBox(width: 10),
                  Text(
                    isBlocked ? 'Activer' : 'Désactiver',
                    style: const TextStyle(
                      fontSize: 14, fontFamily: 'Poppins')),
                ])),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline,
                    size: 18, color: TColors.error),
                  SizedBox(width: 10),
                  Text('Supprimer',
                    style: TextStyle(
                      fontSize: 14,
                      color: TColors.error,
                      fontFamily: 'Poppins')),
                ])),
            ],
          ),
      ]),
    );
  }

  Widget _sheetField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.light,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 4),
      child: Row(children: [
        Icon(icon, size: 20, color: TColors.textHint),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            obscureText: obscure,
            style: const TextStyle(
              fontSize: 14,
              color: TColors.textPrimary,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: TColors.textHint,
                fontFamily: 'Poppins',
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12),
            ),
          ),
        ),
      ]),
    );
  }
}