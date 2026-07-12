import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/note_data.dart';

/// Visual note component that falls toward the judgment line.
class NoteComponent extends PositionComponent {
  final NoteData data;
  final double bpm;

  bool hit = false;
  bool missed = false;
  double _opacity = 1.0;
  bool isHeld = false;
  double _holdProgress = 0.0;

  NoteComponent({required this.data, required this.bpm});

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    final noteSize = _noteSizeForType(data.type);
    size = Vector2(noteSize, noteSize);
    priority = 5;
  }

  static double _noteSizeForType(int type) {
    switch (type) {
      case 1:
        return 56.0;
      case 2:
        return 52.0;
      case 3:
        return 48.0;
      default:
        return 56.0;
    }
  }

  double get hitTime => data.time * (60.0 / bpm);

  /// Render the note once to a [Picture] and replay it each frame.
  /// Only re-renders when [opacity] changes — avoids the per-frame
  /// [saveLayer] overhead.
  static final Map<int, Picture> _cachedShapes = {};
  double _lastOpacity = 1.0;

  @override
  void render(Canvas canvas) {
    if (hit || missed) return;
    // Rebuild cached picture only when opacity changes.
    // For the static demo chart this means once per note total;
    // for hold/Flick notes with animation it may repaint a few times.
    final key = (data.type * 1000 + (_opacity * 100).round()).toInt();
    var pic = _cachedShapes[key];
    if (pic == null || _opacity != _lastOpacity) {
      final recorder = PictureRecorder();
      final offCanvas = Canvas(recorder);
      switch (data.type) {
        case 1:
          _paintTap(offCanvas);
          break;
        case 2:
          _paintHold(offCanvas);
          break;
        case 3:
          _paintFlick(offCanvas);
          break;
      }
      pic = recorder.endRecording();
      _cachedShapes[key] = pic;
      _lastOpacity = _opacity;
    }
    canvas.drawPicture(pic);
  }

  void _paintTap(Canvas canvas) {
    final glowPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.2 * _opacity)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset.zero, size.x / 2, glowPaint);

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.x * 0.7,
        height: size.y * 0.35,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.cyanAccent.withValues(alpha: 0.9 * _opacity)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8 * _opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _paintHold(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0, -size.y * 0.25),
        width: size.x * 0.6,
        height: size.y * 0.8,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.amberAccent.withValues(alpha: 0.9 * _opacity)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8 * _opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      Offset(0, -size.y * 0.55),
      4,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9 * _opacity)
        ..style = PaintingStyle.fill,
    );
    if (_holdProgress > 0) {
      final progressRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          -size.x * 0.25,
          -size.y * 0.65 + size.y * 0.8 * (1 - _holdProgress),
          size.x * 0.5,
          size.y * 0.8 * _holdProgress,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(
        progressRect,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _paintFlick(Canvas canvas) {
    final path = Path()
      ..moveTo(0, -size.y / 2)
      ..lineTo(size.x / 2, size.y / 4)
      ..lineTo(size.x / 6, 0)
      ..lineTo(size.x / 2, size.y / 2)
      ..lineTo(-size.x / 2, size.y / 2)
      ..lineTo(-size.x / 6, 0)
      ..lineTo(-size.x / 2, size.y / 4)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.pinkAccent.withValues(alpha: 0.9 * _opacity)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8 * _opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void setOpacity(double opacity) => _opacity = opacity.clamp(0.0, 1.0);
  void setHoldProgress(double progress) =>
      _holdProgress = progress.clamp(0.0, 1.0);
}
