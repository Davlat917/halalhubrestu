import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/circle_btn_widget.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/models/vendor_finance_period.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/repositories/finance_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/screens/finance_transactions/bloc/finance_transactions_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/screens/finance_transactions/bloc/finance_transactions_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/screens/finance_transactions/widgets/finance_transactions_body_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/screens/finance_transactions/widgets/finance_transactions_pdf_download_bar.dart';

@RoutePage()
class FinanceTransactionsPage extends ResponsiveSection {
  const FinanceTransactionsPage({
    super.key,
    @QueryParam('period') this.period = 'weekly',
  });

  final String period;

  VendorFinancePeriod get _initialPeriod =>
      VendorFinancePeriod.fromApiValue(period);

  @override
  Widget buildMobile(BuildContext context) => BlocProvider(
        create: (_) => FinanceTransactionsBloc(getIt<FinanceRepository>())
          ..add(FinanceTransactionsLoadRequested(period: _initialPeriod)),
        child: const _FinanceTransactionsScaffold(
          maxContentWidth: null,
          columnCount: 1,
        ),
      );

  @override
  Widget buildTablet(BuildContext context) => BlocProvider(
        create: (_) => FinanceTransactionsBloc(getIt<FinanceRepository>())
          ..add(FinanceTransactionsLoadRequested(period: _initialPeriod)),
        child: const _FinanceTransactionsScaffold(
          maxContentWidth: 720,
          columnCount: 2,
        ),
      );

  @override
  Widget? buildTabletLandscape(BuildContext context) => BlocProvider(
        create: (_) => FinanceTransactionsBloc(getIt<FinanceRepository>())
          ..add(FinanceTransactionsLoadRequested(period: _initialPeriod)),
        child: const _FinanceTransactionsScaffold(
          maxContentWidth: 1200,
          columnCount: 3,
        ),
      );

  @override
  Widget buildDesktop(BuildContext context) => BlocProvider(
        create: (_) => FinanceTransactionsBloc(getIt<FinanceRepository>())
          ..add(FinanceTransactionsLoadRequested(period: _initialPeriod)),
        child: const _FinanceTransactionsScaffold(
          maxContentWidth: 1200,
          columnCount: 2,
        ),
      );
}

class _FinanceTransactionsScaffold extends StatelessWidget {
  const _FinanceTransactionsScaffold({
    required this.maxContentWidth,
    required this.columnCount,
  });

  final double? maxContentWidth;
  final int columnCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StaticColors.cF8F8F8,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: StaticColors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          TranslationKeys.vendorFinanceTransactionsTitle.tr(context: context),
          style: AppTextStyle.semibold18(context, color: StaticColors.black),
        ),
        leading: Align(
          alignment: Alignment.center,
          child: CircleBtnWidget(
            bgColor: StaticColors.white,
            iconColor: StaticColors.black,
            onPress: () => context.router.maybePop(),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: StaticColors.cE2E2E2),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FinanceTransactionsBodySection(
              maxContentWidth: maxContentWidth,
              columnCount: columnCount,
            ),
          ),
          const FinanceTransactionsPdfDownloadBar(),
        ],
      ),
    );
  }
}
