import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_t_hero/utils/constants/api_constant.dart';

class AuthService {

  // ── Save token + user to local storage ────────────────────
  static Future<void> _saveSession(String token,
      Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user',  jsonEncode(user));
  }

  // ── Get saved token ────────────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ── Get saved user ─────────────────────────────────────────
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user');
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  // ── Clear session on logout ────────────────────────────────
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  // ── LOGIN ──────────────────────────────────────────────────
  // Backend expects: { email, password }
  // Backend returns: { token, data: { _id, nom, email, role } }
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
        final token = body['token'];
        final user  = body['data'];
        await _saveSession(token, user);
        return {'success': true, 'user': user, 'token': token};
      } else {
        // Backend error message
        final msg = body['error'] ?? body['message'] ?? 'Erreur de connexion';
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Impossible de contacter le serveur.\nVérifiez votre connexion.'
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