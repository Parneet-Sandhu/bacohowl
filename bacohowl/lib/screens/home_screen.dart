import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io' show File;
import '../constants/theme.dart';
import '../constants/assets.dart';
import '../widgets/player_controls.dart';
import '../widgets/drop_zone.dart';
import 'dart:math';
import '../widgets/settings_menu.dart';
import '../utils/responsive_layout.dart';
import '../widgets/bottom_info_box.dart';
import '../widgets/story_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String? currentSong;
  late AnimationController _scaleController;
  List<PlatformFile> playlist = [];
  int currentIndex = 0;
  Map<String, Uint8List> audioBytes = {};
  bool showPlaylist = false;
  String currentBackground = AppAssets.defaultBackground;
  bool showSettings = false;
  bool autoPlay = true;  // Add this property

  // Add this property for demo stories
  final List<Story> stories = [
    Story(
      username: 'Sophie',
      imageUrl: 'https://i.pravatar.cc/150?img=1',
      hasStory: true,
      currentSong: 'Howl\'s Moving Castle Theme',
    ),
    Story(
      username: 'Howl',
      imageUrl: 'https://i.pravatar.cc/150?img=2',
      hasStory: true,
      currentSong: 'Merry Go Round of Life',
    ),
    // Add more demo stories as needed
  ];

  @override
  void initState() {
    super.initState();
    setupAudioPlayer();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Add error handling
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted && autoPlay) {  // Check autoPlay setting
        handleForward(); // Play next song when current one completes
      }
    });
  }

  Future<void> pickAndPlayAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        List<PlatformFile> newSongs;
        if (kIsWeb) {
          newSongs = result.files.where((file) => file.bytes != null).toList();
        } else {
          newSongs = result.files.where((file) => file.path != null).toList();
        }

        if (newSongs.isEmpty) {
          throw Exception('No valid audio files selected');
        }

        setState(() {
          // If playlist is empty, start playing the first new song
          bool wasEmpty = playlist.isEmpty;
          
          // Add new songs to the existing playlist
          playlist.addAll(newSongs);

          // If this was the first song added, start playing it
          if (wasEmpty) {
            currentIndex = 0;
            playAudio(playlist[currentIndex]);
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting audio files: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> playAudio(PlatformFile file) async {
    try {
      await _audioPlayer.stop();
      
      if (kIsWeb) {
        if (file.bytes == null) {
          throw Exception('No audio data available for ${file.name}');
        }
        
        // Store bytes in memory
        audioBytes[file.name] = file.bytes!;
        
        // Create an object URL from bytes for web playback
        final url = Uri.dataFromBytes(
          file.bytes!,
          mimeType: 'audio/mp3',
        ).toString();

        await _audioPlayer.play(UrlSource(url));
      } else {
        if (file.path == null) {
          throw Exception('No file path available for ${file.name}');
        }
        await _audioPlayer.play(DeviceFileSource(file.path!));
      }

      setState(() {
        isPlaying = true;
        currentSong = file.name;
      });
    } catch (e) {
      debugPrint('Error playing audio: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing ${file.name}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() => duration = newDuration);
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() => position = newPosition);
    });
  }

  void handleForward() {
    if (playlist.isEmpty) return;
    final nextIndex = (currentIndex + 1) % playlist.length;
    setState(() => currentIndex = nextIndex);
    playAudio(playlist[currentIndex]);
  }

  void handleBackward() {
    if (playlist.isEmpty) return;
    final prevIndex = (currentIndex - 1 + playlist.length) % playlist.length;
    setState(() => currentIndex = prevIndex);
    playAudio(playlist[currentIndex]);
  }

  Widget _buildPlaylistView() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: showPlaylist ? 200 : 0,
      margin: EdgeInsets.only(
        top: showPlaylist ? 10 : 0,
        bottom: showPlaylist ? 10 : 0,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (showPlaylist) Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Playlist',
                    style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: pickAndPlayAudio,
                    color: AppTheme.accentColor,
                  ),
                ],
              ),
            ),
            if (showPlaylist) SizedBox(
              height: 152, // 200 - header height
              child: ListView.builder(
                itemCount: playlist.length,
                itemBuilder: (context, index) {
                  final song = playlist[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.music_note,
                      color: currentIndex == index ? AppTheme.primaryColor : AppTheme.textColor.withOpacity(0.5),
                    ),
                    title: Text(
                      song.name,
                      style: AppTheme.bodyStyle.copyWith(
                        color: currentIndex == index ? AppTheme.primaryColor : AppTheme.textColor,
                        fontWeight: currentIndex == index ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _removeFromPlaylist(index),
                      color: AppTheme.textColor.withOpacity(0.5),
                    ),
                    onTap: () => _playFromPlaylist(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeFromPlaylist(int index) {
    setState(() {
      if (index == currentIndex) {
        _audioPlayer.stop();
        isPlaying = false;
        currentSong = null;
      } else if (index < currentIndex) {
        currentIndex--;
      }
      playlist.removeAt(index);
    });
  }

  void _playFromPlaylist(int index) {
    setState(() => currentIndex = index);
    playAudio(playlist[index]);
  }

  void _handleBackgroundChange(String newBackground) {
    setState(() {
      currentBackground = newBackground;
      showSettings = false;
    });
  }

  void _handleCustomBackground(String path) {
    setState(() {
      currentBackground = path;
      showSettings = false;
    });
  }

  void _handleAutoPlayChanged(bool value) {
    setState(() => autoPlay = value);
  }

  void _handleAddStory() {
    // Implement story addition logic
  }

  void _handleTapStory(Story story) {
    // Implement story view logic
  }

  ImageProvider _getBackgroundImage() {
    if (currentBackground.startsWith('assets/')) {
      return AssetImage(currentBackground);
    } else if (currentBackground.startsWith('data:')) {
      // Handle web data URLs
      return NetworkImage(currentBackground);
    } else if (kIsWeb) {
      // Handle other web URLs
      return NetworkImage(currentBackground);
    } else {
      // Handle local file paths for desktop/mobile
      return FileImage(File(currentBackground));
    }
  }

  Widget _buildControls(bool isMobile) {
    return Wrap(
      spacing: isMobile ? 5 : 10,
      runSpacing: isMobile ? 5 : 10,
      alignment: WrapAlignment.center,
      children: [
        SizedBox(
          height: 32,
          child: TextButton.icon(
            onPressed: () => setState(() => showPlaylist = !showPlaylist),
            icon: Icon(
              showPlaylist ? Icons.playlist_remove : Icons.queue_music,
              color: AppTheme.accentColor,
              size: isMobile ? 18 : 24,
            ),
            label: Text(
              showPlaylist ? 'Hide' : 'Show',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 11 : 14,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.accentColor.withOpacity(0.1),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 6 : 12,
                vertical: isMobile ? 4 : 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 32,
          child: TextButton.icon(
            onPressed: pickAndPlayAudio,
            icon: Icon(
              Icons.add,
              size: isMobile ? 18 : 24,
            ),
            label: Text(
              'Add',
              style: AppTheme.bodyStyle.copyWith(
                fontSize: isMobile ? 11 : 14,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.accentColor.withOpacity(0.1),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 6 : 12,
                vertical: isMobile ? 4 : 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 32,
          child: TextButton.icon(
            onPressed: () => setState(() => showSettings = !showSettings),
            icon: Icon(
              Icons.settings,
              color: AppTheme.secondaryColor,
              size: isMobile ? 18 : 24,
            ),
            label: Text(
              'Settings',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 11 : 14,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 6 : 12,
                vertical: isMobile ? 4 : 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoriesBox(bool isMobile, double width) {
    return Container(
      width: width,
      margin: EdgeInsets.symmetric(vertical: isMobile ? 5 : 10),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppTheme.secondaryColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stories',
            style: AppTheme.titleStyle.copyWith(
              fontSize: isMobile ? 18 : 20,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          StoryRow(
            stories: stories,
            onAddStory: _handleAddStory,
            onTapStory: _handleTapStory,
            currentSong: currentSong,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWidget = ResponsiveLayout.isWidget(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final playerWidth = ResponsiveLayout.getPlayerWidth(context);
    
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: _getBackgroundImage(),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.3),
                AppTheme.secondaryColor.withOpacity(0.3),
              ],
            ),
          ),
          child: SafeArea(
            child: DropZone(
              onDroppedFile: (file) async => await playAudio(file),
              child: Column(
                children: [
                  // Main Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: isMobile ? 10 : 20,
                        right: isMobile ? 10 : 20,
                        top: isMobile ? 5 : 10,
                        bottom: 100, // Add padding for bottom info box
                      ),
                      child: Column(
                        children: [
                          // Stories Box
                          Container(
                            constraints: BoxConstraints(maxWidth: playerWidth),
                            margin: EdgeInsets.only(bottom: isMobile ? 15 : 25),
                            child: _buildStoriesBox(isMobile, playerWidth),
                          ),

                          // Player Container and Settings
                          Container(
                            constraints: BoxConstraints(maxWidth: playerWidth),
                            margin: EdgeInsets.only(bottom: isMobile ? 10 : 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Main Player Container (Updated)
                                Container(
                                  padding: ResponsiveLayout.getPlayerPadding(context),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.97),
                                    borderRadius: BorderRadius.circular(ResponsiveLayout.getPlayerRadius(context)),
                                    border: Border.all(
                                      color: AppTheme.primaryColor.withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFB5838D).withOpacity(0.15),
                                        blurRadius: 25,
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: AppTheme.accentColor.withOpacity(0.1),
                                        blurRadius: 20,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Song Title Container (Updated)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isWidget ? 12 : 20,
                                          vertical: isWidget ? 12 : 16,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppTheme.backgroundColor,
                                              Colors.white.withOpacity(0.95),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(isWidget ? 15 : 20),
                                          border: Border.all(
                                            color: AppTheme.primaryColor.withOpacity(0.15),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.primaryColor.withOpacity(0.1),
                                              blurRadius: 10,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          currentSong ?? 'Select songs to play',
                                          style: AppTheme.titleStyle.copyWith(
                                            fontSize: ResponsiveLayout.getFontSize(context, 24),
                                            color: AppTheme.textColor.withOpacity(0.8),
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 25),
                                      PlayerControls(
                                        audioPlayer: _audioPlayer,
                                        isPlaying: isPlaying,
                                        duration: duration,
                                        position: position,
                                        onPlayPause: handlePlayPause,
                                        onForward: handleForward,
                                        onBackward: handleBackward,
                                        currentSong: currentSong, // Add this
                                      ),
                                      const SizedBox(height: 20),
                                      _buildControls(isMobile),
                                    ],
                                  ),
                                ),
                                
                                // Settings Menu - Moved here
                                if (showSettings)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: SettingsMenu(
                                      currentBackground: currentBackground,
                                      onBackgroundChanged: _handleBackgroundChange,
                                      onCustomBackgroundPicked: _handleCustomBackground,
                                      autoPlay: autoPlay,
                                      onAutoPlayChanged: _handleAutoPlayChanged,
                                    ),
                                  ),
                                
                                // Playlist when shown
                                if (showPlaylist) 
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: _buildPlaylistView(),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Fixed Bottom Info Box
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 10 : 20,
                      vertical: isMobile ? 8 : 12,
                    ),
                    child: Center(
                      child: BottomInfoBox(
                        width: playerWidth,
                        opacity: 0.95,
                        elevation: isWidget ? 15 : 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void handlePlayPause() {
    if (currentSong == null) {
      pickAndPlayAudio();
    } else {
      setState(() {
        if (isPlaying) {
          _audioPlayer.pause();
        } else {
          _audioPlayer.resume();
        }
        isPlaying = !isPlaying;
      });
    }
  }

  @override
  void dispose() {
    audioBytes.clear();
    _audioPlayer.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}

class BubblePainter extends CustomPainter {
  final Color color;
  BubblePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final random = Random();
    for (var i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 30 + 10;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
