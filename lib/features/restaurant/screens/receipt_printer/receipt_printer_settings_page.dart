import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/mixins/receipt_printer_settings_mixin.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/sections/receipt_printer_settings_sections.dart';

@RoutePage()
class ReceiptPrinterSettingsPage extends ResponsiveSection {
  const ReceiptPrinterSettingsPage({super.key});

  @override
  Widget buildMobile(BuildContext context) =>
      const _ReceiptPrinterSettingsScaffold(isTablet: false);

  @override
  Widget buildTablet(BuildContext context) =>
      const _ReceiptPrinterSettingsScaffold(isTablet: true);

  @override
  Widget buildDesktop(BuildContext context) => buildTablet(context);
}

class _ReceiptPrinterSettingsScaffold extends StatefulWidget {
  const _ReceiptPrinterSettingsScaffold({required this.isTablet});

  final bool isTablet;

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
    final pad = widget.isTablet ? 24.0 : 16.0;
    return Scaffold(
      backgroundColor: StaticColors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: StaticColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: StaticColors.black,
            size: 20,
          ),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(
          TranslationKeys.printerSettingsTitle.tr(context: context),
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
          return ListView(
            padding: EdgeInsets.all(pad),
            children: [
              ReceiptPrinterIntroSection(wifiIp: state.wifiIp),
              const SizedBox(height: 16),
              ReceiptPrinterManualConnectSection(
                controller: manualController,
                scanning: state.scanning,
                onScan: onScan,
                onConnectManual: connectManual, //
              ),
              const SizedBox(height: 12),
              ReceiptPrinterStatusSection(status: state.status),
              const SizedBox(height: 24),
              Text(
                TranslationKeys.printerFoundDevices.tr(context: context),
                style: AppTextStyle.semibold16(context),
              ),
              const SizedBox(height: 8),
              ReceiptPrinterFoundDevicesSection(
                found: state.found,
                scanning: state.scanning,
                onTap: connectTo,
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: TranslationKeys.printerRemoveSaved.tr(context: context),
                type: ButtonType.outlined,
                onPressed: clearSavedPrinter,
                height: context
                    .wOf(50, MediaQuery.sizeOf(context).width)
                    .clamp(44.0, 50.0),
                textStyle: AppTextStyle.regular14(
                  context,
                  size: context
                      .spOf(14, MediaQuery.sizeOf(context).width)
                      .clamp(13.0, 14.0),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
