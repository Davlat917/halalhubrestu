import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_category/vendor_category_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_create/vendor_create_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_me/vendor_me_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';
import 'package:image_picker/image_picker.dart';

enum UpdateRestaurantTab { basic, documents, location, workHours }

class UpdateRestaurantState extends Equatable {
  const UpdateRestaurantState({
    this.loading = true,
    this.submitting = false,
    this.tab = UpdateRestaurantTab.basic,
    this.name = '',
    this.email = '',
    this.description = '',
    this.address = '',
    this.phone1 = '',
    this.phone2 = '',
    this.profileUrl,
    this.bannerUrl,
    this.profileImage,
    this.bannerImage,
    this.deleteProfile = false,
    this.deleteBanner = false,
    this.hasCertificate = false,
    this.certificateFiles = const [],
    this.existingCertificates = const [],
    this.categories = const [],
    this.selectedCategoryIds = const [],
    this.deletedCertificateIds = const [],
    this.avgDeliveryTime = '',
    this.locationConfirmed = false,
    this.selectedLatLng,
    this.openDays = const [true, true, true, true, true, true, false],
    this.startTimes = const [
      TimeOfDay(hour: 9, minute: 0),
      TimeOfDay(hour: 9, minute: 0),
      TimeOfDay(hour: 9, minute: 0),
      TimeOfDay(hour: 9, minute: 0),
      TimeOfDay(hour: 9, minute: 0),
      TimeOfDay(hour: 9, minute: 0),
      TimeOfDay(hour: 9, minute: 0),
    ],
    this.endTimes = const [
      TimeOfDay(hour: 23, minute: 59),
      TimeOfDay(hour: 23, minute: 59),
      TimeOfDay(hour: 23, minute: 59),
      TimeOfDay(hour: 23, minute: 59),
      TimeOfDay(hour: 23, minute: 59),
      TimeOfDay(hour: 23, minute: 59),
      TimeOfDay(hour: 23, minute: 59),
    ],
    this.errorMessage,
    this.successMessage,
  });

  final bool loading;
  final bool submitting;
  final UpdateRestaurantTab tab;
  final String name;
  final String email;
  final String description;
  final String address;
  final String phone1;
  final String phone2;
  final String? profileUrl;
  final String? bannerUrl;
  final XFile? profileImage;
  final XFile? bannerImage;
  final bool deleteProfile;
  final bool deleteBanner;
  final bool hasCertificate;
  final List<XFile> certificateFiles;
  final List<VendorCertificateMe> existingCertificates;
  final List<VendorCategoryModel> categories;
  final List<int> selectedCategoryIds;
  final List<int> deletedCertificateIds;
  final String avgDeliveryTime;
  final bool locationConfirmed;
  final LatLng? selectedLatLng;
  final List<bool> openDays;
  final List<TimeOfDay> startTimes;
  final List<TimeOfDay> endTimes;
  final String? errorMessage;
  final String? successMessage;

