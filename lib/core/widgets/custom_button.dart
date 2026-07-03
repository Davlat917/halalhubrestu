import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:flutter/material.dart';

// ─── Enumlar ──────────────────────────────────────────────────────────────────

enum ButtonType { filled, outlined, text, gradient }

enum ButtonLoadingType { circular, dots }

// ─── CustomButton ─────────────────────────────────────────────────────────────

class CustomButton extends ResponsiveSection {
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = ButtonType.filled,
    this.loadingType = ButtonLoadingType.circular,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.gradientColors,
    this.loadingColor,
    this.textStyle,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 12.0,
    this.borderWidth = 1.5,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonLoadingType loadingType;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final List<Color>? gradientColors;
  final Color? loadingColor;
  final TextStyle? textStyle;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double borderWidth;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget buildMobile(BuildContext context) => _ButtonContent(
    button: this,
    height: height ?? 50,
    textStyle: textStyle ?? AppTextStyle.semibold16(context),
    width: width ?? context.screenWidth,
  );

  @override
  Widget buildTablet(BuildContext context) => _ButtonContent(
    button: this,
    height: height ?? 50,
    textStyle: textStyle ?? AppTextStyle.semibold16(context),
    width: width ?? context.screenWidth,
  );
}

// ─── Button content ───────────────────────────────────────────────────────────

class _ButtonContent extends StatefulWidget {
  const _ButtonContent({
    required this.button,
    required this.height,
    required this.textStyle,
    required this.width,
  });

  final CustomButton button;
  final double height;
  final TextStyle textStyle;
  final double width;

  @override
  State<_ButtonContent> createState() => _ButtonContentState();
}

class _ButtonContentState extends State<_ButtonContent> {
  bool _isPressed = false;

  // Cached values — har buildda yangi obyekt yaratilmaydi
  late BoxDecoration _cachedDecoration;
  late Color _cachedFg;
  late TextStyle _cachedTextStyle;
  late Color _cachedLoadingColor;

  @override
  void initState() {
    super.initState();
    _buildCache();
  }

