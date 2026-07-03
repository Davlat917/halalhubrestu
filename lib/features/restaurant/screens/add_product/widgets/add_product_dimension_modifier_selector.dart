import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/bloc/add_product_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/widgets/add_product_details_parts.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/widgets/add_product_modifier_group_dialog.dart';

class AddProductDimensionModifierSelector extends StatelessWidget {
  const AddProductDimensionModifierSelector({
    super.key,
    required this.groups,
    required this.onAddModifierGroup,
    required this.onUpdateModifierGroup,
    required this.onRemoveModifierGroup,
    this.dishName,
  });

  final List<AddProductModifierGroup> groups;
  final ValueChanged<AddProductModifierGroup> onAddModifierGroup;
  final void Function(int index, AddProductModifierGroup group)
  onUpdateModifierGroup;
  final ValueChanged<int> onRemoveModifierGroup;
  final String? dishName;

  static final List<_DimensionTemplate> _templates = [
    _DimensionTemplate(
      title: 'Inches',
      group: AddProductModifierGroup(
        name: 'Size & Measurement',
        selectionType: 'single',
        isRequired: true,
        minSelect: 1,
        maxSelect: 1,
        options: [
          AddProductModifierOption(name: 'Regular', price: 0),
          AddProductModifierOption(name: 'Large', price: 0),
        ],
      ),
    ),
    _DimensionTemplate(
      title: 'Weight/Ounces/Pounds',
      group: AddProductModifierGroup(
        name: 'Weight',
        selectionType: 'single',
        isRequired: true,
        minSelect: 1,
        maxSelect: 1,
        options: [
          AddProductModifierOption(name: '4 oz', price: 0),
          AddProductModifierOption(name: '8 oz', price: 0),
          AddProductModifierOption(name: '1 lb', price: 0),
        ],
      ),
    ),
    _DimensionTemplate(
      title: 'Volume/Fluid Ounces',
      group: AddProductModifierGroup(
        name: 'Volume',
        selectionType: 'single',
        isRequired: true,
        minSelect: 1,
        maxSelect: 1,
        options: [
          AddProductModifierOption(name: '8 fl oz', price: 0),
          AddProductModifierOption(name: '12 fl oz', price: 0),
          AddProductModifierOption(name: '16 fl oz', price: 0),
        ],
      ),
    ),
    _DimensionTemplate(
      title: 'Count/Pieces',
      group: AddProductModifierGroup(
        name: 'Count',
        selectionType: 'single',
        isRequired: true,
        minSelect: 1,
        maxSelect: 1,
        options: [
          AddProductModifierOption(name: '1 piece', price: 0),
          AddProductModifierOption(name: '6 pieces', price: 0),
          AddProductModifierOption(name: '12 pieces', price: 0),
        ],
      ),
    ),
    _DimensionTemplate(
      title: 'Abstract',
      group: AddProductModifierGroup(
        name: 'Size & Measurement',
        selectionType: 'single',
        isRequired: true,
        minSelect: 1,
        maxSelect: 1,
        options: [
          AddProductModifierOption(name: 'Regular', price: 0),
          AddProductModifierOption(name: 'Large', price: 0),
        ],
      ),
    ),
  ];

  static final List<AddProductModifierGroup> _commonExampleGroups = [
    AddProductModifierGroup(
      name: 'Sauces Inside',
      selectionType: 'multi',
      isRequired: false,
      minSelect: 0,
      maxSelect: 3,
      options: [
        AddProductModifierOption(name: 'Tzatziki', price: 0),
        AddProductModifierOption(name: 'Garlic Mayo', price: 0),
        AddProductModifierOption(name: 'Hot Sauce', price: 0),
      ],
    ),
    AddProductModifierGroup(
      name: 'Exclusions (Remove)',
      selectionType: 'multi',
      isRequired: false,
      minSelect: 0,
      maxSelect: 2,
      options: [
        AddProductModifierOption(name: 'No Onions', price: 0),
        AddProductModifierOption(name: 'No Tomatoes', price: 0),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedLabels = groups.map((group) => group.name).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FieldLabel(text: 'Dimension food', required: true),
        const SizedBox(height: 8),
        Material(
          color: StaticColors.cF4F4F4,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: StaticColors.transparent,
              splashColor: StaticColors.transparent,
              highlightColor: StaticColors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 18),
              childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              minTileHeight: 58,
              iconColor: StaticColors.c9AA0A6,
              collapsedIconColor: StaticColors.c9AA0A6,
              title: _DimensionSelectorTitle(
                text: groups.isEmpty
                    ? 'Select food measurement'
                    : 'Selected option groups',
                isHint: groups.isEmpty,
                selectedLabels: selectedLabels,
              ),
              children: [
                for (final template in _templates)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      template.title,
                      style: AppTextStyle.regular16(context),
                    ),
                    onTap: () => showAddProductModifierGroupDialog(
                      context: context,
                      groups: groups,
                      suggestedGroups: [
                        template.group,
                        ..._commonExampleGroups,
                      ],
                      dishName: dishName,
                      onAdd: onAddModifierGroup,
                      onUpdate: onUpdateModifierGroup,
                      onRemove: onRemoveModifierGroup,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DimensionTemplate {
  const _DimensionTemplate({required this.title, required this.group});

  final String title;
  final AddProductModifierGroup group;
}

class _DimensionSelectorTitle extends StatelessWidget {
  const _DimensionSelectorTitle({
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
