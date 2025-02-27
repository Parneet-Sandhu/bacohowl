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
    final isWidget = ResponsiveLayout.isWidget(context);
    final buttonSpacing = isWidget ? 12.0 : 24.0;
    final controlsMargin = isWidget ? 10.0 : 20.0;
    final sliderPadding = isWidget ? 10.0 : 15.0;

    Widget buildControlButton({
      required IconData icon,
      required VoidCallback onTap,
      required double size,
    }) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 200),
          tween: Tween<double>(begin: 1, end: 1),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Icon(
              icon,
              color: AppTheme.secondaryColor,
              size: size,
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
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 200),
          tween: Tween<double>(begin: 1, end: 1),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withOpacity(0.1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
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
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: controlsMargin),
          padding: EdgeInsets.symmetric(
            vertical: sliderPadding,
            horizontal: 5,
          ),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliderTheme(
                data: SliderThemeData(
                  thumbColor: AppTheme.primaryColor,
                  activeTrackColor: AppTheme.secondaryColor,
                  inactiveTrackColor: Colors.white,
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
                padding: EdgeInsets.symmetric(
                  horizontal: isWidget ? 10 : 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: TextStyle(fontSize: isWidget ? 10 : 12),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: TextStyle(fontSize: isWidget ? 10 : 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isWidget ? 10 : 20),
        SizedBox(
          height: isWidget ? 48 : 64,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildControlButton(
                icon: Icons.skip_previous_rounded,
                onTap: onBackward,
                size: isWidget ? 32 : 40,
              ),
              SizedBox(width: buttonSpacing),
              buildPlayPauseButton(
                isPlaying: isPlaying,
                onTap: onPlayPause,
                size: isWidget ? 48 : 64,
              ),
              SizedBox(width: buttonSpacing),
              buildControlButton(
                icon: Icons.skip_next_rounded,
                onTap: onForward,
                size: isWidget ? 32 : 40,
              ),
            ],
          ),
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
