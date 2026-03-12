import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

part 'feedback_parts.dart';

OverlayEntry? _activeAppMessageEntry;

void showAppMessage(
  BuildContext context,
  String message, {
  bool isError = false,
  VoidCallback? onTap,
}) {
  final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) {
    final MediaQueryData mediaQuery =
        MediaQuery.maybeOf(context) ?? const MediaQueryData();
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? const Color(0xFFB42318) : const Color(0xFF173C32),
          action: onTap == null
              ? null
              : SnackBarAction(
                  label: 'Open',
                  onPressed: onTap,
                  textColor: Colors.white,
                ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            110 + mediaQuery.padding.bottom,
          ),
        ),
      );
    return;
  }

  _activeAppMessageEntry?.remove();

  final MediaQueryData mediaQuery =
      MediaQuery.maybeOf(context) ?? const MediaQueryData();
  final _AppMessagePresentation presentation = mediaQuery.padding.top >= 44
      ? _AppMessagePresentation.dynamicIsland
      : _AppMessagePresentation.bottomFloating;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (BuildContext overlayContext) {
      return _AppMessageOverlay(
        message: message,
        isError: isError,
        presentation: presentation,
        topInset: mediaQuery.padding.top,
        bottomInset: mediaQuery.padding.bottom,
        onTap: onTap,
        onDismissed: () {
          if (_activeAppMessageEntry == entry) {
            _activeAppMessageEntry = null;
          }
          if (entry.mounted) {
            entry.remove();
          }
        },
      );
    },
  );

  _activeAppMessageEntry = entry;
  overlay.insert(entry);
}

enum _AppMessagePresentation {
  dynamicIsland,
  bottomFloating,
}

class _AppMessageOverlay extends StatefulWidget {
  const _AppMessageOverlay({
    required this.message,
    required this.isError,
    required this.presentation,
    required this.topInset,
    required this.bottomInset,
    this.onTap,
    required this.onDismissed,
  });

  final String message;
  final bool isError;
  final _AppMessagePresentation presentation;
  final double topInset;
  final double bottomInset;
  final VoidCallback? onTap;
  final VoidCallback onDismissed;

  @override
  State<_AppMessageOverlay> createState() => _AppMessageOverlayState();
}
