import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/repositories/finance_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/screens/finance_transactions/bloc/finance_transactions_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/screens/finance_transactions/bloc/finance_transactions_state.dart';
import 'package:open_filex/open_filex.dart';

class FinanceTransactionsPdfDownloadBar extends StatefulWidget {
  const FinanceTransactionsPdfDownloadBar({super.key});

  @override
  State<FinanceTransactionsPdfDownloadBar> createState() =>
      _FinanceTransactionsPdfDownloadBarState();
}

class _FinanceTransactionsPdfDownloadBarState
    extends State<FinanceTransactionsPdfDownloadBar> {
  bool _isDownloading = false;

  Future<void> _onDownloadTap(FinanceTransactionsState state) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final file = await getIt<FinanceRepository>().downloadTransactionsPdf(
        period: state.period,
      );

      final targetDir = await _resolveDownloadDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeName = file.fileName.replaceAll('/', '_');
      final localPath = '${targetDir.path}/$timestamp-$safeName';
      final localFile = File(localPath);
      await localFile.writeAsBytes(file.bytes, flush: true);

      if (!mounted) return;
      final openResult = await OpenFilex.open(localFile.path);
      if (openResult.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(openResult.message)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final message = e is NetworkException
          ? e.message
          : TranslationKeys.vendorFinanceTransactionsPdfFailed
              .tr(context: context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<Directory> _resolveDownloadDirectory() async {
    if (Platform.isAndroid) {
      final downloads = Directory('/storage/emulated/0/Download');
      if (await downloads.exists()) return downloads;
    }
    final homeDownloads = Directory(
      '${Platform.environment['HOME'] ?? ''}/Downloads',
    );
    if (await homeDownloads.exists()) return homeDownloads;
    return Directory.systemTemp;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceTransactionsBloc, FinanceTransactionsState>(
      buildWhen: (prev, curr) => prev.period != curr.period,
      builder: (context, state) {
        return Material(
          color: StaticColors.white,
          child: SafeArea(
            top: false,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: StaticColors.cE2E2E2),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _isDownloading
                      ? null
                      : () => _onDownloadTap(state),
                  style: FilledButton.styleFrom(
                    backgroundColor: StaticColors.primary,
                    disabledBackgroundColor:
                        StaticColors.primary.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isDownloading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: StaticColors.white,
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 20),
                  label: Text(
                    _isDownloading
                        ? TranslationKeys.vendorFinanceTransactionsPdfDownloading
                            .tr(context: context)
                        : TranslationKeys.vendorFinanceTransactionsDownloadPdf
                            .tr(context: context),
                    style: AppTextStyle.semibold14(
                      context,
                      color: StaticColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
