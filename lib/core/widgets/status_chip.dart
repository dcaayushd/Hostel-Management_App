import 'package:flutter/material.dart';

import '../../theme/colors.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.emphasized = false,
  });

  final String label;
  final Color color;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: emphasized
            ? AppColors.activeSurfaceFor(
                brightness,
                color: color,
                lightAlpha: 0.14,
                darkAlpha: 0.26,
              )
            : AppColors.emphasisSurface(
                color,
                brightness,
                lightAlpha: 0.12,
                darkAlpha: 0.24,
              ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: emphasized
              ? AppColors.activeBorderFor(
                  brightness,
                  color: color,
                  lightAlpha: 0.28,
                  darkAlpha: 0.38,
                )
              : AppColors.emphasisBorder(
                  color,
                  brightness,
                  lightAlpha: 0.20,
                  darkAlpha: 0.34,
                ),
        ),
        boxShadow: emphasized
            ? <BoxShadow>[
                AppColors.activeShadow(
                  brightness,
                  color: color,
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: brightness == Brightness.dark ? Colors.white : color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
