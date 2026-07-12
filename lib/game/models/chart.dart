import 'note_data.dart';

/// Represents a complete chart (beatmap) for a song.
class Chart {
  final String name;
  final String difficulty;
  final int difficultyLevel;
  final double bpm;
  final double offset; // audio offset in seconds
  final List<NoteData> notes;
  final List<JudgmentLineEvent> events;

  const Chart({
    required this.name,
    required this.difficulty,
    required this.difficultyLevel,
    required this.bpm,
    this.offset = 0.0,
    this.notes = const [],
    this.events = const [],
  });

  /// Beat duration in seconds (60 / bpm)
  double get beatDuration => 60.0 / bpm;

  /// Time (seconds) for a given beat position
  double timeAtBeat(double beat) => offset + beat * beatDuration;

  /// Beat position for a given time
  double beatAtTime(double time) => (time - offset) / beatDuration;

  factory Chart.fromJson(Map<String, dynamic> json) {
    final notesJson = json['notes'] as List<dynamic>? ?? [];
    final eventsJson = json['events'] as List<dynamic>? ?? [];

    return Chart(
      name: json['name'] as String? ?? 'Untitled',
      difficulty: json['difficulty'] as String? ?? 'EZ',
      difficultyLevel: json['difficulty_level'] as int? ?? 1,
      bpm: (json['bpm'] as num?)?.toDouble() ?? 120.0,
      offset: (json['offset'] as num?)?.toDouble() ?? 0.0,
      notes: notesJson
          .map((n) => NoteData.fromJson(n as Map<String, dynamic>))
          .toList(),
      events: eventsJson
          .map((e) => JudgmentLineEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Dynamic events for the judgment line (position, rotation, speed changes).
class JudgmentLineEvent {
  /// Event type: 'move', 'rotate', 'speed'
  final String type;

  /// Beat time of the event start
  final double startTime;

  /// Beat time of the event end (for gradual changes)
  final double endTime;

  /// Start value (y-position, angle in degrees, or speed multiplier)
  final double startValue;

  /// End value
  final double endValue;

  /// Easing function: 'linear', 'ease_in', 'ease_out', 'ease_in_out'
  final String easing;

  const JudgmentLineEvent({
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.startValue,
    required this.endValue,
    this.easing = 'linear',
  });

  factory JudgmentLineEvent.fromJson(Map<String, dynamic> json) {
    return JudgmentLineEvent(
      type: json['type'] as String,
      startTime: (json['start_time'] as num).toDouble(),
      endTime: (json['end_time'] as num).toDouble(),
      startValue: (json['start_value'] as num).toDouble(),
      endValue: (json['end_value'] as num).toDouble(),
      easing: json['easing'] as String? ?? 'linear',
    );
  }
}
