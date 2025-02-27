import 'package:flutter/material.dart';
import '../constants/theme.dart';
import 'background_picker.dart';

class SettingsMenu extends StatelessWidget {
  final String currentBackground;
  final Function(String) onBackgroundChanged;
  final Function(String) onCustomBackgroundPicked;
  final bool autoPlay;
  final Function(bool) onAutoPlayChanged;

  const SettingsMenu({
    super.key,
    required this.currentBackground,
    required this.onBackgroundChanged,
    required this.onCustomBackgroundPicked,
    required this.autoPlay,
    required this.onAutoPlayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Changed from fixed 300 to match parent width
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Settings',
                style: AppTheme.titleStyle.copyWith(fontSize: 24),
              ),
              Icon(
                Icons.settings,
                color: AppTheme.secondaryColor,
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            'Themes',
            style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          BackgroundPicker(
            currentBackground: currentBackground,
            onBackgroundChanged: onBackgroundChanged,
            onCustomBackgroundPicked: onCustomBackgroundPicked,
          ),
          const SizedBox(height: 16),
          Text(
            'Playback',
            style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text(
              'Auto-play next song',
              style: AppTheme.bodyStyle,
            ),
            value: autoPlay,
            onChanged: onAutoPlayChanged,
            activeColor: AppTheme.secondaryColor,
          ),
          const Divider(height: 16),
          // Add more settings options here
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: AppTheme.secondaryColor,
            ),
            title: Text(
              'About BacoHowl',
              style: AppTheme.bodyStyle,
            ),
            trailing: Text(
              'v1.0.0',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.textColor.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
