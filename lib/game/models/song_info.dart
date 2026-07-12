import 'package:flutter/material.dart';

/// Song metadata for the song select screen.
class SongInfo {
  final String id;
  final String title;
  final String artist;
  final String illustrator;
  final List<ChartDifficulty> difficulties;
  final Color themeColor;

  const SongInfo({
    required this.id,
    required this.title,
    required this.artist,
    this.illustrator = '',
    this.difficulties = const [],
    this.themeColor = Colors.cyanAccent,
  });

  static const List<SongInfo> songs = [
    SongInfo(
      id: 'demo',
      title: 'demo_chart',
      artist: 'System',
      illustrator: 'Phigros',
      difficulties: [
        ChartDifficulty('EZ', 1),
        ChartDifficulty('HD', 5),
      ],
      themeColor: Colors.cyanAccent,
    ),
  ];
}

class ChartDifficulty {
  final String name;
  final int level;

  const ChartDifficulty(this.name, this.level);
}
