import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_product/vendor_product_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_menu_preview_chips_row.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_menu_preview_info_card.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_menu_preview_pinned_chips_delegate.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_menu_preview_products_grid.dart';

class VendorMenuPreviewSection extends StatefulWidget {
  const VendorMenuPreviewSection({
    super.key,
    required this.vendorId,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.maxWidth,
  });

  final int? vendorId;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategorySelected;
  final double maxWidth;

  @override
  State<VendorMenuPreviewSection> createState() =>
      _VendorMenuPreviewSectionState();
}

class _VendorMenuPreviewSectionState extends State<VendorMenuPreviewSection> {
  late Future<List<VendorProductGroupModel>> _groupsFuture;
  final ScrollController _chipsScrollController = ScrollController();
  final Map<int, GlobalKey> _sectionKeys = {};
  final Map<int, GlobalKey> _chipKeys = {};
  final GlobalKey _chipsRowKey = GlobalKey();
  bool _isProgrammaticSectionScroll = false;
  List<VendorProductGroupModel> _latestGroups = const [];
  int? _lastSyncedCategoryId;

  /// [FutureBuilder] har rebuildda [WidgetsBinding.addPostFrameCallback] qo'shmasligi uchun.
  bool _didScheduleDefaultCategorySelection = false;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _loadGroups();
  }

  @override
  void dispose() {
    _chipsScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VendorMenuPreviewSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vendorId != widget.vendorId) {
      _groupsFuture = _loadGroups();
      _didScheduleDefaultCategorySelection = false;
    }
  }

  Future<List<VendorProductGroupModel>> _loadGroups() async {
    final vendorId = widget.vendorId;
    if (vendorId == null) return const [];
    return getIt<RestaurantRepo>().getVendorProductsByVendorId(vendorId);
  }

  /// Profil menyusi [NestedScrollView] ichida; marshrutdan qaytganda ichki scroll 0 ga tushib qoladi.
  /// Offsetlarni saqlab, [push] dan keyin qayta qo‘llaymiz.
  Future<void> _pushEditProductAndRestoreScroll(
    BuildContext menuContext,
    VendorProductModel product,
  ) async {
    final vendorId = widget.vendorId;
    if (vendorId == null) return;

    final nested = menuContext.findAncestorStateOfType<NestedScrollViewState>();
    final double? outerBefore =
        nested != null && nested.outerController.hasClients
        ? nested.outerController.offset
        : null;
    double? innerBefore = nested != null && nested.innerController.hasClients
        ? nested.innerController.offset
        : null;
    if (innerBefore == null) {
      final primary = PrimaryScrollController.maybeOf(menuContext);
      if (primary != null && primary.hasClients) {
        innerBefore = primary.offset;
      }
    }

    final firstDiscount = product.discounts.isNotEmpty
        ? product.discounts.first
        : null;

    final updated = await menuContext.router.push<bool>(
      EditProductRoute(
        vendorId: vendorId,
        productId: product.id,
        initialName: product.name,
        initialDescription: product.description,
        initialPrice: product.price,
        initialPreparationTime: product.preparationTime,
        initialIsAvailable: product.isAvailable ?? true,
        initialCategoryIds: product.categories
            .map((e) => e.id)
            .toList(growable: false),
        initialIngredientTitles: product.ingredients,
        initialImageUrls: product.images
            .map((e) => e.imageUrl)
            .where((e) => e.trim().isNotEmpty)
            .toList(growable: false),
        initialImageIds: product.images
            .map((e) => e.id)
            .toList(growable: false),
        initialDiscountTitle: firstDiscount?.title,
        initialDiscountPercent: firstDiscount?.percent,
      ),
    );

    if (updated == true && mounted) {
      setState(() {
        _groupsFuture = _loadGroups();
        _didScheduleDefaultCategorySelection = false;
      });
    }

    if (!menuContext.mounted) return;
    if (outerBefore == null && innerBefore == null) return;

    void restore() {
      if (!menuContext.mounted) return;
      final nest = menuContext.findAncestorStateOfType<NestedScrollViewState>();
      if (nest != null) {
        if (outerBefore != null && nest.outerController.hasClients) {
          final pos = nest.outerController.position;
          nest.outerController.jumpTo(
            outerBefore.clamp(pos.minScrollExtent, pos.maxScrollExtent),
          );
        }
        if (innerBefore != null && nest.innerController.hasClients) {
          final pos = nest.innerController.position;
          nest.innerController.jumpTo(
            innerBefore.clamp(pos.minScrollExtent, pos.maxScrollExtent),
          );
        }
        return;
      }
      if (innerBefore != null) {
        final primary = PrimaryScrollController.maybeOf(menuContext);
        if (primary != null && primary.hasClients) {
          final pos = primary.position;
          primary.jumpTo(
            innerBefore.clamp(pos.minScrollExtent, pos.maxScrollExtent),
          );
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      restore();
      WidgetsBinding.instance.addPostFrameCallback((_) => restore());
    });
  }

  void _onCategoryChipTap(VendorProductGroupModel g) {
    if (_isProgrammaticSectionScroll) return;
    widget.onCategorySelected(g.id);
    _scrollToSection(g.id).then((_) => _scrollChipToStart(g.id));
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = widget.maxWidth;
    final titleStyle = AppTextStyle.semibold24(
      context,
      color: StaticColors.black,
    );

    return FutureBuilder<List<VendorProductGroupModel>>(
      future: _groupsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: CircularProgressIndicator(color: StaticColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return VendorMenuPreviewInfoCard(
            maxWidth: maxWidth,
            text:
                '${TranslationKeys.menuProductsLoadFailed.tr(context: context)}: ${snapshot.error}',
          );
        }

        final groups = snapshot.data ?? const <VendorProductGroupModel>[];
        _latestGroups = groups;
        if (groups.isEmpty) {
          return VendorMenuPreviewInfoCard(
            maxWidth: maxWidth,
            text: TranslationKeys.menuNoProductsInCategory.tr(context: context),
          );
        }

        for (final g in groups) {
          _sectionKeys.putIfAbsent(g.id, () => GlobalKey());
          _chipKeys.putIfAbsent(g.id, () => GlobalKey());
        }

        final activeCategoryId = widget.selectedCategoryId ?? groups.first.id;
        if (widget.selectedCategoryId == null &&
            !_didScheduleDefaultCategorySelection) {
          _didScheduleDefaultCategorySelection = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            widget.onCategorySelected(groups.first.id);
          });
        }

        return NotificationListener<ScrollUpdateNotification>(
          onNotification: (notification) {
            if (notification.depth != 0) return false;
            final notificationContext = notification.context;
            if (notificationContext == null) return false;
            _syncActiveCategoryFromScroll(notificationContext);
            return false;
          },
          child: CustomScrollView(
            key: const PageStorageKey<String>('vendor_menu_preview_products'),
            slivers: [
              SliverToBoxAdapter(
                child: Text(
                  TranslationKeys.menuProducts.tr(context: context),
                  style: titleStyle,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: context.wOf(14, maxWidth)),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: VendorMenuPreviewPinnedChipsHeaderDelegate(
                  height: 58,
                  child: VendorMenuPreviewChipsRow(
                    groups: groups,
                    activeCategoryId: activeCategoryId,
                    chipsScrollController: _chipsScrollController,
                    chipsRowKey: _chipsRowKey,
                    chipKeys: _chipKeys,
                    onChipTap: _onCategoryChipTap,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              for (final group in groups) ...[
                SliverToBoxAdapter(
                  child: Container(
                    key: _sectionKeys[group.id],
                    alignment: Alignment.centerLeft,
                    child: Text(
                      group.name,
                      style: AppTextStyle.semibold24(
                        context,
                        color: StaticColors.black,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                SliverToBoxAdapter(
                  child: VendorMenuPreviewProductsGrid(
                    products: group.products,
                    onEditProduct: (product) =>
                        _pushEditProductAndRestoreScroll(context, product),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 18)),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _scrollToSection(int id) async {
    final targetContext = _sectionKeys[id]?.currentContext;
    if (targetContext == null) return;
    final renderObject = targetContext.findRenderObject();
    if (renderObject == null) return;
    final scrollableState = Scrollable.of(targetContext);

    _isProgrammaticSectionScroll = true;
    try {
      await scrollableState.position.ensureVisible(
        renderObject,
        alignment: 0.03,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } finally {
      _isProgrammaticSectionScroll = false;
    }
  }

  void _syncActiveCategoryFromScroll(BuildContext notificationContext) {
    if (_isProgrammaticSectionScroll) return;
    if (_latestGroups.isEmpty) return;
    final viewportBox = notificationContext.findRenderObject() as RenderBox?;
    if (viewportBox == null) return;

    const anchorY = 72.0;
    int? bestPassedCategoryId;
    double bestPassedDy = double.negativeInfinity;
    int? nearestUpcomingCategoryId;
    double nearestUpcomingDy = double.infinity;

    for (final group in _latestGroups) {
      final sectionContext = _sectionKeys[group.id]?.currentContext;
      if (sectionContext == null) continue;
      final sectionBox = sectionContext.findRenderObject() as RenderBox?;
      if (sectionBox == null) continue;

      final dy = sectionBox
          .localToGlobal(Offset.zero, ancestor: viewportBox)
          .dy;
      if (dy <= anchorY && dy > bestPassedDy) {
        bestPassedDy = dy;
        bestPassedCategoryId = group.id;
      } else if (dy > anchorY && dy < nearestUpcomingDy) {
        nearestUpcomingDy = dy;
        nearestUpcomingCategoryId = group.id;
      }
    }

    final bestCategoryId =
        bestPassedCategoryId ??
        nearestUpcomingCategoryId ??
        _latestGroups.first.id;
    if (bestCategoryId == _lastSyncedCategoryId) return;
    _lastSyncedCategoryId = bestCategoryId;

    if (widget.selectedCategoryId != bestCategoryId) {
      widget.onCategorySelected(bestCategoryId);
    }
    _scrollChipToStart(bestCategoryId);
  }

  Future<void> _scrollChipToStart(int id) async {
    final targetContext = _chipKeys[id]?.currentContext;
    final chipsRowContext = _chipsRowKey.currentContext;
    if (targetContext == null ||
        chipsRowContext == null ||
        !_chipsScrollController.hasClients) {
      return;
    }

    final chipBox = targetContext.findRenderObject() as RenderBox?;
    final rowBox = chipsRowContext.findRenderObject() as RenderBox?;
    if (chipBox == null || rowBox == null) return;

    final chipDx = chipBox.localToGlobal(Offset.zero, ancestor: rowBox).dx;
    final targetOffset = (_chipsScrollController.offset + chipDx - 8).clamp(
      _chipsScrollController.position.minScrollExtent,
      _chipsScrollController.position.maxScrollExtent,
    );

    await _chipsScrollController.animateTo(
      targetOffset.toDouble(),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
    );
  }
}
