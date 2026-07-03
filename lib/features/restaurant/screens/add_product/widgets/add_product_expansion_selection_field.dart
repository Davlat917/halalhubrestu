import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/widgets/add_product_details_parts.dart';

enum ExpansionSelectionControlType { checkbox, radio }

class ExpansionSelectionField extends StatefulWidget {
  const ExpansionSelectionField({
    super.key,
    required this.label,
    required this.hint,
    required this.ids,
    required this.labels,
    required this.selectedIds,
    required this.controlType,
    required this.onSelected,
    this.required = false,
    this.isLoading = false,
    this.validator,
  });

  final String label;
  final String hint;
  final List<int> ids;
  final List<String> labels;
  final Set<int> selectedIds;
  final ExpansionSelectionControlType controlType;
  final bool required;
  final bool isLoading;
  final void Function(int id, bool selected) onSelected;
  final String? Function(Set<int>?)? validator;

  @override
  State<ExpansionSelectionField> createState() =>
      _ExpansionSelectionFieldState();
}

class _ExpansionSelectionFieldState extends State<ExpansionSelectionField> {
  final ExpansibleController _controller = ExpansibleController();
  bool _isExpanded = false;

  List<String> get _selectedLabels {
    final selectedLabels = <String>[];
    for (int i = 0; i < widget.ids.length; i++) {
      if (widget.selectedIds.contains(widget.ids[i])) {
        selectedLabels.add(widget.labels[i]);
      }
    }
    return selectedLabels;
  }

  String get _title {
    final selectedLabels = _selectedLabels;
    if (widget.selectedIds.isEmpty) return widget.hint;
    if (widget.controlType == ExpansionSelectionControlType.radio) {
      return selectedLabels.isEmpty ? widget.hint : selectedLabels.first;
    }
    return widget.hint;
  }

  bool get _showSelectedChips => !_isExpanded && _selectedLabels.isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<Set<int>>(
      initialValue: widget.selectedIds,
      validator: widget.validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FieldLabel(text: widget.label, required: widget.required),
            const SizedBox(height: 8),
            Material(
              color: StaticColors.cF4F4F4,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: field.hasError
                    ? const BorderSide(color: StaticColors.cFF4E4E)
                    : BorderSide.none,
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: StaticColors.transparent,
                  splashColor: StaticColors.transparent,
                  highlightColor: StaticColors.transparent,
                ),
                child: ExpansionTile(
                  controller: _controller,
                  onExpansionChanged: (value) {
                    setState(() => _isExpanded = value);
                  },
                  tilePadding: const EdgeInsets.symmetric(horizontal: 18),
                  childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                  minTileHeight: 58,
                  iconColor: StaticColors.c9AA0A6,
                  collapsedIconColor: StaticColors.c9AA0A6,
                  title: _ExpansionSelectionTitle(
                    text: _title,
                    isHint: widget.selectedIds.isEmpty,
                    selectedLabels: _showSelectedChips
                        ? _selectedLabels
                        : const [],
                  ),
                  children: [
                    if (widget.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: LinearProgressIndicator(),
                      )
                    else if (widget.controlType ==
                        ExpansionSelectionControlType.radio)
                      RadioGroup<int>(
                        groupValue: widget.selectedIds.isEmpty
                            ? null
                            : widget.selectedIds.first,
                        onChanged: (value) {
                          if (value == null) return;
                          widget.onSelected(value, true);
                          field.didChange(<int>{value});
                          _controller.collapse();
                        },
                        child: Column(
                          children: [
                            for (int i = 0; i < widget.ids.length; i++)
                              _ExpansionSelectionTile(
                                id: widget.ids[i],
                                label: widget.labels[i],
                                selected: widget.selectedIds.contains(
                                  widget.ids[i],
                                ),
                                controlType: widget.controlType,
                              ),
                          ],
                        ),
                      )
                    else
                      for (int i = 0; i < widget.ids.length; i++)
                        _ExpansionSelectionTile(
                          id: widget.ids[i],
                          label: widget.labels[i],
                          selected: widget.selectedIds.contains(widget.ids[i]),
                          controlType: widget.controlType,
                          onSelected: (id, selected) {
                            widget.onSelected(id, selected);
                            field.didChange(_nextSelectedIds(id, selected));
                          },
                        ),
                  ],
                ),
              ),
            ),
            if (field.hasError) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  field.errorText!,
                  style: AppTextStyle.regular12(
                    context,
                    color: StaticColors.cFF4E4E,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Set<int> _nextSelectedIds(int id, bool selected) {
    if (widget.controlType == ExpansionSelectionControlType.radio) {
      return selected ? <int>{id} : <int>{};
    }
    final updated = {...widget.selectedIds};
    if (selected) {
      updated.add(id);
    } else {
      updated.remove(id);
    }
    return updated;
  }
}

class _ExpansionSelectionTitle extends StatelessWidget {
  const _ExpansionSelectionTitle({
    required this.text,
    required this.isHint,
    required this.selectedLabels,
  });

  final String text;
  final bool isHint;
  final List<String> selectedLabels;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.regular14(
            context,
            color: isHint ? StaticColors.cBDC1C6 : StaticColors.c4C4C4C,
          ),
        ),
        if (selectedLabels.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final label in selectedLabels)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: StaticColors.primary,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: StaticColors.primary),
                  ),
                  child: Text(
                    label,
                    style: AppTextStyle.regular12(
                      context,
                      color: StaticColors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ExpansionSelectionTile extends StatelessWidget {
  const _ExpansionSelectionTile({
    required this.id,
    required this.label,
    required this.selected,
    required this.controlType,
    this.onSelected,
  });

  final int id;
  final String label;
  final bool selected;
  final ExpansionSelectionControlType controlType;
  final void Function(int id, bool selected)? onSelected;

  @override
  Widget build(BuildContext context) {
    final title = Text(
      label,
      style: AppTextStyle.regular14(context, color: StaticColors.c4C4C4C),
    );

    if (controlType == ExpansionSelectionControlType.radio) {
      return RadioListTile<int>(
        value: id,
        title: title,
        selected: selected,
        activeColor: StaticColors.primary,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      );
    }

    return CheckboxListTile(
      value: selected,
      onChanged: (value) => onSelected?.call(id, value ?? false),
      title: title,
      activeColor: StaticColors.primary,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
