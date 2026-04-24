import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/update_restaurant/bloc/update_restaurant_cubit.dart';

class CategoryUpdateSection extends StatelessWidget {
  const CategoryUpdateSection({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return BlocBuilder<UpdateRestaurantCubit, UpdateRestaurantState>(
      buildWhen: (p, c) =>
          p.categories != c.categories ||
          p.selectedCategoryIds != c.selectedCategoryIds,
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(context.wOf(12, w)),
          decoration: BoxDecoration(
            color: StaticColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: StaticColors.cE2E2E2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TranslationKeys.updateAddCategory.tr(context: context),
                style: AppTextStyle.semibold16(
                  context,
                  color: StaticColors.black,
                ),
              ),
              const Divider(height: 20),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: state.categories.map((item) {
                  final selected = state.selectedCategoryIds.contains(item.id);
                  return InkWell(
                    onTap: () => context
                        .read<UpdateRestaurantCubit>()
                        .toggleCategory(item.id),
                    borderRadius: BorderRadius.circular(999),
                    child: IntrinsicWidth(
                      child: Container(
                        height: 30,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? StaticColors.primary
                              : StaticColors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: selected
                                ? StaticColors.primary
                                : StaticColors.cE2E2E2,
                          ),
                        ),
                        child: Text(
                          item.name,
                          maxLines: 1,
                          softWrap: false,
                          style: AppTextStyle.medium12(
                            context,
                            aW: w,
                            color: selected
                                ? StaticColors.white
                                : StaticColors.c666666, //
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
