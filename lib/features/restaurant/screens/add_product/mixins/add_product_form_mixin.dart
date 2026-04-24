import 'package:flutter/material.dart';

mixin AddProductFormMixin<T extends StatefulWidget> on State<T> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final preparationController = TextEditingController();
  final ingredientsController = TextEditingController();
  final discountController = TextEditingController();
  final deletedImageIdsController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    preparationController.dispose();
    ingredientsController.dispose();
    discountController.dispose();
    deletedImageIdsController.dispose();
    super.dispose();
  }

  List<String> buildIngredients() {
    return ingredientsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String? nonEmptyOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void clearInputs() {
    formKey.currentState?.reset();
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    preparationController.clear();
    ingredientsController.clear();
    discountController.clear();
    deletedImageIdsController.clear();
  }
}
