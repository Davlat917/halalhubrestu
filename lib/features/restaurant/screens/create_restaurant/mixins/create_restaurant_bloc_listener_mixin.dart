import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/widgets/feedback/global_feedback_dialog.dart';
import 'package:halalhub_restaurant/features/restaurant/bloc/restaurant_bloc.dart';

/// [RestaurantBloc] holatiga UI reaksiya (xabarlar) — forma holati [RestaurantActionMixin] da.
mixin CreateRestaurantBlocListenerMixin {
  void listenCreateRestaurant(BuildContext context, RestaurantState state) {
    if (state is RestaurantFailure) {
      showGlobalFailureFeedback(context, message: state.exception.message);
    }
    if (state is RestaurantUpdateSuccess) {
      showGlobalSuccessFeedback(
        context,
        title: TranslationKeys.createRestaurantUpdatedSuccessTitle.tr(
          context: context,
        ),
        message: TranslationKeys.createRestaurantUpdatedSuccessMessage.tr(
          context: context,
        ),
      );
    }
  }
}
