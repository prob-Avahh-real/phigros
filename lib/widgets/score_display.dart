import 'package:flutter/material.dart';
import '../game/systems/judgment_system.dart';

/// In-game HUD showing score, combo, and accuracy.
class ScoreDisplay extends StatelessWidget {
  final ScoreManager scoreManager;
  final double currentTime;
  final double totalTime;

  const ScoreDisplay({
    super.key,
    required this.scoreManager,
    required this.currentTime,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Top bar: score + combo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${scoreManager.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      scoreManager.grade,
                      style: TextStyle(
                        color: _gradeColor(scoreManager.grade),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                // Combo
                if (scoreManager.combo > 1)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${scoreManager.combo}',
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Text(
                        'COMBO',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const Spacer(),
            // Accuracy
            Text(
              '${(scoreManager.accuracy * 100).toStringAsFixed(2)}%',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'φ':
        return Colors.cyanAccent;
      case 'S':
        return Colors.amber;
      case 'A':
        return Colors.greenAccent;
      case 'B':
        return Colors.blueAccent;
      case 'C':
        return Colors.orangeAccent;
      default:
        return Colors.redAccent;
    }
  }
}
