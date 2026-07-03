import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/bloc/add_product_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/add_product/utils/add_product_input_parsers.dart';

enum _ModifierGroupPresentation { dialog, bottomSheet }

Future<void> showAddProductModifierGroupDialog({
  required BuildContext context,
  required List<AddProductModifierGroup> groups,
  required ValueChanged<AddProductModifierGroup> onAdd,
  required void Function(int index, AddProductModifierGroup group) onUpdate,
  required ValueChanged<int> onRemove,
  AddProductModifierGroup? suggestedGroup,
  List<AddProductModifierGroup> suggestedGroups = const [],
  int? editingIndex,
  String? dishName,
}) {
  final isMobile = ResponsiveSection.isMobileLayout(context);
  final child = _ModifierGroupDialog(
    presentation: isMobile
        ? _ModifierGroupPresentation.bottomSheet
        : _ModifierGroupPresentation.dialog,
    groups: groups,
    onAdd: onAdd,
    onUpdate: onUpdate,
    onRemove: onRemove,
    suggestedGroup: suggestedGroup,
    suggestedGroups: suggestedGroups,
    editingIndex: editingIndex,
    dishName: dishName,
  );

  if (isMobile) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: StaticColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => child,
    );
  }

  return showDialog<void>(
    context: context,
    builder: (_) => child,
  );
}

class _ModifierGroupDialog extends StatefulWidget {
  const _ModifierGroupDialog({
    required this.presentation,
    required this.groups,
    required this.onAdd,
    required this.onUpdate,
    required this.onRemove,
    this.suggestedGroup,
    this.suggestedGroups = const [],
    this.editingIndex,
    this.dishName,
  });

  final _ModifierGroupPresentation presentation;
  final List<AddProductModifierGroup> groups;
  final ValueChanged<AddProductModifierGroup> onAdd;
  final void Function(int index, AddProductModifierGroup group) onUpdate;
  final ValueChanged<int> onRemove;
  final AddProductModifierGroup? suggestedGroup;
  final List<AddProductModifierGroup> suggestedGroups;
  final int? editingIndex;
  final String? dishName;

  @override
  State<_ModifierGroupDialog> createState() => _ModifierGroupDialogState();
}

class _ModifierGroupDialogState extends State<_ModifierGroupDialog> {
  final _groupNameController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _itemPriceController = TextEditingController();
  final _minSelectController = TextEditingController();
  final _maxSelectController = TextEditingController();
  final List<AddProductModifierGroup> _groups = [];
  final List<AddProductModifierOption> _options = [];
  bool _isRequired = true;
  String _selectionType = 'single';
  int? _editingIndex;
  int? _editingOptionIndex;
  StateSetter? _formSetState;

  String get _dialogDishName {
    final name = widget.dishName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Spicy Chicken Wrap';
  }

