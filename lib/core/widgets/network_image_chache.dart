import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkImageCache extends StatefulWidget {
  const NetworkImageCache({
    super.key,
    required this.imgUrl,
    this.heightH,
    this.widthW,
    this.radius = 12,
    this.fit,
    this.placeholder,
  });

  final String? imgUrl;
  final double? widthW;
  final double? heightH;
  final double radius;
  final BoxFit? fit;
  final Widget? placeholder;

  @override
  State<NetworkImageCache> createState() => _NetworkImageCacheState();
}

class _NetworkImageCacheState extends State<NetworkImageCache> {
  late BorderRadius _borderRadius;
  late BoxFit _fit;
  double? _dpr;

  bool get _isEmpty => widget.imgUrl == null || widget.imgUrl!.trim().isEmpty;

  @override
  void initState() {
    super.initState();
    _borderRadius = BorderRadius.circular(widget.radius);
    _fit = widget.fit ?? BoxFit.cover;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dpr = MediaQuery.devicePixelRatioOf(context);
  }

  @override
  void didUpdateWidget(NetworkImageCache oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.radius != widget.radius) {
      _borderRadius = BorderRadius.circular(widget.radius);
    }
    if (oldWidget.fit != widget.fit) {
      _fit = widget.fit ?? BoxFit.cover;
    }
  }

  // double.infinity va noto'g'ri qiymatlarni filter qiladi
  double? _sanitize(double? value) {
    if (value == null || !value.isFinite || value <= 0) return null;
    return value;
  }

  int? _cacheSize(double? size) {
    final s = _sanitize(size);
    if (s == null) return null;
    return (s * (_dpr ?? 2.0)).round();
  }

  String _buildUrl(double? w, double? h) {
    final url = widget.imgUrl!;
    // infinity kelsa heightdan fallback
    final effectiveW = _sanitize(w) ?? _sanitize(h);
    final cacheW = _cacheSize(effectiveW);
    if (cacheW == null) return url;
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}w=$cacheW';
  }

  Widget _defaultImage(double? w, double? h) {
    final sw = _sanitize(w);
    final sh = _sanitize(h);
    final double paddingVal = (sh != null) ? sh / 4 : 20;
    return Container(
      alignment: Alignment.center,
      height: sh,
      width: sw,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _borderRadius,
      ),
      child: Padding(
        padding: EdgeInsets.all(paddingVal.clamp(8, 40)),
        child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
      ),
    );
  }

  Widget _buildImage(double w, double h) {
    final double? sw = _sanitize(w);
    final double? sh = _sanitize(h);
    final int? cacheW = _cacheSize(sw);
    final int? cacheH = _cacheSize(sh);
    final String optimizedUrl = _buildUrl(w, h);

    return CachedNetworkImage(
      imageUrl: optimizedUrl,
      memCacheWidth: cacheW,
      memCacheHeight: cacheH,
      maxWidthDiskCache: cacheW,
      maxHeightDiskCache: cacheH,
      filterQuality: FilterQuality.low,
      placeholder: (_, __) =>
          widget.placeholder ??
          Container(
            width: sw ?? double.infinity,
            height: sh ?? double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: _borderRadius,
            ),
          ),
      errorWidget: (_, __, ___) => _defaultImage(sw, sh),
      imageBuilder: (_, imageProvider) => Container(
        height: sh,
        width: sw,
        decoration: BoxDecoration(
          borderRadius: _borderRadius,
          image: DecorationImage(
            image: imageProvider,
            fit: _fit,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) {
      return _defaultImage(widget.widthW, widget.heightH);
    }

    final double? sw = _sanitize(widget.widthW);
    final double? sh = _sanitize(widget.heightH);

    // Ikkalasi ham aniq — LayoutBuilder shart emas
    if (sw != null && sh != null) {
      return _buildImage(sw, sh);
    }

    // Kamida bittasi infinity yoki null — LayoutBuilder ishlatiladi
    return LayoutBuilder(
      builder: (context, constraints) {
        final double resolvedW = sw ?? 
            (constraints.maxWidth.isFinite ? constraints.maxWidth : 0);
        final double resolvedH = sh ?? 
            (constraints.maxHeight.isFinite ? constraints.maxHeight : 0);
        return _buildImage(resolvedW, resolvedH);
      },
    );
  }
}