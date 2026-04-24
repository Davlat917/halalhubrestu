import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CommonTextField extends StatefulWidget {
  const CommonTextField({
    super.key,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.errorText,
    this.onChanged,
    this.keyboardType,
    this.inputFormatter,
    this.enabled,
    this.suffix,
    this.mask,
    this.maxLength,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.background,
    this.hintColor,
    this.textColor,
    this.suffixPressed,
    this.moneyInput = false,
    this.upperCaseInput = false,
    this.autofocus = false,
    this.padding,
    this.initialValue,
    this.textInputAction,
    this.onTap,
    this.minLines,
    this.maxLines = 1,
    this.readOnly = false,
    this.focusNode,
    this.radius = 12,
    this.validator,
    this.scrollPadding,
    this.textSize,
    this.textFontWeight = FontWeight.w500,
    this.availableWidth, // ✅
  });

  final FocusNode? focusNode;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffix;
  final TextEditingController? controller;
  final bool obscureText;
  final bool? enabled;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatter;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final Color? background;
  final Color? hintColor;
  final Color? textColor;
  final String? mask;
  final int? maxLength;
  final VoidCallback? suffixPressed;
  final bool moneyInput;
  final bool upperCaseInput;
  final bool autofocus;
  final bool readOnly;
  final EdgeInsets? padding;
  final EdgeInsets? scrollPadding;
  final String? initialValue;
  final TextInputAction? textInputAction;
  final GestureTapCallback? onTap;
  final int? maxLines;
  final int? minLines;
  final double radius;
  final double? textSize;
  final FontWeight textFontWeight;
  final double? availableWidth; // ✅
  final String? Function(String?)? validator;

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  bool _passwordVisible = true;
  late MaskTextInputFormatter _maskFormatter;

  late BorderRadius _borderRadius;
  late InputBorder _border;
  late InputBorder _enabledBorder;
  late InputBorder _disabledBorder;
  late InputBorder _focusedBorder;
  late InputBorder _errorBorder;

  @override
  void initState() {
    super.initState();
    _passwordVisible = widget.obscureText;
    _maskFormatter = MaskTextInputFormatter(
      mask: widget.mask,
      filter: {'#': RegExp(r'\d')},
      type: MaskAutoCompletionType.lazy,
    );
    _buildBorders();
  }

  @override
  void didUpdateWidget(CommonTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.radius != widget.radius ||
        oldWidget.enabledBorderColor != widget.enabledBorderColor ||
        oldWidget.focusedBorderColor != widget.focusedBorderColor) {
      _buildBorders();
    }
    if (oldWidget.mask != widget.mask) {
      _maskFormatter.updateMask(mask: widget.mask);
    }
  }

  void _buildBorders() {
    _borderRadius = BorderRadius.circular(widget.radius);
    _border = OutlineInputBorder(
      borderSide: const BorderSide(color: StaticColors.backgroundColor),
      borderRadius: _borderRadius,
    );
    _enabledBorder = OutlineInputBorder(
      borderSide: BorderSide(color: widget.enabledBorderColor ?? StaticColors.backgroundColor),
      borderRadius: _borderRadius,
    );
    _disabledBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: _borderRadius,
    );
    _focusedBorder = OutlineInputBorder(
      borderSide: BorderSide(color: widget.focusedBorderColor ?? StaticColors.primary.withAlpha(125)),
      borderRadius: _borderRadius,
    );
    _errorBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red),
      borderRadius: _borderRadius,
    );
  }

  List<TextInputFormatter> _getFormatters() {
    final List<TextInputFormatter> formatters = [];
    if (widget.mask != null) {
      formatters.add(_maskFormatter);
    } else if (widget.moneyInput) {
      formatters.add(PriceInputFormatter());
    }
    if (widget.upperCaseInput) {
      formatters.add(const UpperCaseTextFormatter());
    }
    if (widget.inputFormatter != null) {
      formatters.addAll(widget.inputFormatter!);
    }
    return formatters;
  }

  @override
  Widget build(BuildContext context) {
    final double aW = widget.availableWidth ?? MediaQuery.sizeOf(context).width; // ✅
    final bool isTablet = aW >= 700;

    final double inputTextSize = widget.textSize ?? (isTablet ? context.spOf(18, aW) : context.spOf(16, aW)); // ✅
    final double hintTextSize = widget.textSize ?? (isTablet ? context.spOf(16, aW) : context.spOf(14, aW));  // ✅

    final EdgeInsets resolvedPadding = widget.padding ??
        EdgeInsets.symmetric(
          horizontal: isTablet ? context.wOf(20, aW) : context.wOf(16, aW),
          vertical: isTablet ? context.wOf(16, aW) : context.wOf(12, aW),
        );

    return TextFormField(
      scrollPadding: widget.scrollPadding ?? EdgeInsets.all(context.size16),
      textCapitalization: widget.upperCaseInput ? TextCapitalization.characters : TextCapitalization.sentences,
      validator: widget.validator,
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      textAlignVertical:
          (widget.maxLines ?? 1) > 1 ? TextAlignVertical.top : TextAlignVertical.center,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      initialValue: widget.initialValue,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      controller: widget.controller,
      onTap: widget.onTap,
      keyboardType: widget.keyboardType,
      obscureText: _passwordVisible,
      cursorColor: StaticColors.primary,
      onChanged: (value) {
        if (widget.onChanged == null) return;
        String result = value;
        if (widget.moneyInput) {
          result = value.replaceAll(' ', '');
        } else if (widget.mask != null) {
          result = _maskFormatter.getUnmaskedText();
        }
        widget.onChanged!(result);
      },
      inputFormatters: _getFormatters(),
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.background ?? StaticColors.backgroundColor,
        hintText: widget.hint,
        errorText: widget.errorText,
        contentPadding: resolvedPadding,
        prefixIcon: widget.prefixIcon == null
            ? null
            : Align(widthFactor: 1, alignment: Alignment.center, child: widget.prefixIcon),
        hintStyle: TextStyle(
          fontSize: hintTextSize, // ✅
          fontWeight: FontWeight.w400,
          color: widget.hintColor ?? StaticColors.cBDC1C6,
        ),
        border: _border,
        enabledBorder: _enabledBorder,
        disabledBorder: _disabledBorder,
        focusedBorder: _focusedBorder,
        errorBorder: _errorBorder,
        focusedErrorBorder: _errorBorder,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  color: StaticColors.primary,
                  _passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                ),
                onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
              )
            : widget.suffix != null
                ? IconButton(icon: widget.suffix!, onPressed: widget.suffixPressed)
                : null,
      ),
      style: TextStyle(
        fontSize: inputTextSize, // ✅
        fontWeight: widget.textFontWeight,
        color: widget.textColor ?? StaticColors.black,
      ),
    );
  }
}

// ─── PriceInputFormatter ─────────────────────────────────────────────────────

class PriceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'\D'), '');
    final StringBuffer buffer = StringBuffer();
    final int len = newText.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buffer.write(' ');
      buffer.write(newText[i]);
    }
    final String formattedText = buffer.toString();
    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

// ─── UpperCaseTextFormatter ───────────────────────────────────────────────────

class UpperCaseTextFormatter extends TextInputFormatter {
  const UpperCaseTextFormatter({this.maxLength});

  final int? maxLength;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (maxLength != null && newValue.text.length > maxLength!) {
      return oldValue;
    }
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}