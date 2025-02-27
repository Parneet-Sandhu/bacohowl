import 'package:flutter/material.dart';
import '../constants/theme.dart';

class Story {
  final String username;
  final String imageUrl;
  final String? currentSong;
  final bool hasStory;
  final bool isMe;

  const Story({
    required this.username,
    required this.imageUrl,
    this.currentSong,
    this.hasStory = false,
    this.isMe = false,
  });
}

class StoryRow extends StatelessWidget {
  final List<Story> stories;
  final VoidCallback onAddStory;
  final Function(Story) onTapStory;
  final String? currentSong;

  const StoryRow({
    super.key,
    required this.stories,
    required this.onAddStory,
    required this.onTapStory,
    this.currentSong,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Add Story Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                GestureDetector(
                  onTap: onAddStory,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color: AppTheme.primaryColor,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add Story',
                  style: AppTheme.bodyStyle.copyWith(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                  ),
                ),
                if (currentSong != null)
                  Text(
                    currentSong!,
                    style: AppTheme.bodyStyle.copyWith(
                      fontSize: 10,
                      color: AppTheme.secondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          // Stories
          ...stories.map((story) => _StoryItem(
                story: story,
                onTap: () => onTapStory(story),
              )),
        ],
      ),
    );
  }
}

class _StoryItem extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;

  const _StoryItem({
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: story.hasStory
                    ? LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                          AppTheme.accentColor,
                        ],
                      )
                    : null,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(story.imageUrl),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            story.username,
            style: AppTheme.bodyStyle.copyWith(
              fontSize: 12,
              fontWeight: story.hasStory ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (story.currentSong != null)
            Text(
              story.currentSong!,
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 10,
                color: AppTheme.secondaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
