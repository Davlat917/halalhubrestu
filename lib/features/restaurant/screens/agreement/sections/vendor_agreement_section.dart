import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/bloc/vendor_agreement_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/bloc/vendor_agreement_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/bloc/vendor_agreement_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/data/vendor_agreement_api.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/data/vendor_agreement_repository_impl.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/mixins/vendor_agreement_feedback_mixin.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/models/vendor_agreement_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/widgets/vendor_agreement_body.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/widgets/vendor_agreement_steps_list.dart';
import 'package:open_filex/open_filex.dart';

/// Layout breakpoints
///   landscape tablet / desktop : maxWidth >= 860
///   portrait  tablet           : 600 <= maxWidth < 860
///   mobile                     : maxWidth < 600
enum AgreementLayout { wide, tabletPortrait, mobile }

AgreementLayout _resolveLayout(double maxWidth) {
  if (maxWidth >= 860) return AgreementLayout.wide;
  if (maxWidth >= 600) return AgreementLayout.tabletPortrait;
  return AgreementLayout.mobile;
}

class VendorAgreementSection extends StatefulWidget {
  const VendorAgreementSection({
    super.key,
    required this.vendorId,
    required this.maxWidth,
  });

  final int vendorId;
  final double maxWidth;

  @override
  State<VendorAgreementSection> createState() => _VendorAgreementSectionState();
}

