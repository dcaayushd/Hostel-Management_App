part of 'home_screen.dart';

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.metric,
  });

  final _MetricData metric;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return DashboardTileCard(
      accentColor: metric.color,
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 9.h),
      onTap: () {
        Navigator.of(context).pushNamed(
          metric.route,
          arguments: metric.routeArgs,
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  metric.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: brightness == Brightness.dark
                            ? const Color(0xE6FFFFFF)
                            : const Color(0xFF335546),
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5.sp,
                      ),
                ),
              ),
              DashboardIconBadge(
                icon: metric.icon,
                accentColor: metric.color,
              ),
            ],
          ),
          Text(
            metric.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryTextFor(brightness),
                  fontWeight: FontWeight.w800,
                  fontSize: 21.sp,
                  height: 1,
                ),
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.title,
    required this.value,
    required this.route,
    required this.icon,
    required this.color,
    this.routeArgs,
  });

  final String title;
  final String value;
  final String route;
  final IconData icon;
  final Color color;
  final Object? routeArgs;
}

class _DashboardAction {
  const _DashboardAction({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.color,
    required this.icon,
    this.countText,
  });

  final String title;
  final String subtitle;
  final String route;
  final Color color;
  final IconData icon;
  final String? countText;
}
