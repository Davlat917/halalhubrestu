import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:halalhub_restaurant/core/widgets/feedback/global_feedback_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

mixin RestaurantActionMixin<T extends StatefulWidget> on State<T> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final phonePrimaryController = TextEditingController();
  final phoneSecondaryController = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();
  XFile? profileImage;
  XFile? bannerImage;
  final List<XFile> certificates = [];

  int currentStep = 0;
  bool hasCertificate = false;
  bool locationConfirmed = false;
  LatLng? selectedLatLng;
  GoogleMapController? mapController;
  final List<bool> completedSteps = [false, false, false, false];
  final List<bool> openDays = [true, true, true, true, true, true, false];
  final List<TimeOfDay> startTimes = List.generate(
    7,
    (_) => const TimeOfDay(hour: 9, minute: 0),
  );
  final List<TimeOfDay> endTimes = List.generate(
    7,
    (_) => const TimeOfDay(hour: 23, minute: 59),
  );

  Future<void> pickProfileImage() async {
    final file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;
    setState(() => profileImage = file);
  }

  Future<void> pickBannerImage() async {
    final file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;
    setState(() => bannerImage = file);
  }

  Future<void> pickCertificates() async {
    final files = await imagePicker.pickMultiImage(limit: 5);
    if (files.isEmpty || !mounted) return;
    setState(() => certificates.addAll(files));
  }

  void removeCertificateAt(int index) {
    if (index < 0 || index >= certificates.length) return;
    setState(() => certificates.removeAt(index));
  }

  void toggleHasCertificate(bool value) =>
      setState(() => hasCertificate = value);
  void toggleDay(int index, bool value) =>
      setState(() => openDays[index] = value);
  void markLocation(LatLng position) {
    setState(() {
      selectedLatLng = position;
      locationConfirmed = true;
    });
  }

  void onMapCreated(GoogleMapController controller) =>
      mapController = controller;

  Future<void> zoomInMap() async =>
      mapController?.animateCamera(CameraUpdate.zoomIn());

  Future<void> zoomOutMap() async =>
      mapController?.animateCamera(CameraUpdate.zoomOut());

  Future<void> moveToCurrentLocation({
    required void Function(String message) onError,
  }) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        onError('Location service is disabled.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        onError('Location permission is not granted.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final target = LatLng(position.latitude, position.longitude);
      markLocation(target);
      await mapController?.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 16)),
      );
    } catch (_) {
      onError('Could not fetch current location.');
    }
  }

  Future<void> pickDayTime(
    BuildContext context,
    int index, {
    required bool isStart,
  }) async {
    final initial = isStart ? startTimes[index] : endTimes[index];
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        startTimes[index] = picked;
      } else {
        endTimes[index] = picked;
      }
    });
  }

  String? firstFormError() {
    final invalidFields = formKey.currentState?.validateGranularly();
    if (invalidFields == null || invalidFields.isEmpty) return null;
    return invalidFields.first.errorText;
  }

  bool validateCurrentStep() {
    switch (currentStep) {
      case 0:
        final formState = formKey.currentState;
        if (formState == null || !formState.validate()) return false;
        return profileImage != null && bannerImage != null;
      case 1:
        if (!hasCertificate) return true;
        return certificates.isNotEmpty;
      case 2:
        return locationConfirmed;
      case 3:
        return openDays.any((e) => e);
      default:
        return false;
    }
  }

  void nextStepOrFinish(BuildContext context) {
    if (!validateCurrentStep()) return;
    setState(() => completedSteps[currentStep] = true);
    if (currentStep < 3) {
      setState(() => currentStep++);
      return;
    }
    showGlobalSuccessFeedback(
      context,
      title: TranslationKeys.createRestaurantCreatedSuccessTitle.tr(
        context: context,
      ),
      message: TranslationKeys.createRestaurantCreatedSuccessMessage.tr(
        context: context,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    phonePrimaryController.dispose();
    phoneSecondaryController.dispose();
    mapController?.dispose();
    super.dispose();
  }
}
