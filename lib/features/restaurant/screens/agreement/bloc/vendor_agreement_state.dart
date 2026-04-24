import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/models/vendor_agreement_model.dart';

enum VendorAgreementStatus { initial, loading, success, failure }

class VendorAgreementState extends Equatable {
  const VendorAgreementState({
    this.status = VendorAgreementStatus.initial,
    this.agreement,
    this.selectedStep,
    this.errorMessage,
    this.isAccepting = false,
    this.isSigning = false,
    this.actionMessage,
  });

  final VendorAgreementStatus status;
  final VendorAgreementModel? agreement;
  final int? selectedStep;
  final String? errorMessage;
  final bool isAccepting;
  final bool isSigning;
  final String? actionMessage;

  VendorAgreementState copyWith({
    VendorAgreementStatus? status,
    VendorAgreementModel? agreement,
    bool setAgreement = false,
    int? selectedStep,
    bool setSelectedStep = false,
    String? errorMessage,
    bool clearError = false,
    bool? isAccepting,
    bool? isSigning,
    String? actionMessage,
    bool clearActionMessage = false,
  }) {
    return VendorAgreementState(
      status: status ?? this.status,
      agreement: setAgreement ? agreement : this.agreement,
      selectedStep: setSelectedStep ? selectedStep : this.selectedStep,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isAccepting: isAccepting ?? this.isAccepting,
      isSigning: isSigning ?? this.isSigning,
      actionMessage: clearActionMessage
          ? null
          : (actionMessage ?? this.actionMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    agreement,
    selectedStep,
    errorMessage,
    isAccepting,
    isSigning,
    actionMessage,
  ];
}