  @override
  void initState() {
    super.initState();
    _groups.addAll(widget.groups);
    final suggestedGroup = widget.suggestedGroup;
    if (suggestedGroup != null) {
      final editingIndex = widget.editingIndex;
      if (editingIndex == null) {
        _addDraftGroupIfMissing(suggestedGroup);
      } else {
        _openForm(group: suggestedGroup, index: editingIndex);
      }
    }
    for (final group in widget.suggestedGroups) {
      _addDraftGroupIfMissing(group);
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _itemNameController.dispose();
    _itemPriceController.dispose();
    _minSelectController.dispose();
    _maxSelectController.dispose();
    super.dispose();
  }

  void _openForm({AddProductModifierGroup? group, int? index}) {
    _groupNameController.text = group?.name ?? '';
    final groupOptions = group?.options ?? const <AddProductModifierOption>[];
    if (groupOptions.isEmpty) {
      _itemNameController.clear();
      _itemPriceController.clear();
      _editingOptionIndex = null;
    } else {
      final firstOption = groupOptions.first;
      _itemNameController.text = firstOption.name;
      _itemPriceController.text = firstOption.price == 0
          ? '0'
          : firstOption.price.toStringAsFixed(2);
      _editingOptionIndex = 0;
    }
    _options
      ..clear()
      ..addAll(groupOptions);
    _isRequired = group?.isRequired ?? true;
    _selectionType = group?.selectionType ?? 'single';
    _minSelectController.text = group?.minSelect.toString() ?? '';
    _maxSelectController.text = group?.maxSelect.toString() ?? '';
    _editingIndex = index;
  }

  bool get _isBottomSheet =>
      widget.presentation == _ModifierGroupPresentation.bottomSheet;

  double _sheetHeight(BuildContext context) {
    return (MediaQuery.sizeOf(context).height * 0.92).clamp(520.0, 900.0);
  }

  Widget _wrapSheetContent(BuildContext context, Widget child) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SizedBox(
        height: _sheetHeight(context),
        child: child,
      ),
    );
  }

  Future<void> _showFormDialog({AddProductModifierGroup? group, int? index}) {
    _openForm(group: group, index: index);
    final isMobile = ResponsiveSection.isMobileLayout(context);

    Widget buildFormContent(BuildContext context, StateSetter dialogSetState) {
      _formSetState = dialogSetState;
      final formBody = Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: _buildFormScaffold(context),
      );

      if (isMobile) {
        return _wrapSheetContent(context, formBody);
      }

      final dialogHeight = (MediaQuery.sizeOf(context).height - 56)
          .clamp(560.0, 820.0)
          .toDouble();
      return Dialog(
        backgroundColor: StaticColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: SizedBox(height: dialogHeight, child: formBody),
        ),
      );
    }

    if (isMobile) {
      return showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: StaticColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        builder: (_) => StatefulBuilder(
          builder: (context, dialogSetState) =>
              buildFormContent(context, dialogSetState),
        ),
      ).whenComplete(() {
        _formSetState = null;
        if (mounted) setState(_resetForm);
      });
    }

    return showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, dialogSetState) =>
            buildFormContent(context, dialogSetState),
      ),
    ).whenComplete(() {
      _formSetState = null;
      if (mounted) setState(_resetForm);
    });
  }

  void _updateFormState(VoidCallback action) {
    final formSetState = _formSetState;
    if (formSetState == null) {
      setState(action);
      return;
    }
    formSetState(action);
  }

  void _addDraftGroupIfMissing(AddProductModifierGroup group) {
    final alreadyExists = _groups.any(
      (item) => item.name.toLowerCase() == group.name.toLowerCase(),
    );
    if (!alreadyExists) _groups.add(group);
  }

  void _addOption() {
    final name = _itemNameController.text.trim();
    final priceText = _itemPriceController.text.trim();
    final price = priceText.isEmpty ? 0.0 : parsePriceValue(priceText);
    if (name.isEmpty || price == null) return;
    _updateFormState(() {
      final option = AddProductModifierOption(name: name, price: price);
      final editingOptionIndex = _editingOptionIndex;
      if (editingOptionIndex != null &&
          editingOptionIndex >= 0 &&
          editingOptionIndex < _options.length) {
        _options[editingOptionIndex] = option;
      } else {
        _options.add(option);
      }
      _itemNameController.clear();
      _itemPriceController.clear();
      _editingOptionIndex = null;
    });
  }

  void _saveGroup() {
    final name = _groupNameController.text.trim();
    final options = _collectOptions();
    if (name.isEmpty || options.isEmpty) return;
    final selectionType = _selectionType;
    final isRequired = _isRequired;
    final minSelect =
        int.tryParse(_minSelectController.text.trim()) ?? (isRequired ? 1 : 0);
    final maxSelect =
        int.tryParse(_maxSelectController.text.trim()) ??
        (selectionType == 'single' ? 1 : options.length);
    final group = AddProductModifierGroup(
      name: name,
      selectionType: selectionType,
      isRequired: isRequired,
      minSelect: minSelect,
      maxSelect: maxSelect,
      options: List.unmodifiable(options),
    );
    setState(() {
      final editingIndex = _editingIndex;
      if (editingIndex == null) {
        _groups.add(group);
      } else {
        _groups[editingIndex] = group;
      }
      _resetForm();
    });
    Navigator.of(context).pop();
  }

  void _resetForm() {
    _groupNameController.clear();
    _itemNameController.clear();
    _itemPriceController.clear();
    _minSelectController.clear();
    _maxSelectController.clear();
    _options.clear();
    _isRequired = true;
    _selectionType = 'single';
    _editingIndex = null;
    _editingOptionIndex = null;
  }

  List<AddProductModifierOption> _collectOptions() {
    final options = [..._options];
    final name = _itemNameController.text.trim();
    final price = parsePriceValue(_itemPriceController.text);
    if (name.isNotEmpty && price != null) {
      final option = AddProductModifierOption(name: name, price: price);
      final editingOptionIndex = _editingOptionIndex;
      if (editingOptionIndex == null) {
        options.add(option);
      } else if (editingOptionIndex >= 0 &&
          editingOptionIndex < options.length) {
        options[editingOptionIndex] = option;
      }
    }
    return options;
  }

  void _editOptionAt(int index) {
    if (index < 0 || index >= _options.length) return;
    final option = _options[index];
    _updateFormState(() {
      _editingOptionIndex = index;
      _itemNameController.text = option.name;
      _itemPriceController.text = option.price == 0
          ? '0'
          : option.price.toStringAsFixed(2);
    });
  }

  void _removeOptionAt(int index) {
    if (index < 0 || index >= _options.length) return;
    _updateFormState(() {
      _options.removeAt(index);
      if (_editingOptionIndex == index) {
        _itemNameController.clear();
        _itemPriceController.clear();
        _editingOptionIndex = null;
      }
    });
  }

  void _removeGroup(int index) {
    setState(() {
      _groups.removeAt(index);
      if (_editingIndex == index) _resetForm();
    });
  }

  void _submitGroups() {
    for (var i = widget.groups.length - 1; i >= 0; i--) {
      widget.onRemove(i);
    }
    for (final group in _groups) {
      widget.onAdd(group);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final listContent = Padding(
      padding: const EdgeInsets.all(20),
      child: _buildList(context),
    );

    if (_isBottomSheet) {
      return _wrapSheetContent(context, listContent);
    }

    final maxHeight = (MediaQuery.sizeOf(context).height - 56).clamp(
      520.0,
      900.0,
    );
    return Dialog(
      backgroundColor: StaticColors.backgroundColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: maxHeight),
        child: listContent,
      ),
    );
  }

  Widget _buildFormScaffold(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _editingIndex == null
                    ? 'Add new group option'
                    : 'Edit group option',
                style: AppTextStyle.medium20(context),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Expanded(child: SingleChildScrollView(child: _buildForm(context))),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Dish name: $_dialogDishName',
          style: AppTextStyle.medium20(context),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: StaticColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: StaticColors.cE2E2E2),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < _groups.length; i++) ...[
                    _ModifierGroupTile(
                      group: _groups[i],
                      onEdit: () =>
                          _showFormDialog(group: _groups[i], index: i),
                      onDelete: () => _removeGroup(i),
                    ),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton.icon(
                    onPressed: _showFormDialog,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      foregroundColor: StaticColors.black,
                      side: const BorderSide(color: StaticColors.cE2E2E2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: AppTextStyle.medium16(context),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add new option groups'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                label: 'Back',
                height: 50,
                width: double.infinity,
                backgroundColor: StaticColors.cDADADA,
                foregroundColor: StaticColors.black,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CustomButton(
                label: 'Submit',
                height: 50,
                width: double.infinity,
                onPressed: _submitGroups,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommonTextField(
          controller: _groupNameController,
          hint: 'Group name',
          textSize: 16,
          radius: 14,
          enabledBorderColor: StaticColors.primary,
          focusedBorderColor: StaticColors.primary,
          background: StaticColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 18,
          runSpacing: 10,
          children: [
            _ChoiceDot(
              label: 'Required',
              selected: _isRequired,
              onTap: () => _updateFormState(() => _isRequired = true),
            ),
            _ChoiceDot(
              label: 'Optional',
              selected: !_isRequired,
              onTap: () => _updateFormState(() => _isRequired = false),
            ),
            _ChoiceDot(
              label: 'Single Select',
              selected: _selectionType == 'single',
              onTap: () => _updateFormState(() => _selectionType = 'single'),
            ),
            _ChoiceDot(
              label: 'Multi Select',
              selected: _selectionType == 'multi',
              onTap: () => _updateFormState(() => _selectionType = 'multi'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RequiredFieldLabel(text: 'Item name'),
                  const SizedBox(height: 10),
                  CommonTextField(
                    controller: _itemNameController,
                    hint: 'Item name',
                    textSize: 16,
                    radius: 14,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RequiredFieldLabel(text: 'Item price'),
                  const SizedBox(height: 10),
                  CommonTextField(
                    controller: _itemPriceController,
                    hint: 'e.x. 14 \$',
                    textSize: 16,
                    radius: 14,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldTitleLabel(text: 'Min'),
                  const SizedBox(height: 10),
                  CommonTextField(
                    controller: _minSelectController,
                    hint: 'Min',
                    textSize: 16,
                    radius: 14,
                    keyboardType: TextInputType.number,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldTitleLabel(text: 'Max'),
                  const SizedBox(height: 10),
                  CommonTextField(
                    controller: _maxSelectController,
                    hint: 'Max',
                    textSize: 16,
                    radius: 14,
                    keyboardType: TextInputType.number,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        CustomButton(
          label: 'Add new item',
          onPressed: _addOption,
          height: 50,
          width: double.infinity,
          borderRadius: 12,
          textStyle: AppTextStyle.regular16(context, color: StaticColors.white),
        ),
        if (_options.isNotEmpty) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Added items', style: AppTextStyle.medium14(context)),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _options.length; i++)
            _ModifierOptionTile(
              option: _options[i],
              selected: _editingOptionIndex == i,
              onEdit: () => _editOptionAt(i),
              onDelete: () => _removeOptionAt(i),
            ),
        ],
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                label: 'Cancel',
                height: 50,
                width: double.infinity,
                borderRadius: 12,
                backgroundColor: StaticColors.cDADADA,
                foregroundColor: StaticColors.black,
                textStyle: AppTextStyle.regular16(
                  context,
                  color: StaticColors.black,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CustomButton(
                label: _editingIndex == null ? 'Add' : 'Save',
                height: 50,
                width: double.infinity,
                borderRadius: 12,
                textStyle: AppTextStyle.regular16(
                  context,
                  color: StaticColors.white,
                ),
                onPressed: _saveGroup,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RequiredFieldLabel extends StatelessWidget {
  const _RequiredFieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: AppTextStyle.regular16(context, color: StaticColors.c4C4C4C),
        children: [
          TextSpan(
            text: ' *',
            style: AppTextStyle.regular16(context, color: StaticColors.cFF4E4E),
          ),
        ],
      ),
    );
  }
}

class _FieldTitleLabel extends StatelessWidget {
  const _FieldTitleLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyle.regular16(context, color: StaticColors.c4C4C4C),
    );
  }
}

class _ModifierOptionTile extends StatelessWidget {
  const _ModifierOptionTile({
    required this.option,
    required this.selected,
    required this.onEdit,
    required this.onDelete,
  });

  final AddProductModifierOption option;
  final bool selected;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? StaticColors.cEAF8EF : StaticColors.cF8F8F8,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? StaticColors.primary : StaticColors.cE2E2E2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${option.name}  \$${option.price.toStringAsFixed(2)}',
              style: AppTextStyle.regular14(context),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_rounded,
              color: StaticColors.primary,
              size: 18,
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: StaticColors.cFF4E4E,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModifierGroupTile extends StatelessWidget {
  const _ModifierGroupTile({
    required this.group,
    required this.onEdit,
    required this.onDelete,
  });

  final AddProductModifierGroup group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final type = group.selectionType == 'single'
        ? 'Single Select'
        : 'Multi Select';
    final requiredText = group.isRequired ? 'Required' : 'Optional';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(group.name, style: AppTextStyle.medium16(context)),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_rounded,
                  color: StaticColors.primary,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: StaticColors.cFF4E4E,
                  size: 20,
                ),
              ),
            ],
          ),
          Text(
            '$requiredText • $type',
            style: AppTextStyle.regular14(context, color: StaticColors.c666666),
          ),
          const SizedBox(height: 12),
          Text(
            '( ${group.options.map((e) => e.name).join(', ')} )',
            style: AppTextStyle.regular14(context),
          ),
        ],
      ),
    );
  }
}

class _ChoiceDot extends StatelessWidget {
  const _ChoiceDot({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyle.regular16(context)),
          const SizedBox(width: 8),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? StaticColors.primary : StaticColors.cBDC1C6,
                width: selected ? 5 : 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
