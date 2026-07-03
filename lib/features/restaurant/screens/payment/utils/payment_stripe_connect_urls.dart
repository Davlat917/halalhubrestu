import 'package:halalhub_restaurant/core/constants/constants.dart';

abstract final class PaymentStripeConnectUrls {
  static String get returnUrl =>
      '${Constants.baseUrl}/stripe/connect/return?status=success';

  static String get refreshUrl =>
      '${Constants.baseUrl}/stripe/connect/return?status=reauth';
}
