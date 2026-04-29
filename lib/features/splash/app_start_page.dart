import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';

/// Guard ishlashi uchun lightweight initial route.
/// Normal holatda foydalanuvchi bu ekranni ko'rmaydi.
@RoutePage()
class AppStartPage extends StatefulWidget {
  const AppStartPage({super.key});

  @override
  State<AppStartPage> createState() => _AppStartPageState();
}

class _AppStartPageState extends State<AppStartPage> {
  void _log(String message) {
    if (kDebugMode) debugPrint('[AppStartPage] $message');
  }

  @override
  void initState() {
    super.initState();
    _log('initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _log('first frame rendered');
    });
  }

  @override
  void dispose() {
    _log('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _log('build');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Assets.images.logoImage.image(
          width: 120,
          height: 120,
        ),
      ),
    );
  }
}
