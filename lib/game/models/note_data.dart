/// Note data model for individual notes in a chart.
class NoteData {
  /// 1 = Tap, 2 = Hold, 3 = Flick
  final int type;

  /// Beat position of the note (float, where 0.0 = first beat)
  final double time;

  /// Horizontal position: 0.0 (left) to 1.0 (right)
  final double x;

  /// Hold duration in beats (only for type 2)
  final double holdTime;

  /// Note fall speed multiplier
  final double speed;

  const NoteData({
    required this.type,
    required this.time,
    this.x = 0.5,
    this.holdTime = 0.0,
    this.speed = 1.0,
  });

  factory NoteData.fromJson(Map<String, dynamic> json) {
    return NoteData(
      type: json['type'] as int,
      time: (json['time'] as num).toDouble(),
      x: (json['x'] as num?)?.toDouble() ?? 0.5,
      holdTime: (json['hold_time'] as num?)?.toDouble() ?? 0.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
