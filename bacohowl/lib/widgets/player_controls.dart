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
    final isMobile = ResponsiveLayout.isMobile(context);
    final isWidget = ResponsiveLayout.isWidget(context);
    final buttonSpacing = isWidget ? 12.0 : 24.0;
    final controlsMargin = isWidget ? 10.0 : 20.0;
    final sliderPadding = isWidget ? 10.0 : 15.0;

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
          height: isWidget ? 48 : 56,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: isWidget ? 24 : 32,
                padding: EdgeInsets.zero,
                onPressed: onBackward,
                icon: Icon(
                  Icons.skip_previous_rounded,
                  color: AppTheme.secondaryColor,
                ),
              ),
              SizedBox(width: buttonSpacing),
              Container(
                height: isWidget ? 40 : 48,
                width: isWidget ? 40 : 48,
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
                      padding: EdgeInsets.all(isWidget ? 8 : 12),
                      child: Image.asset(
                        isPlaying ? AppAssets.pauseButton : AppAssets.playButton,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: buttonSpacing),
              IconButton(
                iconSize: isWidget ? 24 : 32,
                padding: EdgeInsets.zero,
                onPressed: onForward,
                icon: Icon(
                  Icons.skip_next_rounded,
                  color: AppTheme.secondaryColor,
                ),
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
