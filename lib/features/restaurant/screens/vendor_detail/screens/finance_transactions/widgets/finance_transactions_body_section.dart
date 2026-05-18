import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/models/vendor_finance_transaction_item_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/screens/finance_transactions/bloc/finance_transactions_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/screens/finance_transactions/bloc/finance_transactions_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/screens/finance_transactions/bloc/finance_transactions_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/screens/finance_transactions/widgets/finance_transaction_card.dart';

class FinanceTransactionsBodySection extends StatefulWidget {
  const FinanceTransactionsBodySection({
    super.key,
    this.maxContentWidth,
    this.columnCount = 1,
  });

  final double? maxContentWidth;
  final int columnCount;

  @override
  State<FinanceTransactionsBodySection> createState() =>
      _FinanceTransactionsBodySectionState();
}

class _FinanceTransactionsBodySectionState
    extends State<FinanceTransactionsBodySection> {
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
    final bloc = context.read<FinanceTransactionsBloc>();
    final s = bloc.state;
    if (!s.hasMore ||
        s.isLoadingMore ||
        s.status != FinanceTransactionsLoadStatus.success) {
      return;
    }
    bloc.add(const FinanceTransactionsLoadMoreRequested());
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPad = widget.columnCount > 1 ? 20.0 : 12.0;

    Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: BlocBuilder<FinanceTransactionsBloc, FinanceTransactionsState>(
            builder: (context, state) => _buildList(
              context,
              state,
              horizontalPad: horizontalPad,
            ),
          ),
        ),
      ],
    );

    if (widget.maxContentWidth != null) {
      column = Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxContentWidth!),
          child: column,
        ),
      );
    }

    return ColoredBox(color: StaticColors.cF8F8F8, child: column);
  }

  Widget _buildList(
    BuildContext context,
    FinanceTransactionsState state, {
    required double horizontalPad,
  }) {
    if (state.status == FinanceTransactionsLoadStatus.loading &&
        state.transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (state.status == FinanceTransactionsLoadStatus.failure &&
        state.transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage ??
                    TranslationKeys.vendorFinanceTransactionsFailedLoad
                        .tr(context: context),
                textAlign: TextAlign.center,
                style: AppTextStyle.regular14(
                  context,
                  color: StaticColors.c666666,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  context.read<FinanceTransactionsBloc>().add(
                        const FinanceTransactionsRefreshRequested(),
                      );
                },
                child: Text(TranslationKeys.retry.tr(context: context)),
              ),
            ],
          ),
        ),
      );
    }

    if (state.transactions.isEmpty) {
      return Center(
        child: Text(
          TranslationKeys.vendorDetailNoData.tr(context: context),
          style: AppTextStyle.regular14(
            context,
            color: StaticColors.c9AA0A6,
          ),
        ),
      );
    }

    final Widget list;
    if (widget.columnCount <= 1) {
      list = ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(horizontalPad, 12, horizontalPad, 20),
        itemCount: state.transactions.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _itemAt(context, state, index),
      );
    } else {
      final gridDataRows =
          (state.transactions.length / widget.columnCount).ceil();
      final gridItemCount = gridDataRows + (state.isLoadingMore ? 1 : 0);
      list = ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(horizontalPad, 12, horizontalPad, 20),
        itemCount: gridItemCount,
        itemBuilder: (context, row) {
          if (row >= gridDataRows) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          final i0 = row * widget.columnCount;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var c = 0; c < widget.columnCount; c++) ...[
                  if (c > 0) const SizedBox(width: 12),
                  Expanded(
                    child: i0 + c < state.transactions.length
                        ? _transactionCard(
                            context,
                            state.transactions[i0 + c],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          );
        },
      );
    }

    return RefreshIndicator(
      color: StaticColors.primary,
      onRefresh: () async {
        context.read<FinanceTransactionsBloc>().add(
              const FinanceTransactionsRefreshRequested(),
            );
        await context.read<FinanceTransactionsBloc>().stream.firstWhere(
              (s) => s.status != FinanceTransactionsLoadStatus.loading,
            );
      },
      child: list,
    );
  }

  Widget _itemAt(
    BuildContext context,
    FinanceTransactionsState state,
    int index,
  ) {
    if (index >= state.transactions.length) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    return _transactionCard(context, state.transactions[index]);
  }

  Widget _transactionCard(
    BuildContext context,
    VendorFinanceTransactionItemModel transaction,
  ) {
    return FinanceTransactionCard(transaction: transaction);
  }
}
