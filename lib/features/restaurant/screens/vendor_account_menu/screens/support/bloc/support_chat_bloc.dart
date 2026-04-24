import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/bloc/support_chat_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/bloc/support_chat_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/data/models/service_support_chat_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/data/support_chat_repository.dart';

class SupportChatBloc extends Bloc<SupportChatEvent, SupportChatState> {
  SupportChatBloc(this._repo) : super(const SupportChatState()) {
    on<SupportChatStarted>(_onStarted);
    on<SupportChatInbound>(_onInbound);
    on<SupportChatSendRequested>(_onSend);
    on<SupportChatClosed>(_onClosed);
  }

  final SupportChatRepository _repo;
  StreamSubscription<ServiceSupportChatModel>? _inboundSub;

  Future<void> _onStarted(SupportChatStarted event, Emitter<SupportChatState> emit) async {
    emit(state.copyWith(status: SupportChatStatus.connecting, clearError: true));
    await _inboundSub?.cancel();
    try {
      await _repo.connect();
      _inboundSub = _repo.inbound.listen(
        (model) => add(SupportChatInbound(model)),
        onError: (Object e, StackTrace _) {
          emit(state.copyWith(status: SupportChatStatus.failure, errorMessage: e.toString()));
        },
      );
      emit(state.copyWith(status: SupportChatStatus.ready));
    } catch (e) {
      emit(
        state.copyWith(
          status: SupportChatStatus.failure,
          errorMessage: e is StateError ? e.message : e.toString(),
        ),
      );
    }
  }

  void _onInbound(SupportChatInbound event, Emitter<SupportChatState> emit) {
    final m = event.model;
    var list = List<Message>.from(state.messages);

    if (m.messages != null && m.messages!.isNotEmpty) {
      list = List<Message>.of(m.messages!);
    } else if (m.message != null) {
      final msg = m.message!;
      final id = msg.id;
      if (id != null && list.any((x) => x.id == id)) {
        return;
      }
      list = [...list, msg];
    } else {
      return;
    }

    list.sort((a, b) {
      final ta = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      final tb = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      return ta.compareTo(tb);
    });

    emit(state.copyWith(messages: list, status: SupportChatStatus.ready, clearError: true));
  }

  Future<void> _onSend(SupportChatSendRequested event, Emitter<SupportChatState> emit) async {
    if (state.status != SupportChatStatus.ready) return;
    _repo.sendText(event.text);
  }

  Future<void> _onClosed(SupportChatClosed event, Emitter<SupportChatState> emit) async {
    await _inboundSub?.cancel();
    _inboundSub = null;
    await _repo.disconnect();
    emit(state.copyWith(status: SupportChatStatus.disconnected));
  }

  @override
  Future<void> close() async {
    await _inboundSub?.cancel();
    await _repo.disconnect();
    return super.close();
  }
}
