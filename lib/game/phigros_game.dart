import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'components/judgment_line.dart';
import 'components/note.dart';
import 'components/hit_effect.dart';
import 'models/chart.dart';
import 'systems/audio_manager.dart';
import 'systems/judgment_system.dart';

/// The main Flame game for Phigros rhythm gameplay.
class PhigrosGame extends FlameGame with TapCallbacks {
  final Chart chart;
  final AudioManager audioManager;
  final ScoreManager scoreManager = ScoreManager();
  final ValueNotifier<ScoreManager> scoreNotifier;

  late JudgmentLineComponent _judgmentLine;
  final List<NoteComponent> _activeNotes = [];
  final Map<int, NoteComponent> _heldNotes = {};
  final Map<int, _PendingFlick> _pendingFlicks = {};

  int _nextNoteIndex = 0;
  double playbackTime = 0.0;

  static const double visibleBeats = 4.0;
  static const double pixelsPerBeat = 200.0;

  bool songEnded = false;
  bool isPaused = false;
  void Function()? onSongEnd;

  PhigrosGame({
    required this.chart,
    required this.audioManager,
    required this.scoreNotifier,
  }) {
    scoreManager.setTotalNotes(chart.notes.length);
  }

  @override
  Color backgroundColor() => const Color(0xFF1A1A2E);

  @override
  Future<void> onLoad() async {
    _judgmentLine = JudgmentLineComponent();
    _judgmentLine.initWithScreenSize(size);
    add(_judgmentLine);
    await audioManager.play('audio/neon_pulse.wav', offset: chart.offset);
    playbackTime = 0.0;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _judgmentLine.initWithScreenSize(size);
  }

  @override
  void update(double dt) {
    if (isPaused || songEnded) return;
    super.update(dt);

    if (audioManager.isPlaying) {
      playbackTime = audioManager.currentTime;
    } else {
      playbackTime += dt;
    }

    _processEvents();
    _spawnNotes();
    _updateNotePositions();
    _checkMissedNotes();
    _checkSongEnd();
  }

  void _processEvents() {
    final currentBeat = chart.beatAtTime(playbackTime);
    for (final event in chart.events) {
      if (currentBeat < event.startTime || currentBeat > event.endTime) continue;
      final duration = event.endTime - event.startTime;
      final progress = duration > 0
          ? ((currentBeat - event.startTime) / duration).clamp(0.0, 1.0)
          : 1.0;
      final easedProgress = _applyEasing(progress, event.easing);
      final currentValue =
          event.startValue + (event.endValue - event.startValue) * easedProgress;
      switch (event.type) {
        case 'move':
          _judgmentLine.moveTo(currentValue);
          break;
        case 'rotate':
          _judgmentLine.setRotation(currentValue);
          break;
        case 'speed':
          _judgmentLine.setSpeed(currentValue);
          break;
      }
    }
  }

  double _applyEasing(double t, String easing) {
    switch (easing) {
      case 'ease_in':
        return t * t;
      case 'ease_out':
        return t * (2 - t);
      case 'ease_in_out':
        return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
      default:
        return t;
    }
  }

  void _spawnNotes() {
    final currentBeat = chart.beatAtTime(playbackTime);
    while (_nextNoteIndex < chart.notes.length) {
      final noteData = chart.notes[_nextNoteIndex];
      final beatsAhead = noteData.time - currentBeat;
      if (beatsAhead > visibleBeats) break;
      final note = NoteComponent(data: noteData, bpm: chart.bpm);
      final pixelsAhead = beatsAhead * _judgmentLine.speedMultiplier * pixelsPerBeat;
      note.position = Vector2(
        size.x * noteData.x,
        _judgmentLine.position.y - pixelsAhead,
      );
      if (beatsAhead > visibleBeats - 1.0) {
        note.setOpacity(1.0 - (beatsAhead - (visibleBeats - 1.0)).clamp(0.0, 1.0));
      }
      add(note);
      _activeNotes.add(note);
      _nextNoteIndex++;
    }
  }

  void _updateNotePositions() {
    final currentBeat = chart.beatAtTime(playbackTime);
    final lineY = _judgmentLine.position.y;
    final speed = _judgmentLine.speedMultiplier * pixelsPerBeat;
    for (final note in _activeNotes) {
      if (note.hit || note.missed) continue;
      final beatsAhead = note.data.time - currentBeat;
      note.position.y = lineY - beatsAhead * speed;
      note.position.x = size.x * note.data.x;
      if (beatsAhead < -0.5) {
        note.setOpacity(1.0 - (-beatsAhead - 0.5).clamp(0.0, 0.5) * 2);
      }
      if (note.isHeld && note.data.type == 2 && note.data.holdTime > 0) {
        final holdBeats = currentBeat - note.data.time;
        note.setHoldProgress((holdBeats / note.data.holdTime).clamp(0.0, 1.0));
      }
    }
  }

