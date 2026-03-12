import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../common/app_bar.dart';
import '../../../common/custom_text_field.dart';
import '../../../common/spacing.dart';
import '../../../core/models/admin_catalog.dart';
import '../../../core/models/user_role.dart';
import '../../../core/services/hostel_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/app_icons.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_screen_background.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../features/auth/widgets/custom_button.dart';
import '../../../theme/colors.dart';

class AdminCatalogScreen extends StatefulWidget {
  const AdminCatalogScreen({super.key});

  @override
  State<AdminCatalogScreen> createState() => _AdminCatalogScreenState();
}

class _AdminCatalogScreenState extends State<AdminCatalogScreen> {
  AdminCatalog? _draftCatalog;
  String? _syncedSignature;

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final Brightness brightness = Theme.of(context).brightness;
    final bool canManage = state.currentUser?.role == UserRole.admin;
    if (!canManage) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: buildAppBar(context, 'Operations Catalog'),
        body: const AppScreenBackground(
          child: AppEmptyState(
            icon: Icons.lock_outline,
            title: 'Admin only',
            message: 'Only admins can manage service catalogs and presets.',
          ),
        ),
      );
    }

    _syncDraft(state.adminCatalog);
    final AdminCatalog catalog = _draftCatalog!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(context, 'Operations Catalog'),
      body: AppScreenBackground(
        child: ListView(
          padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 18.h),
          children: <Widget>[
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Backend-managed operations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryTextFor(brightness),
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  heightSpacer(4),
                  Text(
                    'Control complaint categories, notice categories, quick alerts, laundry machines, parcel carriers, and optional dashboard shortcuts from one place.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedTextFor(brightness),
                          height: 1.45,
                        ),
                  ),
                  heightSpacer(12),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: <Widget>[
                      _QuickJumpChip(
                        label: 'Fee categories',
                        icon: AppIcons.fees,
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.fees);
                        },
                      ),
                      _QuickJumpChip(
                        label: 'Weekly menu',
                        icon: AppIcons.mess,
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.mess);
                        },
                      ),
                      _QuickJumpChip(
                        label: 'Room inventory',
                        icon: AppIcons.room,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.roomAvailability,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _StringCatalogSection(
              title: 'Complaint categories',
              description:
                  'Students can choose from these issue categories in the Issue Center.',
              items: catalog.issueCategories,
              icon: AppIcons.issue,
              onAdd: () => _editStringItem(
                title: 'Add complaint category',
                onSaved: (String value) {
                  _updateCatalog(
                    catalog.copyWith(
                      issueCategories: <String>[
                        ...catalog.issueCategories,
                        value,
                      ],
                    ),
                  );
                },
              ),
              onEdit: (int index) => _editStringItem(
                title: 'Edit complaint category',
                initialValue: catalog.issueCategories[index],
                onSaved: (String value) {
                  final List<String> next = List<String>.from(
                    catalog.issueCategories,
                  );
                  next[index] = value;
                  _updateCatalog(catalog.copyWith(issueCategories: next));
                },
              ),
              onRemove: (int index) {
                final List<String> next = List<String>.from(
                  catalog.issueCategories,
                )..removeAt(index);
                _updateCatalog(catalog.copyWith(issueCategories: next));
              },
            ),
            _StringCatalogSection(
              title: 'Notice categories',
              description:
                  'Admins can publish notices and alerts under these categories.',
              items: catalog.noticeCategories,
              icon: AppIcons.notice,
              onAdd: () => _editStringItem(
                title: 'Add notice category',
                onSaved: (String value) {
                  _updateCatalog(
                    catalog.copyWith(
                      noticeCategories: <String>[
                        ...catalog.noticeCategories,
                        value,
                      ],
                    ),
                  );
                },
              ),
              onEdit: (int index) => _editStringItem(
                title: 'Edit notice category',
                initialValue: catalog.noticeCategories[index],
                onSaved: (String value) {
                  final List<String> next = List<String>.from(
                    catalog.noticeCategories,
                  );
                  next[index] = value;
                  _updateCatalog(catalog.copyWith(noticeCategories: next));
                },
              ),
              onRemove: (int index) {
                final List<String> next = List<String>.from(
                  catalog.noticeCategories,
                )..removeAt(index);
                _updateCatalog(catalog.copyWith(noticeCategories: next));
              },
            ),
            _StringCatalogSection(
              title: 'Laundry machines',
              description:
                  'Student booking and staff queue views use this machine list.',
              items: catalog.laundryMachines,
              icon: AppIcons.laundry,
              onAdd: () => _editStringItem(
                title: 'Add laundry machine',
                onSaved: (String value) {
                  _updateCatalog(
                    catalog.copyWith(
                      laundryMachines: <String>[
                        ...catalog.laundryMachines,
                        value,
                      ],
                    ),
                  );
                },
              ),
              onEdit: (int index) => _editStringItem(
                title: 'Edit laundry machine',
                initialValue: catalog.laundryMachines[index],
                onSaved: (String value) {
                  final List<String> next = List<String>.from(
                    catalog.laundryMachines,
                  );
                  next[index] = value;
                  _updateCatalog(catalog.copyWith(laundryMachines: next));
                },
              ),
              onRemove: (int index) {
                final List<String> next = List<String>.from(
                  catalog.laundryMachines,
                )..removeAt(index);
                _updateCatalog(catalog.copyWith(laundryMachines: next));
              },
            ),
            _StringCatalogSection(
              title: 'Parcel carriers',
              description:
                  'Front desk staff can quick-pick from these parcel carriers.',
              items: catalog.parcelCarriers,
              icon: AppIcons.parcel,
              onAdd: () => _editStringItem(
                title: 'Add parcel carrier',
                onSaved: (String value) {
                  _updateCatalog(
                    catalog.copyWith(
                      parcelCarriers: <String>[
                        ...catalog.parcelCarriers,
                        value,
                      ],
                    ),
                  );
                },
              ),
              onEdit: (int index) => _editStringItem(
                title: 'Edit parcel carrier',
                initialValue: catalog.parcelCarriers[index],
                onSaved: (String value) {
                  final List<String> next = List<String>.from(
                    catalog.parcelCarriers,
                  );
                  next[index] = value;
                  _updateCatalog(catalog.copyWith(parcelCarriers: next));
                },
              ),
              onRemove: (int index) {
                final List<String> next = List<String>.from(
                  catalog.parcelCarriers,
                )..removeAt(index);
                _updateCatalog(catalog.copyWith(parcelCarriers: next));
              },
            ),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _SectionHeader(
                    title: 'Quick alert presets',
                    icon: AppIcons.alert,
                    onAdd: () => _editAlertPreset(
                      categories: catalog.noticeCategories,
                      onSaved: (AdminAlertPreset preset) {
                        _updateCatalog(
                          catalog.copyWith(
                            alertPresets: <AdminAlertPreset>[
                              ...catalog.alertPresets,
                              preset,
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  heightSpacer(4),
                  Text(
                    'These presets appear in the Notice Board compose form so admins can publish repeated alerts faster.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedTextFor(brightness),
                          height: 1.45,
                        ),
                  ),
                  heightSpacer(12),
                  if (catalog.alertPresets.isEmpty)
                    const AppEmptyState(
                      icon: AppIcons.alert,
                      title: 'No presets yet',
                      message:
                          'Add quick alerts for recurring notices like maintenance or mess changes.',
                    )
                  else
                    ...catalog.alertPresets.asMap().entries.map(
                          (MapEntry<int, AdminAlertPreset> entry) =>
                              _EditableRow(
                            title: entry.value.title,
                            subtitle:
                                '${entry.value.category} • ${entry.value.message}',
                            onEdit: () => _editAlertPreset(
                              categories: catalog.noticeCategories,
                              existing: entry.value,
                              onSaved: (AdminAlertPreset preset) {
                                final List<AdminAlertPreset> next =
                                    List<AdminAlertPreset>.from(
                                  catalog.alertPresets,
                                );
                                next[entry.key] = preset;
                                _updateCatalog(
                                  catalog.copyWith(alertPresets: next),
                                );
                              },
                            ),
                            onDelete: () {
                              final List<AdminAlertPreset> next =
                                  List<AdminAlertPreset>.from(
                                catalog.alertPresets,
                              )..removeAt(entry.key);
                              _updateCatalog(
                                  catalog.copyWith(alertPresets: next));
                            },
                          ),
                        ),
                ],
              ),
            ),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _SectionHeader(
                    title: 'Dashboard shortcuts',
                    icon: AppIcons.adminCatalog,
                    onAdd: () => _editShortcut(
                      onSaved: (AdminServiceShortcut shortcut) {
                        _updateCatalog(
                          catalog.copyWith(
                            serviceShortcuts: <AdminServiceShortcut>[
                              ...catalog.serviceShortcuts,
                              shortcut,
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  heightSpacer(4),
                  Text(
                    'Optional extra service cards are appended on dashboards for the selected user roles.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedTextFor(brightness),
                          height: 1.45,
                        ),
                  ),
                  heightSpacer(12),
                  if (catalog.serviceShortcuts.isEmpty)
                    const AppEmptyState(
                      icon: AppIcons.open,
                      title: 'No shortcuts yet',
                      message:
                          'Add extra dashboard shortcuts for supported routes like notices, laundry, room requests, or parcel desk.',
                    )
                  else
                    ...catalog.serviceShortcuts.asMap().entries.map(
                          (MapEntry<int, AdminServiceShortcut> entry) =>
                              _EditableRow(
                            title: entry.value.title,
                            subtitle:
                                '${entry.value.subtitle} • ${entry.value.roles.map((UserRole role) => role.label).join(', ')}',
                            trailingChip: entry.value.route,
                            onEdit: () => _editShortcut(
                              existing: entry.value,
                              onSaved: (AdminServiceShortcut shortcut) {
                                final List<AdminServiceShortcut> next =
                                    List<AdminServiceShortcut>.from(
                                  catalog.serviceShortcuts,
                                );
                                next[entry.key] = shortcut;
                                _updateCatalog(
                                  catalog.copyWith(serviceShortcuts: next),
                                );
                              },
                            ),
                            onDelete: () {
                              final List<AdminServiceShortcut> next =
                                  List<AdminServiceShortcut>.from(
                                catalog.serviceShortcuts,
                              )..removeAt(entry.key);
                              _updateCatalog(
                                catalog.copyWith(serviceShortcuts: next),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
            CustomButton(
              buttonText: 'Save Operations Catalog',
              onTap: _saveCatalog,
            ),
          ],
        ),
      ),
    );
  }

  void _syncDraft(AdminCatalog catalog) {
    final String signature = jsonEncode(catalog.toJson());
    if (_draftCatalog == null || _syncedSignature != signature) {
      _draftCatalog = AdminCatalog.fromJson(catalog.toJson());
      _syncedSignature = signature;
    }
  }

  void _updateCatalog(AdminCatalog catalog) {
    setState(() {
      _draftCatalog = catalog;
    });
  }

  Future<void> _saveCatalog() async {
    final AdminCatalog? catalog = _draftCatalog;
    if (catalog == null) {
      return;
    }
    final AppState appState = context.read<AppState>();
    try {
      await appState.updateAdminCatalog(catalog);
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Operations catalog updated.');
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(
        context,
        'Unable to update the operations catalog.',
        isError: true,
      );
    }
  }

  Future<void> _editStringItem({
    required String title,
    String? initialValue,
    required ValueChanged<String> onSaved,
  }) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController controller = TextEditingController(
      text: initialValue ?? '',
    );

    final String? value = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _EditorSheet(
          title: title,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CustomTextField(
                  controller: controller,
                  inputHint: 'Name',
                  validator: (String? value) =>
                      AppValidators.requiredField(value, 'Name'),
                ),
                heightSpacer(8),
                CustomButton(
                  buttonText: 'Save',
                  onTap: () {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    Navigator.of(context).pop(controller.text.trim());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    controller.dispose();
    if (!mounted || value == null || value.trim().isEmpty) {
      return;
    }
    onSaved(value);
  }

  Future<void> _editAlertPreset({
    required List<String> categories,
    AdminAlertPreset? existing,
    required ValueChanged<AdminAlertPreset> onSaved,
  }) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController titleController = TextEditingController(
      text: existing?.title ?? '',
    );
    final TextEditingController messageController = TextEditingController(
      text: existing?.message ?? '',
    );
    String? selectedCategory =
        existing?.category ?? (categories.isEmpty ? null : categories.first);

    final AdminAlertPreset? preset =
        await showModalBottomSheet<AdminAlertPreset>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return _EditorSheet(
              title:
                  existing == null ? 'Add alert preset' : 'Edit alert preset',
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CustomTextField(
                      controller: titleController,
                      inputHint: 'Preset title',
                      validator: (String? value) =>
                          AppValidators.requiredField(value, 'Preset title'),
                    ),
                    CustomTextField(
                      controller: messageController,
                      inputHint: 'Preset message',
                      minLines: 3,
                      maxLines: 4,
                      validator: (String? value) =>
                          AppValidators.requiredField(value, 'Preset message'),
                    ),
                    AppDropdownField<String>(
                      initialValue: selectedCategory,
                      items: categories
                          .map(
                            (String category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (String? value) {
                        setModalState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    heightSpacer(8),
                    CustomButton(
                      buttonText: 'Save Preset',
                      onTap: () {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        final String? category = selectedCategory;
                        if (category == null || category.trim().isEmpty) {
                          showAppMessage(
                            context,
                            'Select a category.',
                            isError: true,
                          );
                          return;
                        }
                        Navigator.of(context).pop(
                          AdminAlertPreset(
                            title: titleController.text.trim(),
                            category: category,
                            message: messageController.text.trim(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    messageController.dispose();
    if (!mounted || preset == null) {
      return;
    }
    onSaved(preset);
  }

  Future<void> _editShortcut({
    AdminServiceShortcut? existing,
    required ValueChanged<AdminServiceShortcut> onSaved,
  }) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController titleController = TextEditingController(
      text: existing?.title ?? '',
    );
    final TextEditingController subtitleController = TextEditingController(
      text: existing?.subtitle ?? '',
    );
    String? route = existing?.route ?? _routeOptions.first.route;
    String? iconKey = existing?.iconKey ?? _iconOptions.first.key;
    final Set<UserRole> selectedRoles =
        existing?.roles.toSet() ?? <UserRole>{UserRole.student};

    final AdminServiceShortcut? shortcut =
        await showModalBottomSheet<AdminServiceShortcut>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return _EditorSheet(
              title: existing == null
                  ? 'Add dashboard shortcut'
                  : 'Edit dashboard shortcut',
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CustomTextField(
                      controller: titleController,
                      inputHint: 'Card title',
                      validator: (String? value) =>
                          AppValidators.requiredField(value, 'Card title'),
                    ),
                    CustomTextField(
                      controller: subtitleController,
                      inputHint: 'Card subtitle',
                      validator: (String? value) =>
                          AppValidators.requiredField(value, 'Card subtitle'),
                    ),
                    AppDropdownField<String>(
                      initialValue: route,
                      items: _routeOptions
                          .map(
                            (_ShortcutRouteOption option) =>
                                DropdownMenuItem<String>(
                              value: option.route,
                              child: Text(option.label),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (String? value) {
                        setModalState(() {
                          route = value;
                        });
                      },
                    ),
                    heightSpacer(6),
                    AppDropdownField<String>(
                      initialValue: iconKey,
                      items: _iconOptions
                          .map(
                            (_ShortcutIconOption option) =>
                                DropdownMenuItem<String>(
                              value: option.key,
                              child: Text(option.label),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (String? value) {
                        setModalState(() {
                          iconKey = value;
                        });
                      },
                    ),
                    heightSpacer(8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Visible for',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mutedTextFor(
                                Theme.of(context).brightness,
                              ),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    heightSpacer(8),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: UserRole.values.map((UserRole role) {
                        final bool selected = selectedRoles.contains(role);
                        return FilterChip(
                          label: Text(role.label),
                          selected: selected,
                          onSelected: (bool value) {
                            setModalState(() {
                              if (value) {
                                selectedRoles.add(role);
                              } else {
                                selectedRoles.remove(role);
                              }
                            });
                          },
                        );
                      }).toList(growable: false),
                    ),
                    heightSpacer(10),
                    CustomButton(
                      buttonText: 'Save Shortcut',
                      onTap: () {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        final String? selectedRoute = route;
                        final String? selectedIconKey = iconKey;
                        if (selectedRoute == null ||
                            selectedIconKey == null ||
                            selectedRoles.isEmpty) {
                          showAppMessage(
                            context,
                            'Select a route, icon, and at least one role.',
                            isError: true,
                          );
                          return;
                        }
                        Navigator.of(context).pop(
                          AdminServiceShortcut(
                            title: titleController.text.trim(),
                            subtitle: subtitleController.text.trim(),
                            route: selectedRoute,
                            iconKey: selectedIconKey,
                            roles: selectedRoles.toList(growable: false),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    subtitleController.dispose();
    if (!mounted || shortcut == null) {
      return;
    }
    onSaved(shortcut);
  }
}

class _StringCatalogSection extends StatelessWidget {
  const _StringCatalogSection({
    required this.title,
    required this.description,
    required this.items,
    required this.icon,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
  });

  final String title;
  final String description;
  final List<String> items;
  final IconData icon;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionHeader(
            title: title,
            icon: icon,
            onAdd: onAdd,
          ),
          heightSpacer(4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                  height: 1.45,
                ),
          ),
          heightSpacer(12),
          if (items.isEmpty)
            const AppEmptyState(
              icon: AppIcons.category,
              title: 'No entries yet',
              message: 'Add items to make them available across the app.',
            )
          else
            ...items.asMap().entries.map(
                  (MapEntry<int, String> entry) => _EditableRow(
                    title: entry.value,
                    onEdit: () => onEdit(entry.key),
                    onDelete: () => onRemove(entry.key),
                  ),
                ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.onAdd,
  });

  final String title;
  final IconData icon;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          height: 38.h,
          width: 38.w,
          decoration: BoxDecoration(
            color: AppColors.softSurfaceFor(Theme.of(context).brightness),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            color: AppColors.kGreenColor,
          ),
        ),
        widthSpacer(10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryTextFor(Theme.of(context).brightness),
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add'),
        ),
      ],
    );
  }
}

class _EditableRow extends StatelessWidget {
  const _EditableRow({
    required this.title,
    this.subtitle,
    this.trailingChip,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String? subtitle;
  final String? trailingChip;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.softSurfaceFor(brightness),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderFor(brightness)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryTextFor(brightness),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (subtitle != null) ...<Widget>[
                  heightSpacer(2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedTextFor(brightness),
                          height: 1.35,
                        ),
                  ),
                ],
                if (trailingChip != null) ...<Widget>[
                  heightSpacer(8),
                  StatusChip(
                    label: trailingChip!,
                    color: AppColors.kGreenColor,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _QuickJumpChip extends StatelessWidget {
  const _QuickJumpChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16.sp, color: AppColors.kGreenColor),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _EditorSheet extends StatelessWidget {
  const _EditorSheet({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 14.w,
        right: 14.w,
        top: 24.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 14.h,
      ),
      child: Material(
        color: AppColors.surfaceColor(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(26.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryTextFor(
                          Theme.of(context).brightness),
                      fontWeight: FontWeight.w800,
                    ),
              ),
              heightSpacer(12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutRouteOption {
  const _ShortcutRouteOption(this.route, this.label);

  final String route;
  final String label;
}

class _ShortcutIconOption {
  const _ShortcutIconOption(this.key, this.label);

  final String key;
  final String label;
}

const List<_ShortcutRouteOption> _routeOptions = <_ShortcutRouteOption>[
  _ShortcutRouteOption(AppRoutes.roomAvailability, 'Room Availability'),
  _ShortcutRouteOption(AppRoutes.fees, 'Fees'),
  _ShortcutRouteOption(AppRoutes.notifications, 'Notifications'),
  _ShortcutRouteOption(AppRoutes.laundry, 'Laundry'),
  _ShortcutRouteOption(AppRoutes.mess, 'Mess'),
  _ShortcutRouteOption(AppRoutes.parcelDesk, 'Parcel Desk'),
  _ShortcutRouteOption(AppRoutes.notices, 'Notice Board'),
  _ShortcutRouteOption(AppRoutes.createIssue, 'Issue Center'),
  _ShortcutRouteOption(AppRoutes.roomChangeRequests, 'Room Change Requests'),
  _ShortcutRouteOption(AppRoutes.chat, 'Chat'),
  _ShortcutRouteOption(AppRoutes.gatePass, 'Gate Pass'),
  _ShortcutRouteOption(AppRoutes.search, 'Search'),
];

const List<_ShortcutIconOption> _iconOptions = <_ShortcutIconOption>[
  _ShortcutIconOption('room', 'Room'),
  _ShortcutIconOption('fees', 'Fees'),
  _ShortcutIconOption('notifications', 'Notifications'),
  _ShortcutIconOption('laundry', 'Laundry'),
  _ShortcutIconOption('mess', 'Mess'),
  _ShortcutIconOption('parcel', 'Parcel'),
  _ShortcutIconOption('notice', 'Notice'),
  _ShortcutIconOption('issue', 'Issue'),
  _ShortcutIconOption('request', 'Request'),
  _ShortcutIconOption('chat', 'Chat'),
  _ShortcutIconOption('gatePass', 'Gate Pass'),
  _ShortcutIconOption('settings', 'Settings'),
];
