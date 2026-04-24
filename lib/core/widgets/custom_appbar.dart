import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/circle_btn_widget.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_appbar.dart';
import 'package:flutter/material.dart';

// Const — har build'da yangi Color yaratilmaydi
const _kShadowColor = Color(0x28000000); // Colors.black.withAlpha(40)

class CustomAppbar extends ResponsiveAppBar {
  const CustomAppbar({super.key, super.bottom, super.toolbarHeight, this.actions, this.title, this.textColor, this.color, this.onpress, this.isLeading = false, this.elevation});

  final Color? textColor;
  final Color? color;
  final String? title;
  final List<Widget>? actions;
  final VoidCallback? onpress;
  final bool isLeading;
  final double? elevation;

  AppBar _buildAppBar(BuildContext context, {required double titleSize, required double leadingPadding, required double buttonSize}) {
    // TextStyle bir marta hisoblanadi
    final titleStyle = AppTextStyle.semibold20(context);

    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: color ?? StaticColors.backgroundColor,
      elevation: elevation ?? 10,
      shadowColor: _kShadowColor, // const
      toolbarHeight: toolbarHeight,
      scrolledUnderElevation: 10,
      automaticallyImplyLeading: isLeading,
      centerTitle: true,
      leadingWidth: isLeading ? null : leadingPadding + buttonSize + 8,
      leading: isLeading
          ? null
          : Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: leadingPadding),
                child: CircleBtnWidget(onPress: onpress),
              ),
            ),
      title: Text(title ?? '', style: titleStyle),
      bottom: bottom,
      actions: actions,
    );
  }

  @override
  PreferredSizeWidget buildMobile(BuildContext context) => _buildAppBar(context, titleSize: context.text16, leadingPadding: context.size16, buttonSize: context.size35);

  @override
  PreferredSizeWidget buildTablet(BuildContext context) => _buildAppBar(context, titleSize: context.text18, leadingPadding: context.size24, buttonSize: context.size48);
}
