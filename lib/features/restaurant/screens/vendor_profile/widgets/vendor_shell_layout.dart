import 'dart:math' as math;
// import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
// import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/theme/theme_extension.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_me/vendor_me_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/navigation/vendor_nav_item.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_nav_sidebar.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_shell_app_bars.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_tablet_main_top_bar.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';

/// Mobil: [Drawer] + AppBar. Tablet: sidebar (logo + menyu) + asosiy ustun (utility bar + kontent).
class VendorShellLayout extends StatefulWidget {
  const VendorShellLayout({
    super.key,
    required this.isTablet,
    required this.selectedNavItem,
    required this.body,
    this.vendor,
    this.onNavItemSelected, //
  });

  final bool isTablet;
  final VendorNavItem selectedNavItem;
  final Widget body;
  final VendorMeModel? vendor;
  final ValueChanged<VendorNavItem>? onNavItemSelected;

  @override
  State<VendorShellLayout> createState() => _VendorShellLayoutState();
}

class _VendorShellLayoutState extends State<VendorShellLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onNavItem(BuildContext context, VendorNavItem item) {
    if (item == widget.selectedNavItem) return;
    if (widget.onNavItemSelected != null) {
      widget.onNavItemSelected!(item);
      return;
    }
    switch (item) {
      default:
        getIt<Display>().info(
          TranslationKeys.comingSoonWithLabel.tr(
            context: context,
            namedArgs: {'label': item.label(context)},
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = context.colors.background;

    if (widget.isTablet) {
      return Scaffold(
      //   floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     context.router.push(ServerErrorRoute());
      //   },
      // ), 
        backgroundColor: bg,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 240,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: StaticColors.white,
                  border: Border(
                    right: BorderSide(color: StaticColors.cE2E2E2),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 18, 14, 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Assets.images.logoImage.image(
                            height: 34,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Expanded(
                        child: VendorNavSidebar(
                          selected: widget.selectedNavItem,
                          onItemTap: (item) => _onNavItem(context, item),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VendorTabletMainTopBar(vendor: widget.vendor),
                  Expanded(
                    child: ColoredBox(color: bg, child: widget.body),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final drawerW = math.min(320.0, MediaQuery.sizeOf(context).width * 0.86);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bg,
      appBar: vendorMobileAppBar(
        context: context,
        vendor: widget.vendor,
        onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: Drawer(
        width: drawerW,
        backgroundColor: StaticColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Assets.images.logoImage.image(
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              child: VendorNavSidebar(
                selected: widget.selectedNavItem,
                onItemTap: (item) {
                  Navigator.of(context).pop();
                  _onNavItem(context, item);
                },
              ),
            ),
          ],
        ),
      ),
      body: widget.body,
    );
  }
}
