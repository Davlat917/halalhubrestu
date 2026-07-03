// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AccountSettingsPage]
class AccountSettingsRoute extends PageRouteInfo<void> {
  const AccountSettingsRoute({List<PageRouteInfo>? children})
    : super(AccountSettingsRoute.name, initialChildren: children);

  static const String name = 'AccountSettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AccountSettingsPage();
    },
  );
}

/// generated route for
/// [AppStartPage]
class AppStartRoute extends PageRouteInfo<void> {
  const AppStartRoute({List<PageRouteInfo>? children})
    : super(AppStartRoute.name, initialChildren: children);

  static const String name = 'AppStartRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AppStartPage();
    },
  );
}

/// generated route for
/// [AuthFlowPage]
class AuthFlowRoute extends PageRouteInfo<void> {
  const AuthFlowRoute({List<PageRouteInfo>? children})
    : super(AuthFlowRoute.name, initialChildren: children);

  static const String name = 'AuthFlowRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AuthFlowPage();
    },
  );
}

/// generated route for
/// [ChangePasswordConfirmPage]
class ChangePasswordConfirmRoute
    extends PageRouteInfo<ChangePasswordConfirmRouteArgs> {
  ChangePasswordConfirmRoute({
    Key? key,
    required String resetToken,
    List<PageRouteInfo>? children,
  }) : super(
         ChangePasswordConfirmRoute.name,
         args: ChangePasswordConfirmRouteArgs(key: key, resetToken: resetToken),
         initialChildren: children,
       );

  static const String name = 'ChangePasswordConfirmRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChangePasswordConfirmRouteArgs>();
      return ChangePasswordConfirmPage(
        key: args.key,
        resetToken: args.resetToken,
      );
    },
  );
}

class ChangePasswordConfirmRouteArgs {
  const ChangePasswordConfirmRouteArgs({this.key, required this.resetToken});

  final Key? key;

  final String resetToken;

  @override
  String toString() {
    return 'ChangePasswordConfirmRouteArgs{key: $key, resetToken: $resetToken}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChangePasswordConfirmRouteArgs) return false;
    return key == other.key && resetToken == other.resetToken;
  }

  @override
  int get hashCode => key.hashCode ^ resetToken.hashCode;
}

/// generated route for
/// [ChangePasswordOtpPage]
class ChangePasswordOtpRoute extends PageRouteInfo<ChangePasswordOtpRouteArgs> {
  ChangePasswordOtpRoute({
    Key? key,
    required String email,
    List<PageRouteInfo>? children,
  }) : super(
         ChangePasswordOtpRoute.name,
         args: ChangePasswordOtpRouteArgs(key: key, email: email),
         initialChildren: children,
       );

  static const String name = 'ChangePasswordOtpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChangePasswordOtpRouteArgs>();
      return ChangePasswordOtpPage(key: args.key, email: args.email);
    },
  );
}

class ChangePasswordOtpRouteArgs {
  const ChangePasswordOtpRouteArgs({this.key, required this.email});

  final Key? key;

  final String email;

  @override
  String toString() {
    return 'ChangePasswordOtpRouteArgs{key: $key, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChangePasswordOtpRouteArgs) return false;
    return key == other.key && email == other.email;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode;
}

/// generated route for
/// [ChangePasswordPage]
class ChangePasswordRoute extends PageRouteInfo<ChangePasswordRouteArgs> {
  ChangePasswordRoute({
    Key? key,
    String? initialEmail,
    List<PageRouteInfo>? children,
  }) : super(
         ChangePasswordRoute.name,
         args: ChangePasswordRouteArgs(key: key, initialEmail: initialEmail),
         initialChildren: children,
       );

  static const String name = 'ChangePasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChangePasswordRouteArgs>(
        orElse: () => const ChangePasswordRouteArgs(),
      );
      return ChangePasswordPage(key: args.key, initialEmail: args.initialEmail);
    },
  );
}

class ChangePasswordRouteArgs {
  const ChangePasswordRouteArgs({this.key, this.initialEmail});

  final Key? key;

  final String? initialEmail;

