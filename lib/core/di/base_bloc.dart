import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BaseBloc<E, S> extends Bloc<E, S> {
  BaseBloc(super.initialState);

  Emitter<S>? currentEmitter;

  void onAsync<T extends E>(Future<void> Function(T event) handler) {
    on<T>((event, emit) async {
      currentEmitter = emit;
      await handler(event);
      currentEmitter = null;
    });
  }

  Future<void> callable<T>({
    required Future<T> future,
    required S Function() buildOnStart,
    required S Function(T data) buildOnData,
    S Function(NetworkException error)? buildOnError,
  }) async {
    final emit = currentEmitter;
    if (emit == null) return;

    emit(buildOnStart());

    try {
      final result = await future;
      emit(buildOnData(result));
    } catch (e) {
      final networkException = e is NetworkException ? e : NetworkException(message: e.toString());

      if (buildOnError != null) {
        emit(buildOnError(networkException));
      } else {
        _logError(networkException);
      }
    }
  }

  void _logError(NetworkException e) {
    if (kDebugMode) {
      debugPrint("BaseBloc Error: ${e.message} | Code: ${e.statusCode}");
    }
  }
}
