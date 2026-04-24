import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/models/vendor_agreement_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/sections/vendor_agreement_section.dart';

class VendorAgreementBody extends StatelessWidget {
  const VendorAgreementBody({super.key, required this.agreement, required this.selected, required this.maxWidth, required this.layout, required this.initialsController, required this.isAccepting, required this.isSigning, required this.isDownloading, required this.onAcceptTap, required this.onSignTap, required this.onDownloadTap});

  final VendorAgreementModel agreement;
  final VendorAgreementSectionModel selected;
  final double maxWidth;
  final AgreementLayout layout;
  final TextEditingController initialsController;
  final bool isAccepting;
  final bool isSigning;
  final bool isDownloading;
  final VoidCallback onAcceptTap;
  final VoidCallback onSignTap;
  final VoidCallback onDownloadTap;

  bool get _isMobile => layout == AgreementLayout.mobile;

  int _maxStep(List<VendorAgreementSectionModel> sections) {
    if (sections.isEmpty) return 0;
    return sections.map((e) => e.stepNumber).reduce((a, b) => a > b ? a : b);
  }

  VendorAgreementSectionModel? _resolveCurrentSection(VendorAgreementModel agreement) {
    if (agreement.sections.isEmpty) return null;
    final byStep = agreement.sections.where((e) => e.stepNumber == agreement.currentStep);
    if (byStep.isNotEmpty) return byStep.first;
    final idx = agreement.currentStep - 1;
    if (idx >= 0 && idx < agreement.sections.length) {
      return agreement.sections[idx];
    }
    final pending = agreement.sections.where((e) => !e.isAccepted);
    if (pending.isNotEmpty) return pending.first;
    return agreement.sections.first;
  }

  bool _allSectionsAccepted(VendorAgreementModel agreement) => agreement.sections.every((e) => e.isAccepted);

  @override
  Widget build(BuildContext context) {
    final agreement = this.agreement;
    final selected = this.selected;
    final currentSection = _resolveCurrentSection(agreement);
    final canAcceptCurrent = currentSection != null && !currentSection.isAccepted;
    final backendMaxStep = _maxStep(agreement.sections);
    final isSignSection = selected.stepNumber > backendMaxStep;
    final canSubmitSign = _allSectionsAccepted(agreement) && (agreement.signedAt == null || agreement.signedAt!.isEmpty);
    final isSigned = agreement.signedAt != null && agreement.signedAt!.isNotEmpty;
    final hasDownload = isSigned && (agreement.signedPdfUrl?.trim().isNotEmpty ?? false);

    final agreeEnabled = selected.stepNumber == agreement.currentStep && canAcceptCurrent && !isSignSection;

    final showHeader = !isSignSection || selected.body.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.wOf(14, maxWidth)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader) ...[Text(selected.title, style: AppTextStyle.semibold20(context, color: StaticColors.black)), const SizedBox(height: 8)],
            if (selected.body.trim().isNotEmpty) ...[Text(selected.body, style: AppTextStyle.regular14(context, color: StaticColors.c666666)), const SizedBox(height: 14)],
            if (isSignSection) _buildSignSection(context, canSubmitSign, isSigned, hasDownload) else _buildAgreeSection(context, agreeEnabled),
          ],
        ),
      ),
    );
  }

  Widget _buildSignSection(BuildContext context, bool canSubmitSign, bool isSigned, bool hasDownload) {
    final label = Text(
      TranslationKeys.agreementTypeInitials.tr(context: context),
      style: AppTextStyle.regular14(context, color: StaticColors.c666666),
    );

    final initialsInput = SizedBox(
      height: 50,
      child: CommonTextField(
        controller: initialsController,
        hint: TranslationKeys.agreementInitialsHint.tr(context: context),
        availableWidth: maxWidth,
        textSize: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );

    final submitBtn = SizedBox(
      width: _isMobile ? double.infinity : 140,
      child: CustomButton(
        label: TranslationKeys.agreementSubmit.tr(context: context),
        isDisabled: !canSubmitSign,
        isLoading: isSigning,
        textStyle: AppTextStyle.regular14(context),
        height: 46,
        onPressed: onSignTap,
      ),
    );

    if (isSigned) {
      final fileName = _resolveSignedFileName();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            TranslationKeys.agreementSigned.tr(context: context),
            style: AppTextStyle.medium14(context, color: StaticColors.primary),
          ),
          if (hasDownload) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: StaticColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: StaticColors.cE2E2E2),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.insert_drive_file_rounded,
                    color: StaticColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.medium14(
                        context,
                        color: StaticColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: _isMobile ? double.infinity : 180,
              child: CustomButton(
                label: TranslationKeys.agreementDownload.tr(context: context),
                textStyle: AppTextStyle.regular14(context),
                isLoading: isDownloading,
                height: 46,
                onPressed: onDownloadTap,
              ),
            ),
          ],
        ],
      );
    }

    if (_isMobile) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [label, const SizedBox(height: 8), initialsInput, const SizedBox(height: 12), submitBtn]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: initialsInput),
            const SizedBox(width: 10),
            Padding(padding: const EdgeInsets.only(top: 4), child: submitBtn),
          ],
        ),
      ],
    );
  }

  String _resolveSignedFileName() {
    final rawUrl = agreement.signedPdfUrl?.trim();
    if (rawUrl == null || rawUrl.isEmpty) return 'agreement.pdf';
    final uri = Uri.tryParse(rawUrl);
    final lastSegment = (uri?.pathSegments.isNotEmpty ?? false)
        ? uri!.pathSegments.last
        : rawUrl.split('/').last;
    final normalized = Uri.decodeComponent(lastSegment).trim();
    return normalized.isEmpty ? 'agreement.pdf' : normalized;
  }

  Widget _buildAgreeSection(BuildContext context, bool agreeEnabled) {
    final statusText = Text(
      TranslationKeys.agreementStatus.tr(context: context, namedArgs: {'status': agreement.status, 'accepted': '${agreement.sections.where((e) => e.isAccepted).length}', 'total': '${agreement.sections.length}'}),
      style: AppTextStyle.regular14(context, color: StaticColors.c9AA0A6),
    );

    final agreeBtn = SizedBox(
      width: _isMobile ? double.infinity : 150,
      child: CustomButton(
        label: selected.isAccepted ? TranslationKeys.agreementAccepted.tr(context: context) : TranslationKeys.agreementAgree.tr(context: context),
        isDisabled: !agreeEnabled,
        textStyle: AppTextStyle.regular14(context),
        isLoading: isAccepting,
        height: 46,
        onPressed: agreeEnabled ? onAcceptTap : null,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        statusText,
        const SizedBox(height: 10),
        if (_isMobile) agreeBtn,
        if (!_isMobile) Align(alignment: Alignment.centerRight, child: agreeBtn),
      ],
    );
  }
}
