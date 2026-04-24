import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_media_clip/vendor_media_clip_model.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VendorClipCard extends StatefulWidget {
  const VendorClipCard({
    super.key,
    required this.clip,
    required this.onPlay,
    required this.onEdit,
  });

  final VendorMediaClipModel clip;
  final VoidCallback onPlay;
  final VoidCallback onEdit;

  @override
  State<VendorClipCard> createState() => _VendorClipCardState();
}

class _VendorClipCardState extends State<VendorClipCard> {
  late final Future<Uint8List?> _thumbFuture;

  @override
  void initState() {
    super.initState();
    _thumbFuture = VideoThumbnail.thumbnailData(
      video: widget.clip.video,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 600,
      quality: 70,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: StaticColors.cF4F4F4,
        child: InkWell(
          onTap: widget.onPlay,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FutureBuilder<Uint8List?>(
                future: _thumbFuture,
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  if (data != null && data.isNotEmpty) {
                    return Image.memory(data, fit: BoxFit.cover);
                  }
                  return const ColoredBox(
                    color: StaticColors.cF4F4F4,
                    child: Icon(
                      Icons.videocam_outlined,
                      color: StaticColors.c9AA0A6,
                      size: 40,
                    ),
                  );
                },
              ),
              Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: StaticColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: StaticColors.white,
                    size: 36,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: StaticColors.white,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: widget.onEdit,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Assets.icons.edit.svg(
                        width: 18,
                        height: 18,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Text(
                  widget.clip.description.isEmpty ? '—' : widget.clip.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.regular12(
                    context,
                    color: StaticColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
