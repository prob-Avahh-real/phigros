import 'package:flutter/material.dart';
import 'song_select_screen.dart';

/// Main menu screen for Phigros.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.cyanAccent, Colors.purpleAccent],
                ).createShader(bounds),
                child: const Text(
                  'PHIGROS',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 8,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 3,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.cyanAccent, Colors.purpleAccent],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'RHYTHM GAME',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 64),

              // Play button
              _MenuButton(
                label: 'PLAY',
                icon: Icons.play_arrow_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SongSelectScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Settings placeholder
              _MenuButton(
                label: 'SETTINGS',
                icon: Icons.settings,
                onTap: () {},
              ),
              const SizedBox(height: 16),

              // About
              _MenuButton(
                label: 'ABOUT',
                icon: Icons.info_outline,
                onTap: () => _showAbout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('About', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Phigros Rhythm Game\n\n'
          'A Flutter-based mobile rhythm game\n'
          'featuring dynamic judgment lines\n'
          'and immersive gameplay.\n\n'
          'Built with Flame Engine\n'
          'Version 1.0.0',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.08),
              Colors.white.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
