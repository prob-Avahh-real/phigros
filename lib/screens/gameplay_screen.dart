import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/phigros_game.dart';
import '../game/systems/audio_manager.dart';
import '../game/systems/chart_loader.dart';
import '../game/systems/judgment_system.dart';
import '../widgets/score_display.dart';

/// The gameplay screen — embeds the Flame game and overlays the HUD.
class GameplayScreen extends StatefulWidget {
  final String chartFile;
  final String songTitle;
  final Color themeColor;

  const GameplayScreen({
    super.key,
    required this.chartFile,
    required this.songTitle,
    this.themeColor = Colors.cyanAccent,
  });

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late PhigrosGame _game;
  final AudioManager _audioManager = AudioManager();
  final ValueNotifier<ScoreManager> _scoreNotifier =
      ValueNotifier(ScoreManager());
  bool _isLoading = true;
  bool _isPaused = false;
  bool _isFinished = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChart();
  }

  Future<void> _loadChart() async {
    try {
      final chart = await ChartLoader.loadChart(widget.chartFile);
      _game = PhigrosGame(
        chart: chart,
        audioManager: _audioManager,
        scoreNotifier: _scoreNotifier,
      );
      _game.onSongEnd = () {
        setState(() => _isFinished = true);
      };
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      _game.isPaused = _isPaused;
      if (_isPaused) {
        _audioManager.pause();
      } else {
        _audioManager.resume();
      }
    });
  }

  @override
  void dispose() {
    _audioManager.dispose();
    _scoreNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A2E),
        body: Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text('Failed to load chart',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
              const SizedBox(height: 8),
              Text(_error!,
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          GameWidget(game: _game),
          ValueListenableBuilder<ScoreManager>(
            valueListenable: _scoreNotifier,
            builder: (context, score, _) => ScoreDisplay(
              scoreManager: score,
              currentTime: _game.playbackTime,
              totalTime: _game.playbackTime + 60,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  widget.songTitle,
                  style: const TextStyle(
                    color: Colors.white38, fontSize: 12, letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: GestureDetector(
              onTap: _togglePause,
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.white70, size: 22,
                ),
              ),
            ),
          ),
          if (_isPaused)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('PAUSED',
                      style: TextStyle(color: Colors.white, fontSize: 32,
                          fontWeight: FontWeight.bold, letterSpacing: 6)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _togglePause,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white24,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('RESUME'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('QUIT',
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              ),
            ),
          if (_isFinished)
            Container(
              color: Colors.black87,
              child: SafeArea(
                child: ValueListenableBuilder<ScoreManager>(
                  valueListenable: _scoreNotifier,
                  builder: (context, score, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(score.grade,
                          style: TextStyle(
                            color: widget.themeColor,
                            fontSize: 72, fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Score: ${score.score}',
                          style: const TextStyle(
                            color: Colors.white, fontSize: 24,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('${(score.accuracy * 100).toStringAsFixed(2)}%',
                          style: const TextStyle(
                            color: Colors.white70, fontSize: 18,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 24),
                        _ResultRow('Perfect', '${score.perfectCount}', Colors.cyanAccent),
                        _ResultRow('Good', '${score.goodCount}', Colors.greenAccent),
                        _ResultRow('Bad', '${score.badCount}', Colors.orangeAccent),
                        _ResultRow('Miss', '${score.missCount}', Colors.redAccent),
                        const SizedBox(height: 8),
                        _ResultRow('Max Combo', '${score.maxCombo}', Colors.white70),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.themeColor.withValues(alpha: 0.3),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('CONTINUE'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ResultRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, textAlign: TextAlign.right,
              style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 14)),
          ),
          const SizedBox(width: 16),
          Text(value,
            style: TextStyle(color: color, fontSize: 16, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
