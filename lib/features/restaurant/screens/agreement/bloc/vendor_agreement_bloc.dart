import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/bloc/vendor_agreement_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/bloc/vendor_agreement_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/data/vendor_agreement_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/models/vendor_agreement_model.dart';

class VendorAgreementBloc extends Bloc<VendorAgreementEvent, VendorAgreementState> {
  VendorAgreementBloc({required int vendorId, required VendorAgreementRepository repository}) : _vendorId = vendorId, _repository = repository, super(const VendorAgreementState()) {
    on<VendorAgreementLoadRequested>(_onLoad);
    on<VendorAgreementAcceptRequested>(_onAccept);
    on<VendorAgreementSignRequested>(_onSign);
    on<VendorAgreementStepSelected>(_onSelectStep);
  }

  final int _vendorId;
  final VendorAgreementRepository _repository;

  Future<void> _onLoad(VendorAgreementLoadRequested event, Emitter<VendorAgreementState> emit) async {
    if (_vendorId <= 0) {
      emit(state.copyWith(status: VendorAgreementStatus.failure, errorMessage: 'Invalid vendor id'));
      return;
    }
    emit(state.copyWith(status: VendorAgreementStatus.loading, clearError: true, clearActionMessage: true));
    try {
      final agreement = await _repository.getAgreement(vendorId: _vendorId);
      emit(
        state.copyWith(
          status: VendorAgreementStatus.success,
          setAgreement: true,
          agreement: agreement,
          setSelectedStep: true,
          selectedStep: _resolveSelectedStep(agreement, preferredStep: state.selectedStep),
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: VendorAgreementStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onAccept(VendorAgreementAcceptRequested event, Emitter<VendorAgreementState> emit) async {
    final agreement = state.agreement;
    if (agreement == null || state.isAccepting) return;
    final currentSection = _resolveCurrentSection(agreement);
    if (currentSection == null || currentSection.isAccepted) return;

    emit(state.copyWith(isAccepting: true, clearError: true, clearActionMessage: true));
    try {
      final updated = await _repository.acceptStep(vendorId: _vendorId, stepNumber: agreement.currentStep);
      emit(state.copyWith(status: VendorAgreementStatus.success, setAgreement: true, agreement: updated, setSelectedStep: true, selectedStep: updated.currentStep, isAccepting: false, actionMessage: 'agreement.stepAccepted'));
    } catch (e) {
      emit(state.copyWith(isAccepting: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onSign(VendorAgreementSignRequested event, Emitter<VendorAgreementState> emit) async {
    final agreement = state.agreement;
    if (agreement == null || state.isSigning) return;
    final initials = event.initials.trim().toUpperCase();
    if (initials.isEmpty) {
      emit(state.copyWith(actionMessage: 'agreement.nameRequired'));
      return;
    }
    if (!_allSectionsAccepted(agreement)) {
      emit(state.copyWith(actionMessage: 'agreement.sectionsRequired'));
      return;
    }

    emit(state.copyWith(isSigning: true, clearError: true, clearActionMessage: true));
    try {
      final updated = await _repository.signAgreement(vendorId: _vendorId, initials: initials);
      emit(state.copyWith(status: VendorAgreementStatus.success, setAgreement: true, agreement: updated, isSigning: false, actionMessage: 'agreement.signSuccess'));
    } catch (e) {
      emit(state.copyWith(isSigning: false, errorMessage: e.toString()));
    }
  }

  void _onSelectStep(VendorAgreementStepSelected event, Emitter<VendorAgreementState> emit) {
    emit(state.copyWith(setSelectedStep: true, selectedStep: event.stepNumber, clearActionMessage: true));
  }

  int? _resolveSelectedStep(VendorAgreementModel agreement, {int? preferredStep}) {
    if (agreement.sections.isEmpty) return null;
    if (preferredStep != null && agreement.sections.any((e) => e.stepNumber == preferredStep)) {
      return preferredStep;
    }
    final pending = agreement.sections.where((e) => !e.isAccepted);
    if (pending.isNotEmpty) return pending.first.stepNumber;
    return agreement.sections.first.stepNumber;
  }

  VendorAgreementSectionModel? _resolveCurrentSection(VendorAgreementModel agreement) {
    if (agreement.sections.isEmpty) return null;
    final byStep = agreement.sections.where((e) => e.stepNumber == agreement.currentStep);
    if (byStep.isNotEmpty) return byStep.first;
    final idx = agreement.currentStep - 1;
    if (idx >= 0 && idx < agreement.sections.length) {
      return agreement.sections[idx];
    }
    final pending = agreement.sections.where((e) => !e.isAccepted);
    if (pending.isNotEmpty) return pending.first;
    return agreement.sections.first;
  }

  bool _allSectionsAccepted(VendorAgreementModel agreement) {
    return agreement.sections.every((e) => e.isAccepted);
  }
}
