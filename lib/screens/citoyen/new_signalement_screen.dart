// ============================================================
// NewSignalementScreen — Create a New Signalement
// ============================================================
// Allows a Citoyen to report a city problem.
// Design matches mockup exactly:
// - White AppBar with back button
// - Map placeholder with rounded corners inside white card
// - White input fields with visible borders
// - Modern bottom sheet style dropdowns for Catégorie/Priorité
// - Dashed red border photo button
// - Full width red submit button
// ============================================================

import 'package:flutter/material.dart';
import 'package:frontend_t_hero/utils/constants/colors.dart';

class NewSignalementScreen extends StatefulWidget {
  const NewSignalementScreen({super.key});
  @override
  State<NewSignalementScreen> createState() =>
      _NewSignalementScreenState();
}

class _NewSignalementScreenState
    extends State<NewSignalementScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _locCtrl  = TextEditingController();
  String? _categorie;
  String? _priorite;
  bool _loading = false;

  final _categories = [
    'Voirie', 'Eclairage', 'Propreté', 'Espaces Verts', 'Autre'];
  final _priorites = ['FAIBLE', 'MOYENNE', 'ELEVEE'];

  // Priority display labels and colors
  final _priorityLabels = {
    'FAIBLE':  'Faible',
    'MOYENNE': 'Moyenne',
    'ELEVEE':  'Élevée',
  };

  final _priorityColors = {
    'FAIBLE':  TColors.success,
    'MOYENNE': TColors.warning,
    'ELEVEE':  TColors.error,
  };

  final _priorityBgs = {
    'FAIBLE':  TColors.successLight,
    'MOYENNE': TColors.warningLight,
    'ELEVEE':  TColors.errorLight,
  };

  @override
  void dispose() {
    _descCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Signalement envoyé avec succès ✓',
          style: TextStyle(fontSize: 14, fontFamily: 'Poppins')),
        backgroundColor: TColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      ));
    });
  }

  // ── Modern bottom sheet picker ─────────────────────────────
  // Opens a styled bottom sheet instead of default dropdown.
  // Much more modern and chic than the standard Flutter dropdown.
  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildPickerSheet(
        title: 'Choisir une catégorie',
        items: _categories,
        selected: _categorie,
        onSelect: (v) => setState(() => _categorie = v),
        iconBuilder: (item) => _catIcon(item),
      ),
    );
  }

  void _showPriorityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildPickerSheet(
        title: 'Choisir la priorité',
        items: _priorites,
        selected: _priorite,
        onSelect: (v) => setState(() => _priorite = v),
        labelBuilder: (item) => _priorityLabels[item] ?? item,
        colorBuilder: (item) => _priorityColors[item],
        bgBuilder:    (item) => _priorityBgs[item],
      ),
    );
  }

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'Voirie':        return Icons.warning_amber_rounded;
      case 'Eclairage':     return Icons.lightbulb_outline;
      case 'Propreté':      return Icons.delete_outline;
      case 'Espaces Verts': return Icons.park_outlined;
      default:              return Icons.help_outline;
    }
  }

  // ── Bottom sheet picker widget ─────────────────────────────
  Widget _buildPickerSheet({
    required String title,
    required List<String> items,
    required String? selected,
    required void Function(String) onSelect,
    IconData Function(String)? iconBuilder,
    String Function(String)? labelBuilder,
    Color? Function(String)? colorBuilder,
    Color? Function(String)? bgBuilder,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: TColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: TColors.textPrimary,
              fontFamily: 'Poppins',
            )),
          const SizedBox(height: 16),
          ...items.map((item) {
            final isSelected = selected == item;
            final label = labelBuilder != null
              ? labelBuilder(item) : item;
            final color = colorBuilder != null
              ? colorBuilder(item) : TColors.primary;
            final bg = bgBuilder != null
              ? bgBuilder(item) : TColors.primaryLight;

            return GestureDetector(
              onTap: () {
                onSelect(item);
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                    ? (bg ?? TColors.primaryLight)
                    : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                      ? (color ?? TColors.primary)
                      : TColors.borderLight,
                    width: isSelected ? 1.5 : 0.5),
                ),
                child: Row(children: [
                  if (iconBuilder != null) ...[
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                          ? (color ?? TColors.primary)
                              .withValues(alpha: 0.12)
                          : TColors.light,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(iconBuilder(item),
                        size: 18,
                        color: isSelected
                          ? (color ?? TColors.primary)
                          : TColors.grey),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected
                          ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                          ? (color ?? TColors.primary)
                          : TColors.textPrimary,
                        fontFamily: 'Poppins',
                      )),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded,
                      color: color ?? TColors.primary,
                      size: 20),
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size   = MediaQuery.of(context).size;

    return Scaffold(
      // Always white/light background — matches mockup
      backgroundColor: isDark ? TColors.dark : TColors.light,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── AppBar — white with dark text ────────────
              Container(
                color: isDark ? TColors.cardDark : Colors.white,
                padding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
                child: Row(children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                      size: 20,
                      color: isDark
                        ? TColors.textWhite : TColors.textPrimary),
                    onPressed: () => Navigator.pop(context)),
                  Text('Nouveau signalement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                        ? TColors.textWhite : TColors.textPrimary,
                      fontFamily: 'Poppins',
                    )),
                ]),
              ),

              // ── Map placeholder — white card style ───────
              // Rounded corners + shadow gives card feel
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Container(
                  height: size.height * 0.20,
                  decoration: BoxDecoration(
                    color: isDark
                      ? const Color(0xFF1A2A1A)
                      : const Color(0xFFEFF4EF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: TColors.borderLight, width: 0.5),
                  ),
                  child: Stack(children: [
                    // Grid lines
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CustomPaint(
                        size: Size(size.width, size.height * 0.20),
                        painter: _GridPainter(isDark: isDark),
                      ),
                    ),
                    // Pin + label
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 52, height: 52,
                            decoration: const BoxDecoration(
                              color: TColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.location_on,
                              color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 8),
                          Text('Définir la localisation',
                            style: TextStyle(
                              fontSize: 13,
                              color: TColors.textHint,
                              fontFamily: 'Poppins',
                            )),
                        ],
                      ),
                    ),
                    // Location button
                    Positioned(
                      right: 12, bottom: 12,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: TColors.primary,
                            borderRadius:
                              BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.my_location,
                            color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),

              // ── Form fields ──────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      // Description — white card field
                      _whiteField(
                        controller: _descCtrl,
                        hint: 'Description du problème...',
                        icon: Icons.format_align_left_rounded,
                        isDark: isDark,
                        maxLines: 2,
                        validator: (v) =>
                          v!.isEmpty ? 'Requis' : null,
                      ),

                      // Localisation — white card field
                      _whiteField(
                        controller: _locCtrl,
                        hint: 'Localisation',
                        icon: Icons.place_outlined,
                        isDark: isDark,
                        validator: (v) =>
                          v!.isEmpty ? 'Requis' : null,
                      ),

                      // Catégorie + Priorité — modern tap pickers
                      Row(children: [
                        // Catégorie picker
                        Expanded(
                          child: GestureDetector(
                            onTap: _showCategoryPicker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark
                                  ? TColors.darkContainer
                                  : Colors.white,
                                borderRadius:
                                  BorderRadius.circular(14),
                                border: Border.all(
                                  color: _categorie != null
                                    ? TColors.primary
                                    : TColors.borderLight,
                                  width: _categorie != null
                                    ? 1.5 : 0.5),
                              ),
                              child: Row(children: [
                                Icon(
                                  _categorie != null
                                    ? _catIcon(_categorie!)
                                    : Icons.category_outlined,
                                  size: 18,
                                  color: _categorie != null
                                    ? TColors.primary
                                    : TColors.textHint),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _categorie ?? 'Catégorie',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Poppins',
                                      color: _categorie != null
                                        ? TColors.primary
                                        : TColors.textHint,
                                      fontWeight: _categorie != null
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    )),
                                ),
                                Icon(Icons.keyboard_arrow_down,
                                  size: 18,
                                  color: _categorie != null
                                    ? TColors.primary
                                    : TColors.textHint),
                              ]),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Priorité picker
                        Expanded(
                          child: GestureDetector(
                            onTap: _showPriorityPicker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: _priorite != null
                                  ? (_priorityBgs[_priorite] ??
                                      Colors.white)
                                  : (isDark
                                      ? TColors.darkContainer
                                      : Colors.white),
                                borderRadius:
                                  BorderRadius.circular(14),
                                border: Border.all(
                                  color: _priorite != null
                                    ? (_priorityColors[_priorite]
                                        ?? TColors.primary)
                                    : TColors.borderLight,
                                  width: _priorite != null
                                    ? 1.5 : 0.5),
                              ),
                              child: Row(children: [
                                Icon(Icons.flag_outlined,
                                  size: 18,
                                  color: _priorite != null
                                    ? (_priorityColors[_priorite]
                                        ?? TColors.primary)
                                    : TColors.textHint),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _priorite != null
                                      ? (_priorityLabels[_priorite]
                                          ?? _priorite!)
                                      : 'Priorité',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Poppins',
                                      color: _priorite != null
                                        ? (_priorityColors[_priorite]
                                            ?? TColors.primary)
                                        : TColors.textHint,
                                      fontWeight: _priorite != null
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    )),
                                ),
                                Icon(Icons.keyboard_arrow_down,
                                  size: 18,
                                  color: _priorite != null
                                    ? (_priorityColors[_priorite]
                                        ?? TColors.primary)
                                    : TColors.textHint),
                              ]),
                            ),
                          ),
                        ),
                      ]),

                      // Photo button — red dashed border
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: TColors.primaryLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: TColors.primary, width: 1.5),
                          ),
                          child: const Row(
                            mainAxisAlignment:
                              MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined,
                                size: 22, color: TColors.primary),
                              SizedBox(width: 10),
                              Text('Ajouter une photo',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: TColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                )),
                            ],
                          ),
                        ),
                      ),

                      // Submit button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: _loading
                            ? const SizedBox(
                                height: 22, width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2))
                            : const Text(
                                'Envoyer le signalement',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── White field ────────────────────────────────────────────
  // Clean white card input — always white background.
  // No gray/dark tint — matches the mockup exactly.
  Widget _whiteField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        // Always white — matches mockup
        color: isDark ? TColors.darkContainer : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 4),
      child: Row(
        crossAxisAlignment: maxLines > 1
          ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 10 : 0),
            child: Icon(icon, size: 20, color: TColors.textHint),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                  ? TColors.textWhite : TColors.textPrimary,
                fontFamily: 'Poppins',
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: TColors.textHint,
                  fontFamily: 'Poppins'),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12),
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Grid Painter ───────────────────────────────────────────────
// Subtle grid lines inside the map placeholder.
class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black)
          .withValues(alpha: 0.05)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.isDark != isDark;
}