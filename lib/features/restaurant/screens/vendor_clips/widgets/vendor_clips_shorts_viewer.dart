import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_media_clip/vendor_media_clip_model.dart';
import 'package:video_player/video_player.dart';

class VendorClipsShortsViewer extends StatefulWidget {
  const VendorClipsShortsViewer({
    super.key,
    required this.clips,
    required this.initialIndex,
  });

  final List<VendorMediaClipModel> clips;
  final int initialIndex;

  @override
  State<VendorClipsShortsViewer> createState() =>
      _VendorClipsShortsViewerState();
}

class _VendorClipsShortsViewerState extends State<VendorClipsShortsViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    if (widget.clips.isEmpty) {
      _currentIndex = 0;
      _pageController = PageController();
      return;
    }
    final start = widget.initialIndex.clamp(0, widget.clips.length - 1);
    _currentIndex = start;
    _pageController = PageController(initialPage: start);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.clips.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            TranslationKeys.clipsEmpty.tr(context: context),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            allowImplicitScrolling: false,
            itemCount: widget.clips.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              return _ClipSlide(
                clip: widget.clips[index],
                isActive: index == _currentIndex,
              );
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                style: IconButton.styleFrom(backgroundColor: Colors.black26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClipSlide extends StatefulWidget {
  const _ClipSlide({required this.clip, required this.isActive});

  final VendorMediaClipModel clip;
  final bool isActive;

  @override
  State<_ClipSlide> createState() => _ClipSlideState();
}

class _ClipSlideState extends State<_ClipSlide> {
  VideoPlayerController? _controller;
  bool _ready = false;
  String? _error;
  bool _initInProgress = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureController());
    }
  }

  @override
  void didUpdateWidget(covariant _ClipSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      final c = _controller;
      if (c != null && _ready && c.value.isInitialized) {
        c.play();
      } else {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _ensureController(),
        );
      }
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller?.pause();
    }
  }

  Future<void> _ensureController() async {
    if (!mounted || !widget.isActive) return;
    if (_error != null || _initInProgress) return;
    if (_controller != null) return;

    final uri = Uri.tryParse(widget.clip.video);
    if (uri == null || !uri.hasScheme) {
      setState(
        () => _error = TranslationKeys.clipsInvalidUrl.tr(context: context),
      );
      return;
    }

    _initInProgress = true;
    final controller = VideoPlayerController.networkUrl(uri)..setLooping(true);

    try {
      await controller.initialize();
      await controller.setVolume(1.0);
    } catch (e) {
      await controller.dispose();
      _initInProgress = false;
      if (!mounted) return;
      setState(() => _error = e.toString());
      return;
    }

    _initInProgress = false;
    if (!mounted) {
      await controller.dispose();
      return;
    }
    if (!widget.isActive) {
      await controller.dispose();
      return;
    }

    setState(() {
      _controller = controller;
      _ready = true;
    });
    controller.play();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (c.value.isPlaying) {
      c.pause();
    } else {
      c.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: AppTextStyle.regular14(context, color: StaticColors.white),
          ),
        ),
      );
    }

    if (!_ready || _controller == null || !_controller!.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.black),
          if (widget.isActive)
            const Center(
              child: CircularProgressIndicator(color: StaticColors.primary),
            ),
        ],
      );
    }

    final c = _controller!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _togglePlay,
      child: AnimatedBuilder(
        animation: c,
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: c.value.aspectRatio == 0
                      ? (9 / 16)
                      : c.value.aspectRatio,
                  child: VideoPlayer(c),
                ),
              ),
              if (!c.value.isPlaying)
                const IgnorePointer(
                  child: Center(
                    child: Icon(
                      Icons.play_circle_rounded,
                      color: Colors.white54,
                      size: 72,
                    ),
                  ),
                ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16 + MediaQuery.paddingOf(context).bottom,
                child: Text(
                  widget.clip.description.isEmpty
                      ? ''
                      : widget.clip.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.medium16(
                    context,
                    color: StaticColors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
