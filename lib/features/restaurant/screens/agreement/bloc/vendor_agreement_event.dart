import 'package:equatable/equatable.dart';

sealed class VendorAgreementEvent extends Equatable {
  const VendorAgreementEvent();

  @override
  List<Object?> get props => [];
}

final class VendorAgreementLoadRequested extends VendorAgreementEvent {
  const VendorAgreementLoadRequested();
}

final class VendorAgreementAcceptRequested extends VendorAgreementEvent {
  const VendorAgreementAcceptRequested();
}

final class VendorAgreementSignRequested extends VendorAgreementEvent {
  const VendorAgreementSignRequested({required this.initials});

  final String initials;

  @override
  List<Object?> get props => [initials];
}

final class VendorAgreementStepSelected extends VendorAgreementEvent {
  const VendorAgreementStepSelected({required this.stepNumber});

  final int stepNumber;

  @override
  List<Object?> get props => [stepNumber];
}
