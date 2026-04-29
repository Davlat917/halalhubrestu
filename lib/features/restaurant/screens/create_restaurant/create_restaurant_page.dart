import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/mixins/validation_mixin.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/bloc/restaurant_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_create/vendor_create_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_me/vendor_me_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';
import 'package:halalhub_restaurant/features/restaurant/mixins/restaurant_action_mixin.dart';
import 'package:halalhub_restaurant/features/restaurant/navigation/post_auth_vendor_navigation.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/mixins/create_restaurant_bloc_listener_mixin.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/sections/basic_info_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/sections/documents_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/sections/location_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/sections/work_hours_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/widgets/pending_approval_spinner.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/widgets/restaurant_step_indicator.dart';
import 'package:halalhub_restaurant/features/restaurant/services/restaurant_map_service.dart';

@RoutePage()
class CreateRestaurantPage extends ResponsiveSection {
  const CreateRestaurantPage({super.key, this.isEdit = false});

  final bool isEdit;

  @override
  Widget buildMobile(BuildContext context) => BlocProvider(
    create: (_) => getIt<RestaurantBloc>(),
    child: Scaffold(
      body: CreateRestaurantBody(isEdit: isEdit), //
    ),
  );

  @override
  Widget? buildMobileLandscape(BuildContext context) => BlocProvider(
    create: (_) => getIt<RestaurantBloc>(),
    child: Scaffold(body: CreateRestaurantBody(compact: true, isEdit: isEdit)),
  );

  @override
  Widget buildTablet(BuildContext context) => BlocProvider(
    create: (_) => getIt<RestaurantBloc>(),
    child: Scaffold(
      body: CreateRestaurantBody(isTablet: true, isEdit: isEdit), //
    ),
  );

  @override
  Widget? buildTabletLandscape(BuildContext context) => BlocProvider(
    create: (_) => getIt<RestaurantBloc>(),
    child: Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     getIt<Storage>().token.delete();
      //   },
      // ),
      body: CreateRestaurantBody(isTablet: true, compact: true, isEdit: isEdit), //
    ),
  );
}

class CreateRestaurantBody extends StatefulWidget {
  const CreateRestaurantBody({super.key, this.isTablet = false, this.compact = false, this.isEdit = false});

  final bool isTablet;
  final bool compact;
  final bool isEdit;

  @override
  State<CreateRestaurantBody> createState() => _CreateRestaurantBodyState();
}

