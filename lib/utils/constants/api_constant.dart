class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5000';

  // ── Auth ───────────────────────────────────────────────────
  static const String login  = '$baseUrl/users/login';
  static const String logout = '$baseUrl/users/logout';

  // ── Register ───────────────────────────────────────────────
  static const String createUser  = '$baseUrl/users/CreateUser';
  static const String createAgent = '$baseUrl/users/CreateAgent';
  static const String createAdmin = '$baseUrl/users/CreateUserAdmin';

  // ── Signalements ───────────────────────────────────────────
  static const String createSignalement  = '$baseUrl/signalements/CreateSignalement';
  static const String getAllSignalements  = '$baseUrl/signalements/GetAllSignalements';
  static const String getSignalementById = '$baseUrl/signalements/GetSignalementById';

  // ── Categories ─────────────────────────────────────────────
  static const String getAllCategories = '$baseUrl/categories/GetAllCategories';

  // ── Users ──────────────────────────────────────────────────
  static const String getAllUsers     = '$baseUrl/users/GetAllUsers';
  static const String getAllAgents    = '$baseUrl/users/GetAllAgents';
  static const String toggleBlockUser = '$baseUrl/users/ToggleBlock';

  // ── Municipalities ─────────────────────────────────────────
  static const String getAllMunicipalities    = '$baseUrl/municipalities';
  static const String getMunicipalitiesByGov = '$baseUrl/municipalities/by-governorate';

  // ── Notifications ──────────────────────────────────────────
  static const String getNotificationsByUser = '$baseUrl/notifications/user';
  static const String markAllAsRead          = '$baseUrl/notifications/mark-all-read';
}