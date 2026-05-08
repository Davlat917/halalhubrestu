import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

/// Bir dialogda bir nechta buyurtma qatorlarini ko‘rsatish uchun model.
class VendorNewOrderDialogVm {
  const VendorNewOrderDialogVm({
    required this.firstTitleMessage,
    required this.orderTokenList,
    required this.seenTokens,
  });

  final String? firstTitleMessage;
  /// Har bir element: buyurtma raqami/id matni yoki `''` = id yo‘q (umumiy qator).
  final List<String> orderTokenList;
  final Set<String> seenTokens;

  static String? _token(Map<String, dynamic> raw) {
    for (final k in ['order_number', 'orderNumber', 'order_id', 'orderId', 'id']) {
      final v = raw[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  factory VendorNewOrderDialogVm.fromRaw(Map<String, dynamic> raw) {
    final t = _token(raw);
    if (t == null) {
      return VendorNewOrderDialogVm(
        firstTitleMessage: raw['message']?.toString(),
        orderTokenList: const [''],
        seenTokens: const {},
      );
    }
    return VendorNewOrderDialogVm(
      firstTitleMessage: raw['message']?.toString(),
      orderTokenList: [t],
      seenTokens: {t},
    );
  }

  VendorNewOrderDialogVm append(Map<String, dynamic> raw) {
    final t = _token(raw);
    if (t != null) {
      if (seenTokens.contains(t)) return this;
      return VendorNewOrderDialogVm(
        firstTitleMessage: firstTitleMessage ?? raw['message']?.toString(),
        orderTokenList: [...orderTokenList, t],
        seenTokens: {...seenTokens, t},
      );
    }
    if (orderTokenList.isNotEmpty && orderTokenList.last.isEmpty) {
      return this;
    }
    return VendorNewOrderDialogVm(
      firstTitleMessage: firstTitleMessage ?? raw['message']?.toString(),
      orderTokenList: [...orderTokenList, ''],
      seenTokens: seenTokens,
    );
  }

  String title(BuildContext context) {
    final t = firstTitleMessage?.trim();
    if (t != null && t.isNotEmpty) return t;
    return TranslationKeys.ordersNewOrderDialogTitle.tr(context: context);
  }

  String body(BuildContext context) {
    if (orderTokenList.isEmpty) {
      return TranslationKeys.ordersNewOrderDialogBodyNoNumber.tr(context: context);
    }
    return orderTokenList
        .map(
          (tok) => tok.isEmpty
              ? TranslationKeys.ordersNewOrderDialogBodyNoNumber.tr(context: context)
              : TranslationKeys.ordersNewOrderDialogBody.tr(
                  context: context,
                  namedArgs: {'orderNumber': tok},
                ),
        )
        .join('\n');
  }
}

/// Yangi buyurtma(lar) — [vmNotifier] orqali ro‘yxat yangilanadi (dialog ustiga dialog chiqarmaydi).
Future<void> showVendorNewOrderDialog({
  required BuildContext context,
  required ValueNotifier<VendorNewOrderDialogVm> vmNotifier,
  required VoidCallback onDismiss,
  required VoidCallback onGoToOrders,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return ValueListenableBuilder<VendorNewOrderDialogVm>(
        valueListenable: vmNotifier,
        builder: (context, vm, _) {
          return AlertDialog(
            title: Text(vm.title(dialogContext)),
            content: SingleChildScrollView(child: Text(vm.body(dialogContext))),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                onPressed: () {
                  onDismiss();
                  Navigator.of(dialogContext).pop();
                },
                child: Text(TranslationKeys.ordersNewOrderGoBack.tr(context: dialogContext)),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: StaticColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  onDismiss();
                  Navigator.of(dialogContext).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onGoToOrders();
                  });
                },
                child: Text(TranslationKeys.ordersNewOrderOpenOrders.tr(context: dialogContext)),
              ),
            ],
          );
        },
      );
    },
  );
}
