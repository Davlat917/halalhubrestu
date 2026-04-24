import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/update_restaurant/bloc/update_restaurant_cubit.dart';

class UpdateRestaurantTabBar extends StatelessWidget {
  const UpdateRestaurantTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isSmallMobile = w < 430;
    return BlocBuilder<UpdateRestaurantCubit, UpdateRestaurantState>(
      buildWhen: (previous, current) => previous.tab != current.tab,
      builder: (context, state) {
        Widget tab(UpdateRestaurantTab tab, String label) {
          final active = state.tab == tab;
          return Padding(
            padding: EdgeInsets.only(right: isSmallMobile ? 16 : 22),
            child: InkWell(
              onTap: () => context.read<UpdateRestaurantCubit>().changeTab(tab),
              child: IntrinsicWidth(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallMobile ? 8 : context.wOf(10, w),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.medium14(
                          context,
                          color: active
                              ? StaticColors.primary
                              : StaticColors.c9AA0A6,
                          aW: w,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 3,
                        width: double.infinity,
                        color: active
                            ? StaticColors.primary
                            : StaticColors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: isSmallMobile ? 8 : 20),
          color: StaticColors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: EdgeInsets.only(left: isSmallMobile ? 6 : 10),
              child: Row(
              children: [
                tab(
                  UpdateRestaurantTab.basic,
                  TranslationKeys.updateRestaurantTabBasic.tr(context: context),
                ),
                tab(
                  UpdateRestaurantTab.documents,
                  TranslationKeys.updateRestaurantTabDocuments.tr(
                    context: context,
                  ),
                ),
                tab(
                  UpdateRestaurantTab.location,
                  TranslationKeys.updateRestaurantTabLocation.tr(
                    context: context,
                  ),
                ),
                tab(
                  UpdateRestaurantTab.workHours,
                  TranslationKeys.updateRestaurantTabWorkHours.tr(
                    context: context,
                  ),
                ),
              ],
              ),
            ),
          ),
        );
      },
    );
  }
}
