import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';

mixin VendorAgreementFeedbackMixin<T extends StatefulWidget> on State<T> {
  void showAgreementMessage(String message) {
    getIt<Display>().success(message);
  }
}