  @override
  String toString() {
    return 'ChangePasswordRouteArgs{key: $key, initialEmail: $initialEmail}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChangePasswordRouteArgs) return false;
    return key == other.key && initialEmail == other.initialEmail;
  }

  @override
  int get hashCode => key.hashCode ^ initialEmail.hashCode;
}

/// generated route for
/// [CreateRestaurantPage]
class CreateRestaurantRoute extends PageRouteInfo<CreateRestaurantRouteArgs> {
  CreateRestaurantRoute({
    Key? key,
    bool isEdit = false,
    List<PageRouteInfo>? children,
  }) : super(
         CreateRestaurantRoute.name,
         args: CreateRestaurantRouteArgs(key: key, isEdit: isEdit),
         initialChildren: children,
       );

  static const String name = 'CreateRestaurantRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreateRestaurantRouteArgs>(
        orElse: () => const CreateRestaurantRouteArgs(),
      );
      return CreateRestaurantPage(key: args.key, isEdit: args.isEdit);
    },
  );
}

class CreateRestaurantRouteArgs {
  const CreateRestaurantRouteArgs({this.key, this.isEdit = false});

  final Key? key;

  final bool isEdit;

  @override
  String toString() {
    return 'CreateRestaurantRouteArgs{key: $key, isEdit: $isEdit}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateRestaurantRouteArgs) return false;
    return key == other.key && isEdit == other.isEdit;
  }

  @override
  int get hashCode => key.hashCode ^ isEdit.hashCode;
}

/// generated route for
/// [DefaultFallbackPage]
class DefaultFallbackRoute extends PageRouteInfo<void> {
  const DefaultFallbackRoute({List<PageRouteInfo>? children})
    : super(DefaultFallbackRoute.name, initialChildren: children);

  static const String name = 'DefaultFallbackRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DefaultFallbackPage();
    },
  );
}

/// generated route for
/// [DeleteAccountReasonPage]
class DeleteAccountReasonRoute extends PageRouteInfo<void> {
  const DeleteAccountReasonRoute({List<PageRouteInfo>? children})
    : super(DeleteAccountReasonRoute.name, initialChildren: children);

  static const String name = 'DeleteAccountReasonRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DeleteAccountReasonPage();
    },
  );
}

/// generated route for
/// [EditProductPage]
class EditProductRoute extends PageRouteInfo<EditProductRouteArgs> {
  EditProductRoute({
    Key? key,
    required int vendorId,
    required int productId,
    required String initialName,
    required String? initialDescription,
    required String? initialPrice,
    required int? initialPreparationTime,
    required bool initialIsAvailable,
    required List<int> initialCategoryIds,
    required List<String> initialIngredientTitles,
    required List<String> initialImageUrls,
    required List<int> initialImageIds,
    List<VendorProductModifierGroupModel> initialModifierGroups = const [],
    List<VendorProductRecommendationRefModel> initialRecommendationProducts =
        const [],
    List<int> initialRecommendationIds = const [],
    String? initialDiscountTitle,
    double? initialDiscountPercent,
    List<PageRouteInfo>? children,
  }) : super(
         EditProductRoute.name,
         args: EditProductRouteArgs(
           key: key,
           vendorId: vendorId,
           productId: productId,
           initialName: initialName,
           initialDescription: initialDescription,
           initialPrice: initialPrice,
           initialPreparationTime: initialPreparationTime,
           initialIsAvailable: initialIsAvailable,
           initialCategoryIds: initialCategoryIds,
           initialIngredientTitles: initialIngredientTitles,
           initialImageUrls: initialImageUrls,
           initialImageIds: initialImageIds,
           initialModifierGroups: initialModifierGroups,
           initialRecommendationProducts: initialRecommendationProducts,
           initialRecommendationIds: initialRecommendationIds,
           initialDiscountTitle: initialDiscountTitle,
           initialDiscountPercent: initialDiscountPercent,
         ),
         initialChildren: children,
       );

