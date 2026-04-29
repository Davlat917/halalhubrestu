import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/auth/bloc/auth_bloc.dart';
import 'package:halalhub_restaurant/features/auth/otp_flow.dart';
import 'package:halalhub_restaurant/features/auth/sreens/otp/mixins/otp_page_mixin.dart';
import 'package:halalhub_restaurant/features/auth/sreens/otp/widgets/otp_verification_card.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';

@RoutePage()
class OtpPage extends ResponsiveSection {
  final String emailOrPhone;
  final OtpFlow flow;

  const OtpPage({
    super.key,
    required this.emailOrPhone,
    this.flow = OtpFlow.account,
  });

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
        body: OtpPageBody(emailOrPhone: emailOrPhone, flow: flow),
      ),
    );
  }

  @override
  Widget? buildMobileLandscape(BuildContext context) {
    return _authScope(context, Scaffold(body: _mobileLandscapeLayout(context)));
  }

  @override
  Widget buildTablet(BuildContext context) {
    return _authScope(
      context,
      Scaffold(
        body: isLandscape(context) ? _buildLandscapeLayout(context) : _buildPortraitLayout(context),
      ),
    );
  }

  @override
  Widget? buildTabletLandscape(BuildContext context) {
    return _authScope(context, Scaffold(body: _buildLandscapeLayout(context)));
  }

  Widget _mobileLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: OtpPageBody(
                  emailOrPhone: emailOrPhone,
                  flow: flow,
                  availableWidth: constraints.maxWidth,
                  availableHeight: constraints.maxHeight,
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 4,
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

  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: OtpPageBody(
                  emailOrPhone: emailOrPhone,
                  flow: flow,
                  availableWidth: constraints.maxWidth * 0.7,
                  availableHeight: constraints.maxHeight,
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
        final double safeWidth = constraints.maxWidth > 500 ? 500 : constraints.maxWidth;
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: OtpPageBody(
              emailOrPhone: emailOrPhone,
              flow: flow,
              availableWidth: safeWidth,
              availableHeight: constraints.maxHeight,
              buttonHeight: context.wOf(30, constraints.maxWidth),
            ),
          ),
        );
      },
    );
  }
}

class OtpPageBody extends StatefulWidget {
  const OtpPageBody({
    super.key,
    required this.emailOrPhone,
    this.flow = OtpFlow.account,
    this.availableWidth,
    this.availableHeight,
    this.buttonHeight,
  });

  final String emailOrPhone;
  final OtpFlow flow;
  final double? availableWidth;
  final double? availableHeight;
  final double? buttonHeight;

  @override
  State<OtpPageBody> createState() => _OtpPageBodyState();
}

class _OtpPageBodyState extends State<OtpPageBody> with OtpPageMixin {
  static const int _resendCooldownSeconds = 120;

  AuthPendingAction? _successFromAction;
  Timer? _resendCooldownTimer;
  /// OTP sahifasiga kirishda darhol 2:00 dan boshlanadi.
  int _resendCooldownRemaining = _resendCooldownSeconds;

  void _runResendCooldownTicker() {
    _resendCooldownTimer?.cancel();
    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_resendCooldownRemaining <= 1) {
        t.cancel();
        setState(() => _resendCooldownRemaining = 0);
      } else {
        setState(() => _resendCooldownRemaining--);
      }
    });
  }

  /// Yangi kod yuborilgach yoki sahifa ochilganda 2 daqiqa qayta yuborishni bloklash.
  void _startResendCooldown() {
    _resendCooldownTimer?.cancel();
    setState(() => _resendCooldownRemaining = _resendCooldownSeconds);
    _runResendCooldownTicker();
  }

  @override
  void initState() {
    super.initState();
    _runResendCooldownTicker();
  }

  @override
  void dispose() {
    _resendCooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (p, c) {
        if (c is AuthFailure) {
          _successFromAction = null;
          return true;
        }
        if (c is AuthSuccess && p is AuthLoading) {
          _successFromAction = p.action;
          return true;
        }
        return false;
      },
      listener: (context, state) => handleOtpAuthEffects(
        context,
        state,
        _successFromAction,
        onResetOtpSucceeded: _startResendCooldown,
      ),
      builder: (context, state) {
        final busy = state is AuthLoading;
        final pending = state is AuthLoading ? state.action : null;
        final continueLoading = pending == AuthPendingAction.verifyOtp ||
            pending == AuthPendingAction.passwordResetOtpVerify;
        final resendLoading =
            pending == AuthPendingAction.resetOtp || pending == AuthPendingAction.passwordResetResend;
        return LayoutBuilder(
          builder: (context, constraints) {
            return OtpVerificationCard(
              emailOrPhone: widget.emailOrPhone,
              headline: widget.flow == OtpFlow.passwordReset
                  ? TranslationKeys.resetPassword.tr(context: context)
                  : TranslationKeys.otpEmailVerification.tr(context: context),
              availableHeight: widget.availableHeight ?? constraints.maxHeight,
              availableWidth: widget.availableWidth ?? constraints.maxWidth,
              buttonHeight: widget.buttonHeight,
              isBusy: busy,
              continueLoading: continueLoading,
              resendLoading: resendLoading,
              resendCooldownRemaining: _resendCooldownRemaining,
              onContinue: (otp) => onOtpContinue(context, otp),
              onResend: _resendCooldownRemaining > 0 ? null : () => onOtpResend(context),
            );
          },
        );
      },
    );
  }
}