  @override
  void didUpdateWidget(_ButtonContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_needsRebuildCache(oldWidget)) {
      _buildCache();
    }
  }

  bool _needsRebuildCache(_ButtonContent old) {
    final o = old.button;
    final c = widget.button;
    return o.isDisabled != c.isDisabled ||
        o.type != c.type ||
        o.backgroundColor != c.backgroundColor ||
        o.foregroundColor != c.foregroundColor ||
        o.borderColor != c.borderColor ||
        o.gradientColors != c.gradientColors ||
        o.borderRadius != c.borderRadius ||
        o.borderWidth != c.borderWidth ||
        old.textStyle != widget.textStyle;
  }

  void _buildCache() {
    _cachedFg = _resolveFg();
    _cachedDecoration = _buildDecoration();
    _cachedTextStyle = widget.textStyle.copyWith(color: _cachedFg);
    _cachedLoadingColor = widget.button.loadingColor ?? _cachedFg;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  CustomButton get b => widget.button;
  bool get _isInteractable => !b.isDisabled && !b.isLoading;

  Color _resolveFg() => switch (b.type) {
    ButtonType.filled ||
    ButtonType.gradient => b.foregroundColor ?? Colors.white,
    ButtonType.outlined => b.foregroundColor ?? StaticColors.primary,
    ButtonType.text => b.foregroundColor ?? StaticColors.black,
  };

  Color get _resolveBg => switch (b.type) {
    ButtonType.filled => b.backgroundColor ?? StaticColors.primary,
    ButtonType.outlined ||
    ButtonType.text => b.backgroundColor ?? StaticColors.white,
    ButtonType.gradient => Colors.transparent,
  };

  BoxDecoration _buildDecoration() {
    final radius = BorderRadius.circular(b.borderRadius);
    final opacity = b.isDisabled ? 126 : 255;

    if (b.type == ButtonType.gradient) {
      final colors =
          b.gradientColors ?? const [Color(0xFF2979FF), Color(0xFF00C853)];
      return BoxDecoration(
        gradient: LinearGradient(
          colors: colors.map((c) => c.withAlpha(opacity)).toList(),
        ),
        borderRadius: radius,
      );
    }

    return BoxDecoration(
      color: _resolveBg.withAlpha(opacity),
      borderRadius: radius,
      border: b.type == ButtonType.outlined
          ? Border.all(
              color: (b.borderColor ?? StaticColors.primary).withAlpha(opacity),
              width: b.borderWidth,
            )
          : null,
    );
  }

  // ─── Tap handlers ─────────────────────────────────────────────────────────

  void _onTapDown(_) {
    if (_isInteractable && !_isPressed) {
      setState(() => _isPressed = true);
    }
  }

  void _onTapUp(_) {
    if (_isPressed) setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    if (_isPressed) setState(() => _isPressed = false);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _isInteractable ? b.onPressed : null,
        child: _ScaleWrapper(
          isPressed: _isPressed,
          child: Container(
            width: widget.width,
            height: widget.height,
            margin: b.margin,
            padding: b.padding ?? const EdgeInsets.symmetric(horizontal: 24),
            decoration: _cachedDecoration,
            alignment: Alignment.center,
            child: _ButtonLabel(
              label: b.label,
              textStyle: _cachedTextStyle,
              isLoading: b.isLoading,
              loadingType: b.loadingType,
              loadingColor: _cachedLoadingColor,
              prefixIcon: b.prefixIcon,
              suffixIcon: b.suffixIcon,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Scale wrapper ────────────────────────────────────────────────────────────
// Alohida widget — scale o'zgarganda Container rebuild bo'lmaydi

class _ScaleWrapper extends StatelessWidget {
  const _ScaleWrapper({required this.isPressed, required this.child});

  final bool isPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      child: child,
    );
  }
}

// ─── Button label ─────────────────────────────────────────────────────────────
// StatelessWidget — ichida hech qanday state yo'q

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({
    required this.label,
    required this.textStyle,
    required this.isLoading,
    required this.loadingType,
    required this.loadingColor,
    required this.prefixIcon,
    required this.suffixIcon,
  });

  final String label;
  final TextStyle textStyle;
  final bool isLoading;
  final ButtonLoadingType loadingType;
  final Color loadingColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  Widget _buildLoading() => switch (loadingType) {
    ButtonLoadingType.circular => SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation(loadingColor),
      ),
    ),
    ButtonLoadingType.dots => _DotsIndicator(color: loadingColor),
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (suffixIcon != null && !isLoading) suffixIcon!,
        Flexible(
          child: Text(
            label,
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        if (isLoading) _buildLoading(),
        if (prefixIcon != null && !isLoading) prefixIcon!,
      ],
    );
  }
}

// ─── Dots indicator ───────────────────────────────────────────────────────────

class _DotsIndicator extends StatefulWidget {
  const _DotsIndicator({required this.color});

  final Color color;

  @override
  State<_DotsIndicator> createState() => _DotsIndicatorState();
}

class _DotsIndicatorState extends State<_DotsIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 18,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (i) {
            final value = ((_controller.value - i / 3) % 1.0);
            final scale = (value < 0.5 ? 0.5 + value : 1.5 - value).clamp(
              0.5,
              1.0,
            );
            return Transform.scale(
              scale: scale,
              child: _DotShape(color: widget.color),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Dot shape ────────────────────────────────────────────────────────────────
// Alohida const widget — har animatsiyada Container qayta yaratilmaydi

class _DotShape extends StatelessWidget {
  const _DotShape({required this.color});

  final Color color;

  static const _decoration = BoxDecoration(shape: BoxShape.circle);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: _decoration.copyWith(color: color),
    );
  }
}
