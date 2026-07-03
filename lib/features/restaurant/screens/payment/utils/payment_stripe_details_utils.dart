import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_stripe_check/vendor_stripe_check_model.dart';

/// Backend `details` ko‘pincha o‘zbekcha string yoki `false` bo‘lib keladi.
abstract final class PaymentStripeDetailsUtils {
  static const String _onboardingNotFoundUz =
      'Stripe account ID topilmadi. Onboarding jarayonini boshlang.';

  static const String onboardingNotFoundEn =
      'Stripe account ID not found. Please start the onboarding process.';

  static const String notConnectedDefaultEn =
      'Stripe account is not connected. Please complete onboarding.';

  static const String connectedReadyEn =
      'Your Stripe account is connected and ready to receive payouts.';

  static const String connectedIncompleteIntroEn =
      'Your Stripe account is connected, but payouts are not enabled yet. '
      'Please complete the following requirements in Stripe:';

  static String englishDetails(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return notConnectedDefaultEn;
    if (text == _onboardingNotFoundUz ||
        text.contains('Stripe account ID topilmadi') ||
        text.contains('Onboarding jarayonini boshlang')) {
      return onboardingNotFoundEn;
    }
    return notConnectedDefaultEn;
  }

  static String buildConnectedMessage(VendorStripeCheckModel check) {
    if (check.isFullyReady) return connectedReadyEn;
    if (check.requirements.isEmpty) {
      return connectedIncompleteIntroEn;
    }
    final items = check.requirements
        .map(humanizeRequirement)
        .map((label) => '• $label')
        .join('\n');
    return '$connectedIncompleteIntroEn\n$items';
  }

  static String humanizeRequirement(String key) {
    const labels = <String, String>{
      'business_type': 'Business type',
      'external_account': 'Bank account',
      'representative.dob.day': 'Representative date of birth (day)',
      'representative.dob.month': 'Representative date of birth (month)',
      'representative.dob.year': 'Representative date of birth (year)',
      'representative.email': 'Representative email',
      'representative.first_name': 'Representative first name',
      'representative.last_name': 'Representative last name',
      'tos_acceptance.date': 'Terms of service acceptance date',
      'tos_acceptance.ip': 'Terms of service acceptance IP',
    };
    return labels[key] ?? key.replaceAll('.', ' ').replaceAll('_', ' ');
  }
}
