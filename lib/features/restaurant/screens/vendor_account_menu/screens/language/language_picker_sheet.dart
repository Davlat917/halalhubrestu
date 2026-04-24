import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/storage/storage.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';

class LanguagePickerSheet extends StatefulWidget {
  const LanguagePickerSheet({super.key});

  static const String storageKeyDefault = 'en';
  static const Locale enLocale = Locale('en', 'US');
  static const Locale uzLocale = Locale('uz', 'UZ');
  static const Locale arLocale = Locale('ar', 'SA');
  static const Locale ruLocale = Locale('ru', 'RU');

  static final List<_LanguageOption> _options = [
    _LanguageOption(
      code: 'en',
      titleKey: TranslationKeys.languageEnglish,
      flag: Assets.images.englishFlag,
      locale: enLocale,
    ),
    _LanguageOption(
      code: 'uz',
      titleKey: TranslationKeys.languageUzbek,
      flag: Assets.images.uzbekFlag,
      locale: uzLocale,
    ),
    _LanguageOption(
      code: 'ar',
      titleKey: TranslationKeys.languageArabic,
      flag: Assets.images.arabFlag,
      locale: arLocale,
    ),
    _LanguageOption(
      code: 'ru',
      titleKey: TranslationKeys.languageRussian,
      flag: Assets.images.rusFlag,
      locale: ruLocale,
    ),
  ];

  static Future<void> open(BuildContext context) async {
    if (ResponsiveSection.isMobileLayout(context)) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: StaticColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => const LanguagePickerSheet(),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: StaticColors.white,
          insetPadding: _dialogInset(ctx),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _dialogMaxWidth(ctx)),
            child: const LanguagePickerSheet(),
          ),
        );
      },
    );
  }

  static double _dialogMaxWidth(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    if (landscape) return 430;
    return (size.width * 0.58).clamp(360.0, 460.0);
  }

  static EdgeInsets _dialogInset(BuildContext context) {
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    return EdgeInsets.symmetric(horizontal: landscape ? 48 : 56, vertical: 24);
  }

  @override
  State<LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<LanguagePickerSheet> {
  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    final saved = getIt<Storage>().languageCode.call();
    _selectedCode = saved?.trim().isNotEmpty == true
        ? saved!.trim()
        : LanguagePickerSheet.storageKeyDefault;
  }

  Future<void> _select(_LanguageOption option) async {
    setState(() => _selectedCode = option.code);
    await getIt<Storage>().languageCode.set(option.code);

    if (!mounted) return;

    // Faqat ilova qo‘llab-quvvatlaydigan locale bo‘lsa set qilamiz.
    if (context.supportedLocales.contains(option.locale) &&
        context.locale != option.locale) {
      await context.setLocale(option.locale);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return _LanguagePickerBody(
      options: LanguagePickerSheet._options,
      selectedCode: _selectedCode,
      onSelect: _select,
      onClose: () => Navigator.of(context).pop(),
    );
  }
}

class _LanguagePickerBody extends ResponsiveSection {
  const _LanguagePickerBody({
    required this.options,
    required this.selectedCode,
    required this.onSelect,
    required this.onClose,
  });

  final List<_LanguageOption> options;
  final String selectedCode;
  final ValueChanged<_LanguageOption> onSelect;
  final VoidCallback onClose;

  @override
  Widget buildMobile(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: _content(context),
      ),
    );
  }

  @override
  Widget buildTablet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 4,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: StaticColors.cE2E2E2,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        SizedBox(
          height: 44,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  splashRadius: 20,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  TranslationKeys.language.tr(context: context),
                  style: AppTextStyle.medium16(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = selectedCode == option.code;
              return _LanguageTile(
                option: option,
                isSelected: isSelected,
                onTap: () => onSelect(option),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _LanguageOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: option.flag.image(
                width: 28,
                height: 20,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.titleKey.tr(context: context),
                style: AppTextStyle.regular14(
                  context,
                  color: StaticColors.black,
                ),
              ),
            ),
            _SelectionIndicator(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF16A34A),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 9,
          height: 9,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: StaticColors.white,
          ),
        ),
      );
    }
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFBEBEBE), width: 1.4),
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({
    required this.code,
    required this.titleKey,
    required this.flag,
    required this.locale,
  });

  final String code;
  final String titleKey;
  final AssetGenImage flag;
  final Locale locale;
}
