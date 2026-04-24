import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/auth/bloc/auth_bloc.dart';
import 'package:halalhub_restaurant/features/auth/sreens/sign_up/widgets/sign_up_card_widget.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';

@RoutePage()
class SignUpPage extends ResponsiveSection {
  const SignUpPage({super.key});

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
        body: SafeArea(child: SignUpCardWidget()), //
      ),
    );
  }

  @override
  Widget buildTablet(BuildContext context) {
    return _authScope(
      context,
      Scaffold(body: isLandscape(context) ? _buildLandscapeLayout(context) : _buildPortraitLayout(context)),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SignUpCardWidget(
                  availableWidth: constraints.maxWidth - 100, //
                  availableHeight: constraints.maxHeight, //
                ),
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

  Widget _buildPortraitLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: SignUpCardWidget(
              availableWidth: constraints.maxWidth - 200, //
              availableHeight: constraints.maxHeight - 20, //
              buttonHeight: context.wOf(30, constraints.maxWidth),
            ),
          ),
        );
      },
    );
  }
}
