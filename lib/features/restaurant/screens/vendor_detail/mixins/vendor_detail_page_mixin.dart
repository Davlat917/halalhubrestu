import 'package:flutter/widgets.dart';

mixin VendorDetailPageMixin<T extends StatefulWidget> on State<T> {
  bool isWideLayout(BoxConstraints constraints) => constraints.maxWidth >= 900;

  double horizontalPadding(bool isWide) => isWide ? 20 : 12;

  int financeCardsPerRow(bool isWide) => isWide ? 4 : 2;
}
