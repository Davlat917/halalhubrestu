import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/models/vendor_agreement_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/sections/vendor_agreement_section.dart';

class VendorAgreementStepsList extends StatelessWidget {
  const VendorAgreementStepsList({super.key, required this.sections, required this.selectedStepNumber, required this.onStepTap, required this.layout});

  final List<VendorAgreementSectionModel> sections;
  final int selectedStepNumber;
  final ValueChanged<int> onStepTap;
  final AgreementLayout layout;

  @override
  Widget build(BuildContext context) {
    return switch (layout) {
      // ── Wide: vertical list in a card ─────────────────────────────────────
      AgreementLayout.wide => _VerticalStepsList(sections: sections, selectedStepNumber: selectedStepNumber, onStepTap: onStepTap),

      // ── Portrait tablet: vertical list card ───────────────────────────────
      AgreementLayout.tabletPortrait => _VerticalStepsList(sections: sections, selectedStepNumber: selectedStepNumber, onStepTap: onStepTap),

      // ── Mobile: vertical list card (no chips) ─────────────────────────────
      AgreementLayout.mobile => _VerticalStepsList(sections: sections, selectedStepNumber: selectedStepNumber, onStepTap: onStepTap),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vertical list  (wide + tablet portrait)
// ─────────────────────────────────────────────────────────────────────────────
class _VerticalStepsList extends StatelessWidget {
  const _VerticalStepsList({required this.sections, required this.selectedStepNumber, required this.onStepTap});

  final List<VendorAgreementSectionModel> sections;
  final int selectedStepNumber;
  final ValueChanged<int> onStepTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StaticColors.cEAF8EF,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: sections.map((section) {
          final isSelected = selectedStepNumber == section.stepNumber;
          return _VerticalStepTile(section: section, isSelected: isSelected, onTap: () => onStepTap(section.stepNumber));
        }).toList(),
      ),
    );
  }
}

class _VerticalStepTile extends StatelessWidget {
  const _VerticalStepTile({required this.section, required this.isSelected, required this.onTap});

  final VendorAgreementSectionModel section;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          title: Text('${section.stepNumber}. ${section.title}', style: AppTextStyle.medium14(context, color: isSelected ? StaticColors.primary : StaticColors.black)),
          trailing: section.isAccepted ? const Icon(Icons.check_circle_rounded, color: StaticColors.primary, size: 18) : null,
        ),
      ),
    );
  }
}
