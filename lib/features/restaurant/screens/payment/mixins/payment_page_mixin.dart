import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/mixins/validation_mixin.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_bank_info/vendor_bank_info_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/widgets/payment_edit_bank_account_dialog_content.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/widgets/payment_withdraw_dialog_content.dart';

mixin PaymentPageMixin<T extends StatefulWidget> on State<T>, ValidationMixin {
  late final TextEditingController editBusinessNameController;
  late final TextEditingController editEinController;
  late final TextEditingController editAccountNumberController;
  late final TextEditingController editRoutingNumberController;

  late final ValueNotifier<String> payoutScheduleNotifier;
  late final ValueNotifier<String?> businessNameErrorNotifier;
  late final ValueNotifier<String?> einErrorNotifier;
  late final ValueNotifier<String?> accountNumberErrorNotifier;
  late final ValueNotifier<String?> routingNumberErrorNotifier;

  VendorBankInfoModel? _editingBankInfo;

  void initPaymentPageMixin() {
    editBusinessNameController = TextEditingController();
    editEinController = TextEditingController();
    editAccountNumberController = TextEditingController();
    editRoutingNumberController = TextEditingController();
    payoutScheduleNotifier = ValueNotifier<String>('weekly');
    businessNameErrorNotifier = ValueNotifier<String?>(null);
    einErrorNotifier = ValueNotifier<String?>(null);
    accountNumberErrorNotifier = ValueNotifier<String?>(null);
    routingNumberErrorNotifier = ValueNotifier<String?>(null);
  }

  void disposePaymentPageMixin() {
    editBusinessNameController.dispose();
    editEinController.dispose();
    editAccountNumberController.dispose();
    editRoutingNumberController.dispose();
    payoutScheduleNotifier.dispose();
    businessNameErrorNotifier.dispose();
    einErrorNotifier.dispose();
    accountNumberErrorNotifier.dispose();
    routingNumberErrorNotifier.dispose();
  }

  String pageTitle(BuildContext context) =>
      TranslationKeys.paymentManagement.tr(context: context);
  String get currentBalance => '\$2,541.00';
  String get scheduledPayouts => '\$8,325.32';
  String commissionDescription(BuildContext context) => TranslationKeys
      .paymentCommissionPerOrder
      .tr(context: context, namedArgs: {'fee': '\$4'});
  String get halalHubFee => '\$4.00';

  void onWithdrawPressed(BuildContext context) {
    final bloc = context.read<PaymentDashboardBloc>();
    bloc.add(const PaymentWithdrawRequestStatusCleared());

    final maxBalance = bloc.state.dashboard.currentBalance;
    final maxBalanceLabel = _formatMoney(maxBalance);

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final size = MediaQuery.sizeOf(dialogContext);
        final isLandscape =
            MediaQuery.orientationOf(dialogContext) == Orientation.landscape;
        final maxDialogWidth = isLandscape ? 560.0 : 460.0;
        final dialogWidth = (size.width - 32).clamp(280.0, maxDialogWidth);
        return BlocProvider.value(
          value: bloc,
          child: BlocListener<PaymentDashboardBloc, PaymentDashboardState>(
            listenWhen: (previous, current) {
              return previous.withdrawRequestStatus !=
                  current.withdrawRequestStatus;
            },
            listener: (listenerContext, state) {
              if (state.withdrawRequestStatus ==
                      PaymentDashboardStatus.success &&
                  state.withdrawRequestMessage != null) {
                getIt<Display>().success(state.withdrawRequestMessage!);
                bloc.add(const PaymentWithdrawRequestStatusCleared());
                _closeOwnRoute(dialogContext);
                return;
              }
              if (state.withdrawRequestStatus ==
                      PaymentDashboardStatus.failure &&
                  state.withdrawRequestMessage != null) {
                getIt<Display>().error(state.withdrawRequestMessage!);
                bloc.add(const PaymentWithdrawRequestStatusCleared());
              }
            },
            child: Dialog(
              backgroundColor: StaticColors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18), //
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: dialogWidth,
                  minWidth: dialogWidth,
                ),
                child: PaymentWithdrawDialogContent(
                  maxBalanceLabel: maxBalanceLabel,
                  onClose: () => _closeOwnRoute(dialogContext),
                  onSubmit: (amountText) {
                    bloc.add(
                      PaymentWithdrawRequestSubmitted(
                        requestedAmount: amountText,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> onEditBankAccountPressed(
    BuildContext context,
    VendorBankInfoModel bankInfo,
  ) async {
    _fillEditBankForm(bankInfo);
    var isClosingEditSheet = false;
    final paymentDashboardBloc = context.read<PaymentDashboardBloc>();
    paymentDashboardBloc.add(const PaymentBankInfoUpdateStatusCleared());
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    if (isTablet) {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return BlocProvider.value(
            value: paymentDashboardBloc,
            child: BlocListener<PaymentDashboardBloc, PaymentDashboardState>(
              listenWhen: (previous, current) {
                return previous.bankInfoUpdateStatus !=
                    current.bankInfoUpdateStatus;
              },
              listener: (listenerContext, state) {
                if (state.bankInfoUpdateStatus ==
                        PaymentDashboardStatus.success &&
                    !isClosingEditSheet) {
                  isClosingEditSheet = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _closeOwnRoute(dialogContext);
                  });
                }
              },
              child: Dialog(
                backgroundColor: StaticColors.white,
                alignment: Alignment.center,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child:
                      BlocBuilder<PaymentDashboardBloc, PaymentDashboardState>(
                        buildWhen: (previous, current) {
                          return previous.bankInfoUpdateStatus !=
                                  current.bankInfoUpdateStatus ||
                              previous.bankInfoUpdateMessage !=
                                  current.bankInfoUpdateMessage;
                        },
                        builder: (builderContext, state) {
                          return PaymentEditBankAccountDialogContent(
                            onClose: () => _closeOwnRoute(dialogContext),
                            submitStatus: state.bankInfoUpdateStatus,
                            submitErrorMessage:
                                state.bankInfoUpdateStatus ==
                                    PaymentDashboardStatus.failure
                                ? state.bankInfoUpdateMessage
                                : null,
                            businessNameController: editBusinessNameController,
                            einController: editEinController,
                            accountNumberController:
                                editAccountNumberController,
                            routingNumberController:
                                editRoutingNumberController,
                            payoutScheduleListenable: payoutScheduleNotifier,
                            businessNameErrorListenable:
                                businessNameErrorNotifier,
                            einErrorListenable: einErrorNotifier,
                            accountNumberErrorListenable:
                                accountNumberErrorNotifier,
                            routingNumberErrorListenable:
                                routingNumberErrorNotifier,
                            onWeeklySelected: _setWeeklyPayoutSchedule,
                            onManualSelected: _setManualPayoutSchedule,
                            onBusinessNameChanged: _onBusinessNameChanged,
                            onEinChanged: _onEinChanged,
                            onAccountNumberChanged: _onAccountNumberChanged,
                            onRoutingNumberChanged: _onRoutingNumberChanged,
                            onSubmit: () =>
                                _submitEditBankAccount(builderContext),
                          );
                        },
                      ),
                ),
              ),
            ),
          );
        },
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: StaticColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: BlocProvider.value(
              value: paymentDashboardBloc,
              child: BlocListener<PaymentDashboardBloc, PaymentDashboardState>(
                listenWhen: (previous, current) {
                  return previous.bankInfoUpdateStatus !=
                      current.bankInfoUpdateStatus;
                },
                listener: (listenerContext, state) {
                  if (state.bankInfoUpdateStatus ==
                          PaymentDashboardStatus.success &&
                      !isClosingEditSheet) {
                    isClosingEditSheet = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _closeOwnRoute(sheetContext);
                    });
                  }
                },
                child: BlocBuilder<PaymentDashboardBloc, PaymentDashboardState>(
                  buildWhen: (previous, current) {
                    return previous.bankInfoUpdateStatus !=
                            current.bankInfoUpdateStatus ||
                        previous.bankInfoUpdateMessage !=
                            current.bankInfoUpdateMessage;
                  },
                  builder: (builderContext, state) {
                    return PaymentEditBankAccountDialogContent(
                      onClose: () => _closeOwnRoute(sheetContext),
                      submitStatus: state.bankInfoUpdateStatus,
                      submitErrorMessage:
                          state.bankInfoUpdateStatus ==
                              PaymentDashboardStatus.failure
                          ? state.bankInfoUpdateMessage
                          : null,
                      businessNameController: editBusinessNameController,
                      einController: editEinController,
                      accountNumberController: editAccountNumberController,
                      routingNumberController: editRoutingNumberController,
                      payoutScheduleListenable: payoutScheduleNotifier,
                      businessNameErrorListenable: businessNameErrorNotifier,
                      einErrorListenable: einErrorNotifier,
                      accountNumberErrorListenable: accountNumberErrorNotifier,
                      routingNumberErrorListenable: routingNumberErrorNotifier,
                      onWeeklySelected: _setWeeklyPayoutSchedule,
                      onManualSelected: _setManualPayoutSchedule,
                      onBusinessNameChanged: _onBusinessNameChanged,
                      onEinChanged: _onEinChanged,
                      onAccountNumberChanged: _onAccountNumberChanged,
                      onRoutingNumberChanged: _onRoutingNumberChanged,
                      onSubmit: () => _submitEditBankAccount(builderContext),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatMoney(double value) {
    final normalized = value.toStringAsFixed(2);
    if (normalized.endsWith('.00')) {
      return '\$${normalized.substring(0, normalized.length - 3)}';
    }
    return '\$$normalized';
  }

  void _fillEditBankForm(VendorBankInfoModel bankInfo) {
    _editingBankInfo = bankInfo;
    editBusinessNameController.text = bankInfo.businessName;
    editEinController.text = bankInfo.einNumberMasked;
    editAccountNumberController.text = bankInfo.accountNumberMasked;
    editRoutingNumberController.text = bankInfo.routingNumberMasked;
    payoutScheduleNotifier.value = bankInfo.payoutSchedule.isEmpty
        ? 'weekly'
        : bankInfo.payoutSchedule;
    _clearEditBankErrors();
  }

  bool _isMaskedBankFieldUnchanged(String current, String originalMasked) {
    return current.trim() == originalMasked.trim();
  }

  String? _validateEinForEdit(String value) {
    final original = _editingBankInfo?.einNumberMasked ?? '';
    if (_isMaskedBankFieldUnchanged(value, original)) return null;
    return validateEinForPayment(value);
  }

  String? _validateAccountNumberForEdit(String value) {
    final original = _editingBankInfo?.accountNumberMasked ?? '';
    if (_isMaskedBankFieldUnchanged(value, original)) return null;
    return validatePaymentDigitsField(
      value,
      fieldName: TranslationKeys.paymentAccountNumber.tr(context: context),
      exactLength: 12,
      maxLength: 12,
    );
  }

  String? _validateRoutingNumberForEdit(String value) {
    final original = _editingBankInfo?.routingNumberMasked ?? '';
    if (_isMaskedBankFieldUnchanged(value, original)) return null;
    return validatePaymentDigitsField(
      value,
      fieldName: TranslationKeys.paymentRoutingNumber.tr(context: context),
      exactLength: 9,
      maxLength: 9,
    );
  }

  String? _einNumberForSubmit(String value) {
    final original = _editingBankInfo?.einNumberMasked ?? '';
    if (_isMaskedBankFieldUnchanged(value, original)) return null;
    return value.trim();
  }

  String? _accountNumberForSubmit(String value) {
    final original = _editingBankInfo?.accountNumberMasked ?? '';
    if (_isMaskedBankFieldUnchanged(value, original)) return null;
    return value.trim();
  }

  String? _routingNumberForSubmit(String value) {
    final original = _editingBankInfo?.routingNumberMasked ?? '';
    if (_isMaskedBankFieldUnchanged(value, original)) return null;
    return value.trim();
  }

  void _setWeeklyPayoutSchedule() {
    payoutScheduleNotifier.value = 'weekly';
  }

  void _setManualPayoutSchedule() {
    payoutScheduleNotifier.value = 'manual';
  }

  void _onBusinessNameChanged(String _) {
    if (businessNameErrorNotifier.value == null) return;
    businessNameErrorNotifier.value = validateBusinessNameForPayment(
      editBusinessNameController.text,
    );
  }

  void _onEinChanged(String _) {
    if (einErrorNotifier.value == null) return;
    einErrorNotifier.value = _validateEinForEdit(editEinController.text);
  }

  void _onAccountNumberChanged(String _) {
    if (accountNumberErrorNotifier.value == null) return;
    accountNumberErrorNotifier.value =
        _validateAccountNumberForEdit(editAccountNumberController.text);
  }

  void _onRoutingNumberChanged(String _) {
    if (routingNumberErrorNotifier.value == null) return;
    routingNumberErrorNotifier.value =
        _validateRoutingNumberForEdit(editRoutingNumberController.text);
  }

  bool _validateEditBankForm() {
    final businessError = validateBusinessNameForPayment(
      editBusinessNameController.text,
    );
    final einError = _validateEinForEdit(editEinController.text);
    final accountError =
        _validateAccountNumberForEdit(editAccountNumberController.text);
    final routingError =
        _validateRoutingNumberForEdit(editRoutingNumberController.text);

    businessNameErrorNotifier.value = businessError;
    einErrorNotifier.value = einError;
    accountNumberErrorNotifier.value = accountError;
    routingNumberErrorNotifier.value = routingError;

    return businessError == null &&
        einError == null &&
        accountError == null &&
        routingError == null;
  }

  void _clearEditBankErrors() {
    businessNameErrorNotifier.value = null;
    einErrorNotifier.value = null;
    accountNumberErrorNotifier.value = null;
    routingNumberErrorNotifier.value = null;
  }

  void _submitEditBankAccount(BuildContext context) {
    if (!_validateEditBankForm()) return;
    context.read<PaymentDashboardBloc>().add(
      PaymentBankInfoUpdateRequested(
        businessName: editBusinessNameController.text.trim(),
        payoutSchedule: payoutScheduleNotifier.value,
        einNumber: _einNumberForSubmit(editEinController.text),
        accountNumber: _accountNumberForSubmit(editAccountNumberController.text),
        routingNumber: _routingNumberForSubmit(editRoutingNumberController.text),
      ),
    );
  }

  void _closeOwnRoute(BuildContext routeContext) {
    if (!routeContext.mounted) return;
    final route = ModalRoute.of(routeContext);
    if (route == null || !route.isActive) return;
    Navigator.of(routeContext).removeRoute(route);
  }
}
