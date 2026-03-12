import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/custom_text_field.dart';
import '../../common/spacing.dart';
import '../utils/app_icons.dart';
import '../utils/feedback.dart';
import '../../theme/colors.dart';
import 'app_section_card.dart';

Future<String?> showBackendEndpointSheet({
  required BuildContext context,
  required String? initialOverride,
  required String? activeUrl,
  required String? defaultUrlHint,
  required bool lockedByBuild,
}) {
  return showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      return _BackendEndpointSheet(
        initialOverride: initialOverride,
        activeUrl: activeUrl,
        defaultUrlHint: defaultUrlHint,
        lockedByBuild: lockedByBuild,
      );
    },
  );
}

class _BackendEndpointSheet extends StatefulWidget {
  const _BackendEndpointSheet({
    required this.initialOverride,
    required this.activeUrl,
    required this.defaultUrlHint,
    required this.lockedByBuild,
  });

  final String? initialOverride;
  final String? activeUrl;
  final String? defaultUrlHint;
  final bool lockedByBuild;

  @override
  State<_BackendEndpointSheet> createState() => _BackendEndpointSheetState();
}

class _BackendEndpointSheetState extends State<_BackendEndpointSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialOverride ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bool hasOverride = widget.initialOverride != null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, bottomInset + 14.h),
        child: AppSectionCard(
          margin: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Backend connection',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(AppIcons.close),
                  ),
                ],
              ),
              Text(
                widget.lockedByBuild
                    ? 'This build is pinned to a fixed backend URL. Rebuild the app if you want to change it.'
                    : 'Use a LAN URL for same-Wi-Fi testing, or an HTTPS URL if someone farther away needs to connect.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedTextFor(brightness),
                      height: 1.45,
                    ),
              ),
              heightSpacer(14),
              if (widget.activeUrl != null)
                _ConnectionValueCard(
                  label: widget.lockedByBuild ? 'Build URL' : 'Current URL',
                  value: widget.activeUrl!,
                ),
              if (!widget.lockedByBuild &&
                  widget.defaultUrlHint != null) ...<Widget>[
                heightSpacer(10),
                _ConnectionValueCard(
                  label: 'Build fallback',
                  value: widget.defaultUrlHint!,
                ),
              ],
              if (!widget.lockedByBuild) ...<Widget>[
                heightSpacer(14),
                CustomTextField(
                  controller: _controller,
                  inputHint: 'http://192.168.1.20:8000 or https://example.com',
                  inputKeyBoardType: TextInputType.url,
                  inputAction: TextInputAction.done,
                  inputCapitalization: TextCapitalization.none,
                ),
                heightSpacer(8),
                Text(
                  'Same Wi-Fi: http://YOUR-LAPTOP-IP:8000\nFar away: use an HTTPS URL from a deployed server or tunnel.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedTextFor(brightness),
                        height: 1.45,
                      ),
                ),
                heightSpacer(16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: hasOverride
                            ? () {
                                Navigator.of(context).pop('');
                              }
                            : null,
                        child: const Text('Use default'),
                      ),
                    ),
                    widthSpacer(10),
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        child: const Text('Save URL'),
                      ),
                    ),
                  ],
                ),
              ] else ...<Widget>[
                heightSpacer(16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    final String value = _controller.text.trim();
    if (value.isEmpty) {
      Navigator.of(context).pop('');
      return;
    }
    final Uri? uri = Uri.tryParse(value);
    final bool isValid = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isValid) {
      showAppMessage(
        context,
        'Enter a full backend URL like http://192.168.1.20:8000 or https://example.com.',
        isError: true,
      );
      return;
    }
    Navigator.of(context).pop(
      value.endsWith('/') ? value.substring(0, value.length - 1) : value,
    );
  }
}

class _ConnectionValueCard extends StatelessWidget {
  const _ConnectionValueCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.tonalSurfaceFor(brightness),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.outlineFor(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                  fontWeight: FontWeight.w700,
                ),
          ),
          heightSpacer(4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
