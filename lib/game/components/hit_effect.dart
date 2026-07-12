import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../systems/judgment_system.dart';

/// Visual hit feedback effect (text popup + sparkle).
class HitEffectComponent extends PositionComponent {
  final HitResult result;
  double _elapsed = 0.0;
  static const double _duration = 0.6;
  final List<_Sparkle> _sparkles = [];

  HitEffectComponent({required this.result});

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    size = Vector2(120, 60);
    priority = 100;
    final rng = Random();
    for (int i = 0; i < 8; i++) {
      _sparkles.add(_Sparkle(
        angle: rng.nextDouble() * 2 * pi,
        speed: 80 + rng.nextDouble() * 120,
        life: 0.3 + rng.nextDouble() * 0.3,
        color: _sparkleColor(),
      ));
    }
  }

  Color _sparkleColor() {
    switch (result) {
      case HitResult.perfect:
        return Colors.cyanAccent;
      case HitResult.good:
        return Colors.greenAccent;
      case HitResult.bad:
        return Colors.orangeAccent;
      case HitResult.miss:
        return Colors.redAccent;
    }
  }

  Color _textColor() => _sparkleColor();

  String _text() {
    switch (result) {
      case HitResult.perfect:
        return 'PERFECT';
      case HitResult.good:
        return 'GOOD';
      case HitResult.bad:
        return 'BAD';
      case HitResult.miss:
        return 'MISS';
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    for (final s in _sparkles) {
      s.update(dt);
    }
    if (_elapsed >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = _elapsed / _duration;
    final textOpacity = (1.0 - progress).clamp(0.0, 1.0);
    final textOffsetY = -30 * progress;

    for (final s in _sparkles) {
      if (s.life > 0) {
        canvas.drawCircle(
          Offset(s.x, s.y + textOffsetY),
          2.5,
          Paint()
            ..color = s.color
                .withValues(alpha: (s.life / 0.6).clamp(0.0, 1.0) * textOpacity)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: _text(),
        style: TextStyle(
          color: _textColor().withValues(alpha: textOpacity),
          fontSize: 22,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: _textColor().withValues(alpha: 0.5),
              blurRadius: 8,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2 + textOffsetY),
    );
  }
}

class _Sparkle {
  final double angle;
  final double speed;
  double life;
  final Color color;
  double x = 0;
  double y = 0;

  _Sparkle({
    required this.angle,
    required this.speed,
    required this.life,
    required this.color,
  });

  void update(double dt) {
    if (life <= 0) return;
    life -= dt;
    x += cos(angle) * speed * dt;
    y += sin(angle) * speed * dt;
  }
}
