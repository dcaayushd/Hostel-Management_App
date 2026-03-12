part of 'feedback.dart';

class _AppMessageOverlayState extends State<_AppMessageOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    reverseDuration: const Duration(milliseconds: 220),
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: widget.presentation == _AppMessagePresentation.dynamicIsland
        ? const Offset(0, -0.12)
        : const Offset(0, 0.12),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ),
  );
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _dismissTimer = Timer(const Duration(milliseconds: 2800), _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) {
      widget.onDismissed();
      return;
    }
    await _controller.reverse();
    if (!mounted) {
      return;
    }
    widget.onDismissed();
  }

  void _handleTap() {
    _dismissTimer?.cancel();
    widget.onDismissed();
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool useCompactPill =
        widget.presentation == _AppMessagePresentation.dynamicIsland;
    final bool showAboveNav =
        widget.presentation == _AppMessagePresentation.bottomFloating;
    final Color backgroundColor =
        widget.isError ? const Color(0xFF7A271A) : const Color(0xFF173C32);
    final IconData icon = widget.isError
        ? Icons.error_outline_rounded
        : Icons.check_circle_outline_rounded;
    final double topOffset = useCompactPill
        ? math.max(widget.topInset > 0 ? widget.topInset - 6 : 12, 12)
        : 0;
    final double bottomOffset =
        showAboveNav ? math.max(widget.bottomInset + 92, 88) : 0;

    Widget surface = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap == null ? null : _handleTap,
        borderRadius: BorderRadius.circular(useCompactPill ? 999 : 20),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: useCompactPill ? 16 : 18,
            vertical: useCompactPill ? 12 : 13,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(useCompactPill ? 999 : 20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x1F101828),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  widget.message,
                  maxLines: useCompactPill ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                ),
              ),
              if (widget.onTap != null) ...<Widget>[
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white.withValues(alpha: 0.88),
                  size: 18,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: widget.onTap == null,
        child: SafeArea(
          top: false,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: useCompactPill
                    ? Alignment.topCenter
                    : Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: topOffset,
                    bottom: bottomOffset,
                  ),
                  child: FadeTransition(
                    opacity: _opacity,
                    child: SlideTransition(
                      position: _offset,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: useCompactPill ? 340 : 360,
                        ),
                        child: surface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
