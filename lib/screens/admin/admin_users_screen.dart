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

  // [ADDED] Search
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

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
        setState(() {
          _users = (data['data'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _createUser(String nom, String email,
      String motDePasse, String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final url   = role == 'AGENT_MUNICIPAL'
        ? ApiConstants.createAgent
        : ApiConstants.createUser;
      final body  = role == 'AGENT_MUNICIPAL'
        ? { 'nom': nom, 'email': email,
            'motDePasse': motDePasse, 'code_Agent': 1234 }
        : { 'nom': nom, 'email': email,
            'motDePasse': motDePasse };
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 201) {
        _snack('Utilisateur ajouté ✓', TColors.success);
        await _fetchUsers();
      } else {
        final data = jsonDecode(response.body);
        _snack(data['message'] ?? 'Erreur', TColors.error);
      }
    } catch (_) {
      _snack('Erreur serveur', TColors.error);
    }
  }

  Future<void> _updateUser(String id, String nom, String email) async {
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
        _snack('Utilisateur modifié ✓', TColors.success);
        await _fetchUsers();
      } else {
        _snack('Erreur modification', TColors.error);
      }
    } catch (_) {
      _snack('Erreur serveur', TColors.error);
    }
  }

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
        _snack('Utilisateur supprimé', TColors.success);
        await _fetchUsers();
      } else {
        _snack('Erreur suppression', TColors.error);
      }
    } catch (_) {
      _snack('Erreur serveur', TColors.error);
    }
  }

  Future<void> _toggleBlock(String id, bool currentlyBlocked) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.put(
        Uri.parse('${ApiConstants.toggleBlockUser}/$id'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        _snack(
          currentlyBlocked ? 'Compte activé ✓' : 'Compte désactivé ✓',
          currentlyBlocked ? TColors.success : TColors.warning,
        );
        await _fetchUsers();
      } else {
        final data = jsonDecode(response.body);
        _snack(data['message'] ?? 'Erreur', TColors.error);
      }
    } catch (_) {
      _snack('Erreur serveur', TColors.error);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
        style: const TextStyle(fontSize: 13, fontFamily: 'Poppins')),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

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

  String _roleEmoji(String r) {
    switch (r) {
      case 'ADMIN':           return '🛡️';
      case 'AGENT_MUNICIPAL': return '🦸';
      default:                return '👤';
    }
  }

  String _initials(String nom) {
    final parts = nom.trim().split(' ');
    if (parts.length >= 2)
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return nom.length >= 2
      ? nom.substring(0, 2).toUpperCase()
      : nom.toUpperCase();
  }

  // [ADDED] Filter by role tab AND search query
  List<Map<String, dynamic>> get _filtered {
    List<Map<String, dynamic>> list;
    if (_filter == 0)      list = _users;
    else if (_filter == 1) list = _users.where((u) => u['role'] == 'CITOYEN').toList();
    else                   list = _users.where((u) => u['role'] == 'AGENT_MUNICIPAL').toList();

    if (_searchQuery.isEmpty) return list;

    return list.where((u) {
      final nom   = (u['nom']   ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      return nom.contains(_searchQuery) || email.contains(_searchQuery);
    }).toList();
  }

  int get _citoyens =>
    _users.where((u) => u['role'] == 'CITOYEN').length;
  int get _agents =>
    _users.where((u) => u['role'] == 'AGENT_MUNICIPAL').length;

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
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
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
              const Row(children: [
                Text('➕ ', style: TextStyle(fontSize: 18)),
                Text('Ajouter un utilisateur',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                    color: TColors.textPrimary, fontFamily: 'Poppins')),
              ]),
              const SizedBox(height: 20),
              Row(children: [
                'CITOYEN', 'AGENT_MUNICIPAL',
              ].map((role) {
                final active = selectedRole == role;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setSheet(() => selectedRole = role),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? _roleBg(role) : TColors.light,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: active ? _roleColor(role) : TColors.borderLight,
                          width: active ? 1.5 : 0.5)),
                      child: Text(
                        role == 'CITOYEN' ? '👤 Citoyen' : '🦸 Agent',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                          color: active ? _roleColor(role) : TColors.textHint,
                          fontFamily: 'Poppins')),
                    ),
                  ),
                );
              }).toList()),
              const SizedBox(height: 16),
              _sheetField(controller: nomCtrl,   hint: 'Nom complet',  icon: Icons.person_outline),
              const SizedBox(height: 10),
              _sheetField(controller: emailCtrl, hint: 'Email',        icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
              const SizedBox(height: 10),
              _sheetField(controller: passCtrl,  hint: 'Mot de passe', icon: Icons.lock_outline,   obscure: true),
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
                        selectedRole);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                    elevation: 0),
                  child: const Text('Ajouter',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins'))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> u) {
    final nomCtrl   = TextEditingController(text: u['nom']   ?? '');
    final emailCtrl = TextEditingController(text: u['email'] ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
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
            const Row(children: [
              Text('✏️ ', style: TextStyle(fontSize: 18)),
              Text('Modifier l\'utilisateur',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: TColors.textPrimary, fontFamily: 'Poppins')),
            ]),
            const SizedBox(height: 20),
            _sheetField(controller: nomCtrl,   hint: 'Nom complet', icon: Icons.person_outline),
            const SizedBox(height: 10),
            _sheetField(controller: emailCtrl, hint: 'Email',       icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (nomCtrl.text.isNotEmpty) {
                    Navigator.pop(context);
                    _updateUser(u['_id'], nomCtrl.text.trim(), emailCtrl.text.trim());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                  elevation: 0),
                child: const Text('Enregistrer',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins'))),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> u) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer l\'utilisateur',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: TColors.textSecondary,
              fontFamily: 'Poppins', height: 1.5),
            children: [
              const TextSpan(text: 'Supprimer '),
              TextSpan(text: u['nom'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.w700, color: TColors.textPrimary)),
              const TextSpan(text: ' ? Action irréversible.'),
            ])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
              style: TextStyle(fontSize: 14, color: TColors.textHint, fontFamily: 'Poppins'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.error, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0),
            onPressed: () { Navigator.pop(context); _deleteUser(u['_id']); },
            child: const Text('Supprimer',
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'))),
        ],
      ),
    );
  }

  void _showToggleBlockDialog(Map<String, dynamic> u) {
    final isBlocked = u['isBlocked'] == true;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Text(isBlocked ? '🔓 ' : '🔒 ', style: const TextStyle(fontSize: 18)),
          Text(isBlocked ? 'Activer le compte' : 'Désactiver le compte',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
        ]),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: TColors.textSecondary,
              fontFamily: 'Poppins', height: 1.5),
            children: [
              TextSpan(text: isBlocked ? 'Activer le compte de ' : 'Désactiver le compte de '),
              TextSpan(text: u['nom'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.w700, color: TColors.textPrimary)),
              TextSpan(text: isBlocked
                ? ' ? Il pourra se reconnecter.'
                : ' ? Il ne pourra plus se connecter.'),
            ])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
              style: TextStyle(fontSize: 14, color: TColors.textHint, fontFamily: 'Poppins'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocked ? TColors.success : TColors.warning,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0),
            onPressed: () { Navigator.pop(context); _toggleBlock(u['_id'], isBlocked); },
            child: Text(isBlocked ? 'Activer' : 'Désactiver',
              style: const TextStyle(fontSize: 14, fontFamily: 'Poppins'))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── Gradient Header ──────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [TColors.primary, Color(0xFFE53935)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(28),
                bottomRight: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('👥 Utilisateurs',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                          color: Colors.white, fontFamily: 'Poppins')),
                      Text('Gérez les comptes',
                        style: TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'Poppins')),
                    ],
                  ),
                  Row(children: [
                    GestureDetector(
                      onTap: _fetchUsers,
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
                        child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 17)),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showAddDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: const Row(children: [
                          Icon(Icons.add, color: TColors.primary, size: 16),
                          SizedBox(width: 5),
                          Text('Ajouter',
                            style: TextStyle(fontSize: 13, color: TColors.primary,
                              fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                        ]),
                      ),
                    ),
                  ]),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
                child: Row(children: [
                  _bannerStat('${_users.length}', 'Total',    Icons.people_outline),
                  _bannerDiv(),
                  _bannerStat('$_citoyens',        'Citoyens', Icons.person_outline),
                  _bannerDiv(),
                  _bannerStat('$_agents',           'Agents',  Icons.engineering_outlined),
                ]),
              ),
            ]),
          ),

          // [ADDED] Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? TColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TColors.borderLight, width: 0.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6, offset: const Offset(0, 2)),
                ]),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(children: [
                const Icon(Icons.search_rounded, color: TColors.textHint, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(
                      fontSize: 14, color: TColors.textPrimary, fontFamily: 'Poppins'),
                    decoration: const InputDecoration(
                      hintText: 'Rechercher par nom ou email...',
                      hintStyle: TextStyle(
                        fontSize: 13, color: TColors.textHint, fontFamily: 'Poppins'),
                      border:        InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10)),
                  ),
                ),
                // [ADDED] Clear button — appears only when search is active
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(Icons.close_rounded,
                      color: TColors.textHint, size: 18)),
              ]),
            ),
          ),

          // ── Filter Tabs ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? TColors.darkContainer : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: List.generate(3, (i) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _filter == i
                          ? (isDark ? TColors.cardDark : Colors.white)
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: _filter == i
                          ? Border.all(color: TColors.borderLight, width: 0.5)
                          : null),
                      child: Text(_filters[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13, fontFamily: 'Poppins',
                          fontWeight: _filter == i ? FontWeight.w600 : FontWeight.w400,
                          color: _filter == i ? TColors.primary : TColors.textHint)),
                    ),
                  ),
                )),
              ),
            ),
          ),

          // [UPDATED] Count line shows search context
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              _searchQuery.isNotEmpty
                ? '${filtered.length} résultat(s) pour "$_searchQuery"'
                : '${filtered.length} utilisateur(s)',
              style: const TextStyle(
                fontSize: 12, color: TColors.textHint, fontFamily: 'Poppins')),
          ),

          // ── List ─────────────────────────────────────────
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator(color: TColors.primary))
              : filtered.isEmpty
                ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _searchQuery.isNotEmpty ? '🔍' : '👥',
                        style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty
                          ? 'Aucun résultat pour "$_searchQuery"'
                          : 'Aucun utilisateur',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                          color: TColors.textPrimary, fontFamily: 'Poppins')),
                      const SizedBox(height: 6),
                      Text(
                        _searchQuery.isNotEmpty
                          ? 'Essayez un autre nom ou email'
                          : 'Ajoutez un compte pour commencer',
                        style: const TextStyle(fontSize: 13, color: TColors.textHint,
                          fontFamily: 'Poppins')),
                    ],
                  ))
                : RefreshIndicator(
                    onRefresh: _fetchUsers,
                    color: TColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _userCard(filtered[i], isDark),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _userCard(Map<String, dynamic> u, bool isDark) {
    final isAdmin   = u['role'] == 'ADMIN';
    final isBlocked = u['isBlocked'] == true;
    final nom       = u['nom']   ?? '';
    final email     = u['email'] ?? '';
    final role      = u['role']  ?? 'CITOYEN';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isBlocked
          ? (isDark ? TColors.cardDark.withValues(alpha: 0.6) : const Color(0xFFFFF3F3))
          : (isDark ? TColors.cardDark : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBlocked ? TColors.error.withValues(alpha: 0.3) : TColors.borderLight,
          width: isBlocked ? 1.0 : 0.5),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Opacity(
          opacity: isBlocked ? 0.5 : 1.0,
          child: Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: isBlocked ? TColors.borderLight : _roleBg(role),
              shape: BoxShape.circle),
            child: Center(
              child: Text(_initials(nom),
                style: TextStyle(
                  fontSize: 14,
                  color: isBlocked ? TColors.textHint : _roleColor(role),
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins'))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(_roleEmoji(role), style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(nom,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: isBlocked
                        ? TColors.textHint
                        : (isDark ? TColors.textWhite : TColors.textPrimary),
                      fontFamily: 'Poppins',
                      decoration: isBlocked
                        ? TextDecoration.lineThrough : TextDecoration.none))),
              ]),
              const SizedBox(height: 2),
              Text(email,
                style: const TextStyle(fontSize: 11, color: TColors.textHint, fontFamily: 'Poppins')),
              if (isBlocked) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: TColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                  child: const Text('🔒 Compte désactivé',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                      color: TColors.error, fontFamily: 'Poppins')),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isBlocked ? TColors.borderLight : _roleBg(role),
            borderRadius: BorderRadius.circular(20)),
          child: Text(_roleLabel(role),
            style: TextStyle(
              fontSize: 11,
              color: isBlocked ? TColors.textHint : _roleColor(role),
              fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
        ),
        const SizedBox(width: 6),
        if (!isAdmin)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20, color: TColors.grey),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
            onSelected: (value) {
              if (value == 'edit')   _showEditDialog(u);
              if (value == 'block')  _showToggleBlockDialog(u);
              if (value == 'delete') _showDeleteDialog(u);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit_outlined, size: 18, color: TColors.info),
                  SizedBox(width: 10),
                  Text('Modifier',
                    style: TextStyle(fontSize: 14, fontFamily: 'Poppins')),
                ])),
              PopupMenuItem(
                value: 'block',
                child: Row(children: [
                  Icon(isBlocked ? Icons.lock_open_outlined : Icons.lock_outline,
                    size: 18, color: isBlocked ? TColors.success : TColors.warning),
                  const SizedBox(width: 10),
                  Text(isBlocked ? 'Activer' : 'Désactiver',
                    style: TextStyle(fontSize: 14, fontFamily: 'Poppins',
                      color: isBlocked ? TColors.success : TColors.warning)),
                ])),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline, size: 18, color: TColors.error),
                  SizedBox(width: 10),
                  Text('Supprimer',
                    style: TextStyle(fontSize: 14, color: TColors.error, fontFamily: 'Poppins')),
                ])),
            ],
          ),
      ]),
    );
  }

  Widget _bannerStat(String num, String label, IconData icon) {
    return Expanded(
      child: Column(children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 15),
        const SizedBox(height: 3),
        Text(num, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
          color: Colors.white, fontFamily: 'Poppins')),
        const SizedBox(height: 1),
        Text(label, style: TextStyle(fontSize: 9,
          color: Colors.white.withValues(alpha: 0.75), fontFamily: 'Poppins')),
      ]),
    );
  }

  Widget _bannerDiv() => Container(
    width: 1, height: 28,
    color: Colors.white.withValues(alpha: 0.2));

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
        border: Border.all(color: TColors.borderLight, width: 0.5)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(children: [
        Icon(icon, size: 20, color: TColors.textHint),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            obscureText: obscure,
            style: const TextStyle(fontSize: 14, color: TColors.textPrimary, fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 14, color: TColors.textHint, fontFamily: 'Poppins'),
              border:        InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
      ]),
    );
  }
}