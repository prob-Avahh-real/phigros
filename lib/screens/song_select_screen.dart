import 'package:flutter/material.dart';
import '../game/models/song_info.dart';
import 'gameplay_screen.dart';

/// Song selection screen with difficulty picker.
class SongSelectScreen extends StatelessWidget {
  const SongSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SELECT SONG',
          style: TextStyle(
            color: Colors.white70,
            letterSpacing: 3,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: SongInfo.songs.length,
        itemBuilder: (context, index) {
          final song = SongInfo.songs[index];
          return _SongCard(
            song: song,
            onSelect: (difficulty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GameplayScreen(
                    chartFile: '${song.id}_${difficulty.name.toLowerCase()}.json',
                    songTitle: song.title,
                    themeColor: song.themeColor,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SongCard extends StatelessWidget {
  final SongInfo song;
  final void Function(ChartDifficulty difficulty) onSelect;

  const _SongCard({required this.song, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            song.themeColor.withValues(alpha: 0.15),
            song.themeColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: song.themeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              song.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              song.artist,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: song.difficulties.map((diff) {
                return _DifficultyChip(
                  difficulty: diff,
                  color: song.themeColor,
                  onTap: () => onSelect(diff),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final ChartDifficulty difficulty;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyChip({
    required this.difficulty,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          '${difficulty.name}  Lv.${difficulty.level}',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
