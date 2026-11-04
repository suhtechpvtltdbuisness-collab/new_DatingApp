import 'package:flutter/material.dart';
import 'package:dating_app/widgets/profile/profile_widgets.dart';
import 'package:dating_app/utils/swipe_theme.dart';

const String _fallbackAsset = 'assets/images/profile.png';

/// Shows one photo at a time with a quick cross-fade. Neighbouring photos are
/// pre-cached so tapping through is instant.
class PhotoCarousel extends StatefulWidget {
  const PhotoCarousel({super.key, required this.urls, required this.index});

  /// Photo URLs; may be empty (a placeholder asset is shown).
  final List<String> urls;
  final int index;

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheAround(widget.index);
  }

  @override
  void didUpdateWidget(PhotoCarousel old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) _precacheAround(widget.index);
  }

  void _precacheAround(int i) {
    for (final n in [i - 1, i, i + 1]) {
      if (n < 0 || n >= widget.urls.length) continue;
      final url = widget.urls[n];
      if (!url.startsWith('http')) continue;
      precacheImage(NetworkImage(url), context, onError: (_, __) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final url =
        widget.urls.isEmpty
            ? ''
            : widget.urls[widget.index.clamp(0, widget.urls.length - 1)];
    return AnimatedSwitcher(
      duration: SwipeTheme.photoFade,
      layoutBuilder:
          (current, previous) => Stack(
            fit: StackFit.expand,
            children: [...previous, if (current != null) current],
          ),
      child: _Photo(key: ValueKey('${widget.index}:$url'), url: url),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (!url.startsWith('http')) {
      return Image.asset(_fallbackAsset, fit: BoxFit.cover);
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      loadingBuilder:
          (_, child, progress) =>
              progress == null ? child : const SkeletonBox(radius: 0),
      errorBuilder:
          (_, __, ___) => Image.asset(_fallbackAsset, fit: BoxFit.cover),
    );
  }
}
