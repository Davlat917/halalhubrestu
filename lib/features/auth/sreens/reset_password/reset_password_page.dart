import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/auth/bloc/auth_bloc.dart';
import 'package:halalhub_restaurant/features/auth/sreens/reset_password/widgets/reset_password_card_widget.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';

@RoutePage()
class ResetPasswordPage extends ResponsiveSection {
  const ResetPasswordPage({super.key});

  Widget _authScope(BuildContext context, Widget child) {
    return BlocProvider.value(
      value: context.read<AuthBloc>(),
      child: child,
    );
  }

  @override
  Widget buildMobile(BuildContext context) {
    return _authScope(
      context,
      Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return ResetPasswordCardWidget(
              availableHeight: constraints.maxHeight,
              availableWidth: constraints.maxWidth, //
            );
          },
        ),
      ),
    );
  }

  @override
  Widget? buildMobileLandscape(BuildContext context) {
    return _authScope(
      context,
      Scaffold(
        body: _landSpaseWidget(
          heightSpase: 1,
          widthSpase: 1, //
        ),
      ),
    );
  }

  @override
  Widget buildTablet(BuildContext context) {
    return _authScope(
      context,
      Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return ResetPasswordCardWidget(
              availableHeight: constraints.maxHeight,
              availableWidth: constraints.maxWidth * 0.5, //
              circleBtnSize: 50,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget? buildTabletLandscape(BuildContext context) {
    return _authScope(
      context,
      Scaffold(
        body: _landSpaseWidget(
          heightSpase: 1,
          widthSpase: 0.6, //
          circleBtnSize: 50,
        ),
      ),
    );
  }

  Widget _landSpaseWidget({required double widthSpase, required double heightSpase, double? circleBtnSize}) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ResetPasswordCardWidget(
                availableWidth: constraints.maxWidth * widthSpase, //
                availableHeight: constraints.maxHeight * heightSpase, //
                circleBtnSize: circleBtnSize,
              );
            },
          ),
        ),
        Expanded(
          flex: 5,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  SizedBox.expand(child: Assets.images.thumbnail.image(fit: BoxFit.cover)),
                  Center(child: Assets.images.logoImage.image(width: constraints.maxWidth * 0.5)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