class _VendorAgreementSectionState extends State<VendorAgreementSection>
    with VendorAgreementFeedbackMixin {
  late final VendorAgreementBloc _bloc;
  final TextEditingController _initialsController = TextEditingController();
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    final api = VendorAgreementApi(getIt<Dio>());
    final repo = VendorAgreementRepositoryImpl(api);
    _bloc = VendorAgreementBloc(vendorId: widget.vendorId, repository: repo)
      ..add(const VendorAgreementLoadRequested());
  }

  @override
  void dispose() {
    _initialsController.dispose();
    _bloc.close();
    super.dispose();
  }

  Future<void> _onDownloadTap(VendorAgreementModel agreement) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final api = VendorAgreementApi(getIt<Dio>());
      final repo = VendorAgreementRepositoryImpl(api);
      final file = await repo.downloadAgreement(vendorId: widget.vendorId);

      final downloadsDir = Directory(
        '${Platform.environment['HOME'] ?? ''}/Downloads',
      );
      final targetDir = await downloadsDir.exists()
          ? downloadsDir
          : Directory.systemTemp;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${targetDir.path}/$timestamp-${file.fileName}';
      final localFile = File(filePath);
      await localFile.writeAsBytes(file.bytes, flush: true);

      if (!mounted) return;
      final openResult = await OpenFilex.open(localFile.path);
      if (openResult.type != ResultType.done) {
        showAgreementMessage(openResult.message);
      }
    } catch (e) {
      if (!mounted) return;
      showAgreementMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  List<VendorAgreementSectionModel> _buildDisplaySections(
    BuildContext context,
    VendorAgreementModel agreement,
  ) {
    if (agreement.sections.isEmpty) return const [];
    final sections = List<VendorAgreementSectionModel>.from(agreement.sections)
      ..sort((a, b) => a.stepNumber.compareTo(b.stepNumber));
    final maxStep = sections.last.stepNumber;
    final isSigned = agreement.signedAt != null && agreement.signedAt!.isNotEmpty;
    sections.add(
      VendorAgreementSectionModel(
        id: -1,
        stepNumber: maxStep + 1,
        title: TranslationKeys.agreementReadAndAgree.tr(context: context),
        body: '',
        isAccepted: isSigned,
        acceptedAt: agreement.signedAt,
      ),
    );
    return sections;
  }

  VendorAgreementSectionModel? _resolveSelectedSection(
    VendorAgreementState state,
    List<VendorAgreementSectionModel> displaySections,
  ) {
    final agreement = state.agreement;
    if (agreement == null || displaySections.isEmpty) return null;
    final pending = agreement.sections.where((e) => !e.isAccepted);
    final isSigned = agreement.signedAt != null && agreement.signedAt!.isNotEmpty;

    // All backend sections are accepted, so keep focus on synthetic final step
    // until user signs.
    if (pending.isEmpty && !isSigned) {
      return displaySections.last;
    }
    // After signing, keep focus on synthetic final step so Download stays visible.
    if (isSigned) {
      return displaySections.last;
    }

    final selected = displaySections.where(
      (e) => e.stepNumber == state.selectedStep,
    );
    if (selected.isNotEmpty) return selected.first;
    if (pending.isNotEmpty) return pending.first;
    return displaySections.last;
  }

  @override
  Widget build(BuildContext context) {
    final layout = _resolveLayout(widget.maxWidth);
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<VendorAgreementBloc, VendorAgreementState>(
        listener: (context, state) {
          if (state.actionMessage != null && state.actionMessage!.isNotEmpty) {
            final m = state.actionMessage!;
            showAgreementMessage(
              m.startsWith('agreement.') ? m.tr(context: context) : m,
            );
          }
          if (state.status == VendorAgreementStatus.failure &&
              state.errorMessage != null &&
              state.errorMessage!.isNotEmpty) {
            showAgreementMessage(state.errorMessage!);
          }
        },
        builder: (context, state) {
          if (state.status == VendorAgreementStatus.loading ||
              state.status == VendorAgreementStatus.initial) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state.status == VendorAgreementStatus.failure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TranslationKeys.agreementLoadFailed.tr(context: context),
                    style: AppTextStyle.regular16(
                      context,
                      color: StaticColors.c666666,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    label: TranslationKeys.retry.tr(context: context),
                    width: 140,
                    height: 46,
                    onPressed: () => context.read<VendorAgreementBloc>().add(
                      const VendorAgreementLoadRequested(),
                    ),
                  ),
                ],
              ),
            );
          }

          final agreement = state.agreement;
          final displaySections = agreement == null
              ? const <VendorAgreementSectionModel>[]
              : _buildDisplaySections(context, agreement);
          final selected = _resolveSelectedSection(state, displaySections);
          if (agreement == null ||
              selected == null ||
              displaySections.isEmpty) {
            return Center(
              child: Text(
                TranslationKeys.agreementNotFound.tr(context: context),
                style: AppTextStyle.regular16(
                  context,
                  color: StaticColors.c666666,
                ),
              ),
            );
          }

          final spacing = context.wOf(16, widget.maxWidth);

          final stepsList = VendorAgreementStepsList(
            sections: displaySections,
            selectedStepNumber: selected.stepNumber,
            layout: layout,
            onStepTap: (step) => context.read<VendorAgreementBloc>().add(
              VendorAgreementStepSelected(stepNumber: step),
            ),
          );

          final body = VendorAgreementBody(
            agreement: agreement,
            selected: selected,
            maxWidth: widget.maxWidth,
            layout: layout,
            initialsController: _initialsController,
            isAccepting: state.isAccepting,
            isSigning: state.isSigning,
            isDownloading: _isDownloading,
            onAcceptTap: () => context
                .read<VendorAgreementBloc>()
                .add(const VendorAgreementAcceptRequested()),
            onSignTap: () => context.read<VendorAgreementBloc>().add(
              VendorAgreementSignRequested(
                initials: _initialsController.text,
              ),
            ),
            onDownloadTap: () => _onDownloadTap(agreement),
          );

          return Container(
            padding: EdgeInsets.all(context.wOf(16, widget.maxWidth)),
            decoration: BoxDecoration(
              color: StaticColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: StaticColors.cE2E2E2),
            ),
            child: switch (layout) {
              // ── Landscape tablet / desktop ────────────────────────────────
              AgreementLayout.wide => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 270, child: stepsList),
                  SizedBox(width: spacing),
                  Expanded(child: body),
                ],
              ),

              // ── Portrait tablet ───────────────────────────────────────────
              // Steps list is shown as a compact horizontal chip row at top;
              // body takes the remaining space below.
              AgreementLayout.tabletPortrait => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  stepsList,
                  SizedBox(height: spacing),
                  body,
                ],
              ),

              // ── Mobile ────────────────────────────────────────────────────
              // Same column layout, but VendorAgreementStepsList switches to
              // a collapsible/scrollable row internally (see widget).
              AgreementLayout.mobile => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  stepsList,
                  SizedBox(height: spacing),
                  body,
                ],
              ),
            },
          );
        },
      ),
    );
  }
}