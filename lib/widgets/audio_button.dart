import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../core/app_colors.dart';
import '../core/app_info.dart';
import '../data/content_repository.dart';

/// Akabuto "Umva": gacuranga amajwi yafashwe y'isomo cyangwa y'ikibazo.
/// Kagaragara gusa iyo amajwi ahari (admin yayashyizeho muri dashboard).
class AudioButton extends StatefulWidget {
  const AudioButton({super.key, required this.audioPath, required this.label});

  /// Path in the Supabase "audio" bucket; null hides the button.
  final String? audioPath;

  /// What is played, for screen readers (e.g. "isomo", "ikibazo").
  final String label;

  @override
  State<AudioButton> createState() => _AudioButtonState();
}

class _AudioButtonState extends State<AudioButton> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _stateSubscription;
  String? _loadedUrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _stateSubscription = _player.playerStateStream.listen((PlayerState s) {
      // Rewind at the end so the next tap plays from the start.
      if (s.processingState == ProcessingState.completed) {
        _player.pause();
        _player.seek(Duration.zero);
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(AudioButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new question reuses this widget: stop the previous recording.
    if (oldWidget.audioPath != widget.audioPath) {
      _player.stop();
      _loadedUrl = null;
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle(String url) async {
    if (_player.playing) {
      await _player.pause();
      return;
    }
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      if (_loadedUrl != url) {
        setState(() => _loading = true);
        await _player.setUrl(url);
        _loadedUrl = url;
      }
      if (mounted) setState(() => _loading = false);
      unawaited(_player.play());
    } catch (_) {
      if (mounted) setState(() => _loading = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(
                'Ntibyakunze gucuranga amajwi. Amajwi akenera internet.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AppInfo.audioEnabled) return SizedBox.shrink();
    final String? url = ContentRepository.instance.audioUrl(widget.audioPath);
    if (url == null) return SizedBox.shrink();
    final bool playing = _player.playing;
    return IconButton(
      tooltip: playing ? 'Hagarika amajwi' : 'Umva ${widget.label}',
      onPressed: _loading ? null : () => _toggle(url),
      icon: _loading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Icon(playing ? Icons.pause_circle_filled : Icons.volume_up_outlined,
              color: playing ? AppColors.primary : null),
    );
  }
}
