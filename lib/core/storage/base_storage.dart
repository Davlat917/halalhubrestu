import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';

class BaseStorage<T> {
  final Box box;

  final String? key;

  String get _key => key ?? T.runtimeType.toString();

  BaseStorage(this.box, this.key);

  T? call() {
    final value = box.get(_key);
    if (value is List) {
      try {
        return List.from(value) as T;
      } catch (e) {
        debugPrint("Storage Cast Error: $e");
        return null;
      }
    }

    return value as T?;
  }

  Future<void> set(T? value) => box.put(_key, value);

  Future<void> delete() => box.delete(_key);

  Stream<T?> watch() async* {
    final initial = call();
    yield* box.watch(key: _key).map((event) => event.value as T?).startWith(initial);
  }
}