class _CreateRestaurantBodyState extends State<CreateRestaurantBody> with ValidationMixin, RestaurantActionMixin<CreateRestaurantBody>, CreateRestaurantBlocListenerMixin {
  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final _mapService = getIt<RestaurantMapService>();
  final _display = getIt<Display>();
  bool _loadingInitialVendor = false;
  bool _showPendingFromVendorStatus = false;
  String? _existingProfileUrl;
  String? _existingBannerUrl;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _prefillFromVendor();
    } else {
      _resolvePendingFromVendorStatus();
    }
  }

  Future<void> _resolvePendingFromVendorStatus() async {
    setState(() => _loadingInitialVendor = true);
    try {
      final vendor = await getIt<RestaurantRepo>().getVendorMe();
      if (!mounted) return;
      setState(() => _showPendingFromVendorStatus = vendor.isActive != true);
    } catch (e) {
      if (!mounted) return;
      final code = e is NetworkException ? e.statusCode : null;
      // 401 (user_inactive) bo'lsa pendingni ko'rsatamiz, 400/404 da create form ochiq qoladi.
      if (code == 401) {
        setState(() => _showPendingFromVendorStatus = true);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingInitialVendor = false);
      }
    }
  }

  Future<void> _prefillFromVendor() async {
    setState(() => _loadingInitialVendor = true);
    try {
      final vendor = await getIt<RestaurantRepo>().getVendorMe();
      if (!mounted) return;
      _applyVendorData(vendor);
    } catch (_) {
      if (!mounted) return;
      _display.error(TranslationKeys.createRestaurantLoadEditFailed.tr(context: context));
    } finally {
      if (mounted) {
        setState(() => _loadingInitialVendor = false);
      }
    }
  }

  void _applyVendorData(VendorMeModel vendor) {
    _existingProfileUrl = vendor.logoUrl ?? vendor.logo;
    _existingBannerUrl = vendor.coverUrl ?? vendor.coverImage;
    nameController.text = vendor.name ?? '';
    emailController.text = vendor.email ?? '';
    descriptionController.text = vendor.description ?? '';
    addressController.text = vendor.address ?? '';
    phonePrimaryController.text = vendor.phoneNumber1 ?? '';
    phoneSecondaryController.text = vendor.phoneNumber2 ?? '';

    final lat = double.tryParse(vendor.latitude ?? '');
    final lng = double.tryParse(vendor.longitude ?? '');
    if (lat != null && lng != null) {
      selectedLatLng = LatLng(lat, lng);
      locationConfirmed = true;
      completedSteps[2] = true;
    }

    final map = {for (final w in vendor.workdays) w.day: w};
    for (var i = 0; i < _days.length; i++) {
      final w = map[_days[i]];
      if (w == null) continue;
      openDays[i] = (w.status ?? '').toLowerCase() == 'open';
      final from = _parseTime(w.fromTime);
      final to = _parseTime(w.toTime);
      if (from != null) startTimes[i] = from;
      if (to != null) endTimes[i] = to;
    }
    completedSteps[3] = openDays.any((e) => e);
    hasCertificate = false;
    completedSteps[0] = true;
    completedSteps[1] = true;
    setState(() {});
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

  void _removeProfileImage() {
    setState(() {
      profileImage = null;
      _existingProfileUrl = null;
    });
  }

  void _removeBannerImage() {
    setState(() {
      bannerImage = null;
      _existingBannerUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingInitialVendor) {
      return const Center(child: CircularProgressIndicator(color: StaticColors.primary));
    }
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = widget.isTablet ? (widget.compact ? width * 0.84 : width * 0.72) : width;
    final outerPadding = EdgeInsets.all(context.wOf(12, cardWidth));
    return BlocConsumer<RestaurantBloc, RestaurantState>(
      listener: (context, state) {
        listenCreateRestaurant(context, state);
        if (state is RestaurantCreateSuccess) {
          _handlePostCreateStatus();
        }
      },
      builder: (context, state) => SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: cardWidth),
            child: state is RestaurantPendingApproval || _showPendingFromVendorStatus
                ? RefreshIndicator(
                    onRefresh: () => _onRefreshVendorApproval(context),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: outerPadding,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: _pendingApprovalView(cardWidth),
                          ),
                        );
                      },
                    ),
                  )
                : SingleChildScrollView(
                    padding: outerPadding,
                    child: Container(
                      padding: EdgeInsets.all(context.wOf(14, cardWidth)),
                      decoration: BoxDecoration(
                        color: StaticColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: StaticColors.cE2E2E2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isEdit ? TranslationKeys.createRestaurantUpdateTitle.tr(context: context) : TranslationKeys.createRestaurantTitle.tr(context: context),
                            style: AppTextStyle.semibold24(context, aW: cardWidth, color: StaticColors.black),
                          ),
                          SizedBox(height: context.wOf(14, cardWidth)),
                          RestaurantStepIndicator(
                            currentStep: currentStep,
                            completedSteps: completedSteps,
                            availableWidth: cardWidth,
                            onStepTap: (i) {
                              if (i <= currentStep || completedSteps.take(i).every((e) => e)) {
                                setState(() => currentStep = i);
                              }
                            },
                          ),
                          SizedBox(height: context.wOf(14, cardWidth)),
                          _stepView(cardWidth),
                          if (widget.isEdit) ...[SizedBox(height: context.wOf(18, cardWidth)), _updateButton(context, cardWidth)],
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePostCreateStatus() async {
    if (_loadingInitialVendor) return;
    setState(() => _loadingInitialVendor = true);
    try {
      final vendor = await getIt<RestaurantRepo>().getVendorMe();
      if (!mounted) return;
      if (vendor.isActive == true) {
        await context.router.replace(const VendorProfileRoute());
        return;
      }
      setState(() => _showPendingFromVendorStatus = true);
    } catch (e) {
      if (!mounted) return;
      final code = e is NetworkException ? e.statusCode : null;
      if (code == 401 || code == 400 || code == 404) {
        setState(() => _showPendingFromVendorStatus = true);
      } else {
        final msg = e is NetworkException ? e.message : e.toString();
        _display.error(msg);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingInitialVendor = false);
      }
    }
  }

  /// Admin tasdig‘idan keyin `vendors/me` → `is_active: true` bo‘lsa asosiy profilga o‘tadi.
  Future<void> _onRefreshVendorApproval(BuildContext context) async {
    try {
      await refreshVendorMeAndGoToProfileIfActive();
    } catch (e) {
      if (!context.mounted) return;
      final code = e is NetworkException ? e.statusCode : null;
      // 400/404 — vendor yo‘q; 401 (masalan user_inactive) — hali admin tasdig‘i; sessiz qolamiz.
      if (code != 400 && code != 404 && code != 401) {
        final msg = e is NetworkException ? e.message : e.toString();
        _display.error(msg);
      }
    }
  }

  Widget _pendingApprovalView(double width) {
    return Center(
      child: Container(
        width: width > 700 ? width * 0.55 : width,
        padding: EdgeInsets.symmetric(vertical: context.wOf(28, width), horizontal: context.wOf(16, width)),
        decoration: BoxDecoration(
          color: StaticColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: StaticColors.cE0E0E0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.wOf(40, width),
              height: context.wOf(40, width),
              decoration: BoxDecoration(color: StaticColors.cEAF8EF, borderRadius: BorderRadius.circular(10)),
              child: const PendingApprovalSpinner(),
            ),
            SizedBox(height: context.wOf(14, width)),
            Text(
              TranslationKeys.createRestaurantPleaseWait.tr(context: context),
              style: AppTextStyle.medium20(context, aW: width, color: StaticColors.primary),
            ),
            SizedBox(height: context.wOf(8, width)),
            Text(
              TranslationKeys.createRestaurantWaitForApproval.tr(context: context),
              textAlign: TextAlign.center,
              style: AppTextStyle.regular14(context, aW: width, color: StaticColors.c9AA0A6),
            ),
            SizedBox(height: context.wOf(16, width)),
            Text(
              TranslationKeys.createRestaurantPullToRefreshStatus.tr(context: context),
              textAlign: TextAlign.center,
              style: AppTextStyle.regular12(context, aW: width, color: StaticColors.cBDC1C6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepView(double width) {
    return switch (currentStep) {
      0 => BasicInfoSection(
        availableWidth: width,
        isTablet: widget.isTablet,
        compact: widget.compact,
        showCategorySection: widget.isEdit,
        formKey: formKey,
        profileImagePath: profileImage?.path ?? _existingProfileUrl,
        bannerImagePath: bannerImage?.path ?? _existingBannerUrl,
        onPickProfileImage: pickProfileImage,
        onPickBannerImage: pickBannerImage,
        onDeleteProfileImage: _removeProfileImage,
        onDeleteBannerImage: _removeBannerImage,
        nameController: nameController,
        emailController: emailController,
        descriptionController: descriptionController,
        addressController: addressController,
        phonePrimaryController: phonePrimaryController,
        phoneSecondaryController: phoneSecondaryController,
        validateName: validateName,
        validateEmail: validateEmail,
        validateRequired: validateRequired,
        validateUsPhone: validateUsPhone,
        continueButton: widget.isEdit ? const SizedBox.shrink() : _nextButton(context, width, TranslationKeys.createRestaurantContinue.tr(context: context)),
      ),
      1 => DocumentsSection(
        availableWidth: width,
        hasCertificate: hasCertificate,
        certificates: certificates,
        toggleHasCertificate: toggleHasCertificate,
        pickCertificates: pickCertificates,
        removeCertificateAt: removeCertificateAt,
        continueButton: widget.isEdit ? const SizedBox.shrink() : _nextButton(context, width, TranslationKeys.createRestaurantContinue.tr(context: context)),
      ),
      2 => LocationSection(
        availableWidth: width,
        isTablet: widget.isTablet,
        locationConfirmed: locationConfirmed,
        selectedLatLng: selectedLatLng,
        mapService: _mapService,
        onMapCreated: onMapCreated,
        onMapTap: markLocation,
        zoomIn: zoomInMap,
        zoomOut: zoomOutMap,
        myLocationTap: () {
          moveToCurrentLocation(onError: (message) => _display.warning(message));
        },
        continueButton: widget.isEdit ? const SizedBox.shrink() : _nextButton(context, width, TranslationKeys.createRestaurantContinue.tr(context: context)),
      ),
      _ => WorkHoursSection(
        availableWidth: width,
        days: _days,
        openDays: openDays,
        startTimes: startTimes,
        endTimes: endTimes,
        toggleDay: (index, value) => toggleDay(index, value),
        onPickStart: (index) => pickDayTime(context, index, isStart: true),
        onPickEnd: (index) => pickDayTime(context, index, isStart: false),
        completeButton: widget.isEdit ? const SizedBox.shrink() : _nextButton(context, width, TranslationKeys.createRestaurantCompleteSetup.tr(context: context)),
      ),
    };
  }

  Widget _nextButton(BuildContext context, double width, String label) {
    final isSubmitting = context.watch<RestaurantBloc>().state is RestaurantLoading;
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        label: label,
        isLoading: currentStep == 3 && isSubmitting,
        textStyle: AppTextStyle.medium16(context, aW: width, color: StaticColors.white),
        onPressed: isSubmitting
            ? null
            : () {
                final hasProfile = profileImage != null || (_existingProfileUrl ?? '').isNotEmpty;
                final hasBanner = bannerImage != null || (_existingBannerUrl ?? '').isNotEmpty;
                final valid = currentStep == 0 && widget.isEdit ? (formKey.currentState?.validate() ?? false) && hasProfile && hasBanner : validateCurrentStep();
                if (!valid) {
                  final formErr = firstFormError();
                  final msg =
                      formErr ??
                      switch (currentStep) {
                        0 => TranslationKeys.createRestaurantFillRequired.tr(context: context),
                        1 => TranslationKeys.createRestaurantUploadOneCertificate.tr(context: context),
                        2 => TranslationKeys.createRestaurantChooseLocation.tr(context: context),
                        _ => TranslationKeys.createRestaurantOneDayOpen.tr(context: context),
                      };
                  _display.warning(msg);
                  return;
                }
                if (currentStep == 3) {
                  setState(() => completedSteps[currentStep] = true);
                  _submitVendor(context);
                  return;
                }
                nextStepOrFinish(context);
              },
      ),
    );
  }

  Widget _updateButton(BuildContext context, double width) {
    final isSubmitting = context.watch<RestaurantBloc>().state is RestaurantLoading;
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        label: TranslationKeys.updateProfile.tr(context: context),
        isLoading: isSubmitting,
        textStyle: AppTextStyle.medium16(context, aW: width, color: StaticColors.white),
        onPressed: isSubmitting
            ? null
            : () {
                final hasProfile = profileImage != null || (_existingProfileUrl ?? '').isNotEmpty;
                final hasBanner = bannerImage != null || (_existingBannerUrl ?? '').isNotEmpty;
                if ((formKey.currentState?.validate() ?? false) == false) {
                  _display.warning(firstFormError() ?? TranslationKeys.createRestaurantFillFields.tr(context: context));
                  return;
                }
                if (!hasProfile || !hasBanner) {
                  _display.warning(TranslationKeys.createRestaurantKeepProfileBanner.tr(context: context));
                  return;
                }
                if (!locationConfirmed) {
                  _display.warning(TranslationKeys.createRestaurantChooseLocation.tr(context: context));
                  return;
                }
                if (!openDays.any((e) => e)) {
                  _display.warning(TranslationKeys.createRestaurantOneDayOpen.tr(context: context));
                  return;
                }
                if (hasCertificate && certificates.isEmpty) {
                  _display.warning(TranslationKeys.createRestaurantUploadOneCertificate.tr(context: context));
                  return;
                }
                _submitVendor(context);
              },
      ),
    );
  }

  void _submitVendor(BuildContext context) {
    final payload = VendorCreateModel(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phoneNumber1: phonePrimaryController.text.trim(),
      phoneNumber2: phoneSecondaryController.text.trim(),
      description: descriptionController.text.trim(),
      address: addressController.text.trim(),
      latitude: _formatCoordinate(selectedLatLng?.latitude),
      longitude: _formatCoordinate(selectedLatLng?.longitude),
      categories: const [],
      workdays: List.generate(_days.length, (i) => Workday(day: _days[i], fromTime: _formatTime24(startTimes[i]), toTime: _formatTime24(endTimes[i]), status: openDays[i] ? 'Open' : 'Closed')),
    );

    if (widget.isEdit) {
      context.read<RestaurantBloc>().add(VendorUpdateSubmitted(payload: payload, profileImage: profileImage, bannerImage: bannerImage, certificateFiles: certificates));
    } else {
      context.read<RestaurantBloc>().add(VendorCreateSubmitted(payload: payload, profileImage: profileImage, bannerImage: bannerImage, certificateFiles: certificates));
    }
  }

  String _formatTime24(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  String? _formatCoordinate(double? value) {
    if (value == null) return null;
    final fixed = value.toStringAsFixed(6);
    return fixed.contains('.') ? fixed.replaceFirst(RegExp(r'\.?0+$'), '') : fixed;
  }
}
