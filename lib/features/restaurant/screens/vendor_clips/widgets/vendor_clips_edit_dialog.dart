import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_media_clip/vendor_media_clip_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';

class VendorClipsEditDialog extends StatefulWidget {
  const VendorClipsEditDialog({
    super.key,
    required this.repo,
    required this.clip,
  });

  final RestaurantRepo repo;
  final VendorMediaClipModel clip;

  @override
  State<VendorClipsEditDialog> createState() => _VendorClipsEditDialogState();
}

class _VendorClipsEditDialogState extends State<VendorClipsEditDialog> {
  late final TextEditingController _descController;
  final ValueNotifier<bool> _savingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.clip.description);
  }

  @override
  void dispose() {
    _descController.dispose();
    _savingNotifier.dispose();
    _errorNotifier.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = _descController.text.trim();
    if (value.isEmpty) {
      _errorNotifier.value = TranslationKeys.clipsDescriptionRequired.tr(
        context: context,
      );
      return;
    }
    _savingNotifier.value = true;
    _errorNotifier.value = null;
    try {
      await widget.repo.updateVendorMediaDescription(
        mediaId: widget.clip.id,
        description: value,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _errorNotifier.value = e.toString();
    } finally {
      _savingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final dialogW = media.width < 560 ? media.width - 24 : 520.0;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: dialogW,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: _savingNotifier,
                    builder: (context, saving, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              TranslationKeys.clipsEditVideo.tr(
                                context: context,
                              ),
                              style: AppTextStyle.medium18(
                                context,
                                color: StaticColors.black,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: saving
                                ? null
                                : () => Navigator.of(context).pop(false),
                            icon: const Icon(
                              Icons.close,
                              color: StaticColors.primary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    TranslationKeys.clipsDescription.tr(context: context),
                    style: AppTextStyle.regular14(
                      context,
                      color: StaticColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<bool>(
                    valueListenable: _savingNotifier,
                    builder: (context, saving, _) {
                      return CommonTextField(
                        controller: _descController,
                        enabled: !saving,
                        maxLines: 3,
                        minLines: 3,
                        hint: TranslationKeys.clipsDescribeFood.tr(
                          context: context,
                        ),
                        textSize: 14,
                        textFontWeight: FontWeight.w400,
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        availableWidth: dialogW,
                      );
                    },
                  ),
                  ValueListenableBuilder<String?>(
                    valueListenable: _errorNotifier,
                    builder: (context, error, _) {
                      if (error == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<bool>(
                    valueListenable: _savingNotifier,
                    builder: (context, saving, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              label: TranslationKeys.cancel.tr(
                                context: context,
                              ),
                              onPressed: saving
                                  ? null
                                  : () => Navigator.of(context).pop(false),
                              backgroundColor: const Color(0xFFDEF3E6),
                              foregroundColor: StaticColors.primary,
                              height: 48,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              label: TranslationKeys.save.tr(context: context),
                              onPressed: saving ? null : _submit,
                              backgroundColor: StaticColors.primary,
                              foregroundColor: StaticColors.white,
                              isLoading: saving,
                              height: 48,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
