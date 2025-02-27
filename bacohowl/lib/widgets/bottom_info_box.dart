import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/theme.dart';
import '../utils/responsive_layout.dart';
import 'package:share_plus/share_plus.dart';

class BottomInfoBox extends StatelessWidget {
  final double width;
  final double opacity;
  final double elevation;
  
  const BottomInfoBox({
    super.key,
    required this.width,
    this.opacity = 0.9,
    this.elevation = 20,
  });

  void _handleShare() {
    Share.share(
      'Check out BacoHowl - A cute MP3 player inspired by Studio Ghibli! 🎵✨',
      subject: 'BacoHowl Music Player',
    );
  }

  void _copyInviteLink(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: 'https://bacohowl.app/invite'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite link copied to clipboard!'),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isWidget = ResponsiveLayout.isWidget(context);
    
    return Container(
      width: width,
      padding: EdgeInsets.all(isWidget ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: elevation / 2,
            spreadRadius: elevation / 10,
          ),
          BoxShadow(
            color: AppTheme.secondaryColor.withOpacity(0.1),
            blurRadius: elevation / 3,
            spreadRadius: elevation / 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAnimatedButton(
            icon: Icons.person,
            label: 'Profile',
            onTap: () {},
            isSmall: isMobile,
          ),
          _buildAnimatedButton(
            icon: Icons.share,
            label: 'Share',
            onTap: _handleShare,
            isSmall: isMobile,
          ),
          _buildAnimatedButton(
            icon: Icons.group_add,
            label: 'Invite',
            onTap: () => _copyInviteLink(context),
            isSmall: isMobile,
          ),
          _buildAnimatedButton(
            icon: Icons.favorite,
            label: 'Like',
            onTap: () {},
            isSmall: isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isSmall,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1, end: 1),
      duration: const Duration(milliseconds: 200),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 8 : 12,
            vertical: isSmall ? 4 : 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: AppTheme.secondaryColor,
                size: isSmall ? 16 : 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTheme.bodyStyle.copyWith(
                  fontSize: isSmall ? 10 : 12,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
