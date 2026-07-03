import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/mixins/validation_mixin.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/core/widgets/shimmer_item.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/mixins/payment_page_mixin.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/sections/payment_bank_account_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/sections/payment_management_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/sections/payment_summary_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/widgets/payment_stripe_check_section.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, this.bloc});

  final PaymentDashboardBloc? bloc;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with ValidationMixin, PaymentPageMixin, WidgetsBindingObserver {
  /// [BlocProvider] boladan pastda — [State.context] orqali o‘qib bo‘lmaydi; listenerlar shu instancedan foydalanadi.
  late final PaymentDashboardBloc _paymentBloc;
  late final ScrollController _scrollController;
  bool _pendingStripeRecheck = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPaymentPageMixin();
    _paymentBloc =
        widget.bloc ??
        (PaymentDashboardBloc(getIt<RestaurantRepo>())
          ..add(const PaymentDashboardRequested()));
    _scrollController = ScrollController()
      ..addListener(_onPaymentScrollLoadMore);
  }

  void _onPaymentScrollLoadMore() {
    if (!mounted) return;
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 200) return;
    _paymentBloc.add(const PaymentPayoutHistoryLoadMore());
  }

  Future<void> _onPaymentRefresh() async {
    if (!mounted) return;
    _paymentBloc.add(const PaymentDashboardRequested());
    await _paymentBloc.stream.firstWhere(
      (s) =>
          s.status == PaymentDashboardStatus.loading ||
          s.bankInfoStatus == PaymentDashboardStatus.loading ||
          s.payoutHistoryStatus == PaymentDashboardStatus.loading,
    );
    if (!mounted) return;
    await _paymentBloc.stream.firstWhere(
      (s) =>
          s.status != PaymentDashboardStatus.loading &&
          s.bankInfoStatus != PaymentDashboardStatus.loading &&
          s.payoutHistoryStatus != PaymentDashboardStatus.loading,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _pendingStripeRecheck) {
      _pendingStripeRecheck = false;
      _paymentBloc.add(const PaymentStripeCheckRequested());
    }
  }

  Future<void> _openStripeOnboarding(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      getIt<Display>().error(
        TranslationKeys.paymentStripeConnectOpenFailed.tr(context: context),
      );
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      if (!mounted) return;
      getIt<Display>().error(
        TranslationKeys.paymentStripeConnectOpenFailed.tr(context: context),
      );
      return;
    }
    _pendingStripeRecheck = true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onPaymentScrollLoadMore);
    _scrollController.dispose();
    if (widget.bloc == null) {
      _paymentBloc.close();
    }
    disposePaymentPageMixin();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _paymentBloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<PaymentDashboardBloc, PaymentDashboardState>(
            listenWhen: (previous, current) {
              return previous.bankInfoUpdateStatus !=
                  current.bankInfoUpdateStatus;
            },
            listener: (context, state) {
              if (state.bankInfoUpdateStatus ==
                      PaymentDashboardStatus.success &&
                  state.bankInfoUpdateMessage != null) {
                getIt<Display>().success(state.bankInfoUpdateMessage!);
                context.read<PaymentDashboardBloc>().add(
                  const PaymentBankInfoUpdateStatusCleared(),
                );
                return;
              }
              if (state.bankInfoUpdateStatus ==
                      PaymentDashboardStatus.failure &&
                  state.bankInfoUpdateMessage != null) {
                getIt<Display>().error(state.bankInfoUpdateMessage!);
              }
            },
          ),
          BlocListener<PaymentDashboardBloc, PaymentDashboardState>(
            listenWhen: (previous, current) {
              return previous.stripeConnectStatus != current.stripeConnectStatus;
            },
            listener: (context, state) async {
              if (state.stripeConnectStatus == PaymentDashboardStatus.failure &&
                  state.stripeConnectErrorMessage != null) {
                getIt<Display>().error(state.stripeConnectErrorMessage!);
                context.read<PaymentDashboardBloc>().add(
                  const PaymentStripeConnectHandled(),
                );
                return;
              }
              if (state.stripeConnectStatus ==
                      PaymentDashboardStatus.success &&
                  state.stripeOnboardingUrl != null &&
                  state.stripeOnboardingUrl!.isNotEmpty) {
                final url = state.stripeOnboardingUrl!;
                context.read<PaymentDashboardBloc>().add(
                  const PaymentStripeConnectHandled(),
                );
                await _openStripeOnboarding(url);
              }
            },
          ),
        ],
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTabletLandscape =
                MediaQuery.orientationOf(context) == Orientation.landscape &&
                constraints.maxWidth >= 900;
            return ColoredBox(
              color: StaticColors.cF8F8F8,
              child: RefreshIndicator(
                color: StaticColors.primary,
                onRefresh: _onPaymentRefresh,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(14),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isTabletLandscape ? 1200 : 520,
                            ),
                            child: BlocBuilder<
                              PaymentDashboardBloc,
                              PaymentDashboardState
                            >(
                              buildWhen: (previous, current) =>
                                  previous.status != current.status ||
                                  previous.bankInfoStatus !=
                                      current.bankInfoStatus ||
                                  previous.payoutHistoryStatus !=
                                      current.payoutHistoryStatus,
                              builder: (context, state) {
                                if (_showLoadingSkeleton(state)) {
                                  return _PaymentPageLoadingSkeleton(
                                    isTabletLandscape: isTabletLandscape,
                                  );
                                }
                                return _buildLoadedContent(
                                  context,
                                  isTabletLandscape,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool _showLoadingSkeleton(PaymentDashboardState state) {
    final allWaiting =
        (state.status == PaymentDashboardStatus.initial ||
            state.status == PaymentDashboardStatus.loading) &&
        (state.bankInfoStatus == PaymentDashboardStatus.initial ||
            state.bankInfoStatus == PaymentDashboardStatus.loading) &&
        (state.payoutHistoryStatus == PaymentDashboardStatus.initial ||
            state.payoutHistoryStatus == PaymentDashboardStatus.loading);
    return allWaiting;
  }

  Widget _buildLoadedContent(BuildContext context, bool isTabletLandscape) {
    return BlocBuilder<PaymentDashboardBloc, PaymentDashboardState>(
      buildWhen: (previous, current) {
        return previous.bankInfo != current.bankInfo ||
            previous.bankInfoStatus != current.bankInfoStatus ||
            previous.payoutHistoryStatus != current.payoutHistoryStatus ||
            previous.payoutHistoryRows != current.payoutHistoryRows ||
            previous.payoutHistoryErrorMessage !=
                current.payoutHistoryErrorMessage ||
            previous.payoutNextUrl != current.payoutNextUrl ||
            previous.payoutLoadingMore != current.payoutLoadingMore ||
            previous.status != current.status ||
            previous.dashboard != current.dashboard ||
            previous.errorMessage != current.errorMessage ||
            previous.stripeCheckStatus != current.stripeCheckStatus ||
            previous.stripeIsConnected != current.stripeIsConnected ||
            previous.stripeChargesEnabled != current.stripeChargesEnabled ||
            previous.stripeRequirements != current.stripeRequirements ||
            previous.stripeDetailsEn != current.stripeDetailsEn ||
            previous.stripeCheckErrorMessage != current.stripeCheckErrorMessage;
      },
      builder: (context, state) {
        final isManualPayout = isManualPayoutSchedule(
          state.bankInfo.payoutSchedule,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(pageTitle(context), style: AppTextStyle.semibold18(context)),
            const SizedBox(height: 12),
            PaymentStripeCheckSection(
              status: state.stripeCheckStatus,
              isConnected: state.stripeIsConnected,
              chargesEnabled: state.stripeChargesEnabled,
              requirements: state.stripeRequirements,
              detailsEn: state.stripeDetailsEn,
              errorMessage: state.stripeCheckErrorMessage,
              connectStatus: state.stripeConnectStatus,
              onCheckPressed: () {
                context.read<PaymentDashboardBloc>().add(
                  const PaymentStripeCheckRequested(),
                );
              },
              onConnectPressed: () {
                context.read<PaymentDashboardBloc>().add(
                  const PaymentStripeConnectRequested(),
                );
              },
            ),
            const SizedBox(height: 14),
            PaymentSummarySection(
              dashboard: state.dashboard,
              status: state.status,
              onRetry: () {
                context.read<PaymentDashboardBloc>().add(
                  const PaymentDashboardRequested(),
                );
              },
            ),
            const SizedBox(height: 14),
            if (isTabletLandscape) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: PaymentManagementSection(
                      isManualPayout: isManualPayout,
                      rows: state.payoutHistoryRows,
                      status: state.payoutHistoryStatus,
                      errorMessage: state.payoutHistoryErrorMessage,
                      onRetry: () {
                        context.read<PaymentDashboardBloc>().add(
                          const PaymentDashboardRequested(),
                        );
                      },
                      isLoadingMore: state.payoutLoadingMore,
                      onWithdrawPressed: () => onWithdrawPressed(context),
                      withdrawButtonWidth: 230,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PaymentBankAccountSection(
                      status: state.bankInfoStatus,
                      bankInfo: state.bankInfo,
                      errorMessage: state.bankInfoErrorMessage,
                      onRetry: () {
                        context.read<PaymentDashboardBloc>().add(
                          const PaymentDashboardRequested(),
                        );
                      },
                      onEditPressed: () =>
                          onEditBankAccountPressed(context, state.bankInfo),
                    ),
                  ),
                ],
              ),
            ] else ...[
              PaymentBankAccountSection(
                status: state.bankInfoStatus,
                bankInfo: state.bankInfo,
                errorMessage: state.bankInfoErrorMessage,
                onRetry: () {
                  context.read<PaymentDashboardBloc>().add(
                    const PaymentDashboardRequested(),
                  );
                },
                onEditPressed: () =>
                    onEditBankAccountPressed(context, state.bankInfo),
              ),
              const SizedBox(height: 12),
              PaymentManagementSection(
                isManualPayout: isManualPayout,
                rows: state.payoutHistoryRows,
                status: state.payoutHistoryStatus,
                errorMessage: state.payoutHistoryErrorMessage,
                onRetry: () {
                  context.read<PaymentDashboardBloc>().add(
                    const PaymentDashboardRequested(),
                  );
                },
                isLoadingMore: state.payoutLoadingMore,
                onWithdrawPressed: () => onWithdrawPressed(context),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PaymentPageLoadingSkeleton extends StatelessWidget {
  const _PaymentPageLoadingSkeleton({required this.isTabletLandscape});

  final bool isTabletLandscape;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: StaticColors.cE2E2E2,
      highlightColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ShimmerBox(height: 24, width: 160, radius: 8),
          const SizedBox(height: 14),
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, _) => const ShimmerBox(
                height: 132,
                width: 190,
                radius: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: ShimmerBox(height: 22, radius: 8)),
              SizedBox(width: 12),
              ShimmerBox(height: 44, width: 210, radius: 10),
            ],
          ),
          const SizedBox(height: 12),
          if (isTabletLandscape)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: ShimmerBox(height: 300, radius: 12)),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(height: 220, radius: 12)),
              ],
            )
          else
            const Column(
              children: [
                ShimmerBox(height: 220, radius: 12),
                SizedBox(height: 12),
                ShimmerBox(height: 300, radius: 12),
              ],
            ),
        ],
      ),
    );
  }
}
