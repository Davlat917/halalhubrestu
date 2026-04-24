import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AppShareService {
  AppShareService._();

  // ─── iPad uchun position ───────────────────────────────────────────────────

  static Rect? _resolveShareOrigin(BuildContext context) {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  // ─── Text ulashish ────────────────────────────────────────────────────────

  static Future<ShareResult> shareText({
    required BuildContext context,
    required String text,
    String? subject,
    String? title, //
  }) async {
    return SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        title: title, //
        sharePositionOrigin: _resolveShareOrigin(context),
      ),
    );
  }

  // ─── URI ulashish ─────────────────────────────────────────────────────────

  static Future<ShareResult> shareUri({
    required BuildContext context,
    required Uri uri,
    String? title, //
  }) async {
    return SharePlus.instance.share(
      ShareParams(
        uri: uri,
        title: title, //
        sharePositionOrigin: _resolveShareOrigin(context),
      ),
    );
  }

  // ─── Fayllar ulashish ─────────────────────────────────────────────────────

  static Future<ShareResult> shareFiles({
    required BuildContext context,
    required List<String> filePaths,
    String? text,
    String? subject,
    String? title, //
  }) async {
    return SharePlus.instance.share(
      ShareParams(
        files: filePaths.map((path) => XFile(path)).toList(),
        text: text,
        subject: subject,
        title: title, //
        sharePositionOrigin: _resolveShareOrigin(context),
      ),
    );
  }
}
