import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class DeepLinkShareService {
  DeepLinkShareService._();

  static const String _scheme = 'myapp';
  static const String _domain = 'com.example.bloc_shablon';

  // ─── Link generatsiya ─────────────────────────────────────────────────────

  /// myapp://test/42
  static String customLink(String path) => '$_scheme://$path';

  /// https://com.example.bloc_shablon/test/42
  static String universalLink(String path) => 'https://$_domain/$path';

  // ─── iPad uchun position ──────────────────────────────────────────────────

  static Rect? _resolveShareOrigin(BuildContext context) {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  // ─── Deep link share ──────────────────────────────────────────────────────
  // custom scheme + text birga — messenjerlar link ko'rsatmasa,
  // text ichidagi link orqali ham ochiladi

  static Future<ShareResult> shareDeepLink({
    required BuildContext context,
    required String path,   // 'test/42', 'product/123' va h.k
    String? title,
    String? description,
  }) async {
    final link = customLink(path); // myapp://test/42

    final text = [
      ?description,
      link,
    ].join('\n');

    return SharePlus.instance.share(
      ShareParams(
        title: title,
        text: text,
        sharePositionOrigin: _resolveShareOrigin(context),
      ),
    );
  }

  // ─── Product share ────────────────────────────────────────────────────────

  static Future<ShareResult> shareProduct({
    required BuildContext context,
    required String productId,
    required String productName,
  }) =>
      shareDeepLink(
        context: context,
        path: 'product/$productId',
        title: productName,
        description: productName,
      );

  // ─── Profile share ────────────────────────────────────────────────────────

  static Future<ShareResult> shareProfile({
    required BuildContext context,
    required String userId,
    required String userName,
  }) =>
      shareDeepLink(
        context: context,
        path: 'profile/$userId',
        title: userName,
        description: userName,
      );

  // ─── Generic text ─────────────────────────────────────────────────────────

  static Future<ShareResult> shareText({
    required BuildContext context,
    required String text,
    String? subject,
    String? title,
  }) async {
    return SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        title: title,
        sharePositionOrigin: _resolveShareOrigin(context),
      ),
    );
  }

  // ─── Files ────────────────────────────────────────────────────────────────

  static Future<ShareResult> shareFiles({
    required BuildContext context,
    required List<String> filePaths,
    String? text,
    String? subject,
    String? title,
  }) async {
    return SharePlus.instance.share(
      ShareParams(
        files: filePaths.map((path) => XFile(path)).toList(),
        text: text,
        subject: subject,
        title: title,
        sharePositionOrigin: _resolveShareOrigin(context),
      ),
    );
  }
}