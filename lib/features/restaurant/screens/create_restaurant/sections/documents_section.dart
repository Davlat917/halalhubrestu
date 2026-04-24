import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/widgets/certificate_file_tile.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/widgets/restaurant_common_widgets.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/widgets/upload_pick_tile.dart';
import 'package:image_picker/image_picker.dart';

class DocumentsSection extends StatelessWidget {
  const DocumentsSection({
    super.key,
    required this.availableWidth,
    required this.hasCertificate,
    required this.certificates,
    required this.toggleHasCertificate,
    required this.pickCertificates,
    required this.removeCertificateAt,
    required this.continueButton,
  });

  final double availableWidth;
  final bool hasCertificate;
  final List<XFile> certificates;
  final ValueChanged<bool> toggleHasCertificate;
  final VoidCallback pickCertificates;
  final ValueChanged<int> removeCertificateAt;
  final Widget continueButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationKeys.createRestaurantHasCertificateQuestion.tr(
            context: context,
          ),
          style: AppTextStyle.semibold18(context, aW: availableWidth),
        ),
        SizedBox(height: context.wOf(8, availableWidth)),
        RestaurantChoiceTile(
          availableWidth: availableWidth,
          selected: !hasCertificate,
          text: TranslationKeys.createRestaurantNoCertificate.tr(
            context: context,
          ),
          onTap: () => toggleHasCertificate(false),
        ),
        RestaurantChoiceTile(
          availableWidth: availableWidth,
          selected: hasCertificate,
          text: TranslationKeys.createRestaurantYesCertificate.tr(
            context: context,
          ),
          onTap: () => toggleHasCertificate(true),
        ),
        SizedBox(height: context.wOf(8, availableWidth)),
        UploadPickTile(
          availableWidth: availableWidth,
          title: TranslationKeys.createRestaurantUploadCertificate.tr(
            context: context,
          ),
          subtitle: TranslationKeys.createRestaurantCertificateTypes.tr(
            context: context,
          ),
          buttonLabel: TranslationKeys.browseFile.tr(context: context),
          onPressed: pickCertificates,
          height: context.wOf(130, availableWidth),
        ),
        SizedBox(height: context.wOf(12, availableWidth)),
        ...certificates.asMap().entries.map(
          (e) => CertificateFileTile(
            availableWidth: availableWidth,
            fileName: e.value.name,
            onDelete: () => removeCertificateAt(e.key),
          ),
        ),
        continueButton,
      ],
    );
  }
}
