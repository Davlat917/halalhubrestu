import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/core/widgets/feedback/global_feedback_dialog.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/update_restaurant/bloc/update_restaurant_cubit.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/update_restaurant/mixins/update_restaurant_validation_mixin.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/update_restaurant/sections/basic_info_update_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/update_restaurant/sections/category_update_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/update_restaurant/sections/documents_update_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/update_restaurant/sections/location_update_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/update_restaurant/sections/work_hours_update_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/update_restaurant/widgets/update_restaurant_tab_bar.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/update_restaurant/widgets/update_restaurant_top_bar.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/widgets/upload_pick_tile.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/maps_places_repo.dart';
import 'package:halalhub_restaurant/features/restaurant/services/restaurant_map_service.dart';

@RoutePage()
class UpdateRestaurantPage extends ResponsiveSection {
  const UpdateRestaurantPage({super.key});

  @override
  Widget buildMobile(BuildContext context) => const _UpdateRestaurantProvider();

  @override
  Widget? buildMobileLandscape(BuildContext context) =>
      const _UpdateRestaurantProvider();

  @override
  Widget buildTablet(BuildContext context) => const _UpdateRestaurantProvider();

  @override
  Widget? buildTabletLandscape(BuildContext context) =>
      const _UpdateRestaurantProvider();
}

class _UpdateRestaurantProvider extends StatelessWidget {
  const _UpdateRestaurantProvider();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UpdateRestaurantCubit(getIt())..load(),
      child: const _UpdateRestaurantScaffold(),
    );
  }
}

class _UpdateRestaurantScaffold extends StatefulWidget {
  const _UpdateRestaurantScaffold();

  @override
  State<_UpdateRestaurantScaffold> createState() =>
      _UpdateRestaurantScaffoldState();
}

