import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_t_hero/utils/constants/api_constant.dart';

class AuthService {

  // ── Save token + user to local storage ────────────────────
  static Future<void> _saveSession(
      String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user',  jsonEncode(user));

    // [DEBUG] Confirm municipalityId is saved — remove after testing
    print('[AUTH] Saved user: ${jsonEncode(user)}');
    print('[AUTH] municipalityId saved: ${user['municipalityId']}');
  }

  // ── Get saved token ────────────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ── Get saved user ─────────────────────────────────────────
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getString('user');
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  // ── Get municipalityId from saved session ──────────────────
  // [ADDED] Helper used anywhere municipalityId is needed
  static Future<String?> getMunicipalityId() async {
    final user = await getUser();
    if (user == null) return null;
    final mid = user['municipalityId'];
    if (mid == null || mid.toString().isEmpty) return null;
    return mid.toString();
  }

  // ── Clear session on logout ────────────────────────────────
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  // ── LOGIN ──────────────────────────────────────────────────
  // Backend returns: { token, data: { _id, nom, email, role, municipalityId } }
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email':    email.trim(),
          'password': password.trim(),
        }),
      ).timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = body['token'] as String;
        final user  = body['data']  as Map<String, dynamic>;

        // [CRITICAL] municipalityId must be present for admin/agent
        // It comes from backend user.controller.js login() response
        // If null here, the user has no municipalityId in the database
        if (user['municipalityId'] == null) {
          print('[AUTH WARNING] municipalityId is NULL for this user!');
          print('[AUTH WARNING] Run fix_orphan_data.js to fix database.');
        }

        await _saveSession(token, user);

        return {
          'success': true,
          'user':    user,
          'token':   token,
        };
      } else {
        final msg = body['error'] ?? body['message'] ?? 'Erreur de connexion';
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Impossible de contacter le serveur.\nVérifiez votre connexion.',
      };
    }
  }

  // ── LOGOUT ─────────────────────────────────────────────────
  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse(ApiConstants.logout),
          headers: {
            'Content-Type':  'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 5));
      }
    } catch (_) {}
    await clearSession();
  }
}