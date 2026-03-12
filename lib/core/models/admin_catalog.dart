import 'user_role.dart';

class AdminAlertPreset {
  const AdminAlertPreset({
    required this.title,
    required this.category,
    required this.message,
  });

  final String title;
  final String category;
  final String message;

  AdminAlertPreset copyWith({
    String? title,
    String? category,
    String? message,
  }) {
    return AdminAlertPreset(
      title: title ?? this.title,
      category: category ?? this.category,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'category': category,
      'message': message,
    };
  }

  static AdminAlertPreset fromJson(Map<String, dynamic> json) {
    return AdminAlertPreset(
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}

class AdminServiceShortcut {
  const AdminServiceShortcut({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.iconKey,
    required this.roles,
    this.accentHex,
  });

  final String title;
  final String subtitle;
  final String route;
  final String iconKey;
  final List<UserRole> roles;
  final String? accentHex;

  AdminServiceShortcut copyWith({
    String? title,
    String? subtitle,
    String? route,
    String? iconKey,
    List<UserRole>? roles,
    String? accentHex,
    bool clearAccentHex = false,
  }) {
    return AdminServiceShortcut(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      route: route ?? this.route,
      iconKey: iconKey ?? this.iconKey,
      roles: roles ?? this.roles,
      accentHex: clearAccentHex ? null : accentHex ?? this.accentHex,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'subtitle': subtitle,
      'route': route,
      'iconKey': iconKey,
      'roles': roles.map((UserRole role) => role.name).toList(growable: false),
      'accentHex': accentHex,
    };
  }

  static AdminServiceShortcut fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawRoles =
        json['roles'] as List<dynamic>? ?? <dynamic>[];
    return AdminServiceShortcut(
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      route: json['route'] as String? ?? '',
      iconKey: json['iconKey'] as String? ?? '',
      roles: rawRoles
          .map((dynamic role) => role as String?)
          .whereType<String>()
          .map(UserRole.values.byName)
          .toList(growable: false),
      accentHex: json['accentHex'] as String?,
    );
  }
}

class AdminCatalog {
  const AdminCatalog({
    required this.issueCategories,
    required this.noticeCategories,
    required this.laundryMachines,
    required this.parcelCarriers,
    required this.alertPresets,
    required this.serviceShortcuts,
  });

  final List<String> issueCategories;
  final List<String> noticeCategories;
  final List<String> laundryMachines;
  final List<String> parcelCarriers;
  final List<AdminAlertPreset> alertPresets;
  final List<AdminServiceShortcut> serviceShortcuts;

  AdminCatalog copyWith({
    List<String>? issueCategories,
    List<String>? noticeCategories,
    List<String>? laundryMachines,
    List<String>? parcelCarriers,
    List<AdminAlertPreset>? alertPresets,
    List<AdminServiceShortcut>? serviceShortcuts,
  }) {
    return AdminCatalog(
      issueCategories: issueCategories ?? this.issueCategories,
      noticeCategories: noticeCategories ?? this.noticeCategories,
      laundryMachines: laundryMachines ?? this.laundryMachines,
      parcelCarriers: parcelCarriers ?? this.parcelCarriers,
      alertPresets: alertPresets ?? this.alertPresets,
      serviceShortcuts: serviceShortcuts ?? this.serviceShortcuts,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'issueCategories': issueCategories,
      'noticeCategories': noticeCategories,
      'laundryMachines': laundryMachines,
      'parcelCarriers': parcelCarriers,
      'alertPresets': alertPresets
          .map((AdminAlertPreset preset) => preset.toJson())
          .toList(growable: false),
      'serviceShortcuts': serviceShortcuts
          .map((AdminServiceShortcut item) => item.toJson())
          .toList(growable: false),
    };
  }

  static AdminCatalog fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawIssueCategories =
        json['issueCategories'] as List<dynamic>? ?? <dynamic>[];
    final List<dynamic> rawNoticeCategories =
        json['noticeCategories'] as List<dynamic>? ?? <dynamic>[];
    final List<dynamic> rawLaundryMachines =
        json['laundryMachines'] as List<dynamic>? ?? <dynamic>[];
    final List<dynamic> rawParcelCarriers =
        json['parcelCarriers'] as List<dynamic>? ?? <dynamic>[];
    final List<dynamic> rawAlertPresets =
        json['alertPresets'] as List<dynamic>? ?? <dynamic>[];
    final List<dynamic> rawServiceShortcuts =
        json['serviceShortcuts'] as List<dynamic>? ?? <dynamic>[];
    return AdminCatalog(
      issueCategories: rawIssueCategories
          .map((dynamic item) => item as String?)
          .whereType<String>()
          .toList(growable: false),
      noticeCategories: rawNoticeCategories
          .map((dynamic item) => item as String?)
          .whereType<String>()
          .toList(growable: false),
      laundryMachines: rawLaundryMachines
          .map((dynamic item) => item as String?)
          .whereType<String>()
          .toList(growable: false),
      parcelCarriers: rawParcelCarriers
          .map((dynamic item) => item as String?)
          .whereType<String>()
          .toList(growable: false),
      alertPresets: rawAlertPresets
          .whereType<Map<String, dynamic>>()
          .map(AdminAlertPreset.fromJson)
          .toList(growable: false),
      serviceShortcuts: rawServiceShortcuts
          .whereType<Map<String, dynamic>>()
          .map(AdminServiceShortcut.fromJson)
          .toList(growable: false),
    );
  }
}

const AdminCatalog defaultAdminCatalog = AdminCatalog(
  issueCategories: <String>[
    'Bathroom',
    'Bedroom',
    'Electricity',
    'Furniture',
    'Mess Food',
    'Water',
  ],
  noticeCategories: <String>[
    'Announcement',
    'Event',
    'Rule',
  ],
  laundryMachines: <String>[
    'Machine A',
    'Machine B',
    'Machine C',
  ],
  parcelCarriers: <String>[
    'DHL',
    'FedEx',
    'Nepal Post',
  ],
  alertPresets: <AdminAlertPreset>[
    AdminAlertPreset(
      title: 'Urgent maintenance',
      category: 'Announcement',
      message: 'A facility maintenance update needs immediate attention.',
    ),
    AdminAlertPreset(
      title: 'Mess update',
      category: 'Event',
      message: 'There is an important change in today\'s mess service.',
    ),
  ],
  serviceShortcuts: <AdminServiceShortcut>[],
);
