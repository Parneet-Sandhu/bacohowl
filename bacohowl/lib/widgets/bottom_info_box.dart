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
        backgroundColor: Color.fromARGB(255, 135, 150, 184),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isWidget = ResponsiveLayout.isWidget(context);
    
    return Container(
      width: width,
      padding: EdgeInsets.all(isWidget ? 10 : 14),
      decoration: BoxDecoration(
        // New color scheme
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFB5838D), // Soft rose
            const Color(0xFF6D6875), // Muted purple
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB5838D).withOpacity(0.2),
            blurRadius: elevation / 2,
            spreadRadius: elevation / 15,
            offset: const Offset(0, -2),
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
            iconColor: Colors.white,
            textColor: Colors.white,
          ),
          _buildAnimatedButton(
            icon: Icons.share,
            label: 'Share',
            onTap: _handleShare,
            isSmall: isMobile,
            iconColor: Colors.white,
            textColor: Colors.white,
          ),
          _buildAnimatedButton(
            icon: Icons.group_add,
            label: 'Invite',
            onTap: () => _copyInviteLink(context),
            isSmall: isMobile,
            iconColor: Colors.white,
            textColor: Colors.white,
          ),
          _buildAnimatedButton(
            icon: Icons.favorite,
            label: 'Like',
            onTap: () {},
            isSmall: isMobile,
            iconColor: Colors.white,
            textColor: Colors.white,
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
    required Color iconColor,
    required Color textColor,
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
                color: iconColor,
                size: isSmall ? 16 : 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTheme.bodyStyle.copyWith(
                  fontSize: isSmall ? 10 : 12,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
