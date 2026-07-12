import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

/// Manages audio playback with position tracking for rhythm sync.
class AudioManager {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<Duration>? _positionSub;
  double _offset = 0.0;
  double _startTime = 0.0;
  bool _isPlaying = false;
  Duration _lastPosition = Duration.zero;

  /// Current playback position in seconds (adjusted for offset).
  double get currentTime =>
      _isPlaying
          ? (_lastPosition.inMilliseconds / 1000.0) - _startTime - _offset
          : 0.0;

  bool get isPlaying => _isPlaying;

  AudioManager() {
    _listenPosition();
  }

  void _listenPosition() {
    _positionSub?.cancel();
    _positionSub = _player.onPositionChanged.listen((position) {
      _lastPosition = position;
    });
  }

  /// Load and play an audio file from assets.
  Future<void> play(String assetPath, {double offset = 0.0}) async {
    _offset = offset;
    await _player.stop();
    _lastPosition = Duration.zero;
    _startTime = 0.0;
    _listenPosition();
    await _player.play(AssetSource(assetPath));
    _isPlaying = true;
  }

  /// Pause playback.
  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  /// Resume playback.
  Future<void> resume() async {
    await _player.resume();
    _isPlaying = true;
  }

  /// Stop and reset.
  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  /// Seek to a specific position in seconds.
  Future<void> seek(double seconds) async {
    await _player.seek(Duration(milliseconds: (seconds * 1000).round()));
  }

  /// Release resources.
  Future<void> dispose() async {
    await _positionSub?.cancel();
    await _player.dispose();
  }
}
