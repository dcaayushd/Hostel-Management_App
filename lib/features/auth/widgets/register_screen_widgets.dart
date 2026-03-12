part of '../screens/register_screen.dart';

class _PickerField<T> extends StatelessWidget {
  const _PickerField({
    super.key,
    required this.value,
    required this.hintText,
    required this.validator,
    this.displayText,
    this.onPick,
    this.onChanged,
    this.enabled = true,
  });

  final T? value;
  final String? displayText;
  final String hintText;
  final String? Function(T? value) validator;
  final Future<T?> Function()? onPick;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color primaryTextColor = AppColors.primaryTextFor(brightness);
    final Color mutedTextColor = AppColors.mutedTextFor(brightness);
    final Color borderColor = AppColors.borderFor(brightness);
    return FormField<T>(
      key: key,
      initialValue: value,
      validator: (_) => validator(value),
      builder: (FormFieldState<T> field) {
        final bool hasSelection =
            displayText != null && displayText!.trim().isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: !enabled || onPick == null
                    ? null
                    : () async {
                        final T? pickedValue = await onPick!.call();
                        if (pickedValue == null) {
                          return;
                        }
                        field.didChange(pickedValue);
                        onChanged?.call(pickedValue);
                      },
                borderRadius: BorderRadius.circular(18.r),
                child: InputDecorator(
                  isEmpty: !hasSelection,
                  decoration: InputDecoration(
                    errorText: field.errorText,
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: enabled ? mutedTextColor : borderColor,
                    ),
                  ),
                  child: Text(
                    hasSelection ? displayText! : hintText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color:
                              hasSelection ? primaryTextColor : mutedTextColor,
                        ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
