import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  int _filter = 0;
  final _filters = ['Tous', 'Citoyens', 'Agents'];

  // ── Mutable user list — admin can add/edit/delete ──────────
  final List<Map<String, String>> _users = [
    {'nom': 'Admin Principal', 'email': 'admin@thero.com',
     'role': 'ADMIN', 'initials': 'AP', 'actif': 'true'},
    {'nom': 'Agent Habib', 'email': 'habib@thero.com',
     'role': 'AGENT_MUNICIPAL', 'initials': 'AH', 'actif': 'true'},
    {'nom': 'Agent Sonia', 'email': 'sonia@thero.com',
     'role': 'AGENT_MUNICIPAL', 'initials': 'AS', 'actif': 'true'},
    {'nom': 'Amira Bouazizi', 'email': 'amira@test.com',
     'role': 'CITOYEN', 'initials': 'AB', 'actif': 'true'},
    {'nom': 'Mohamed Ben Ali', 'email': 'mohamed@test.com',
     'role': 'CITOYEN', 'initials': 'MB', 'actif': 'true'},
    {'nom': 'Sara Jouini', 'email': 'sara@test.com',
     'role': 'CITOYEN', 'initials': 'SJ', 'actif': 'false'},
    {'nom': 'Yassine Trabelsi', 'email': 'yassine@test.com',
     'role': 'CITOYEN', 'initials': 'YT', 'actif': 'true'},
  ];

  // ── Role helpers ───────────────────────────────────────────
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

  // ── Initials from name ─────────────────────────────────────
  String _initials(String nom) {
    final parts = nom.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nom.substring(0, 2).toUpperCase();
  }

  // ── Filtered list ──────────────────────────────────────────
  List<Map<String, String>> get _filtered {
    if (_filter == 0) return _users;
    if (_filter == 1)
      return _users.where((u) => u['role'] == 'CITOYEN').toList();
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
              // Handle
              Center(
                child: Container(
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
                          ? _roleBg(role)
                          : TColors.light,
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

              // Confirm button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (nomCtrl.text.isNotEmpty &&
                        emailCtrl.text.isNotEmpty) {
                      final nom = nomCtrl.text.trim();
                      setState(() => _users.add({
                        'nom':      nom,
                        'email':    emailCtrl.text.trim(),
                        'role':     selectedRole,
                        'initials': _initials(nom),
                        'actif':    'true',
                      }));
                      Navigator.pop(context);
                      _showSuccess(
                        'Utilisateur ajouté avec succès ✓');
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
  void _showEditDialog(int realIndex) {
    final u = _users[realIndex];
    final nomCtrl   = TextEditingController(text: u['nom']);
    final emailCtrl = TextEditingController(text: u['email']);

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
            Center(
              child: Container(
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
                    final nom = nomCtrl.text.trim();
                    setState(() {
                      _users[realIndex] = {
                        ..._users[realIndex],
                        'nom':      nom,
                        'email':    emailCtrl.text.trim(),
                        'initials': _initials(nom),
                      };
                    });
                    Navigator.pop(context);
                    _showSuccess('Utilisateur modifié ✓');
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

  // ── Delete confirmation dialog ─────────────────────────────
  void _showDeleteDialog(int realIndex) {
    final u = _users[realIndex];
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
                text: u['nom'],
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
              setState(() => _users.removeAt(realIndex));
              Navigator.pop(context);
              _showSuccess('Utilisateur supprimé');
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

  // ── Toggle activate/deactivate ─────────────────────────────
  void _toggleActif(int realIndex) {
    final isActif = _users[realIndex]['actif'] == 'true';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
        title: Text(
          isActif ? 'Désactiver le compte' : 'Activer le compte',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          )),
        content: Text(
          isActif
            ? 'L\'utilisateur ne pourra plus se connecter.'
            : 'L\'utilisateur pourra à nouveau se connecter.',
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
              backgroundColor: isActif
                ? TColors.warning : TColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              setState(() {
                _users[realIndex] = {
                  ..._users[realIndex],
                  'actif': isActif ? 'false' : 'true',
                };
              });
              Navigator.pop(context);
              _showSuccess(isActif
                ? 'Compte désactivé'
                : 'Compte activé ✓');
            },
            child: Text(
              isActif ? 'Désactiver' : 'Activer',
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
              ))),
        ],
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
        style: const TextStyle(
          fontSize: 13, fontFamily: 'Poppins')),
      backgroundColor: TColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)),
    ));
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 4),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final u = filtered[i];
                // Find real index in _users for mutations
                final realIndex = _users.indexOf(u);
                return _userCard(u, realIndex, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _userCard(
      Map<String, String> u, int realIndex, bool isDark) {
    final isActif = u['actif'] == 'true';
    final isAdmin = u['role'] == 'ADMIN';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isActif
          ? (isDark ? TColors.cardDark : TColors.cardLight)
          : (isDark
              ? TColors.darkContainer
              : const Color(0xFFF5F5F5)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActif
            ? TColors.borderLight
            : TColors.borderLight.withValues(alpha: 0.5),
          width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 12),
      child: Row(children: [

        // Avatar
        Stack(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: isActif
                ? _roleBg(u['role']!)
                : TColors.lightContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(u['initials']!,
                style: TextStyle(
                  fontSize: 14,
                  color: isActif
                    ? _roleColor(u['role']!)
                    : TColors.textHint,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                )),
            ),
          ),
          // Active indicator dot
          Positioned(
            bottom: 1, right: 1,
            child: Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                color: isActif
                  ? TColors.success : TColors.grey,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ]),

        const SizedBox(width: 12),

        // Name + email + status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(u['nom']!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActif
                    ? (isDark
                        ? TColors.textWhite : TColors.textPrimary)
                    : TColors.textHint,
                  fontFamily: 'Poppins',
                )),
              const SizedBox(height: 2),
              Text(u['email']!,
                style: TextStyle(
                  fontSize: 12,
                  color: isActif
                    ? TColors.textHint
                    : TColors.textHint.withValues(alpha: 0.6),
                  fontFamily: 'Poppins',
                )),
              if (!isActif) ...[
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
            color: isActif
              ? _roleBg(u['role']!)
              : TColors.lightContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(_roleLabel(u['role']!),
            style: TextStyle(
              fontSize: 11,
              color: isActif
                ? _roleColor(u['role']!) : TColors.textHint,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            )),
        ),

        const SizedBox(width: 8),

        // Action menu — not shown for admin
        if (!isAdmin)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
              size: 20, color: TColors.grey),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
            elevation: 2,
            onSelected: (value) {
              if (value == 'edit') _showEditDialog(realIndex);
              if (value == 'toggle') _toggleActif(realIndex);
              if (value == 'delete') _showDeleteDialog(realIndex);
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
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    )),
                ])),
              PopupMenuItem(
                value: 'toggle',
                child: Row(children: [
                  Icon(
                    isActif
                      ? Icons.block_outlined
                      : Icons.check_circle_outline,
                    size: 18,
                    color: isActif
                      ? TColors.warning : TColors.success),
                  const SizedBox(width: 10),
                  Text(
                    isActif ? 'Désactiver' : 'Activer',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    )),
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
                      fontFamily: 'Poppins',
                    )),
                ])),
            ],
          ),
      ]),
    );
  }

  // ── Reusable sheet input field ─────────────────────────────
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