  static const String name = 'EditProductRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditProductRouteArgs>();
      return EditProductPage(
        key: args.key,
        vendorId: args.vendorId,
        productId: args.productId,
        initialName: args.initialName,
        initialDescription: args.initialDescription,
        initialPrice: args.initialPrice,
        initialPreparationTime: args.initialPreparationTime,
        initialIsAvailable: args.initialIsAvailable,
        initialCategoryIds: args.initialCategoryIds,
        initialIngredientTitles: args.initialIngredientTitles,
        initialImageUrls: args.initialImageUrls,
        initialImageIds: args.initialImageIds,
        initialModifierGroups: args.initialModifierGroups,
        initialRecommendationProducts: args.initialRecommendationProducts,
        initialRecommendationIds: args.initialRecommendationIds,
        initialDiscountTitle: args.initialDiscountTitle,
        initialDiscountPercent: args.initialDiscountPercent,
      );
    },
  );
}

class EditProductRouteArgs {
  const EditProductRouteArgs({
    this.key,
    required this.vendorId,
    required this.productId,
    required this.initialName,
    required this.initialDescription,
    required this.initialPrice,
    required this.initialPreparationTime,
    required this.initialIsAvailable,
    required this.initialCategoryIds,
    required this.initialIngredientTitles,
    required this.initialImageUrls,
    required this.initialImageIds,
    this.initialModifierGroups = const [],
    this.initialRecommendationProducts = const [],
    this.initialRecommendationIds = const [],
    this.initialDiscountTitle,
    this.initialDiscountPercent,
  });

  final Key? key;

  final int vendorId;

  final int productId;

  final String initialName;

  final String? initialDescription;

  final String? initialPrice;

  final int? initialPreparationTime;

  final bool initialIsAvailable;

  final List<int> initialCategoryIds;

  final List<String> initialIngredientTitles;

  final List<String> initialImageUrls;

  final List<int> initialImageIds;

  final List<VendorProductModifierGroupModel> initialModifierGroups;

  final List<VendorProductRecommendationRefModel> initialRecommendationProducts;

  final List<int> initialRecommendationIds;

  final String? initialDiscountTitle;

  final double? initialDiscountPercent;

  @override
  String toString() {
    return 'EditProductRouteArgs{key: $key, vendorId: $vendorId, productId: $productId, initialName: $initialName, initialDescription: $initialDescription, initialPrice: $initialPrice, initialPreparationTime: $initialPreparationTime, initialIsAvailable: $initialIsAvailable, initialCategoryIds: $initialCategoryIds, initialIngredientTitles: $initialIngredientTitles, initialImageUrls: $initialImageUrls, initialImageIds: $initialImageIds, initialModifierGroups: $initialModifierGroups, initialRecommendationProducts: $initialRecommendationProducts, initialRecommendationIds: $initialRecommendationIds, initialDiscountTitle: $initialDiscountTitle, initialDiscountPercent: $initialDiscountPercent}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditProductRouteArgs) return false;
    return key == other.key &&
        vendorId == other.vendorId &&
        productId == other.productId &&
        initialName == other.initialName &&
        initialDescription == other.initialDescription &&
        initialPrice == other.initialPrice &&
        initialPreparationTime == other.initialPreparationTime &&
        initialIsAvailable == other.initialIsAvailable &&
        const ListEquality<int>().equals(
          initialCategoryIds,
          other.initialCategoryIds,
        ) &&
        const ListEquality<String>().equals(
          initialIngredientTitles,
          other.initialIngredientTitles,
        ) &&
        const ListEquality<String>().equals(
          initialImageUrls,
          other.initialImageUrls,
        ) &&
        const ListEquality<int>().equals(
          initialImageIds,
          other.initialImageIds,
        ) &&
        const ListEquality<VendorProductModifierGroupModel>().equals(
          initialModifierGroups,
          other.initialModifierGroups,
        ) &&
        const ListEquality<VendorProductRecommendationRefModel>().equals(
          initialRecommendationProducts,
          other.initialRecommendationProducts,
        ) &&
        const ListEquality<int>().equals(
          initialRecommendationIds,
          other.initialRecommendationIds,
        ) &&
        initialDiscountTitle == other.initialDiscountTitle &&
        initialDiscountPercent == other.initialDiscountPercent;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      vendorId.hashCode ^
      productId.hashCode ^
      initialName.hashCode ^
      initialDescription.hashCode ^
      initialPrice.hashCode ^
      initialPreparationTime.hashCode ^
      initialIsAvailable.hashCode ^
      const ListEquality<int>().hash(initialCategoryIds) ^
      const ListEquality<String>().hash(initialIngredientTitles) ^
      const ListEquality<String>().hash(initialImageUrls) ^
      const ListEquality<int>().hash(initialImageIds) ^
      const ListEquality<VendorProductModifierGroupModel>().hash(
        initialModifierGroups,
      ) ^
      const ListEquality<VendorProductRecommendationRefModel>().hash(
        initialRecommendationProducts,
      ) ^
      const ListEquality<int>().hash(initialRecommendationIds) ^
      initialDiscountTitle.hashCode ^
      initialDiscountPercent.hashCode;
}

/// generated route for
/// [FinanceTransactionsPage]
class FinanceTransactionsRoute
    extends PageRouteInfo<FinanceTransactionsRouteArgs> {
  FinanceTransactionsRoute({
    Key? key,
    String period = 'weekly',
    List<PageRouteInfo>? children,
  }) : super(
         FinanceTransactionsRoute.name,
         args: FinanceTransactionsRouteArgs(key: key, period: period),
         rawQueryParams: {'period': period},
         initialChildren: children,
       );

  static const String name = 'FinanceTransactionsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<FinanceTransactionsRouteArgs>(
        orElse: () => FinanceTransactionsRouteArgs(
          period: queryParams.getString('period', 'weekly'),
        ),
      );
      return FinanceTransactionsPage(key: args.key, period: args.period);
    },
  );
}

