/// Hit judgment results for rhythm game timing.
enum HitResult {
  perfect,
  good,
  bad,
  miss,
}

/// Timing windows in milliseconds.
class TimingWindows {
  static const double perfectMs = 40.0;
  static const double goodMs = 80.0;
  static const double badMs = 120.0;

  /// Determine hit result based on time difference.
  static HitResult judge(double diffMs) {
    final absDiff = diffMs.abs();
    if (absDiff <= perfectMs) return HitResult.perfect;
    if (absDiff <= goodMs) return HitResult.good;
    if (absDiff <= badMs) return HitResult.bad;
    return HitResult.miss;
  }

  /// Score percentage for each result.
  static double scorePercent(HitResult result) {
    switch (result) {
      case HitResult.perfect:
        return 1.0;
      case HitResult.good:
        return 0.65;
      case HitResult.bad:
        return 0.0;
      case HitResult.miss:
        return 0.0;
    }
  }
}

/// Game scoring and combo tracking.
class ScoreManager {
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _perfectCount = 0;
  int _goodCount = 0;
  int _badCount = 0;
  int _missCount = 0;
  int _totalNotes = 0;

  int get score => _score;
  int get combo => _combo;
  int get maxCombo => _maxCombo;
  int get perfectCount => _perfectCount;
  int get goodCount => _goodCount;
  int get badCount => _badCount;
  int get missCount => _missCount;

  /// Accuracy as a percentage (0.0 to 1.0).
  double get accuracy {
    if (_totalNotes == 0) return 1.0;
    return (_perfectCount + _goodCount * 0.65) / _totalNotes;
  }

  /// Letter grade based on accuracy.
  String get grade {
    if (accuracy >= 1.0) return 'φ';
    if (accuracy >= 0.96) return 'S';
    if (accuracy >= 0.92) return 'A';
    if (accuracy >= 0.88) return 'B';
    if (accuracy >= 0.80) return 'C';
    return 'D';
  }

  void setTotalNotes(int count) {
    _totalNotes = count;
  }

  void recordHit(HitResult result) {
    switch (result) {
      case HitResult.perfect:
        _perfectCount++;
        _combo++;
        _score += 100 + (_combo > 1 ? (_combo ~/ 10) * 10 : 0);
        break;
      case HitResult.good:
        _goodCount++;
        _combo++;
        _score += 65;
        break;
      case HitResult.bad:
        _badCount++;
        _combo = 0;
        break;
      case HitResult.miss:
        _missCount++;
        _combo = 0;
        break;
    }
    if (_combo > _maxCombo) _maxCombo = _combo;
  }
}
