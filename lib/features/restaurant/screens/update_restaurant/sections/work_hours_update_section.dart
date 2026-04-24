import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/update_restaurant/bloc/update_restaurant_cubit.dart';

class WorkHoursUpdateSection extends StatelessWidget {
  const WorkHoursUpdateSection({super.key, required this.pickTime});

  final Future<TimeOfDay?> Function(BuildContext context, TimeOfDay initial)
  pickTime;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdateRestaurantCubit, UpdateRestaurantState>(
      buildWhen: (p, c) =>
          p.openDays != c.openDays ||
          p.startTimes != c.startTimes ||
          p.endTimes != c.endTimes,
      builder: (context, state) {
        final cubit = context.read<UpdateRestaurantCubit>();
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          decoration: BoxDecoration(
            color: StaticColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: StaticColors.cE2E2E2),
          ),
          child: Column(
            children: List.generate(UpdateRestaurantCubit.days.length, (i) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  border: i == UpdateRestaurantCubit.days.length - 1
                      ? null
                      : const Border(
                          bottom: BorderSide(color: StaticColors.cE2E2E2),
                        ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        UpdateRestaurantCubit.days[i],
                        style: AppTextStyle.medium14(
                          context,
                          color: StaticColors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        state.openDays[i]
                            ? TranslationKeys.updateOpen.tr(context: context)
                            : TranslationKeys.updateClosed.tr(context: context),
                        style: AppTextStyle.medium14(
                          context,
                          color: state.openDays[i]
                              ? StaticColors.primary
                              : StaticColors.c9AA0A6,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Row(
                        children: [
                          _timeMiniButton(
                            context: context,
                            label: state.startTimes[i].format(context),
                            onTap: state.openDays[i]
                                ? () async {
                                    final t = await pickTime(
                                      context,
                                      state.startTimes[i],
                                    );
                                    if (t != null) {
                                      cubit.setStartTime(i, t);
                                    }
                                  }
                                : null,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            TranslationKeys.updateTo.tr(context: context),
                            style: AppTextStyle.regular12(context),
                          ),
                          const SizedBox(width: 6),
                          _timeMiniButton(
                            context: context,
                            label: state.endTimes[i].format(context),
                            onTap: state.openDays[i]
                                ? () async {
                                    final t = await pickTime(
                                      context,
                                      state.endTimes[i],
                                    );
                                    if (t != null) {
                                      cubit.setEndTime(i, t);
                                    }
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 44,
                      child: Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: state.openDays[i],
                          onChanged: (v) => cubit.setOpenDay(i, v),
                          activeThumbColor: StaticColors.primary, //
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _timeMiniButton({
    required BuildContext context,
    required String label,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: SizedBox(
        height: 32,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            side: const BorderSide(color: StaticColors.cE2E2E2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(label, style: AppTextStyle.regular12(context)),
        ),
      ),
    );
  }
}