  void _checkMissedNotes() {
    final currentBeat = chart.beatAtTime(playbackTime);
    for (final note in _activeNotes) {
      if (note.hit || note.missed) continue;
      final beatsPast = currentBeat - note.data.time;
      final missThreshold = note.data.type == 2
          ? note.data.holdTime + 0.2
          : (TimingWindows.badMs / 1000.0) / chart.beatDuration;
      if (beatsPast > missThreshold) {
        note.missed = true;
        scoreManager.recordHit(HitResult.miss);
        scoreNotifier.value = scoreManager;
        _spawnHitEffect(note.position, HitResult.miss);
      }
    }
  }

  void _checkSongEnd() {
    if (songEnded) return;
    final lastNoteTime =
        chart.notes.isNotEmpty ? chart.notes.last.time * chart.beatDuration : 0;
    final endTime = lastNoteTime + 2.0;
    if (playbackTime >= endTime && _activeNotes.every((n) => n.hit || n.missed)) {
      if (scoreManager.perfectCount +
              scoreManager.goodCount +
              scoreManager.badCount +
              scoreManager.missCount >=
          chart.notes.length) {
        songEnded = true;
        onSongEnd?.call();
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isPaused || songEnded) return;
    final tapPoint = event.canvasPosition;
    final pointerId = event.pointerId;
    if (!_judgmentLine.isTapInHitArea(tapPoint)) return;

    // 1) Hold notes — start holding
    final holdResult = _findBestNote(2);
    if (holdResult != null) {
      holdResult.note.isHeld = true;
      _heldNotes[pointerId] = holdResult.note;
      _hitNote(holdResult.note, holdResult.diffMs);
      return;
    }

    // 2) Flick notes — record pending flick for swipe detection
    final flickResult = _findBestNote(3);
    if (flickResult != null) {
      _pendingFlicks[pointerId] = _PendingFlick(flickResult.note, flickResult.diffMs);
      return;
    }

    // 3) Tap notes (type 1)
    final tapResult = _findBestNote(1);
    if (tapResult != null) {
      _hitNote(tapResult.note, tapResult.diffMs);
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (isPaused || songEnded) return;
    final pointerId = event.pointerId;

    // Hold release
    if (_heldNotes.containsKey(pointerId)) {
      onHoldEnd(pointerId);
      return;
    }

    // Flick detection — require minimum swipe distance
    final pending = _pendingFlicks.remove(pointerId);
    if (pending != null) {
      _hitNote(pending.note, pending.diffMs);
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    final pointerId = event.pointerId;
    if (_heldNotes.containsKey(pointerId)) {
      onHoldEnd(pointerId);
    }
    _pendingFlicks.remove(pointerId);
  }

  void _hitNote(NoteComponent note, double diffMs) {
    note.hit = true;
    final result = TimingWindows.judge(diffMs);
    scoreManager.recordHit(result);
    scoreNotifier.value = scoreManager;
    _spawnHitEffect(note.position, result);
  }

  void _spawnHitEffect(Vector2 position, HitResult result) {
    final effect = HitEffectComponent(result: result);
    effect.position = position.clone();
    add(effect);
  }

  /// Find the best active note of a given [type] within timing window.
  /// Returns null if no suitable note found.
  _NoteMatch? _findBestNote(int type) {
    NoteComponent? bestNote;
    double bestDiff = double.infinity;
    for (final note in _activeNotes) {
      if (note.hit || note.missed || note.data.type != type) continue;
      final timeDiff = (note.hitTime - playbackTime).abs() * 1000;
      if (timeDiff <= TimingWindows.badMs && timeDiff < bestDiff) {
        bestDiff = timeDiff;
        bestNote = note;
      }
    }
    if (bestNote != null) return _NoteMatch(bestNote, bestDiff);
    return null;
  }

  void onHoldStart(int pointerId, Vector2 position) {
    // Legacy entry point — now handled inline in onTapDown.
    // Keep for potential programmatic use.
    final result = _findBestNote(2);
    if (result != null) {
      result.note.isHeld = true;
      _heldNotes[pointerId] = result.note;
      _hitNote(result.note, result.diffMs);
    }
  }

  void onHoldEnd(int pointerId) {
    final note = _heldNotes.remove(pointerId);
    if (note != null) {
      note.isHeld = false;
    }
  }

  @override
  void onRemove() {
    audioManager.stop();
    super.onRemove();
  }
}

/// Tracks a pending flick note — the swipe judgement happens on pointer-up.
class _PendingFlick {
  final NoteComponent note;
  final double diffMs;
  _PendingFlick(this.note, this.diffMs);
}

class _NoteMatch {
  final NoteComponent note;
  final double diffMs;
  _NoteMatch(this.note, this.diffMs);
}