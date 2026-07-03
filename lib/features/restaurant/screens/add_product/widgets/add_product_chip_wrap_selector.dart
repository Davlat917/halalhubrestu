import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

class ChipWrapSelector extends StatelessWidget {
  const ChipWrapSelector({
    super.key,
    required this.ids,
    required this.labels,
    required this.selectedIds,
    required this.onSelected,
    required this.chipRadius,
  });

  final List<int> ids;
  final List<String> labels;
  final Set<int> selectedIds;
  final void Function(int id, bool selected) onSelected;
  final double chipRadius;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (int i = 0; i < ids.length; i++)
          _ChoiceChip(
            id: ids[i],
            label: labels[i],
            selected: selectedIds.contains(ids[i]),
            onSelected: onSelected,
            chipRadius: chipRadius,
          ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.id,
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.chipRadius,
  });

  final int id;
  final String label;
  final bool selected;
  final void Function(int id, bool selected) onSelected;
  final double chipRadius;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: AppTextStyle.regular14(
          context,
          color: selected ? StaticColors.white : StaticColors.c4C4C4C,
        ),
      ),
      selected: selected,
      showCheckmark: false,
      selectedColor: StaticColors.primary,
      backgroundColor: StaticColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(chipRadius),
        side: BorderSide(
          color: selected ? StaticColors.primary : StaticColors.cE2E2E2,
        ),
      ),
      onSelected: (v) => onSelected(id, v),
    );
  }
}
