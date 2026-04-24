import 'package:flutter/material.dart';

mixin SignUpTabMixin<T extends StatefulWidget> on State<T> {
  final currentIndex = ValueNotifier<int>(0);

  void toggleIndex(int newValue) {
    currentIndex.value = newValue;
  }

  @override
  void dispose() {
    currentIndex.dispose();
    super.dispose();
  }
}
