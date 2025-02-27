import 'package:flutter/material.dart';
import '../constants/theme.dart';

class Story {
  final String username;
  final String imageUrl;
  final bool hasStory;
  final String currentSong;

  Story({
    required this.username,
    required this.imageUrl,
    required this.hasStory,
    required this.currentSong,
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
    return SizedBox(
      height: 90, // Reduced height since we're not showing songs
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Add Story Button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                InkWell(
                  onTap: onAddStory,
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add Story',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // Stories
          ...stories.map((story) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => onTapStory(story),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: story.hasStory
                          ? LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.secondaryColor,
                              ],
                            )
                          : null,
                      border: !story.hasStory
                          ? Border.all(
                              color: AppTheme.textColor.withOpacity(0.2),
                              width: 1,
                            )
                          : null,
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(story.imageUrl),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    story.username,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textColor.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }
}
