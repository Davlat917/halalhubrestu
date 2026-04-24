import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/network_image_chache.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_me/vendor_me_model.dart';
import 'package:halalhub_restaurant/features/restaurant/utils/vendor_profile_formatting.dart';

class VendorProfileAvatar extends StatelessWidget {
  const VendorProfileAvatar({
    super.key,
    required this.vendor,
    required this.radius,
  });

  final VendorMeModel? vendor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = vendor == null
        ? null
        : effectiveImageUrl(vendor!.logoUrl, vendor!.logo);
    final d = radius * 2;
    return CircleAvatar(
      radius: radius,
      backgroundColor: StaticColors.cF0F0F0,
      child: ClipOval(
        child: url == null
            ? Icon(
                Icons.person_rounded,
                size: radius,
                color: StaticColors.c666666,
              )
            : NetworkImageCache(
                imgUrl: url,
                widthW: d,
                heightH: d,
                radius: 0,
                fit: BoxFit.cover, //
              ),
      ),
    );
  }
}