class FinanceTransactionsRouteArgs {
  const FinanceTransactionsRouteArgs({this.key, this.period = 'weekly'});

  final Key? key;

  final String period;

  @override
  String toString() {
    return 'FinanceTransactionsRouteArgs{key: $key, period: $period}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FinanceTransactionsRouteArgs) return false;
    return key == other.key && period == other.period;
  }

  @override
  int get hashCode => key.hashCode ^ period.hashCode;
}

/// generated route for
/// [ForgotPasswordPage]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForgotPasswordPage();
    },
  );
}

/// generated route for
/// [NotInternetPage]
class NotInternetRoute extends PageRouteInfo<NotInternetRouteArgs> {
  NotInternetRoute({
    Key? key,
    required VoidCallback onRetry,
    List<PageRouteInfo>? children,
  }) : super(
         NotInternetRoute.name,
         args: NotInternetRouteArgs(key: key, onRetry: onRetry),
         initialChildren: children,
       );

  static const String name = 'NotInternetRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NotInternetRouteArgs>();
      return NotInternetPage(key: args.key, onRetry: args.onRetry);
    },
  );
}

class NotInternetRouteArgs {
  const NotInternetRouteArgs({this.key, required this.onRetry});

  final Key? key;

  final VoidCallback onRetry;

  @override
  String toString() {
    return 'NotInternetRouteArgs{key: $key, onRetry: $onRetry}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NotInternetRouteArgs) return false;
    return key == other.key && onRetry == other.onRetry;
  }

  @override
  int get hashCode => key.hashCode ^ onRetry.hashCode;
}

/// generated route for
/// [NotificationPage]
class NotificationRoute extends PageRouteInfo<void> {
  const NotificationRoute({List<PageRouteInfo>? children})
    : super(NotificationRoute.name, initialChildren: children);

  static const String name = 'NotificationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotificationPage();
    },
  );
}

/// generated route for
/// [OrdersHistoryPage]
class OrdersHistoryRoute extends PageRouteInfo<void> {
  const OrdersHistoryRoute({List<PageRouteInfo>? children})
    : super(OrdersHistoryRoute.name, initialChildren: children);

  static const String name = 'OrdersHistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OrdersHistoryPage();
    },
  );
}

/// generated route for
/// [OrdersPage]
class OrdersRoute extends PageRouteInfo<void> {
  const OrdersRoute({List<PageRouteInfo>? children})
    : super(OrdersRoute.name, initialChildren: children);

  static const String name = 'OrdersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OrdersPage();
    },
  );
}

