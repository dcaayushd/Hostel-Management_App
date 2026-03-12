import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/spacing.dart';
import '../../theme/colors.dart';
import 'app_top_info_surface.dart';

class AppFeatureBannerStat {
  const AppFeatureBannerStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class AppFeatureBanner extends StatelessWidget {
  const AppFeatureBanner({
    super.key,
    required this.title,
    required this.icon,
    this.description,
    this.statusLabel,
    this.accentColor = AppColors.kTopInfoAccentColor,
    this.stats = const <AppFeatureBannerStat>[],
  });

  final String title;
  final String? description;
  final String? statusLabel;
  final IconData icon;
  final Color accentColor;
  final List<AppFeatureBannerStat> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: buildTopInfoSurfaceDecoration(
        context,
        accentColor: accentColor,
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppTopInfoIconBox(icon: icon),
              widthSpacer(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (description != null) ...<Widget>[
                      heightSpacer(4),
                      Text(
                        description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.78),
                              height: 1.45,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (statusLabel != null && statusLabel!.trim().isNotEmpty)
                AppTopInfoPill(
                  label: statusLabel!,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 7.h,
                  ),
                  showBorder: true,
                ),
            ],
          ),
          if (stats.isNotEmpty) ...<Widget>[
            heightSpacer(12),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double spacing = 8.w;
                final int columns = stats.length == 1 ? 1 : 2;
                final double tileWidth = columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - spacing) / 2;
                return Wrap(
                  spacing: spacing,
                  runSpacing: 8.h,
                  children: stats
                      .map(
                        (AppFeatureBannerStat stat) => SizedBox(
                          width: tileWidth,
                          child: _BannerStatTile(stat: stat),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _BannerStatTile extends StatelessWidget {
  const _BannerStatTile({
    required this.stat,
  });

  final AppFeatureBannerStat stat;

  @override
  Widget build(BuildContext context) {
    return AppTopInfoStatTile(
      label: stat.label,
      value: stat.value,
    );
  }
}