  UpdateRestaurantState copyWith({
    bool? loading,
    bool? submitting,
    UpdateRestaurantTab? tab,
    String? name,
    String? email,
    String? description,
    String? address,
    String? phone1,
    String? phone2,
    String? profileUrl,
    String? bannerUrl,
    XFile? profileImage,
    XFile? bannerImage,
    bool? deleteProfile,
    bool? deleteBanner,
    bool? hasCertificate,
    List<XFile>? certificateFiles,
    List<VendorCertificateMe>? existingCertificates,
    List<VendorCategoryModel>? categories,
    List<int>? selectedCategoryIds,
    List<int>? deletedCertificateIds,
    String? avgDeliveryTime,
    bool? locationConfirmed,
    LatLng? selectedLatLng,
    List<bool>? openDays,
    List<TimeOfDay>? startTimes,
    List<TimeOfDay>? endTimes,
    String? errorMessage,
    String? successMessage,
    bool clearProfileUrl = false,
    bool clearBannerUrl = false,
    bool clearProfileImage = false,
    bool clearBannerImage = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return UpdateRestaurantState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      tab: tab ?? this.tab,
      name: name ?? this.name,
      email: email ?? this.email,
      description: description ?? this.description,
      address: address ?? this.address,
      phone1: phone1 ?? this.phone1,
      phone2: phone2 ?? this.phone2,
      profileUrl: clearProfileUrl ? null : (profileUrl ?? this.profileUrl),
      bannerUrl: clearBannerUrl ? null : (bannerUrl ?? this.bannerUrl),
      profileImage: clearProfileImage
          ? null
          : (profileImage ?? this.profileImage),
      bannerImage: clearBannerImage ? null : (bannerImage ?? this.bannerImage),
      deleteProfile: deleteProfile ?? this.deleteProfile,
      deleteBanner: deleteBanner ?? this.deleteBanner,
      hasCertificate: hasCertificate ?? this.hasCertificate,
      certificateFiles: certificateFiles ?? this.certificateFiles,
      existingCertificates: existingCertificates ?? this.existingCertificates,
      categories: categories ?? this.categories,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      deletedCertificateIds:
          deletedCertificateIds ?? this.deletedCertificateIds,
      avgDeliveryTime: avgDeliveryTime ?? this.avgDeliveryTime,
      locationConfirmed: locationConfirmed ?? this.locationConfirmed,
      selectedLatLng: selectedLatLng ?? this.selectedLatLng,
      openDays: openDays ?? this.openDays,
      startTimes: startTimes ?? this.startTimes,
      endTimes: endTimes ?? this.endTimes,
      errorMessage: clearError ? null : errorMessage,
      successMessage: clearSuccess ? null : successMessage,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    submitting,
    tab,
    name,
    email,
    description,
    address,
    phone1,
    phone2,
    profileUrl,
    bannerUrl,
    profileImage?.path,
    bannerImage?.path,
    deleteProfile,
    deleteBanner,
    hasCertificate,
    certificateFiles.map((e) => e.path).toList(),
    existingCertificates.map((e) => '${e.id}-${e.file}').toList(),
    categories.map((e) => '${e.id}-${e.name}').toList(),
    selectedCategoryIds,
    deletedCertificateIds,
    avgDeliveryTime,
    locationConfirmed,
    selectedLatLng?.latitude,
    selectedLatLng?.longitude,
    openDays,
    startTimes,
    endTimes,
    errorMessage,
    successMessage,
  ];
}

class UpdateRestaurantCubit extends Cubit<UpdateRestaurantState> {
  UpdateRestaurantCubit(this._repo) : super(const UpdateRestaurantState());

