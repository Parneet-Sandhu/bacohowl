import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../constants/theme.dart';
import '../constants/assets.dart';
import '../utils/responsive_layout.dart';

class PlayerControls extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final bool isPlaying;
  final Duration duration;
  final Duration position;
  final VoidCallback onPlayPause;
  final VoidCallback onForward;
  final VoidCallback onBackward;
  final String? currentSong;

  const PlayerControls({
    super.key,
    required this.audioPlayer,
    required this.isPlaying,
    required this.duration,
    required this.position,
    required this.onPlayPause,
    required this.onForward,
    required this.onBackward,
    this.currentSong,
  });

  Widget buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required double size,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.backgroundColor.withOpacity(0.8),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: AppTheme.secondaryColor,
            size: size * 0.6,
          ),
        ),
      ),
    );
  }

  Widget buildPlayPauseButton({
    required bool isPlaying,
    required VoidCallback onTap,
    required double size,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.9),
                AppTheme.secondaryColor.withOpacity(0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(size * 0.2),
            child: Image.asset(
              isPlaying ? AppAssets.pauseButton : AppAssets.playButton,
              width: size * 0.6,
              height: size * 0.6,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWidget = ResponsiveLayout.isWidget(context);
    final buttonSpacing = isWidget ? 12.0 : 24.0;
    final maxWidth = ResponsiveLayout.getPlayerWidth(context) * 0.9;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress Indicator and Time (moved up)
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: isWidget ? 8 : 16,
              vertical: isWidget ? 8 : 12,
            ),
            padding: EdgeInsets.all(isWidget ? 12 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.backgroundColor.withOpacity(0.5),
                  Colors.white.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    thumbColor: AppTheme.primaryColor,
                    activeTrackColor: AppTheme.secondaryColor,
                    inactiveTrackColor: AppTheme.backgroundColor,
                    overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: isWidget ? 6 : 8,
                    ),
                    overlayShape: RoundSliderOverlayShape(
                      overlayRadius: isWidget ? 12 : 16,
                    ),
                    trackHeight: isWidget ? 3 : 4,
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
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: TextStyle(
                          fontSize: isWidget ? 12 : 14,
                          color: AppTheme.textColor.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: TextStyle(
                          fontSize: isWidget ? 12 : 14,
                          color: AppTheme.textColor.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Play Controls
          Container(
            margin: EdgeInsets.symmetric(vertical: isWidget ? 8 : 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildControlButton(
                  icon: Icons.skip_previous_rounded,
                  onTap: onBackward,
                  size: isWidget ? 36 : 44,
                ),
                SizedBox(width: buttonSpacing),
                buildPlayPauseButton(
                  isPlaying: isPlaying,
                  onTap: onPlayPause,
                  size: isWidget ? 56 : 72,
                ),
                SizedBox(width: buttonSpacing),
                buildControlButton(
                  icon: Icons.skip_next_rounded,
                  onTap: onForward,
                  size: isWidget ? 36 : 44,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
