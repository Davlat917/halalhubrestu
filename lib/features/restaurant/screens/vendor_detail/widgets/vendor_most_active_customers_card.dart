import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/network_image_chache.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_top_customer/vendor_top_customer_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/bloc/vendor_detail_state.dart';

const double _kTopCustomerAvatarRadius = 18;

String? _resolvedAvatarUrl(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final u = raw.trim();
  if (u.startsWith('http://') || u.startsWith('https://')) return u;
  if (u.startsWith('//')) return 'https:$u';
  if (u.startsWith('/')) return '${Constants.baseUrl}$u';
  return u;
}

class _TopCustomerRow extends StatelessWidget {
  const _TopCustomerRow({required this.index, required this.customer});

  final int index;
  final VendorTopCustomerModel customer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text('${index + 1}', style: AppTextStyle.regular14(context)),
          ),
          SizedBox(
            width: _kTopCustomerAvatarRadius * 2,
            child: Center(
              child: _TopCustomerAvatar(avatarUrl: customer.avatar),
            ),
          ),
          Expanded(
            flex: 10,
            child: Text(
              customer.displayName,
              style: AppTextStyle.regular14(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              '${customer.ordersCount}',
              style: AppTextStyle.regular14(context),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopCustomerAvatar extends StatelessWidget {
  const _TopCustomerAvatar({required this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final url = _resolvedAvatarUrl(avatarUrl);
    final d = _kTopCustomerAvatarRadius * 2;
    return CircleAvatar(
      radius: _kTopCustomerAvatarRadius,
      backgroundColor: StaticColors.cF0F0F0,
      child: ClipOval(
        child: url == null
            ? Icon(
                Icons.person_rounded,
                size: _kTopCustomerAvatarRadius,
                color: StaticColors.c666666,
              )
            : NetworkImageCache(
                imgUrl: url,
                widthW: d,
                heightH: d,
                radius: 0,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}

class _TopCustomersServerErrorView extends StatelessWidget {
  const _TopCustomersServerErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: StaticColors.primary.withAlpha(24),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: StaticColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              TranslationKeys.vendorDetailServerError.tr(context: context),
              textAlign: TextAlign.center,
              style: AppTextStyle.regular14(
                context,
                color: StaticColors.c666666,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              TranslationKeys.vendorDetailTryAgainLater.tr(context: context),
              textAlign: TextAlign.center,
              style: AppTextStyle.regular12(
                context,
                color: StaticColors.c9AA0A6,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: onRetry,
              child: Text(TranslationKeys.retry.tr(context: context)),
            ),
          ],
        ),
      ),
    );
  }
}

class VendorMostActiveCustomersCard extends StatelessWidget {
  const VendorMostActiveCustomersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: .center,
            children: [
              SvgPicture.asset(
                'assets/icons/analitic_icon.svg',
                width: 16,
                height: 16,
              ),
              const SizedBox(width: 6),
              Text(
                TranslationKeys.vendorDetailMostActiveCustomers.tr(
                  context: context,
                ),
                style: AppTextStyle.regular14(
                  context,
                  color: StaticColors.c9AA0A6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '#',
                  style: AppTextStyle.semibold14(
                    context,
                    color: StaticColors.black,
                  ),
                ),
              ),
              const SizedBox(width: _kTopCustomerAvatarRadius * 2),
              Expanded(
                flex: 10,
                child: Text(
                  TranslationKeys.vendorDetailCustomer.tr(context: context),
                  style: AppTextStyle.semibold14(
                    context,
                    color: StaticColors.black,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  TranslationKeys.vendorDetailOrderCount.tr(context: context),
                  style: AppTextStyle.semibold14(
                    context,
                    color: StaticColors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<VendorDetailBloc, VendorDetailState>(
              buildWhen: (previous, current) {
                return previous.topCustomersStatus !=
                        current.topCustomersStatus ||
                    previous.topCustomers != current.topCustomers ||
                    previous.topCustomersError != current.topCustomersError;
              },
              builder: (context, state) {
                void retry() {
                  context.read<VendorDetailBloc>().add(
                    const VendorDetailTopCustomersRequested(),
                  );
                }

                if (state.topCustomersStatus ==
                    VendorDetailLoadStatus.failure) {
                  if (state.topCustomersError ==
                      TranslationKeys.networkServerError.tr()) {
                    return _TopCustomersServerErrorView(onRetry: retry);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.topCustomersError ??
                            TranslationKeys.vendorDetailFailedLoadCustomers.tr(
                              context: context,
                            ),
                        style: AppTextStyle.regular14(
                          context,
                          color: StaticColors.c9AA0A6,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: retry,
                        child: Text(TranslationKeys.retry.tr(context: context)),
                      ),
                    ],
                  );
                }

                if (state.topCustomersStatus ==
                        VendorDetailLoadStatus.initial ||
                    state.topCustomersStatus ==
                        VendorDetailLoadStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                if (state.topCustomers.isEmpty) {
                  return Center(
                    child: Text(
                      TranslationKeys.vendorDetailNoData.tr(context: context),
                      style: AppTextStyle.regular14(
                        context,
                        color: StaticColors.c9AA0A6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.separated(
                  physics: const ClampingScrollPhysics(),
                  itemCount: state.topCustomers.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    thickness: 1,
                    color: StaticColors.cE2E2E2,
                  ),
                  itemBuilder: (context, i) {
                    final c = state.topCustomers[i];
                    return _TopCustomerRow(index: i, customer: c);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
