// ============================================================
// NewSignalementScreen — Create a New Signalement
// ============================================================
// Allows a Citoyen to report a city problem by filling in:
//   - Location (map placeholder — replace with Google Maps)
//   - Description of the problem
//   - Localisation (text address)
//   - Category (Voirie, Eclairage, Propreté, etc.)
//   - Priority (FAIBLE, MOYENNE, ELEVEE)
//   - Optional photo (camera/gallery — replace with image_picker)
//
// Design decisions:
// - Red AppBar matches app theme — no back title needed
// - Map placeholder compact at 90px — no scroll needed
// - All form fields compact (9px content padding) to fit screen
// - Photo button uses dashed red border to signal optional action
// - Loading spinner on submit button prevents double-tap
// - Everything fits without scrolling on standard screen size
//
// TODO: Connect to real features:
//   - Map → google_maps_flutter package
//   - Photo → image_picker package
//   - Submit → POST /signalements/CreateSignalement
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

  // Form key to validate all fields at once on submit
  final _formKey  = GlobalKey<FormState>();

  // Text controllers for description and location fields
  final _descCtrl = TextEditingController();
  final _locCtrl  = TextEditingController();

  // Selected dropdown values — null means not yet chosen
  String? _categorie;
  String? _priorite;

  // Prevents double-tap on submit and shows loading state
  bool _loading = false;

  // Available categories — must match backend enum values
  final _categories = [
    'Voirie',
    'Eclairage',
    'Propreté',
    'Espaces Verts',
    'Autre',
  ];

  // Available priorities — must match backend enum values
  final _priorites = ['FAIBLE', 'MOYENNE', 'ELEVEE'];

  @override
  void dispose() {
    // Always dispose text controllers to free memory
    _descCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  // ── Submit Handler ─────────────────────────────────────────
  // Validates all fields, then sends to backend.
  // TODO: Replace Future.delayed with real API call:
  // POST /signalements/CreateSignalement
  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Signalement envoyé avec succès ✓',
            style: TextStyle(
              fontSize: 12, fontFamily: 'Poppins')),
          backgroundColor: TColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.light,

      // ── AppBar ─────────────────────────────────────────────
      // Simple red bar with back button and title.
      appBar: AppBar(
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          onPressed: () => Navigator.pop(context)),
        title: const Text('Nouveau signalement',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          )),
      ),

      // ── Body — no scroll, everything fits ─────────────────
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Map Placeholder ─────────────────────────────
            // Compact at 90px height. Shows location pin icon.
            // Replace with GoogleMap widget when API key ready.
            _buildMapPlaceholder(isDark),

            // ── Form Fields ──────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  children: [

                    // Description input — multiline
                    _buildInputField(
                      controller: _descCtrl,
                      hint: 'Description du problème...',
                      icon: Icons.description_outlined,
                      isDark: isDark,
                      maxLines: 2,
                      validator: (v) =>
                        v!.isEmpty ? 'Description requise' : null,
                    ),

                    const SizedBox(height: 7),

                    // Localisation input — single line
                    _buildInputField(
                      controller: _locCtrl,
                      hint: 'Localisation',
                      icon: Icons.place_outlined,
                      isDark: isDark,
                      validator: (v) =>
                        v!.isEmpty ? 'Localisation requise' : null,
                    ),

                    const SizedBox(height: 7),

                    // Category and Priority dropdowns side by side
                    Row(children: [
                      Expanded(
                        child: _buildDropdown(
                          value: _categorie,
                          hint: 'Catégorie',
                          icon: Icons.category_outlined,
                          items: _categories,
                          isDark: isDark,
                          onChanged: (v) =>
                            setState(() => _categorie = v),
                          validator: (v) =>
                            v == null ? 'Requis' : null,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: _buildDropdown(
                          value: _priorite,
                          hint: 'Priorité',
                          icon: Icons.flag_outlined,
                          items: _priorites,
                          isDark: isDark,
                          onChanged: (v) =>
                            setState(() => _priorite = v),
                          validator: (v) =>
                            v == null ? 'Requis' : null,
                        ),
                      ),
                    ]),

                    const SizedBox(height: 7),

                    // Photo button — dashed red border, optional
                    _buildPhotoButton(),

                    const SizedBox(height: 10),

                    // Submit button — full width red
                    SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _loading
                          ? const SizedBox(
                              height: 18, width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2))
                          : const Text('Envoyer le signalement',
                              style: TextStyle(
                                fontSize: 11,
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
    );
  }

  // ── Map Placeholder ────────────────────────────────────────
  // Compact 90px container with grid lines + location pin.
  // Replace Container with GoogleMap widget when ready.
  Widget _buildMapPlaceholder(bool isDark) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: isDark
          ? const Color(0xFF1A2A1A)
          : const Color(0xFFE8F0E8),
      ),
      child: Stack(children: [

        // Subtle grid lines for map feel
        CustomPaint(
          size: const Size(double.infinity, 90),
          painter: _GridPainter(isDark: isDark),
        ),

        // Center pin + label
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34, height: 34,
                decoration: const BoxDecoration(
                  color: TColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white, size: 18),
              ),
              const SizedBox(height: 5),
              Text('Appuyez pour définir la localisation',
                style: TextStyle(
                  fontSize: 9,
                  color: TColors.textHint,
                  fontFamily: 'Poppins',
                )),
            ],
          ),
        ),

        // My location button — bottom right
        Positioned(
          right: 10, bottom: 10,
          child: GestureDetector(
            onTap: () {
              // TODO: Get current GPS location
            },
            child: Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: TColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.my_location,
                color: Colors.white, size: 14),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Input Field ────────────────────────────────────────────
  // Card-style container wrapping a bare TextFormField.
  // Supports multiline for description field.
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.darkContainer : TColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12, vertical: 4),
      child: Row(
        crossAxisAlignment: maxLines > 1
          ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 6 : 0),
            child: Icon(icon, size: 14, color: TColors.textHint),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                  ? TColors.textWhite : TColors.textPrimary,
                fontFamily: 'Poppins',
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 10, color: TColors.textHint,
                  fontFamily: 'Poppins'),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 6),
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  // ── Dropdown Field ─────────────────────────────────────────
  // Card-style dropdown matching the input field aesthetic.
  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required bool isDark,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.darkContainer : TColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        icon: const Icon(Icons.keyboard_arrow_down,
          size: 16, color: TColors.textHint),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 14, color: TColors.textHint),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 10, color: TColors.textHint,
            fontFamily: 'Poppins'),
        ),
        style: TextStyle(
          fontSize: 10,
          color: isDark ? TColors.textWhite : TColors.textPrimary,
          fontFamily: 'Poppins',
        ),
        dropdownColor: isDark
          ? TColors.darkContainer : TColors.cardLight,
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item,
            style: const TextStyle(
              fontSize: 10, fontFamily: 'Poppins')))).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  // ── Photo Button ───────────────────────────────────────────
  // Dashed red border signals optional upload action.
  // TODO: Connect to image_picker for camera/gallery access.
  Widget _buildPhotoButton() {
    return GestureDetector(
      onTap: () {
        // TODO: Open image picker
      },
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: TColors.primary.withValues(alpha: 0.5),
            width: 1.5,
            // Note: Flutter doesn't support dashed borders natively
            // Use dashed_border package for true dashed effect
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined,
              size: 15, color: TColors.primary),
            const SizedBox(width: 6),
            const Text('Ajouter une photo',
              style: TextStyle(
                fontSize: 10,
                color: TColors.primary,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              )),
          ],
        ),
      ),
    );
  }
}

// ── Grid Painter ───────────────────────────────────────────────
// Custom painter that draws subtle grid lines on the map placeholder.
// Gives a map-like feel without loading a real map widget.
class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black)
          .withValues(alpha: 0.06)
      ..strokeWidth = 0.5;

    // Draw vertical lines every 20px
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines every 20px
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.isDark != isDark;
}