/// generated route for
/// [OtpPage]
class OtpRoute extends PageRouteInfo<OtpRouteArgs> {
  OtpRoute({
    Key? key,
    required String emailOrPhone,
    OtpFlow flow = OtpFlow.account,
    List<PageRouteInfo>? children,
  }) : super(
         OtpRoute.name,
         args: OtpRouteArgs(key: key, emailOrPhone: emailOrPhone, flow: flow),
         initialChildren: children,
       );

  static const String name = 'OtpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OtpRouteArgs>();
      return OtpPage(
        key: args.key,
        emailOrPhone: args.emailOrPhone,
        flow: args.flow,
      );
    },
  );
}

class OtpRouteArgs {
  const OtpRouteArgs({
    this.key,
    required this.emailOrPhone,
    this.flow = OtpFlow.account,
  });

  final Key? key;

  final String emailOrPhone;

  final OtpFlow flow;

  @override
  String toString() {
    return 'OtpRouteArgs{key: $key, emailOrPhone: $emailOrPhone, flow: $flow}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OtpRouteArgs) return false;
    return key == other.key &&
        emailOrPhone == other.emailOrPhone &&
        flow == other.flow;
  }

  @override
  int get hashCode => key.hashCode ^ emailOrPhone.hashCode ^ flow.hashCode;
}

/// generated route for
/// [ReceiptPrinterSettingsPage]
class ReceiptPrinterSettingsRoute extends PageRouteInfo<void> {
  const ReceiptPrinterSettingsRoute({List<PageRouteInfo>? children})
    : super(ReceiptPrinterSettingsRoute.name, initialChildren: children);

  static const String name = 'ReceiptPrinterSettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ReceiptPrinterSettingsPage();
    },
  );
}

/// generated route for
/// [ResetPasswordPage]
class ResetPasswordRoute extends PageRouteInfo<void> {
  const ResetPasswordRoute({List<PageRouteInfo>? children})
    : super(ResetPasswordRoute.name, initialChildren: children);

  static const String name = 'ResetPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ResetPasswordPage();
    },
  );
}

/// generated route for
/// [ServerErrorPage]
class ServerErrorRoute extends PageRouteInfo<void> {
  const ServerErrorRoute({List<PageRouteInfo>? children})
    : super(ServerErrorRoute.name, initialChildren: children);

  static const String name = 'ServerErrorRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ServerErrorPage();
    },
  );
}

/// generated route for
/// [SignInPage]
class SignInRoute extends PageRouteInfo<void> {
  const SignInRoute({List<PageRouteInfo>? children})
    : super(SignInRoute.name, initialChildren: children);

  static const String name = 'SignInRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignInPage();
    },
  );
}

/// generated route for
/// [SignUpPage]
class SignUpRoute extends PageRouteInfo<void> {
  const SignUpRoute({List<PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignUpPage();
    },
  );
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashPage();
    },
  );
}

/// generated route for
/// [SupportChatPage]
class SupportChatRoute extends PageRouteInfo<void> {
  const SupportChatRoute({List<PageRouteInfo>? children})
    : super(SupportChatRoute.name, initialChildren: children);

  static const String name = 'SupportChatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SupportChatPage();
    },
  );
}

/// generated route for
/// [UpdateRestaurantPage]
class UpdateRestaurantRoute extends PageRouteInfo<void> {
  const UpdateRestaurantRoute({List<PageRouteInfo>? children})
    : super(UpdateRestaurantRoute.name, initialChildren: children);

  static const String name = 'UpdateRestaurantRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UpdateRestaurantPage();
    },
  );
}

/// generated route for
/// [VendorAccountMenuPage]
class VendorAccountMenuRoute extends PageRouteInfo<void> {
  const VendorAccountMenuRoute({List<PageRouteInfo>? children})
    : super(VendorAccountMenuRoute.name, initialChildren: children);

  static const String name = 'VendorAccountMenuRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const VendorAccountMenuPage();
    },
  );
}

/// generated route for
/// [VendorProfilePage]
class VendorProfileRoute extends PageRouteInfo<void> {
  const VendorProfileRoute({List<PageRouteInfo>? children})
    : super(VendorProfileRoute.name, initialChildren: children);

  static const String name = 'VendorProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const VendorProfilePage();
    },
  );
}
