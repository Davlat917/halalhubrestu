import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/features/restaurant/navigation/post_auth_vendor_navigation.dart';
import 'package:halalhub_restaurant/core/storage/storage.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    nextPage(context);
    super.initState();
  }

  void nextPage(BuildContext context) async {
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        final token = getIt<Storage>().token.call();
        final refresh = getIt<Storage>().refreshToken.call();
        final isAuthed = (token != null && token.isNotEmpty) || (refresh != null && refresh.isNotEmpty);
        if (isAuthed) {
          navigateAfterLoginCheckingVendor();
        } else {
          context.router.replace(const AuthFlowRoute(children: [SignInRoute()]));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Assets.images.thumbnail.image(
              fit: BoxFit.cover, //
            ),
          ),
          Align(
            child: Assets.images.logoImage.image(
              width: context.screenWidth * 0.5, //
              fit: BoxFit.contain,
            ), //
          ),
        ],
      ), //
    );
  }
}
