import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/models/vendor_finance_period.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/models/vendor_finance_transactions_page_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/models/vendor_finance_transactions_pdf_file.dart';

abstract class FinanceRepository {
  /// [nextPageUrl] — API `next` to‘liq URL; `null` bo‘lsa birinchi sahifa.
  Future<VendorFinanceTransactionsPageModel> fetchTransactions({
    required VendorFinancePeriod period,
    String? nextPageUrl,
  });

  Future<VendorFinanceTransactionsPdfFile> downloadTransactionsPdf({
    required VendorFinancePeriod period,
  });
}