  final RestaurantRepo _repo;
  final ImagePicker _picker = ImagePicker();
  static const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true, clearSuccess: true));
    try {
      final v = await _repo.getVendorMe();
      List<VendorCategoryModel> categoryOptions = const [];
      try {
        categoryOptions = await _repo.getVendorCategories();
      } catch (_) {}
      final openDays = List<bool>.from(state.openDays);
      final start = List<TimeOfDay>.from(state.startTimes);
      final end = List<TimeOfDay>.from(state.endTimes);
      final map = {for (final d in v.workdays) d.day: d};
      for (var i = 0; i < days.length; i++) {
        final d = map[days[i]];
        if (d == null) continue;
        openDays[i] = (d.status ?? '').toLowerCase() == 'open';
        start[i] = _parseTime(d.fromTime) ?? start[i];
        end[i] = _parseTime(d.toTime) ?? end[i];
      }
      final lat = double.tryParse(v.latitude ?? '');
      final lng = double.tryParse(v.longitude ?? '');
      emit(
        state.copyWith(
          loading: false,
          name: v.name ?? '',
          email: v.email ?? '',
          description: v.description ?? '',
          address: v.address ?? '',
          phone1: v.phoneNumber1 ?? '',
          phone2: v.phoneNumber2 ?? '',
          profileUrl: v.logoUrl ?? v.logo,
          bannerUrl: v.coverUrl ?? v.coverImage,
          deleteProfile: false,
          deleteBanner: false,
          existingCertificates: v.certificates,
          hasCertificate: v.certificates.isNotEmpty,
          categories: categoryOptions,
          selectedCategoryIds: v.categories
              .map((e) => e.id)
              .whereType<int>()
              .toList(),
          selectedLatLng: lat != null && lng != null
              ? LatLng(lat, lng)
              : state.selectedLatLng,
          locationConfirmed: lat != null && lng != null,
          openDays: openDays,
          startTimes: start,
          endTimes: end,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: 'Failed to load vendor profile.',
        ),
      );
    }
  }

  void changeTab(UpdateRestaurantTab tab) => emit(state.copyWith(tab: tab));
  void setName(String value) => emit(state.copyWith(name: value));
  void setEmail(String value) => emit(state.copyWith(email: value));
  void setDescription(String value) => emit(state.copyWith(description: value));
  void setAddress(String value) => emit(state.copyWith(address: value));
  void setPhone1(String value) => emit(state.copyWith(phone1: value));
  void setPhone2(String value) => emit(state.copyWith(phone2: value));
  void setHasCertificate(bool value) =>
      emit(state.copyWith(hasCertificate: value));
  void toggleCategory(int id) {
    final list = List<int>.from(state.selectedCategoryIds);
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    emit(state.copyWith(selectedCategoryIds: list));
  }

  Future<void> pickProfileImage() async {
    final f = await _picker.pickImage(source: ImageSource.gallery);
    if (f == null) return;
    emit(
      state.copyWith(
        profileImage: f,
        clearProfileUrl: true,
        deleteProfile: false,
      ),
    );
  }

  Future<void> pickBannerImage() async {
    final f = await _picker.pickImage(source: ImageSource.gallery);
    if (f == null) return;
    emit(
      state.copyWith(bannerImage: f, clearBannerUrl: true, deleteBanner: false),
    );
  }

  void removeProfileImage() => emit(
    state.copyWith(
      clearProfileUrl: true,
      clearProfileImage: true,
      deleteProfile: true,
    ),
  );
  void removeBannerImage() => emit(
    state.copyWith(
      clearBannerUrl: true,
      clearBannerImage: true,
      deleteBanner: true,
    ),
  );

  Future<void> pickCertificates() async {
    const maxFiles = 3;
    final remaining = maxFiles - state.certificateFiles.length;
    if (remaining <= 0) {
      emit(state.copyWith(errorMessage: 'Maximum 3 certificates allowed.'));
      return;
    }
    final files = await _picker.pickMultiImage(limit: remaining);
    if (files.isEmpty) return;
    final merged = [...state.certificateFiles, ...files];
    emit(state.copyWith(certificateFiles: merged.take(maxFiles).toList()));
  }

  void removeCertificateAt(int index) {
    if (index < 0 || index >= state.certificateFiles.length) return;
    final files = List<XFile>.from(state.certificateFiles)..removeAt(index);
    emit(state.copyWith(certificateFiles: files));
  }

  void removeExistingCertificate(int id) {
    final updated = state.existingCertificates
        .where((e) => e.id != id)
        .toList();
    final deleted = List<int>.from(state.deletedCertificateIds);
    if (!deleted.contains(id)) {
      deleted.add(id);
    }
    emit(
      state.copyWith(
        existingCertificates: updated,
        deletedCertificateIds: deleted,
      ),
    );
  }

  void setLocation(LatLng pos) =>
      emit(state.copyWith(selectedLatLng: pos, locationConfirmed: true));

  void setOpenDay(int index, bool value) {
    final list = List<bool>.from(state.openDays);
    list[index] = value;
    emit(state.copyWith(openDays: list));
  }

  void setStartTime(int index, TimeOfDay value) {
    final list = List<TimeOfDay>.from(state.startTimes);
    list[index] = value;
    emit(state.copyWith(startTimes: list));
  }

  void setEndTime(int index, TimeOfDay value) {
    final list = List<TimeOfDay>.from(state.endTimes);
    list[index] = value;
    emit(state.copyWith(endTimes: list));
  }

  Future<void> submit() async {
    emit(
      state.copyWith(submitting: true, clearError: true, clearSuccess: true),
    );
    try {
      final payload = VendorCreateModel(
        name: state.name.trim(),
        email: state.email.trim(),
        phoneNumber1: state.phone1.trim(),
        phoneNumber2: state.phone2.trim(),
        description: state.description.trim(),
        address: state.address.trim(),
        latitude: _coord(state.selectedLatLng?.latitude),
        longitude: _coord(state.selectedLatLng?.longitude),
        categories: const [],
        workdays: List.generate(
          days.length,
          (i) => Workday(
            day: days[i],
            fromTime: _formatTime24(state.startTimes[i]),
            toTime: _formatTime24(state.endTimes[i]),
            status: state.openDays[i] ? 'Open' : 'Closed',
          ),
        ),
      );
      await _repo.vendorUpdate(
        payload: payload,
        categoryIds: state.selectedCategoryIds,
        deletedCertificateIds: state.deletedCertificateIds,
        avgDeliveryTime: state.avgDeliveryTime,
        deleteLogo: state.deleteProfile,
        deleteBanner: state.deleteBanner,
        profileImage: state.profileImage,
        bannerImage: state.bannerImage,
        certificateFiles: state.certificateFiles,
      );
      emit(
        state.copyWith(
          submitting: false,
          successMessage: 'Restaurant updated successfully.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          submitting: false,
          errorMessage: 'Failed to update restaurant profile.',
        ),
      );
    }
  }

  String _formatTime24(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  String? _coord(double? value) {
    if (value == null) return null;
    final fixed = value.toStringAsFixed(6);
    return fixed.contains('.')
        ? fixed.replaceFirst(RegExp(r'\.?0+$'), '')
        : fixed;
  }

  TimeOfDay? _parseTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
  }
}
