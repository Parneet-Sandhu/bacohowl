import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../constants/theme.dart';
import '../constants/assets.dart';

class PlayerControls extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final bool isPlaying;
  final Duration duration;
  final Duration position;
  final VoidCallback onPlayPause;
  final VoidCallback onForward;
  final VoidCallback onBackward;

  const PlayerControls({
    super.key,
    required this.audioPlayer,
    required this.isPlaying,
    required this.duration,
    required this.position,
    required this.onPlayPause,
    required this.onForward,
    required this.onBackward,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  thumbColor: AppTheme.primaryColor,
                  activeTrackColor: AppTheme.secondaryColor,
                  inactiveTrackColor: Colors.white,
                  overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: position.inSeconds.toDouble(),
                  max: duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(position)),
                    Text(_formatDuration(duration)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 32,
              onPressed: onBackward,
              icon: Icon(
                Icons.skip_previous_rounded,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(width: 24),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onPlayPause,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      isPlaying ? AppAssets.pauseButton : AppAssets.playButton,
                      width: 48,
                      height: 48,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            IconButton(
              iconSize: 32,
              onPressed: onForward,
              icon: Icon(
                Icons.skip_next_rounded,
                color: AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
