import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/circle_btn_widget.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/mixins/receipt_printer_settings_mixin.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/sections/receipt_printer_settings_sections.dart';

@RoutePage()
class ReceiptPrinterSettingsPage extends ResponsiveSection {
  const ReceiptPrinterSettingsPage({super.key});

  @override
  Widget buildMobile(BuildContext context) =>
      const _ReceiptPrinterSettingsScaffold(layout: _PrinterSettingsLayout.mobile);

  @override
  Widget buildTablet(BuildContext context) =>
      const _ReceiptPrinterSettingsScaffold(layout: _PrinterSettingsLayout.tablet);

  @override
  Widget? buildMobileLandscape(BuildContext context) =>
      const _ReceiptPrinterSettingsScaffold(layout: _PrinterSettingsLayout.mobileLandscape);

  @override
  Widget? buildTabletLandscape(BuildContext context) =>
      const _ReceiptPrinterSettingsScaffold(layout: _PrinterSettingsLayout.tabletLandscape);

  @override
  Widget buildDesktop(BuildContext context) => buildTablet(context);
}

enum _PrinterSettingsLayout {
  mobile,
  mobileLandscape,
  tablet,
  tabletLandscape,
}

class _ReceiptPrinterSettingsScaffold extends StatefulWidget {
  const _ReceiptPrinterSettingsScaffold({required this.layout});

  final _PrinterSettingsLayout layout;

  @override
  State<_ReceiptPrinterSettingsScaffold> createState() =>
      _ReceiptPrinterSettingsScaffoldState();
}

class _ReceiptPrinterSettingsScaffoldState
    extends State<_ReceiptPrinterSettingsScaffold>
    with ReceiptPrinterSettingsMixin {
  @override
  void initState() {
    super.initState();
    initReceiptPrinterSettings();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = widget.layout == _PrinterSettingsLayout.tablet ||
        widget.layout == _PrinterSettingsLayout.tabletLandscape;
    final pad = isTablet ? 24.0 : 16.0;
    final maxBodyWidth = isTablet ? 920.0 : 560.0;

    Widget buildNetworks(ReceiptPrinterSettingsVm state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReceiptPrinterWifiHeaderSection(
            networkCount: state.found.length,
          ),
          const SizedBox(height: 16),
          ReceiptPrinterFoundDevicesSection(
            found: state.found,
            scanning: state.scanning,
            selectedHost: state.selectedHost,
            connectingHost: state.connectingHost,
            onTap: selectFoundHost,
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: StaticColors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: StaticColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        leading: Align(
          alignment: Alignment.center,
          child: CircleBtnWidget(
            bgColor: StaticColors.white,
            iconColor: StaticColors.black,
            onPress: () => context.router.maybePop(),
          ),
        ),
        title: Text(
          TranslationKeys.commonSearch.tr(context: context),
          style: AppTextStyle.semibold18(context),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: StaticColors.cE2E2E2),
        ),
      ),
      body: ValueListenableBuilder<ReceiptPrinterSettingsVm>(
        valueListenable: vm,
        builder: (context, state, _) {
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBodyWidth),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, pad, pad, 20),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            ReceiptPrinterIntroSection(wifiIp: state.wifiIp),
                            const SizedBox(height: 20),
                            ReceiptPrinterManualConnectSection(
                              controller: manualController,
                              scanning: state.scanning,
                              connectInProgress:
                                  state.connectingHost != null,
                              onManualConnect: connectManualAndFinish,
                              onScan: onScan,
                              onManualChanged: onManualInputChanged,
                            ),
                            const SizedBox(height: 24),
                            buildNetworks(state),
                            if ((state.status ?? '').trim().isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ReceiptPrinterStatusSection(status: state.status),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