class _UpdateRestaurantScaffoldState extends State<_UpdateRestaurantScaffold>
    with UpdateRestaurantValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _mapService = getIt<RestaurantMapService>();
  final _placesRepo = getIt<MapsPlacesRepo>();

  bool _validate(UpdateRestaurantState state) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      showGlobalFailureFeedback(
        context,
        message: TranslationKeys.createRestaurantFillFields.tr(
          context: context,
        ),
      );
      return false;
    }
    if (!state.locationConfirmed) {
      showGlobalFailureFeedback(
        context,
        message: TranslationKeys.createRestaurantChooseLocation.tr(
          context: context,
        ),
      );
      return false;
    }
    if (!state.openDays.any((e) => e)) {
      showGlobalFailureFeedback(
        context,
        message: TranslationKeys.createRestaurantOneDayOpen.tr(
          context: context,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final orientation = MediaQuery.orientationOf(context);
    final isTabletLandscape = orientation == Orientation.landscape && w >= 900;
    return BlocListener<UpdateRestaurantCubit, UpdateRestaurantState>(
      listenWhen: (p, c) =>
          p.errorMessage != c.errorMessage ||
          p.successMessage != c.successMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          showGlobalFailureFeedback(context, message: state.errorMessage!);
        }
        if (state.successMessage != null) {
          context.router.pop(true);
        }
      },
      child: Scaffold(
        backgroundColor: StaticColors.white,
        body: SafeArea(
          child: Column(
            children: [
              const UpdateRestaurantTopBar(),
              if (!isTabletLandscape) const UpdateRestaurantTabBar(),
              Expanded(
                child:
                    BlocBuilder<UpdateRestaurantCubit, UpdateRestaurantState>(
                      buildWhen: (p, c) =>
                          p.loading != c.loading || p.tab != c.tab,
                      builder: (context, state) {
                        if (state.loading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: StaticColors.primary,
                            ),
                          );
                        }
                        return SingleChildScrollView(
                          padding: EdgeInsets.all(context.wOf(12, w)),
                          child: Form(
                            key: _formKey,
                            child: isTabletLandscape
                                ? _tabletLandscapeBody()
                                : _sectionForTab(state.tab),
                          ),
                        );
                      },
                    ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.wOf(12, w),
                  context.wOf(8, w),
                  context.wOf(12, w),
                  context.wOf(14, w),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: isTabletLandscape ? 300 : double.infinity,
                    child:
                        BlocBuilder<
                          UpdateRestaurantCubit,
                          UpdateRestaurantState
                        >(
                          buildWhen: (p, c) =>
                              p.submitting != c.submitting ||
                              p.loading != c.loading,
                          builder: (context, state) {
                            return CustomButton(
                              label: TranslationKeys.saveChanges.tr(
                                context: context,
                              ),
                              height: 44,
                              textStyle: AppTextStyle.medium14(context),
                              isLoading: state.submitting,
                              onPressed: state.submitting || state.loading
                                  ? null
                                  : () {
                                      final cubit = context
                                          .read<UpdateRestaurantCubit>();
                                      final latestState = cubit.state;
                                      if (_validate(latestState)) {
                                        cubit.submit();
                                      }
                                    },
                            );
                          },
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionForTab(UpdateRestaurantTab tab) {
    return switch (tab) {
      UpdateRestaurantTab.basic => BasicInfoUpdateSection(
        validateName: validateName,
        validateEmail: validateEmail,
        validateRequired: validateRequired,
        validateOptionalUsPhone: validateOptionalUsPhone, //
      ),
      UpdateRestaurantTab.documents => const DocumentsUpdateSection(),
      UpdateRestaurantTab.location => LocationUpdateSection(
        mapService: _mapService,
        placesRepo: _placesRepo,
      ),
      UpdateRestaurantTab.workHours => WorkHoursUpdateSection(
        pickTime: pickTime,
      ),
    };
  }

  Widget _tabletLandscapeBody() {
    return Column(
      children: [
        BlocBuilder<UpdateRestaurantCubit, UpdateRestaurantState>(
          buildWhen: (p, c) =>
              p.profileUrl != c.profileUrl ||
              p.bannerUrl != c.bannerUrl ||
              p.profileImage?.path != c.profileImage?.path ||
              p.bannerImage?.path != c.bannerImage?.path,
          builder: (context, state) {
            final w = MediaQuery.sizeOf(context).width;
            final cubit = context.read<UpdateRestaurantCubit>();
            return Row(
              children: [
                Expanded(
                  child: UploadPickTile(
                    availableWidth: w,
                    title:
                        (state.profileImage != null ||
                            (state.profileUrl ?? '').isNotEmpty)
                        ? TranslationKeys.updateProfileImageSelected.tr(
                            context: context,
                          )
                        : TranslationKeys.updateUploadProfileImage.tr(
                            context: context,
                          ),
                    imagePath: state.profileImage?.path ?? state.profileUrl,
                    onPressed: cubit.pickProfileImage,
                    height: 150,
                    useDashedBorder: true,
                    emptyIconAssetPath: 'assets/images/add_image_icon.png',
                    hideIconInLandscape: false,
                    compactInLandscape: false,
                    onDeleteImage:
                        (state.profileImage != null ||
                            (state.profileUrl ?? '').isNotEmpty)
                        ? cubit.removeProfileImage
                        : null, //
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: UploadPickTile(
                    availableWidth: w,
                    title:
                        (state.bannerImage != null ||
                            (state.bannerUrl ?? '').isNotEmpty)
                        ? TranslationKeys.updateBannerSelected.tr(
                            context: context,
                          )
                        : TranslationKeys.updateAddBannerImage.tr(
                            context: context,
                          ),
                    subtitle: TranslationKeys.updateOptimalDimensions.tr(
                      context: context,
                    ),
                    imagePath: state.bannerImage?.path ?? state.bannerUrl,
                    onPressed: cubit.pickBannerImage,
                    height: 150,
                    useDashedBorder: true,
                    emptyIconAssetPath: 'assets/images/add_image_icon.png',
                    hideIconInLandscape: false,
                    compactInLandscape: false,
                    onDeleteImage:
                        (state.bannerImage != null ||
                            (state.bannerUrl ?? '').isNotEmpty)
                        ? cubit.removeBannerImage
                        : null, //
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  BasicInfoUpdateSection(
                    validateName: validateName,
                    validateEmail: validateEmail,
                    validateRequired: validateRequired,
                    validateOptionalUsPhone: validateOptionalUsPhone,
                    showCategory: false,
                    showMediaRow: false, //
                  ),
                  const SizedBox(height: 14),
                  LocationUpdateSection(
                    mapService: _mapService,
                    placesRepo: _placesRepo,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                children: [
                  const DocumentsUpdateSection(uploadTileHeight: 150),
                  const SizedBox(height: 14),
                  WorkHoursUpdateSection(pickTime: pickTime),
                  const SizedBox(height: 14),
                  const CategoryUpdateSection(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
