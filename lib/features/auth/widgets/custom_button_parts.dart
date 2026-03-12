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
    final Brightness brightness = Theme.of(context).brightness;

    return SizedBox(
      width: double.maxFinite,
      height: 52.h,
      child: FilledButton(
        onPressed: isDisabled ? null : _handleTap,
        style: AppButtonStyles.filled(
          brightness,
          foregroundColor: widget.buttonColor ?? Colors.white,
          radius: 20.r,
        ),
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
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: widget.buttonColor ?? Colors.white,
                      fontSize: widget.size ?? 15,
                    ),
              ),
      ),
    );
  }
}
