import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../morfo_colors.dart';

/// Lecteur vidéo — lecture auto, en boucle, muet (aperçu de résultat).
class MorfoVideo extends StatefulWidget {
  const MorfoVideo({super.key, required this.url, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  State<MorfoVideo> createState() => _MorfoVideoState();
}

class _MorfoVideoState extends State<MorfoVideo> {
  late final VideoPlayerController _c;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..setLooping(true)
      ..setVolume(0);
    _c.initialize().then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
      _c.play();
    }).catchError((Object _) {});
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const ColoredBox(
        color: MorfoColors.surface2,
        child: Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }
    return FittedBox(
      fit: widget.fit,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: _c.value.size.width,
        height: _c.value.size.height,
        child: VideoPlayer(_c),
      ),
    );
  }
}
