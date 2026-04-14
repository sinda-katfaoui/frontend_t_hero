import 'package:flutter/material.dart';

class AppSettings {
  AppSettings._();

  // ── Theme mode ─────────────────────────────────────────────
  static final ValueNotifier<ThemeMode> themeMode =
    ValueNotifier(ThemeMode.light);

  static bool get isDark =>
    themeMode.value == ThemeMode.dark;

  static void setDarkMode(bool dark) {
    themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
  }

  // ── Language ───────────────────────────────────────────────
  static final ValueNotifier<String> language =
    ValueNotifier('fr');

  static void setLanguage(String code) {
    language.value = code;
  }

  // ── Text direction ─────────────────────────────────────────
  static TextDirection get textDirection =>
    language.value == 'ar'
      ? TextDirection.rtl
      : TextDirection.ltr;

  // ── Translation helper ─────────────────────────────────────
  static String t(String key) {
    final lang = language.value;
    return _t[lang]?[key] ?? _t['fr']?[key] ?? key;
  }

  // ── Translations ───────────────────────────────────────────
  static final Map<String, Map<String, String>> _t = {

    // ════════════════════════════════════════════════════════
    // FRANÇAIS
    // ════════════════════════════════════════════════════════
    'fr': {
      // Common
      'app_name':               'T HERO',
      'smart_city':             'Smart City Guardian',
      'save':                   'Enregistrer',
      'cancel':                 'Annuler',
      'confirm':                'Confirmer',
      'close':                  'Fermer',
      'delete':                 'Supprimer',
      'edit':                   'Modifier',
      'add':                    'Ajouter',
      'logout':                 'Déconnexion',
      'back':                   'Retour',
      'loading':                'Chargement...',
      'success':                'Succès',
      'error':                  'Erreur',
      'all':                    'Tous',
      'search':                 'Rechercher...',
      'required':               'Champ requis',
      'send':                   'Envoyer',

      // Auth — Login
      'welcome_back':           'Bon retour 👋',
      'connect_to_continue':    'Connectez-vous pour continuer',
      'your_email':             'votre@email.com',
      'password':               'Mot de passe',
      'forgot_password':        'Mot de passe oublié?',
      'sign_in':                'Se connecter',
      'or':                     'ou',
      'create_account':         'Créer un compte',
      'roles_hint':             'Citoyen · Agent · Admin',

      // Auth — Register
      'create_account_title':   'Créer un compte',
      'choose_role':            'Choisissez votre rôle',
      'full_name':              'Nom complet',
      'register':               'S\'inscrire',
      'already_account':        'Déjà un compte?',
      'sign_in_link':           'Se connecter',
      'agent_code':             'Code Agent (fourni par l\'admin)',
      'admin_code':             'Code Admin (accès restreint)',
      'account_created':        'Compte créé avec succès ✓',

      // Roles
      'citoyen':                'Citoyen',
      'agent':                  'Agent Municipal',
      'admin':                  'Admin',

      // Bottom nav — Citoyen
      'accueil':                'Accueil',
      'history':                'Historique',
      'notifs':                 'Notifs',
      'profile':                'Profil',

      // Bottom nav — Agent
      'tableau':                'Tableau',

      // Bottom nav — Admin
      'dashboard':              'Dashboard',
      'users':                  'Utilisateurs',
      'signalements':           'Signalements',
      'categories':             'Catégories',

      // Home — Citoyen
      'hello':                  'Bonjour 👋',
      'recent':                 'Récents',
      'see_all':                'Voir tout →',
      'total':                  'Total',
      'in_progress':            'En cours',
      'resolved':               'Résolus',
      'no_signalements':        'Aucun signalement',
      'no_signalements_sub':    'Vos signalements apparaîtront ici',

      // Home — Agent
      'my_signalements':        'Mes signalements',
      'new_ones':               'Nouveaux',
      'take_charge':            'Prendre',
      'assigned':               'Assignés',
      'agent_municipal_badge':  'Agent Municipal',
      'board':                  'Tableau de bord',

      // Status
      'en_cours':               'En cours',
      'en_attente':             'En attente',
      'resolu':                 'Résolu',

      // Priority
      'faible':                 'Faible',
      'moyenne':                'Moyenne',
      'elevee':                 'Élevée',

      // New signalement
      'new_report':             'Nouveau signalement',
      'define_location':        'Définir la localisation',
      'description':            'Description du problème...',
      'location':               'Localisation',
      'category':               'Catégorie',
      'priority':               'Priorité',
      'add_photo':              'Ajouter une photo',
      'send_report':            'Envoyer le signalement',
      'report_sent':            'Signalement envoyé avec succès ✓',
      'desc_required':          'Description requise',
      'loc_required':           'Localisation requise',
      'cat_required':           'Catégorie requise',
      'prio_required':          'Priorité requise',

      // Categories
      'voirie':                 'Voirie',
      'eclairage':              'Éclairage',
      'proprete':               'Propreté',
      'espaces_verts':          'Espaces Verts',
      'autre':                  'Autre',

      // Notifications
      'notifications':          'Notifications',
      'mark_all_read':          'Tout marquer comme lu',
      'new_badge':              'nouveau',
      'no_notifs':              'Aucune notification',
      'notif_taken':            'Signalement pris en charge',
      'notif_resolved':         'Signalement résolu',
      'notif_registered':       'Signalement enregistré',

      // Profile — Citoyen & Agent
      'my_profile':             'Modifier mon profil',
      'name_email':             'Nom, email',
      'change_password':        'Changer le mot de passe',
      'security':               'Sécurité du compte',
      'my_reports':             'Mes signalements',
      'see_reports':            'Voir mes rapports',
      'settings':               'Paramètres',
      'app_prefs':              'Préférences de l\'app',
      'analyses_ia':            'Analyses IA',
      'ia_reports':             'Rapports intelligents',
      'current_password':       'Mot de passe actuel',
      'new_password':           'Nouveau mot de passe',
      'confirm_password':       'Confirmer le nouveau mot de passe',
      'update':                 'Mettre à jour',
      'profile_updated':        'Profil mis à jour ✓',
      'password_updated':       'Mot de passe mis à jour ✓',
      'passwords_no_match':     'Les mots de passe ne correspondent pas',
      'password_min':           'Au moins 8 caractères requis',
      'edit_profile_title':     'Modifier mon profil',

      // Mes signalements screen
      'my_reports_title':       'Mes signalements',
      'signalements_count':     'signalements',
      'filter_all':             'Tous',
      'filter_progress':        'En cours',
      'filter_resolved':        'Résolus',

      // Agent detail
      'report_detail':          'Détail signalement',
      'citizen':                'Citoyen',
      'cat_label':              'Catégorie',
      'loc_label':              'Localisation',
      'date_label':             'Date',
      'priority_label':         'Priorité',
      'desc_label':             'Description',
      'ai_analysis':            'Analyse IA',
      'suggested_cat':          'Catégorie suggérée',
      'change_status':          'Changer le statut',
      'update_status':          'Mettre à jour',
      'resolve':                'Résoudre',
      'status_updated':         'Statut mis à jour ✓',
      'report_resolved':        'Signalement résolu ✓',

      // Admin — Dashboard
      'admin_dashboard':        'Dashboard Admin',
      'admin_badge':            'Admin',
      'admin_name':             'Admin Principal',
      'total_users':            'Utilisateurs',
      'agents':                 'Agents',
      'by_category':            'Par catégorie',
      'assign':                 'Assigner',
      'assign_agent':           'Assigner un agent',
      'assigned_to':            'Assigné',

      // Admin — Users
      'users_title':            'Utilisateurs',
      'accounts_total':         'comptes au total',
      'add_user':               'Ajouter',
      'filter_citoyens':        'Citoyens',
      'filter_agents':          'Agents',
      'add_user_title':         'Ajouter un utilisateur',
      'edit_user_title':        'Modifier l\'utilisateur',
      'delete_user_title':      'Supprimer l\'utilisateur',
      'delete_user_confirm':    'Voulez-vous supprimer',
      'delete_irreversible':    'Cette action est irréversible.',
      'deactivate':             'Désactiver',
      'activate':               'Activer',
      'deactivate_title':       'Désactiver le compte',
      'activate_title':         'Activer le compte',
      'deactivate_msg':         'L\'utilisateur ne pourra plus se connecter.',
      'activate_msg':           'L\'utilisateur pourra à nouveau se connecter.',
      'user_added':             'Utilisateur ajouté avec succès ✓',
      'user_edited':            'Utilisateur modifié ✓',
      'user_deleted':           'Utilisateur supprimé',
      'account_deactivated':    'Compte désactivé',
      'account_activated':      'Compte activé ✓',
      'deactivated_badge':      'Désactivé',
      'role_label':             'Rôle',

      // Admin — Signalements
      'signalements_title':     'Signalements',
      'filter_pending':         'En attente',
      // ignore: equal_keys_in_map
      'filter_resolved':        'Résolus',

      // Admin — Categories
      'categories_title':       'Catégories',
      'add_category':           'Ajouter',
      'new_category_title':     'Nouvelle catégorie',
      'edit_category_title':    'Modifier catégorie',
      'delete_category_title':  'Supprimer catégorie',
      'cat_name':               'Nom de la catégorie',
      'cat_desc':               'Description',
      'cat_added':              'Catégorie ajoutée ✓',
      'cat_edited':             'Catégorie modifiée ✓',
      'cat_deleted':            'Catégorie supprimée',
      'cat_delete_blocked':     'Impossible de supprimer',
      'cat_has_reports':        'car elle contient des signalements liés.',

      // Paramètres
      'params_title':           'Paramètres',
      'notif_section':          'NOTIFICATIONS',
      'enable_notifs':          'Activer les notifications',
      'notifs_subtitle':        'Recevoir des alertes sur vos signalements',
      'report_notifs':          'Notifications signalements',
      'report_notifs_sub':      'Mises à jour de statut en temps réel',
      'email_notifs':           'Notifications par email',
      'email_notifs_sub':       'Recevoir un email à chaque mise à jour',
      'appearance':             'APPARENCE',
      'dark_mode':              'Mode sombre',
      'dark_mode_on':           'Thème sombre activé 🌙',
      'dark_mode_off':          'Thème clair activé ☀️',
      'language_section':       'LANGUE',
      'app_language':           'Langue de l\'application',
      'about_section':          'À PROPOS',
      'app_version':            'Version de l\'application',
      'privacy':                'Politique de confidentialité',
      'terms':                  'Conditions d\'utilisation',
      'notifs_enabled':         'Notifications activées ✓',
      'notifs_disabled':        'Notifications désactivées',
      'lang_changed':           'Langue changée',
    },

    // ════════════════════════════════════════════════════════
    // ARABIC — العربية
    // ════════════════════════════════════════════════════════
    'ar': {
      // Common
      'app_name':               'تي هيرو',
      'smart_city':             'حارس المدينة الذكية',
      'save':                   'حفظ',
      'cancel':                 'إلغاء',
      'confirm':                'تأكيد',
      'close':                  'إغلاق',
      'delete':                 'حذف',
      'edit':                   'تعديل',
      'add':                    'إضافة',
      'logout':                 'تسجيل الخروج',
      'back':                   'رجوع',
      'loading':                'جاري التحميل...',
      'success':                'نجاح',
      'error':                  'خطأ',
      'all':                    'الكل',
      'search':                 'بحث...',
      'required':               'حقل مطلوب',
      'send':                   'إرسال',

      // Auth — Login
      'welcome_back':           'مرحباً بعودتك 👋',
      'connect_to_continue':    'سجّل دخولك للمتابعة',
      'your_email':             'بريدك@الإلكتروني.com',
      'password':               'كلمة المرور',
      'forgot_password':        'نسيت كلمة المرور؟',
      'sign_in':                'تسجيل الدخول',
      'or':                     'أو',
      'create_account':         'إنشاء حساب',
      'roles_hint':             'مواطن · عون · مدير',

      // Auth — Register
      'create_account_title':   'إنشاء حساب',
      'choose_role':            'اختر دورك',
      'full_name':              'الاسم الكامل',
      'register':               'تسجيل',
      'already_account':        'لديك حساب بالفعل؟',
      'sign_in_link':           'تسجيل الدخول',
      'agent_code':             'رمز العون (يوفره المدير)',
      'admin_code':             'رمز المدير (وصول مقيد)',
      'account_created':        'تم إنشاء الحساب بنجاح ✓',

      // Roles
      'citoyen':                'مواطن',
      'agent':                  'عون بلدي',
      'admin':                  'مدير',

      // Bottom nav — Citoyen
      'accueil':                'الرئيسية',
      'history':                'السجل',
      'notifs':                 'إشعارات',
      'profile':                'الملف',

      // Bottom nav — Agent
      'tableau':                'اللوحة',

      // Bottom nav — Admin
      'dashboard':              'لوحة التحكم',
      'users':                  'المستخدمون',
      'signalements':           'البلاغات',
      'categories':             'الفئات',

      // Home — Citoyen
      'hello':                  'مرحباً 👋',
      'recent':                 'الأحدث',
      'see_all':                'عرض الكل ←',
      'total':                  'الإجمالي',
      'in_progress':            'قيد المعالجة',
      'resolved':               'محلولة',
      'no_signalements':        'لا توجد بلاغات',
      'no_signalements_sub':    'ستظهر بلاغاتك هنا',

      // Home — Agent
      'my_signalements':        'بلاغاتي',
      'new_ones':               'جديدة',
      'take_charge':            'تولّي',
      'assigned':               'المُعيَّنة',
      'agent_municipal_badge':  'عون بلدي',
      'board':                  'لوحة القيادة',

      // Status
      'en_cours':               'قيد المعالجة',
      'en_attente':             'في الانتظار',
      'resolu':                 'محلول',

      // Priority
      'faible':                 'منخفضة',
      'moyenne':                'متوسطة',
      'elevee':                 'مرتفعة',

      // New signalement
      'new_report':             'بلاغ جديد',
      'define_location':        'تحديد الموقع',
      'description':            'وصف المشكلة...',
      'location':               'الموقع',
      'category':               'الفئة',
      'priority':               'الأولوية',
      'add_photo':              'إضافة صورة',
      'send_report':            'إرسال البلاغ',
      'report_sent':            'تم إرسال البلاغ بنجاح ✓',
      'desc_required':          'وصف مطلوب',
      'loc_required':           'موقع مطلوب',
      'cat_required':           'فئة مطلوبة',
      'prio_required':          'أولوية مطلوبة',

      // Categories
      'voirie':                 'طرق',
      'eclairage':              'إضاءة',
      'proprete':               'نظافة',
      'espaces_verts':          'مساحات خضراء',
      'autre':                  'أخرى',

      // Notifications
      'notifications':          'الإشعارات',
      'mark_all_read':          'تحديد الكل كمقروء',
      'new_badge':              'جديد',
      'no_notifs':              'لا توجد إشعارات',
      'notif_taken':            'تم تولي البلاغ',
      'notif_resolved':         'تم حل البلاغ',
      'notif_registered':       'تم تسجيل البلاغ',

      // Profile
      'my_profile':             'تعديل ملفي الشخصي',
      'name_email':             'الاسم، البريد الإلكتروني',
      'change_password':        'تغيير كلمة المرور',
      'security':               'أمان الحساب',
      'my_reports':             'بلاغاتي',
      'see_reports':            'عرض بلاغاتي',
      'settings':               'الإعدادات',
      'app_prefs':              'تفضيلات التطبيق',
      'analyses_ia':            'تحليلات الذكاء الاصطناعي',
      'ia_reports':             'التقارير الذكية',
      'current_password':       'كلمة المرور الحالية',
      'new_password':           'كلمة المرور الجديدة',
      'confirm_password':       'تأكيد كلمة المرور الجديدة',
      'update':                 'تحديث',
      'profile_updated':        'تم تحديث الملف الشخصي ✓',
      'password_updated':       'تم تحديث كلمة المرور ✓',
      'passwords_no_match':     'كلمتا المرور غير متطابقتين',
      'password_min':           'يجب أن تحتوي على 8 أحرف على الأقل',
      'edit_profile_title':     'تعديل ملفي الشخصي',

      // Mes signalements screen
      'my_reports_title':       'بلاغاتي',
      'signalements_count':     'بلاغات',
      'filter_all':             'الكل',
      'filter_progress':        'قيد المعالجة',
      'filter_resolved':        'محلولة',

      // Agent detail
      'report_detail':          'تفاصيل البلاغ',
      'citizen':                'المواطن',
      'cat_label':              'الفئة',
      'loc_label':              'الموقع',
      'date_label':             'التاريخ',
      'priority_label':         'الأولوية',
      'desc_label':             'الوصف',
      'ai_analysis':            'تحليل الذكاء الاصطناعي',
      'suggested_cat':          'الفئة المقترحة',
      'change_status':          'تغيير الحالة',
      'update_status':          'تحديث',
      'resolve':                'حل',
      'status_updated':         'تم تحديث الحالة ✓',
      'report_resolved':        'تم حل البلاغ ✓',

      // Admin — Dashboard
      'admin_dashboard':        'لوحة تحكم المدير',
      'admin_badge':            'مدير',
      'admin_name':             'المدير الرئيسي',
      'total_users':            'المستخدمون',
      'agents':                 'الأعوان',
      'by_category':            'حسب الفئة',
      'assign':                 'تعيين',
      'assign_agent':           'تعيين عون',
      'assigned_to':            'مُعيَّن',

      // Admin — Users
      'users_title':            'المستخدمون',
      'accounts_total':         'حساب إجمالاً',
      'add_user':               'إضافة',
      'filter_citoyens':        'المواطنون',
      'filter_agents':          'الأعوان',
      'add_user_title':         'إضافة مستخدم',
      'edit_user_title':        'تعديل المستخدم',
      'delete_user_title':      'حذف المستخدم',
      'delete_user_confirm':    'هل تريد حذف',
      'delete_irreversible':    'هذا الإجراء لا يمكن التراجع عنه.',
      'deactivate':             'تعطيل',
      'activate':               'تفعيل',
      'deactivate_title':       'تعطيل الحساب',
      'activate_title':         'تفعيل الحساب',
      'deactivate_msg':         'لن يتمكن المستخدم من تسجيل الدخول.',
      'activate_msg':           'سيتمكن المستخدم من تسجيل الدخول مجدداً.',
      'user_added':             'تم إضافة المستخدم بنجاح ✓',
      'user_edited':            'تم تعديل المستخدم ✓',
      'user_deleted':           'تم حذف المستخدم',
      'account_deactivated':    'تم تعطيل الحساب',
      'account_activated':      'تم تفعيل الحساب ✓',
      'deactivated_badge':      'معطّل',
      'role_label':             'الدور',

      // Admin — Signalements
      'signalements_title':     'البلاغات',
      'filter_pending':         'في الانتظار',
      // ignore: equal_keys_in_map
      'filter_resolved':        'محلولة',

      // Admin — Categories
      'categories_title':       'الفئات',
      'add_category':           'إضافة',
      'new_category_title':     'فئة جديدة',
      'edit_category_title':    'تعديل الفئة',
      'delete_category_title':  'حذف الفئة',
      'cat_name':               'اسم الفئة',
      'cat_desc':               'الوصف',
      'cat_added':              'تمت إضافة الفئة ✓',
      'cat_edited':             'تم تعديل الفئة ✓',
      'cat_deleted':            'تم حذف الفئة',
      'cat_delete_blocked':     'لا يمكن الحذف',
      'cat_has_reports':        'لأنها تحتوي على بلاغات مرتبطة.',

      // Paramètres
      'params_title':           'الإعدادات',
      'notif_section':          'الإشعارات',
      'enable_notifs':          'تفعيل الإشعارات',
      'notifs_subtitle':        'استقبال تنبيهات حول بلاغاتك',
      'report_notifs':          'إشعارات البلاغات',
      'report_notifs_sub':      'تحديثات الحالة في الوقت الفعلي',
      'email_notifs':           'إشعارات البريد الإلكتروني',
      'email_notifs_sub':       'استقبال بريد عند كل تحديث',
      'appearance':             'المظهر',
      'dark_mode':              'الوضع الداكن',
      'dark_mode_on':           'تم تفعيل الوضع الداكن 🌙',
      'dark_mode_off':          'تم تفعيل الوضع الفاتح ☀️',
      'language_section':       'اللغة',
      'app_language':           'لغة التطبيق',
      'about_section':          'حول التطبيق',
      'app_version':            'إصدار التطبيق',
      'privacy':                'سياسة الخصوصية',
      'terms':                  'شروط الاستخدام',
      'notifs_enabled':         'تم تفعيل الإشعارات ✓',
      'notifs_disabled':        'تم تعطيل الإشعارات',
      'lang_changed':           'تم تغيير اللغة',
    },

    // ════════════════════════════════════════════════════════
    // ENGLISH
    // ════════════════════════════════════════════════════════
    'en': {
      // Common
      'app_name':               'T HERO',
      'smart_city':             'Smart City Guardian',
      'save':                   'Save',
      'cancel':                 'Cancel',
      'confirm':                'Confirm',
      'close':                  'Close',
      'delete':                 'Delete',
      'edit':                   'Edit',
      'add':                    'Add',
      'logout':                 'Logout',
      'back':                   'Back',
      'loading':                'Loading...',
      'success':                'Success',
      'error':                  'Error',
      'all':                    'All',
      'search':                 'Search...',
      'required':               'Required field',
      'send':                   'Send',

      // Auth — Login
      'welcome_back':           'Welcome back 👋',
      'connect_to_continue':    'Sign in to continue',
      'your_email':             'your@email.com',
      'password':               'Password',
      'forgot_password':        'Forgot password?',
      'sign_in':                'Sign in',
      'or':                     'or',
      'create_account':         'Create account',
      'roles_hint':             'Citizen · Agent · Admin',

      // Auth — Register
      'create_account_title':   'Create account',
      'choose_role':            'Choose your role',
      'full_name':              'Full name',
      'register':               'Register',
      'already_account':        'Already have an account?',
      'sign_in_link':           'Sign in',
      'agent_code':             'Agent code (provided by admin)',
      'admin_code':             'Admin code (restricted access)',
      'account_created':        'Account created successfully ✓',

      // Roles
      'citoyen':                'Citizen',
      'agent':                  'Municipal Agent',
      'admin':                  'Admin',

      // Bottom nav — Citoyen
      'accueil':                'Home',
      'history':                'History',
      'notifs':                 'Notifs',
      'profile':                'Profile',

      // Bottom nav — Agent
      'tableau':                'Board',

      // Bottom nav — Admin
      'dashboard':              'Dashboard',
      'users':                  'Users',
      'signalements':           'Reports',
      'categories':             'Categories',

      // Home — Citoyen
      'hello':                  'Hello 👋',
      'recent':                 'Recent',
      'see_all':                'See all →',
      'total':                  'Total',
      'in_progress':            'In progress',
      'resolved':               'Resolved',
      'no_signalements':        'No reports',
      'no_signalements_sub':    'Your reports will appear here',

      // Home — Agent
      'my_signalements':        'My reports',
      'new_ones':               'New',
      'take_charge':            'Take',
      'assigned':               'Assigned',
      'agent_municipal_badge':  'Municipal Agent',
      'board':                  'Dashboard',

      // Status
      'en_cours':               'In progress',
      'en_attente':             'Pending',
      'resolu':                 'Resolved',

      // Priority
      'faible':                 'Low',
      'moyenne':                'Medium',
      'elevee':                 'High',

      // New signalement
      'new_report':             'New report',
      'define_location':        'Define location',
      'description':            'Problem description...',
      'location':               'Location',
      'category':               'Category',
      'priority':               'Priority',
      'add_photo':              'Add a photo',
      'send_report':            'Send report',
      'report_sent':            'Report sent successfully ✓',
      'desc_required':          'Description required',
      'loc_required':           'Location required',
      'cat_required':           'Category required',
      'prio_required':          'Priority required',

      // Categories
      'voirie':                 'Roads',
      'eclairage':              'Lighting',
      'proprete':               'Cleanliness',
      'espaces_verts':          'Green Spaces',
      'autre':                  'Other',

      // Notifications
      'notifications':          'Notifications',
      'mark_all_read':          'Mark all as read',
      'new_badge':              'new',
      'no_notifs':              'No notifications',
      'notif_taken':            'Report taken over',
      'notif_resolved':         'Report resolved',
      'notif_registered':       'Report registered',

      // Profile
      'my_profile':             'Edit my profile',
      'name_email':             'Name, email',
      'change_password':        'Change password',
      'security':               'Account security',
      'my_reports':             'My reports',
      'see_reports':            'View my reports',
      'settings':               'Settings',
      'app_prefs':              'App preferences',
      'analyses_ia':            'AI Analyses',
      'ia_reports':             'Smart reports',
      'current_password':       'Current password',
      'new_password':           'New password',
      'confirm_password':       'Confirm new password',
      'update':                 'Update',
      'profile_updated':        'Profile updated ✓',
      'password_updated':       'Password updated ✓',
      'passwords_no_match':     'Passwords do not match',
      'password_min':           'At least 8 characters required',
      'edit_profile_title':     'Edit my profile',

      // Mes signalements screen
      'my_reports_title':       'My reports',
      'signalements_count':     'reports',
      'filter_all':             'All',
      'filter_progress':        'In progress',
      'filter_resolved':        'Resolved',

      // Agent detail
      'report_detail':          'Report detail',
      'citizen':                'Citizen',
      'cat_label':              'Category',
      'loc_label':              'Location',
      'date_label':             'Date',
      'priority_label':         'Priority',
      'desc_label':             'Description',
      'ai_analysis':            'AI Analysis',
      'suggested_cat':          'Suggested category',
      'change_status':          'Change status',
      'update_status':          'Update',
      'resolve':                'Resolve',
      'status_updated':         'Status updated ✓',
      'report_resolved':        'Report resolved ✓',

      // Admin — Dashboard
      'admin_dashboard':        'Admin Dashboard',
      'admin_badge':            'Admin',
      'admin_name':             'Admin Principal',
      'total_users':            'Users',
      'agents':                 'Agents',
      'by_category':            'By category',
      'assign':                 'Assign',
      'assign_agent':           'Assign an agent',
      'assigned_to':            'Assigned',

      // Admin — Users
      'users_title':            'Users',
      'accounts_total':         'accounts total',
      'add_user':               'Add',
      'filter_citoyens':        'Citizens',
      'filter_agents':          'Agents',
      'add_user_title':         'Add a user',
      'edit_user_title':        'Edit user',
      'delete_user_title':      'Delete user',
      'delete_user_confirm':    'Are you sure you want to delete',
      'delete_irreversible':    'This action is irreversible.',
      'deactivate':             'Deactivate',
      'activate':               'Activate',
      'deactivate_title':       'Deactivate account',
      'activate_title':         'Activate account',
      'deactivate_msg':         'The user will no longer be able to log in.',
      'activate_msg':           'The user will be able to log in again.',
      'user_added':             'User added successfully ✓',
      'user_edited':            'User updated ✓',
      'user_deleted':           'User deleted',
      'account_deactivated':    'Account deactivated',
      'account_activated':      'Account activated ✓',
      'deactivated_badge':      'Disabled',
      'role_label':             'Role',

      // Admin — Signalements
      'signalements_title':     'Reports',
      'filter_pending':         'Pending',
      // ignore: equal_keys_in_map
      'filter_resolved':        'Resolved',

      // Admin — Categories
      'categories_title':       'Categories',
      'add_category':           'Add',
      'new_category_title':     'New category',
      'edit_category_title':    'Edit category',
      'delete_category_title':  'Delete category',
      'cat_name':               'Category name',
      'cat_desc':               'Description',
      'cat_added':              'Category added ✓',
      'cat_edited':             'Category updated ✓',
      'cat_deleted':            'Category deleted',
      'cat_delete_blocked':     'Cannot delete',
      'cat_has_reports':        'because it has linked reports.',

      // Paramètres
      'params_title':           'Settings',
      'notif_section':          'NOTIFICATIONS',
      'enable_notifs':          'Enable notifications',
      'notifs_subtitle':        'Receive alerts about your reports',
      'report_notifs':          'Report notifications',
      'report_notifs_sub':      'Real-time status updates',
      'email_notifs':           'Email notifications',
      'email_notifs_sub':       'Receive an email on each update',
      'appearance':             'APPEARANCE',
      'dark_mode':              'Dark mode',
      'dark_mode_on':           'Dark mode enabled 🌙',
      'dark_mode_off':          'Light mode enabled ☀️',
      'language_section':       'LANGUAGE',
      'app_language':           'App language',
      'about_section':          'ABOUT',
      'app_version':            'App version',
      'privacy':                'Privacy policy',
      'terms':                  'Terms of use',
      'notifs_enabled':         'Notifications enabled ✓',
      'notifs_disabled':        'Notifications disabled',
      'lang_changed':           'Language changed',
    },
  };
}