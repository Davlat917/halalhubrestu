import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

class CertificateFileTile extends StatelessWidget {
  const CertificateFileTile({
    super.key,
    required this.availableWidth,
    required this.fileName,
    required this.onDelete,
  });

  final double availableWidth;
  final String fileName;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: context.wOf(8, availableWidth)),
      padding: EdgeInsets.symmetric(
        horizontal: context.wOf(12, availableWidth),
        vertical: context.wOf(10, availableWidth),
      ),
      decoration: BoxDecoration(
        color: StaticColors.cEAF8EF,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: StaticColors.primary),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              fileName,
              style: AppTextStyle.regular14(context, aW: availableWidth),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              color: StaticColors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
