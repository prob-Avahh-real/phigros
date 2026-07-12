import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// The dynamic judgment line — the core mechanic that makes Phigros unique.
class JudgmentLineComponent extends PositionComponent {
  /// Current Y offset (0 = center of play area)
  double yOffset = 0.0;

  /// Current rotation in degrees
  double rotationDeg = 0.0;

  /// Current note speed multiplier
  double speedMultiplier = 1.0;

  /// The screen height ratio where the line normally sits
  static const double defaultPositionRatio = 0.82;

  /// Base line width as fraction of screen width
  static const double lineWidthRatio = 0.85;

  /// Hit area height above/below the line
  static const double hitAreaHeight = 60.0;

  /// Screen size set externally after game is initialized
  Vector2 screenSize = Vector2.zero();

  JudgmentLineComponent();

  void initWithScreenSize(Vector2 size) {
    screenSize = size;
    anchor = Anchor.center;
    position = Vector2(size.x / 2, size.y * defaultPositionRatio);
    this.size = Vector2(size.x * lineWidthRatio, 4);
    priority = 10;
  }

  @override
  void render(Canvas canvas) {
    // Main judgment line
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);

    canvas.drawLine(
      Offset(-size.x / 2, 0),
      Offset(size.x / 2, 0),
      paint,
    );

    // Center diamond indicator
    final diamondPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, -8)
      ..lineTo(6, 0)
      ..lineTo(0, 8)
      ..lineTo(-6, 0)
      ..close();
    canvas.drawPath(path, diamondPaint);

    // Glow effect
    final glowPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.15)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawLine(
      Offset(-size.x / 2, 0),
      Offset(size.x / 2, 0),
      glowPaint,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    angle = rotationDeg * pi / 180.0;
  }

  /// Move the line to a new Y ratio (0.0=top, 1.0=bottom)
  void moveTo(double yRatio) {
    yOffset = yRatio - defaultPositionRatio;
    position.y = screenSize.y * yRatio;
  }

  /// Rotate the line by degrees
  void setRotation(double degrees) {
    rotationDeg = degrees;
  }

  /// Set the speed multiplier for notes
  void setSpeed(double speed) {
    speedMultiplier = speed.clamp(0.5, 3.0);
  }

  /// Check if a screen tap point is within the line's hit area
  bool isTapInHitArea(Vector2 tapPoint) {
    final localTap = tapPoint - position;
    final cosA = cos(-angle);
    final sinA = sin(-angle);
    final rotatedY = localTap.x * sinA + localTap.y * cosA;
    return rotatedY.abs() <= hitAreaHeight / 2;
  }
}
