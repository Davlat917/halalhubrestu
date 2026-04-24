import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_clips/widgets/vendor_clips_upload_drop_area.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VendorClipsUploadDialog extends StatefulWidget {
  const VendorClipsUploadDialog({super.key, required this.repo});

  final RestaurantRepo repo;

  @override
  State<VendorClipsUploadDialog> createState() =>
      _VendorClipsUploadDialogState();
}

class _VendorClipsUploadDialogState extends State<VendorClipsUploadDialog> {
  final TextEditingController _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final ValueNotifier<XFile?> _videoNotifier = ValueNotifier<XFile?>(null);
  final ValueNotifier<Uint8List?> _thumbNotifier = ValueNotifier<Uint8List?>(
    null,
  );
  final ValueNotifier<bool> _uploadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorNotifier = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _descController.dispose();
    _videoNotifier.dispose();
    _thumbNotifier.dispose();
    _uploadingNotifier.dispose();
    _errorNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (!mounted || picked == null) return;

    final bytes = await File(picked.path).length();
    const maxBytes = 20 * 1024 * 1024;
    if (bytes > maxBytes) {
      _errorNotifier.value = TranslationKeys.clipsUploadHint.tr();
      return;
    }

    final thumb = await VideoThumbnail.thumbnailData(
      video: picked.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 700,
      quality: 75,
    );

    _videoNotifier.value = picked;
    _thumbNotifier.value = thumb;
    _errorNotifier.value = null;
  }

  void _clearSelectedVideo() {
    _videoNotifier.value = null;
    _thumbNotifier.value = null;
  }

  Future<void> _submit() async {
    final currentVideo = _videoNotifier.value;
    final description = _descController.text.trim();
    if (currentVideo == null) {
      _errorNotifier.value = TranslationKeys.clipsSelectVideo.tr(
        context: context,
      );
      return;
    }
    if (description.isEmpty) {
      _errorNotifier.value = TranslationKeys.clipsDescriptionRequired.tr(
        context: context,
      );
      return;
    }
    _uploadingNotifier.value = true;
    _errorNotifier.value = null;

    try {
      await widget.repo.uploadVendorMedia(
        videoFile: currentVideo,
        description: description,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _errorNotifier.value = e.toString();
    } finally {
      _uploadingNotifier.value = false;
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
                    valueListenable: _uploadingNotifier,
                    builder: (context, uploading, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              TranslationKeys.clipsUploadVideo.tr(
                                context: context,
                              ),
                              style: AppTextStyle.medium18(
                                context,
                                color: StaticColors.black,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: uploading
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
                  ValueListenableBuilder<Uint8List?>(
                    valueListenable: _thumbNotifier,
                    builder: (context, thumb, _) {
                      return ValueListenableBuilder<XFile?>(
                        valueListenable: _videoNotifier,
                        builder: (context, file, _) {
                          return ValueListenableBuilder<bool>(
                            valueListenable: _uploadingNotifier,
                            builder: (context, uploading, _) {
                              return VendorClipsUploadDropArea(
                                thumbBytes: thumb,
                                fileName: file?.name,
                                onBrowseTap: uploading ? null : _pickVideo,
                                onDeleteTap: uploading
                                    ? null
                                    : _clearSelectedVideo,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  Text(
                    TranslationKeys.clipsDescription.tr(context: context),
                    style: AppTextStyle.regular14(
                      context,
                      color: StaticColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<bool>(
                    valueListenable: _uploadingNotifier,
                    builder: (context, uploading, _) {
                      return CommonTextField(
                        controller: _descController,
                        enabled: !uploading,
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
                    valueListenable: _uploadingNotifier,
                    builder: (context, uploading, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              label: TranslationKeys.cancel.tr(
                                context: context,
                              ),
                              onPressed: uploading
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
                              label: TranslationKeys.upload.tr(
                                context: context,
                              ),
                              onPressed: uploading ? null : _submit,
                              backgroundColor: StaticColors.primary,
                              foregroundColor: StaticColors.white,
                              isLoading: uploading,
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
