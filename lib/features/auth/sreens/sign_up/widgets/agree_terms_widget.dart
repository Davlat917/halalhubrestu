import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/constants/vendor_legal_urls.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// Checkbox + matn. [showVendorLegalLinks] bo‘lsa, Terms / Privacy ichki `onTap` bilan brauzerda ochiladi.
class AgreeTermsWidget extends StatefulWidget {
  const AgreeTermsWidget({
    super.key,
    this.availableWidth,
    required this.isAgree,
    required this.onPressed,
    this.label,
    this.showVendorLegalLinks = false,
  }) : assert(
          showVendorLegalLinks || label != null,
          'label kerak, agar showVendorLegalLinks false bo‘lsa',
        );

  final double? availableWidth;
  final bool isAgree;
  final VoidCallback onPressed;
  final InlineSpan? label;
  final bool showVendorLegalLinks;

  @override
  State<AgreeTermsWidget> createState() => _AgreeTermsWidgetState();
}

class _AgreeTermsWidgetState extends State<AgreeTermsWidget> {
  TapGestureRecognizer? _termsTap;
  TapGestureRecognizer? _privacyTap;

  @override
  void initState() {
    super.initState();
    if (widget.showVendorLegalLinks) {
      _termsTap = TapGestureRecognizer()..onTap = _openTermsOfUse;
      _privacyTap = TapGestureRecognizer()..onTap = _openPrivacyPolicy;
    }
  }

  @override
  void didUpdateWidget(covariant AgreeTermsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showVendorLegalLinks != widget.showVendorLegalLinks) {
      _disposeRecognizers();
      if (widget.showVendorLegalLinks) {
        _termsTap = TapGestureRecognizer()..onTap = _openTermsOfUse;
        _privacyTap = TapGestureRecognizer()..onTap = _openPrivacyPolicy;
      }
    }
  }

  void _disposeRecognizers() {
    _termsTap?.dispose();
    _privacyTap?.dispose();
    _termsTap = null;
    _privacyTap = null;
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  Future<void> _openTermsOfUse() async {
    await _launchLegalUrl(VendorLegalUrls.termsOfUse);
  }

  Future<void> _openPrivacyPolicy() async {
    await _launchLegalUrl(VendorLegalUrls.privacyPolicy);
  }

  Future<void> _launchLegalUrl(String rawUrl) async {
    final uri = Uri.parse(rawUrl);
    final openedExternal = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (openedExternal) return;

    final openedInApp = await launchUrl(uri, mode: LaunchMode.inAppWebView);
    if (openedInApp || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the link.')),
    );
  }

  InlineSpan _vendorLegalSpan(BuildContext context, double aW) {
    return TextSpan(
      text: TranslationKeys.authAgreePrefix.tr(context: context),
      style: AppTextStyle.regular14(
        context,
        aW: aW,
        color: StaticColors.c9AA0A6,
      ),
      children: [
        TextSpan(
          text: TranslationKeys.authTermsOfService.tr(context: context),
          style: AppTextStyle.regular14(
            context,
            aW: aW,
            color: StaticColors.primary,
          ),
          recognizer: _termsTap,
        ),
        TextSpan(
          text: ' & ',
          style: AppTextStyle.regular14(
            context,
            aW: aW,
            color: StaticColors.c9AA0A6,
          ),
        ),
        TextSpan(
          text: TranslationKeys.authPrivacyPolicy.tr(context: context),
          style: AppTextStyle.regular14(
            context,
            aW: aW,
            color: StaticColors.primary,
          ),
          recognizer: _privacyTap,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final aW = widget.availableWidth ?? context.screenWidth;
    const primaryGreen = StaticColors.primary;

    final labelSpan = widget.showVendorLegalLinks
        ? _vendorLegalSpan(context, aW)
        : widget.label!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: context.wOf(22, aW),
            height: context.wOf(22, aW),
            decoration: BoxDecoration(
              color: widget.isAgree ? primaryGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(context.wOf(5, aW)),
              border: Border.all(
                color: widget.isAgree ? primaryGreen : Colors.grey.shade400,
                width: 1.5,
              ),
            ),
            child: widget.isAgree
                ? Icon(
                    Icons.check,
                    size: context.wOf(16, aW),
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        SizedBox(width: context.wOf(12, aW)),
        Expanded(
          child: RichText(
            text: TextSpan(children: [labelSpan]),
          ),
        ),
      ],
    );
  }
}
