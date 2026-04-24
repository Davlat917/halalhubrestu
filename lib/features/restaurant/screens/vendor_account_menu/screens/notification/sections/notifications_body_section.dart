import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/bloc/notification_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/bloc/notification_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/bloc/notification_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/widgets/notification_list_tile.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/widgets/notifications_empty_view.dart';

class NotificationsBodySection extends StatefulWidget {
  const NotificationsBodySection({super.key, this.isTablet = false});

  final bool isTablet;

  @override
  State<NotificationsBodySection> createState() =>
      _NotificationsBodySectionState();
}

class _NotificationsBodySectionState extends State<NotificationsBodySection> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 240) return;
    final bloc = context.read<NotificationBloc>();
    final s = bloc.state;
    if (!s.hasMore ||
        s.isLoadingMore ||
        s.status != NotificationsLoadStatus.success) {
      return;
    }
    bloc.add(const NotificationsLoadMoreRequested());
  }

  Widget _constrainOnTablet(Widget child) {
    if (!widget.isTablet) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state.status == NotificationsLoadStatus.loading &&
            state.items.isEmpty) {
          return _constrainOnTablet(
            const Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        if (state.status == NotificationsLoadStatus.failure &&
            state.items.isEmpty) {
          return _constrainOnTablet(
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.errorMessage ??
                          TranslationKeys.ordersFailedLoad.tr(context: context),
                      textAlign: TextAlign.center,
                      style: AppTextStyle.regular14(
                        context,
                        color: StaticColors.c666666,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.read<NotificationBloc>().add(
                        const NotificationsLoadRequested(),
                      ),
                      child: Text(TranslationKeys.retry.tr(context: context)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (state.items.isEmpty) {
          return _constrainOnTablet(const NotificationsEmptyView());
        }

        return _constrainOnTablet(
          RefreshIndicator(
            color: StaticColors.primary,
            onRefresh: () async {
              final bloc = context.read<NotificationBloc>();
              bloc.add(const NotificationsRefreshRequested());
              await bloc.stream.firstWhere(
                (s) => s.status != NotificationsLoadStatus.loading,
              );
            },
            child: ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  );
                }
                return NotificationListTile(item: state.items[index]);
              },
            ),
          ),
        );
      },
    );
  }
}
