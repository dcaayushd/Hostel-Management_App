part of 'custom_button.dart';

class _CustomButtonState extends State<CustomButton> {
  bool _isExecuting = false;

  Future<void> _handleTap() async {
    final FutureOr<void> Function()? callback = widget.onTap;
    if (callback == null || _isExecuting || widget.isLoading) {
      return;
    }

    setState(() {
      _isExecuting = true;
    });

    try {
      await callback();
    } finally {
      if (mounted) {
        setState(() {
          _isExecuting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = widget.isLoading || _isExecuting;
    final bool isDisabled = widget.onTap == null || isLoading;

    return Material(
      color: isDisabled
          ? AppColors.kGreenColor.withValues(alpha: 0.55)
          : AppColors.kGreenColor,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: isDisabled ? null : _handleTap,
        borderRadius: BorderRadius.circular(20.r),
        child: SizedBox(
          width: double.maxFinite,
          height: 52.h,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.buttonText,
                    style: AppTextTheme.kButtonStyle.copyWith(
                      color: widget.buttonColor ?? AppColors.kLight,
                      fontSize: widget.size ?? 15,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
