part of '../screens/search_screen.dart';

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.result,
  });

  final _SearchResult result;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            result.route,
            arguments: result.arguments,
          );
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            children: <Widget>[
              Container(
                height: 40.h,
                width: 40.w,
                decoration: BoxDecoration(
                  color: result.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  result.icon,
                  color: result.accentColor,
                  size: 19.sp,
                ),
              ),
              widthSpacer(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      result.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primaryTextFor(brightness),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    heightSpacer(4),
                    Text(
                      '${result.section} • ${result.subtitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedTextFor(brightness),
                          ),
                    ),
                  ],
                ),
              ),
              widthSpacer(10),
              Icon(
                AppIcons.forward,
                size: 14.sp,
                color: AppColors.mutedTextFor(brightness),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
